import re
import sys
from contextlib import ExitStack
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "Projects/Shared"
GENERATED = ROOT / "Derived/Sources/TuistAssets+LivithDesignSystem.swift"
SOURCES = ROOT / "LivithDesignSystem/Sources/Foundation"


def asset_entries(contents, group, kind):
    block = re.search(rf"^  public enum {group} \{{\n(.*?)^  \}}", contents, re.MULTILINE | re.DOTALL)
    if block is None:
        raise ValueError(f"{group}를 찾을 수 없습니다. tuist generate --no-open을 실행하세요.")
    return re.findall(
        rf'public static let (`?\w+`?) = LivithDesignSystem{kind}\(name: "((?:\\.|[^"\\])*)"\)',
        block[1],
    )


def updated_cases(file, entries, property_name):
    contents = file.read_text()
    declarations = re.findall(r'^        case (`?\w+`?) = "((?:\\.|[^"\\])*)"$', contents, re.MULTILINE)
    existing = {raw for _, raw in declarations}
    names = {name.strip("`") for name, _ in declarations}
    additions = []
    for identifier, raw in sorted(set(entries)):
        if raw in existing:
            continue
        identifier = re.sub(r"^(?:icn|btn|image|img)(?=[A-Z])", "", identifier.strip("`"))
        name = identifier[0].lower() + identifier[1:]
        if name in names:
            raise ValueError(f"{file.name}에서 {raw}의 케이스 이름 {name}이 이미 사용 중입니다.")
        names.add(name)
        existing.add(raw)
        additions.append(f'        case `{name}` = "{raw}"\n')

    if not additions:
        return contents, contents
    marker = f"\n        public var {property_name}:"
    if not declarations or contents.count(marker) != 1:
        raise ValueError(f"{file.name}에서 케이스 등록 위치를 찾을 수 없습니다.")
    return contents, contents.replace(marker, "".join(additions) + marker, 1)


def sync_assets():
    if not GENERATED.is_file():
        raise ValueError("Tuist 에셋 선언이 없습니다. tuist generate --no-open을 실행하세요.")
    contents = GENERATED.read_text()
    images = asset_entries(contents, "ImageAssets", "Images")
    colors = asset_entries(contents, "ColorAssets", "Colors")
    entries = (
        (SOURCES / "Image/LivithIcon.swift", [e for e in images if e[1].startswith("icn_")], "image"),
        (SOURCES / "Image/LivithImage.swift", [e for e in images if not e[1].startswith("icn_")], "image"),
        (SOURCES / "Color/LivithColor.swift", colors, "color"),
    )
    edits = {}
    for file, assets, property_name in entries:
        old, new = updated_cases(file, assets, property_name)
        if old == new:
            continue
        edits[file] = (old, new)
        added = set(new.splitlines()) - set(old.splitlines())
        print(f"  {file.name}")
        for line in sorted(added):
            print(line)

    if not edits:
        print("모든 디자인 시스템 에셋이 동기화되어 있습니다.")
        return
    if input("위 에셋 케이스를 추가할까요? (Y/n): ").strip().lower() == "n":
        print("동기화를 취소했습니다.")
        return
    if any(file.read_text() != old for file, (old, _) in edits.items()):
        raise ValueError("에셋 선언이 변경되었습니다. 명령을 다시 실행하세요.")
    with ExitStack() as revert:
        for file, (old, new) in edits.items():
            revert.callback(file.write_text, old)
            file.write_text(new)
        revert.pop_all()
    print("디자인 시스템 에셋을 동기화했습니다.")


try:
    sync_assets()
except (EOFError, KeyboardInterrupt):
    sys.exit("\n동기화를 취소했습니다.")
except (OSError, ValueError) as error:
    sys.exit(f"에셋 동기화 실패. {error}")
