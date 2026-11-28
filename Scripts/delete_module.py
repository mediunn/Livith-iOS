import fcntl
import json
import re
import sys
from contextlib import ExitStack
from pathlib import Path
from tempfile import mkdtemp

ROOT = Path(__file__).resolve().parents[1]
PROJECTS = Path("Projects")
CONSTANTS = Path("Tuist/ProjectDescriptionHelpers/Module/Module+Constant.swift")
TARGET_IDS = CONSTANTS.with_name("Module+TargetID.swift")
BACKUPS = ROOT / ".module_backup"


def target_blocks(contents, group):
    matches = re.findall(
        rf"(^        \.make\(\n            target: \.{group}\(\.(\w+)\),\n.*?^        \),? *\n)",
        contents,
        re.MULTILINE | re.DOTALL,
    )
    return {member: block for block, member in matches}


def remove_target(contents, name, block):
    if contents.count(block) != 1:
        raise ValueError(f"{name} 타깃 선언을 하나로 찾을 수 없습니다.")
    return contents.replace(block, "", 1)


def deletion_plan(constants):
    modules = {}
    declarations = dict(re.findall(r'^    case (\w+) = "(\w+)"$', constants, re.MULTILINE))
    for layer in ("Data", "Feature"):
        manifest = PROJECTS / layer / "Project.swift"
        group = layer.lower()
        blocks = target_blocks((ROOT / manifest).read_text(), group)
        for member in blocks:
            target = declarations[member]
            if target.endswith("Tests"):
                continue
            name = target.removesuffix(layer)
            modules.setdefault(name, []).append((manifest, group, member, target))
    domain = PROJECTS / "Domain/Sources"
    for directory in (ROOT / domain).iterdir():
        if directory.is_dir() and re.fullmatch(r"[A-Za-z][A-Za-z0-9]*", directory.name):
            modules.setdefault(directory.name, []).append((None, "domain", None, directory.name))

    names = sorted(modules)
    for index, name in enumerate(names, 1):
        print(f"  {index}. {name}")
    value = input("삭제할 모듈 이름 또는 번호: ").strip()
    if value.isascii() and value.isdecimal() and 1 <= int(value) <= len(names):
        value = names[int(value) - 1]
    name = next((entry for entry in names if entry.casefold() == value.casefold()), None)
    if name is None:
        raise ValueError("삭제할 모듈을 찾을 수 없습니다.")

    edits = {CONSTANTS: constants}
    directories = []
    removed = []
    for manifest, group, member, target in modules[name]:
        if manifest is None:
            directories.append(domain / target)
            continue
        original = (ROOT / manifest).read_text()
        blocks = target_blocks(original, group)
        directories.append(manifest.parent / target)
        for key in (member, member + "Tests"):
            if key not in blocks:
                continue
            title = declarations[key]
            original = remove_target(original, title, blocks[key])
            declaration = f'    case {key} = "{title}"\n'
            edits[CONSTANTS] = remove_target(edits[CONSTANTS], title, declaration)
            removed.append((group, key, title))
            if group == "data" and key.endswith("Tests"):
                mapping = edits.get(TARGET_IDS, (ROOT / TARGET_IDS).read_text())
                updated, count = re.subn(rf'^            \.{key}: "{target}",? *\n', "", mapping, flags=re.MULTILINE)
                if count != 1:
                    raise ValueError(f"{title} 테스트 경로를 하나로 찾을 수 없습니다.")
                edits[TARGET_IDS] = updated
        edits[manifest] = original

    if any(not (ROOT / path).is_dir() or (ROOT / path).is_symlink() for path in directories):
        raise ValueError("모듈 디렉토리를 확인할 수 없습니다.")
    for manifest in sorted((ROOT / PROJECTS).glob("*/Project.swift")):
        relative = manifest.relative_to(ROOT)
        contents = edits[relative] if relative in edits else manifest.read_text()
        for group, member, title in removed:
            if re.search(rf"\.{group}\(\s*\.{member}\s*\)|\bname:\s*\"{title}\"", contents):
                raise ValueError(f"{relative}에서 {title} 타깃을 참조 중입니다.")
    if removed:
        names = "|".join(title for _, _, title in removed)
        imports = re.compile(rf"\bimport\s+(?:{names})\b|\bcanImport\(\s*(?:{names})\s*\)")
        for file in (ROOT / PROJECTS).rglob("*.swift"):
            relative = file.relative_to(ROOT)
            if ("Sources" not in relative.parts and "Tests" not in relative.parts) or "Derived" in relative.parts:
                continue
            if any(relative.is_relative_to(directory) for directory in directories):
                continue
            if imports.search(file.read_text()):
                raise ValueError(f"{relative}에서 삭제할 타깃을 참조 중입니다.")
    if edits[CONSTANTS] == constants:
        del edits[CONSTANTS]
    return name, directories, edits


def delete_module(constants):
    name, directories, edits = deletion_plan(constants)
    for path in [*directories, *edits]:
        print(f"  {path}")
    if input(f"{name}을 삭제하고 복구용 백업을 만들까요? (yes): ").strip() != "yes":
        print("삭제를 취소했습니다.")
        return

    BACKUPS.mkdir(exist_ok=True)
    backup = Path(mkdtemp(prefix=f"{name}-", dir=BACKUPS))
    record = {
        "directories": [str(path) for path in directories],
        "files": {str(path): [(ROOT / path).read_text(), updated] for path, updated in edits.items()},
    }
    with ExitStack() as revert:
        revert.callback(backup.rmdir)
        for index, path in enumerate(directories):
            saved = backup / str(index)
            (ROOT / path).rename(saved)
            revert.callback(saved.rename, ROOT / path)
        for path, (original, updated) in record["files"].items():
            file = ROOT / path
            revert.callback(file.write_text, original)
            file.write_text(updated)
        metadata = backup / "backup.json"
        with metadata.open("x") as file:
            revert.callback(metadata.unlink)
            json.dump(record, file, ensure_ascii=False)
        revert.pop_all()
    print("삭제했습니다. make module-rollback으로 복구할 수 있습니다.")


def restore_module():
    backups = list(BACKUPS.glob("*/backup.json"))
    if not backups:
        raise ValueError("복구할 모듈 백업이 없습니다.")
    metadata = max(backups, key=lambda path: path.stat().st_mtime_ns)
    backup = metadata.parent
    record = json.loads(metadata.read_text())
    for index, path in enumerate(record["directories"]):
        if (ROOT / path).exists() or (ROOT / path).is_symlink() or not (backup / str(index)).is_dir():
            raise ValueError(f"{path}을 안전하게 복구할 수 없습니다.")
    for path, (_, updated) in record["files"].items():
        if (ROOT / path).read_text() != updated:
            raise ValueError(f"{path}이 삭제 후 수정되어 복구를 중단했습니다.")

    with ExitStack() as revert:
        for index, path in enumerate(record["directories"]):
            directory = ROOT / path
            saved = backup / str(index)
            saved.rename(directory)
            revert.callback(directory.rename, saved)
        for path, (original, updated) in record["files"].items():
            file = ROOT / path
            revert.callback(file.write_text, updated)
            file.write_text(original)
        revert.pop_all()
    metadata.unlink()
    backup.rmdir()
    print("복구했습니다.")


try:
    with (ROOT / CONSTANTS).open() as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if sys.argv[1:] == ["--rollback"]:
            restore_module()
        elif len(sys.argv) == 1:
            delete_module(lock.read())
        else:
            raise ValueError("make module-delete 또는 make module-rollback을 사용하세요.")
except (EOFError, KeyboardInterrupt):
    sys.exit("\n작업을 취소했습니다.")
except (OSError, ValueError) as error:
    sys.exit(f"모듈 작업 실패. {error}")
