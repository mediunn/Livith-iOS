#!/bin/bash

# Tuist 모듈 삭제 스크립트 (대화형 + 롤백 지원)
# 사용법: ./Scripts/delete_module.sh

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# 프로젝트 루트 경로
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Tuist 파일 경로
HELPERS_DIR="$PROJECT_ROOT/Tuist/ProjectDescriptionHelpers/Module"
CONSTANT_FILE="$HELPERS_DIR/Module+Constant.swift"
TARGET_ID_FILE="$HELPERS_DIR/Module+TargetID.swift"
PROJECT_ID_FILE="$HELPERS_DIR/Module+ProjectID.swift"
DEPENDENCY_FILE="$HELPERS_DIR/TargetDependency+Extension.swift"

# 백업 디렉토리
BACKUP_DIR="$PROJECT_ROOT/.module_backup"

# 롤백 함수
rollback() {
    echo ""
    echo -e "${YELLOW}⏪ 롤백 중...${NC}"

    if [ -d "$BACKUP_DIR" ]; then
        cp "$BACKUP_DIR/Module+Constant.swift" "$CONSTANT_FILE"
        cp "$BACKUP_DIR/Module+TargetID.swift" "$TARGET_ID_FILE"
        cp "$BACKUP_DIR/Module+ProjectID.swift" "$PROJECT_ID_FILE"
        cp "$BACKUP_DIR/TargetDependency+Extension.swift" "$DEPENDENCY_FILE"

        # Projects 디렉토리 복원
        if [ -f "$BACKUP_DIR/module_name.txt" ]; then
            MODULE_NAME=$(cat "$BACKUP_DIR/module_name.txt")
            if [ -d "$BACKUP_DIR/Projects_$MODULE_NAME" ]; then
                cp -r "$BACKUP_DIR/Projects_$MODULE_NAME" "$PROJECT_ROOT/Projects/$MODULE_NAME"
            fi
        fi

        rm -rf "$BACKUP_DIR"
        echo -e "${GREEN}✅ 롤백 완료!${NC}"
    else
        echo -e "${RED}❌ 백업 파일을 찾을 수 없습니다.${NC}"
    fi
    exit 0
}

# 헤더 출력
clear
echo ""
echo -e "${BOLD}${RED}╔════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${RED}║     🗑️  Tuist 모듈 삭제 스크립트      ║${NC}"
echo -e "${BOLD}${RED}╚════════════════════════════════════════╝${NC}"
echo ""

# 롤백 옵션 확인
if [ -d "$BACKUP_DIR" ]; then
    echo -e "${YELLOW}⚠️  이전 삭제 작업의 백업이 발견되었습니다.${NC}"
    echo ""
    read -p "   롤백하시겠습니까? (y/N): " ROLLBACK_CONFIRM
    if [[ "$ROLLBACK_CONFIRM" =~ ^[Yy]$ ]]; then
        rollback
    else
        rm -rf "$BACKUP_DIR"
        echo ""
    fi
fi

# 현재 존재하는 모듈 목록 표시
echo -e "${BOLD}${BLUE}📦 현재 존재하는 모듈 목록${NC}"
echo ""

# ProjectID에서 모듈 목록 추출 (app, core, dsKit 제외)
MODULES=$(grep -E "case .+ = " "$PROJECT_ID_FILE" | grep -vE "(app|core|dsKit)" | sed 's/.*case \([^ ]*\) = .*/\1/' | tr '\n' ' ')

if [ -z "$MODULES" ]; then
    echo -e "   ${YELLOW}삭제 가능한 모듈이 없습니다.${NC}"
    exit 0
fi

# 모듈 목록 출력
INDEX=1
declare -a MODULE_ARRAY
for MODULE in $MODULES; do
    MODULE_ARRAY+=("$MODULE")
    MODULE_DISPLAY="$(echo "${MODULE:0:1}" | tr '[:lower:]' '[:upper:]')${MODULE:1}"
    echo -e "   ${CYAN}[$INDEX]${NC} $MODULE_DISPLAY"
    ((INDEX++))
done

echo ""
echo -e "${BOLD}${BLUE}🗑️  삭제할 모듈을 선택하세요${NC}"
echo -e "${YELLOW}   (번호 또는 모듈 이름 입력)${NC}"
echo ""
read -p "   선택: " MODULE_INPUT

# 입력 검증
if [ -z "$MODULE_INPUT" ]; then
    echo ""
    echo -e "${RED}❌ 모듈을 선택해주세요.${NC}"
    exit 1
fi

# 번호로 입력한 경우
if [[ "$MODULE_INPUT" =~ ^[0-9]+$ ]]; then
    INDEX=$((MODULE_INPUT - 1))
    if [ $INDEX -lt 0 ] || [ $INDEX -ge ${#MODULE_ARRAY[@]} ]; then
        echo ""
        echo -e "${RED}❌ 잘못된 번호입니다.${NC}"
        exit 1
    fi
    MODULE_NAME_LOWER="${MODULE_ARRAY[$INDEX]}"
else
    MODULE_NAME_LOWER="$(echo "${MODULE_INPUT:0:1}" | tr '[:upper:]' '[:lower:]')${MODULE_INPUT:1}"
fi

MODULE_NAME_UPPER="$(echo "${MODULE_NAME_LOWER:0:1}" | tr '[:lower:]' '[:upper:]')${MODULE_NAME_LOWER:1}"

# 모듈 존재 확인
if ! grep -q "case ${MODULE_NAME_LOWER} = \"${MODULE_NAME_UPPER}\"" "$PROJECT_ID_FILE" 2>/dev/null; then
    echo ""
    echo -e "${RED}❌ '${MODULE_NAME_UPPER}' 모듈을 찾을 수 없습니다.${NC}"
    exit 1
fi

# 삭제 확인
echo ""
echo -e "${BOLD}${RED}⚠️  경고${NC}"
echo ""
echo -e "   다음 항목들이 삭제됩니다:"
echo -e "   ${YELLOW}• Projects/${MODULE_NAME_UPPER}/ 디렉토리${NC}"
echo -e "   ${YELLOW}• ${MODULE_NAME_UPPER}Module enum (Module+Constant.swift)${NC}"
echo -e "   ${YELLOW}• TargetID.${MODULE_NAME_LOWER} case (Module+TargetID.swift)${NC}"
echo -e "   ${YELLOW}• ProjectID.${MODULE_NAME_LOWER} case (Module+ProjectID.swift)${NC}"
echo -e "   ${YELLOW}• .${MODULE_NAME_LOWER}() 함수 (TargetDependency+Extension.swift)${NC}"
echo ""
echo -e "   ${GREEN}💾 백업이 생성되며, 문제 발생 시 롤백 가능합니다.${NC}"
echo ""
read -p "   정말 삭제하시겠습니까? (yes를 입력): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo ""
    echo -e "${YELLOW}⚠️  취소되었습니다.${NC}"
    exit 0
fi

echo ""
echo -e "${BOLD}${CYAN}🗑️  모듈 삭제 중...${NC}"
echo ""

# 백업 생성
echo -e "   ${YELLOW}[0/5]${NC} 백업 생성 중..."
mkdir -p "$BACKUP_DIR"
cp "$CONSTANT_FILE" "$BACKUP_DIR/"
cp "$TARGET_ID_FILE" "$BACKUP_DIR/"
cp "$PROJECT_ID_FILE" "$BACKUP_DIR/"
cp "$DEPENDENCY_FILE" "$BACKUP_DIR/"
echo "$MODULE_NAME_UPPER" > "$BACKUP_DIR/module_name.txt"

MODULE_DIR="$PROJECT_ROOT/Projects/${MODULE_NAME_UPPER}"
if [ -d "$MODULE_DIR" ]; then
    cp -r "$MODULE_DIR" "$BACKUP_DIR/Projects_${MODULE_NAME_UPPER}"
fi

# 1. Module+Constant.swift에서 enum 삭제
echo -e "   ${YELLOW}[1/5]${NC} Module+Constant.swift 수정 중..."

TEMP_FILE=$(mktemp)
awk -v module="${MODULE_NAME_UPPER}" '
BEGIN { skip = 0; blank_count = 0 }
/^$/ { blank_count++; next }
{
    # 빈 줄 출력 (최대 1개)
    if (blank_count > 0 && !skip) {
        print ""
        blank_count = 0
    }

    # MARK 주석 발견
    if ($0 ~ "// MARK: - " module " Module") {
        skip = 1
        next
    }

    # enum 시작
    if ($0 ~ "public enum " module "Module") {
        skip = 1
        next
    }

    # enum 끝
    if (/^}$/ && skip) {
        skip = 0
        next
    }

    if (!skip) print
}
' "$CONSTANT_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$CONSTANT_FILE"

# 2. Module+TargetID.swift 수정
echo -e "   ${YELLOW}[2/5]${NC} Module+TargetID.swift 수정 중..."

TEMP_FILE=$(mktemp)
awk -v module="${MODULE_NAME_LOWER}" -v Module="${MODULE_NAME_UPPER}" '
BEGIN { skip_next = 0 }
{
    # enum case 삭제
    if ($0 ~ "case " module "\\(" Module "Module\\)") next

    # name switch case 삭제
    if ($0 ~ "case \\." module "\\(let module\\): return module\\.rawValue") next

    # sourcesPath case 삭제 (2줄)
    if ($0 ~ "case \\." module "\\(let module\\):$") {
        skip_next = 1
        next
    }
    if (skip_next) {
        skip_next = 0
        next
    }

    print
}
' "$TARGET_ID_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$TARGET_ID_FILE"

# 3. Module+ProjectID.swift 수정
echo -e "   ${YELLOW}[3/5]${NC} Module+ProjectID.swift 수정 중..."

TEMP_FILE=$(mktemp)
grep -v "case ${MODULE_NAME_LOWER} = \"${MODULE_NAME_UPPER}\"" "$PROJECT_ID_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$PROJECT_ID_FILE"

# 4. TargetDependency+Extension.swift 수정
echo -e "   ${YELLOW}[4/5]${NC} TargetDependency+Extension.swift 수정 중..."

TEMP_FILE=$(mktemp)
awk -v module="${MODULE_NAME_LOWER}" -v Module="${MODULE_NAME_UPPER}" '
BEGIN { skip = 0 }
{
    if ($0 ~ "public static func " module "\\(_ module: " Module "Module\\)") {
        skip = 1
        next
    }
    if (skip && /^    }$/) {
        skip = 0
        next
    }
    if (!skip) print
}
' "$DEPENDENCY_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$DEPENDENCY_FILE"

# 5. Projects 디렉토리 삭제
echo -e "   ${YELLOW}[5/5]${NC} Projects/${MODULE_NAME_UPPER} 디렉토리 삭제 중..."

if [ -d "$MODULE_DIR" ]; then
    rm -rf "$MODULE_DIR"
fi

# 완료 메시지
echo ""
echo -e "${BOLD}${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║       ✅ 모듈 삭제 완료!               ║${NC}"
echo -e "${BOLD}${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "   ${BOLD}삭제된 모듈:${NC} ${RED}${MODULE_NAME_UPPER}${NC}"
echo ""
echo -e "   ${BOLD}다음 단계:${NC}"
echo -e "   ${YELLOW}tuist generate${NC}"
echo ""
echo -e "   ${BOLD}문제 발생 시:${NC}"
echo -e "   ${CYAN}make module-delete${NC} 실행 후 롤백 선택"
echo ""
