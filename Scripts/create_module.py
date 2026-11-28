import fcntl
import re
import sys
from contextlib import ExitStack
from pathlib import Path


def confirm(prompt):
    return input(prompt).strip().lower() != "n"


def insert_after(contents, marker, addition, path):
    if contents.count(marker) != 1:
        raise ValueError(f"{path}에서 등록 위치를 하나로 찾을 수 없습니다.")
    return contents.replace(marker, marker + addition, 1)


def create_module(root):
    label = input("모듈 이름 (예: Ticket): ").strip()
    if not re.fullmatch(r"[A-Za-z][A-Za-z0-9]*", label):
        raise ValueError("모듈 이름은 영문자로 시작하고 영문자와 숫자만 포함해야 합니다.")

    name = label[0].upper() + label[1:]
    case_prefix = label[0].lower() + label[1:]
    choices = ("Data", "Domain", "Feature")
    if confirm("Data, Domain, Feature를 모두 생성할까요? (Y/n): "):
        layers = choices
    else:
        layers = tuple(layer for layer in choices if confirm(f"{layer} 항목을 생성할까요? (Y/n): "))
    if not layers:
        print("선택한 항목이 없습니다.")
        return

    projects = Path("Projects")
    placeholders = {}
    for layer in layers:
        if layer == "Domain":
            directory = projects / layer / "Sources" / name
        else:
            directory = projects / layer / (name + layer)
        source = directory if layer == "Domain" else directory / "Sources"
        placeholders[directory] = source / "Placeholder.swift"
        print(f"  {root / source}")
    if not confirm("계속할까요? (Y/n): "):
        print("생성을 취소했습니다.")
        return

    constants = root / "Tuist/ProjectDescriptionHelpers/Module/Module+Constant.swift"
    with constants.open() as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        for directory in placeholders:
            if (root / directory).exists():
                raise ValueError(f"{directory}가 이미 존재합니다.")

        original_constants = lock.read()
        updated_constants = original_constants
        edits = {}
        for layer in layers:
            if layer == "Domain":
                continue

            group = layer.lower()
            target = name + layer
            case = case_prefix + layer
            if re.search(rf'^    case {case}\b|= "{target}"', original_constants, re.MULTILINE | re.IGNORECASE):
                raise ValueError(f"{target} 타깃이 이미 등록되어 있습니다.")

            updated_constants = insert_after(
                updated_constants, f"public enum {layer}Module: String {{\n",
                f'    case {case} = "{target}"\n', constants.relative_to(root),
            )
            manifest = root / projects / layer / "Project.swift"
            original = manifest.read_text()
            dependency = ".core(.livithNetwork)" if layer == "Data" else ".shared(.designSystem)"
            entry = f"""        .make(
            target: .{group}(.{case}),
            product: .framework,
            dependencies: [
                .domain(.domain),
                {dependency}
            ]
        ),
"""
            edits[manifest] = (original, insert_after(
                original, "    targets: [\n", entry, manifest.relative_to(root)
            ))
        if updated_constants != original_constants:
            edits[constants] = (original_constants, updated_constants)

        with ExitStack() as rollback:
            for directory, source in placeholders.items():
                target_directory = root / directory
                target_directory.mkdir()
                rollback.callback(target_directory.rmdir)
                if source.parent != directory:
                    (root / source.parent).mkdir()
                    rollback.callback((root / source.parent).rmdir)
                output = root / source
                with output.open("x") as file:
                    rollback.callback(output.unlink)
                    file.write("import Foundation\n")
            for path, (original, updated) in edits.items():
                rollback.callback(path.write_text, original)
                path.write_text(updated)
            rollback.pop_all()

    print("생성했습니다. tuist generate --no-open으로 프로젝트를 갱신하세요.")


try:
    create_module(Path(__file__).resolve().parents[1])
except (EOFError, KeyboardInterrupt):
    sys.exit("\n생성을 취소했습니다.")
except (OSError, ValueError) as error:
    sys.exit(f"모듈 생성 실패. {error}")
