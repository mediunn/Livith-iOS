#!/bin/bash

# Tuist 모듈 자동 생성 스크립트 (대화형)
# 사용법: ./Scripts/create_module.sh

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

# 헤더 출력
clear
echo ""
echo -e "${BOLD}${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║     🛠️  Tuist 모듈 생성 스크립트            ║${NC}"
echo -e "${BOLD}${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

# 모듈 이름 입력
echo -e "${BOLD}${BLUE}📦 모듈 이름을 입력하세요${NC}"
echo -e "${YELLOW}   (예: User, Concert, Ticket)${NC}"
echo ""
read -p "   모듈 이름: " MODULE_INPUT

# 입력 검증
if [ -z "$MODULE_INPUT" ]; then
    echo ""
    echo -e "${RED}❌ 모듈 이름을 입력해주세요.${NC}"
    exit 1
fi

# 이름 정규화 (첫 글자 대문자)
MODULE_NAME_UPPER="$(echo "${MODULE_INPUT:0:1}" | tr '[:lower:]' '[:upper:]')${MODULE_INPUT:1}"
MODULE_NAME_LOWER="$(echo "${MODULE_INPUT:0:1}" | tr '[:upper:]' '[:lower:]')${MODULE_INPUT:1}"

# 이미 존재하는지 확인
if grep -q "case ${MODULE_NAME_LOWER} = \"${MODULE_NAME_UPPER}\"" "$PROJECT_ID_FILE" 2>/dev/null; then
    echo ""
    echo -e "${RED}❌ '${MODULE_NAME_UPPER}' 모듈이 이미 존재합니다.${NC}"
    exit 1
fi

echo ""
echo -e "${BOLD}${BLUE}📂 생성할 하위 모듈을 선택하세요${NC}"
echo -e "${YELLOW}   (스페이스로 선택/해제, Enter로 확인)${NC}"
echo ""

# 하위 모듈 선택
CREATE_DATA=true
CREATE_DOMAIN=true
CREATE_FEATURE=true

echo "   기본값: Data, Domain, Feature 모두 생성"
echo ""
read -p "   모두 생성하시겠습니까? (Y/n): " CONFIRM_ALL

if [[ "$CONFIRM_ALL" =~ ^[Nn]$ ]]; then
    read -p "   Data 모듈 생성? (Y/n): " CREATE_DATA_INPUT
    read -p "   Domain 모듈 생성? (Y/n): " CREATE_DOMAIN_INPUT
    read -p "   Feature 모듈 생성? (Y/n): " CREATE_FEATURE_INPUT

    [[ "$CREATE_DATA_INPUT" =~ ^[Nn]$ ]] && CREATE_DATA=false
    [[ "$CREATE_DOMAIN_INPUT" =~ ^[Nn]$ ]] && CREATE_DOMAIN=false
    [[ "$CREATE_FEATURE_INPUT" =~ ^[Nn]$ ]] && CREATE_FEATURE=false
fi

# 생성 요약 출력
echo ""
echo -e "${BOLD}${BLUE}📋 생성 요약${NC}"
echo ""
echo -e "   모듈 이름: ${GREEN}${MODULE_NAME_UPPER}${NC}"
echo -e "   생성 위치: ${YELLOW}Projects/${MODULE_NAME_UPPER}/${NC}"
echo ""
echo "   하위 모듈:"
$CREATE_DATA && echo -e "     ${GREEN}✓${NC} ${MODULE_NAME_UPPER}Data"
$CREATE_DATA || echo -e "     ${RED}✗${NC} ${MODULE_NAME_UPPER}Data"
$CREATE_DOMAIN && echo -e "     ${GREEN}✓${NC} ${MODULE_NAME_UPPER}Domain"
$CREATE_DOMAIN || echo -e "     ${RED}✗${NC} ${MODULE_NAME_UPPER}Domain"
$CREATE_FEATURE && echo -e "     ${GREEN}✓${NC} ${MODULE_NAME_UPPER}Feature"
$CREATE_FEATURE || echo -e "     ${RED}✗${NC} ${MODULE_NAME_UPPER}Feature"
echo ""

# 최종 확인
read -p "   계속 진행하시겠습니까? (Y/n): " FINAL_CONFIRM

if [[ "$FINAL_CONFIRM" =~ ^[Nn]$ ]]; then
    echo ""
    echo -e "${YELLOW}⚠️  취소되었습니다.${NC}"
    exit 0
fi

echo ""
echo -e "${BOLD}${CYAN}🚀 모듈 생성 중...${NC}"
echo ""

# 1. Module+Constant.swift 수정
echo -e "   ${YELLOW}[1/6]${NC} Module+Constant.swift 수정 중..."

TEMP_FILE=$(mktemp)
awk -v upper="$MODULE_NAME_UPPER" -v lower="$MODULE_NAME_LOWER" \
    -v data="$CREATE_DATA" -v domain="$CREATE_DOMAIN" -v feature="$CREATE_FEATURE" '
/\/\/ MARK: - External Dependency/ {
    print ""
    print "// MARK: - " upper " Module"
    print ""
    print "public enum " upper "Module: String {"
    if (data == "true") print "    case " lower "Data = \"" upper "Data\""
    if (domain == "true") print "    case " lower "Domain = \"" upper "Domain\""
    if (feature == "true") print "    case " lower "Feature = \"" upper "Feature\""
    print "}"
    print ""
}
{ print }
' "$CONSTANT_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$CONSTANT_FILE"

# 2. Module+TargetID.swift 수정
echo -e "   ${YELLOW}[2/6]${NC} Module+TargetID.swift 수정 중..."

TEMP_FILE=$(mktemp)
awk -v upper="$MODULE_NAME_UPPER" -v lower="$MODULE_NAME_LOWER" '
# enum case 추가
/case search\(SearchModule\)/ {
    print
    print "    case " lower "(" upper "Module)"
    next
}
# name switch case 추가
/case \.search\(let module\): return module\.rawValue/ {
    print
    print "        case ." lower "(let module): return module.rawValue"
    next
}
# sourcesPath switch case 추가 (search 다음 줄의 return 이후에 추가)
/case \.search\(let module\):$/ {
    print
    getline  # return 줄 읽기
    print
    print "        case ." lower "(let module):"
    print "            return [\"\\(module.rawValue)/Sources/**\"]"
    next
}
{ print }
' "$TARGET_ID_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$TARGET_ID_FILE"

# 3. Module+ProjectID.swift 수정
echo -e "   ${YELLOW}[3/6]${NC} Module+ProjectID.swift 수정 중..."

TEMP_FILE=$(mktemp)
awk -v upper="$MODULE_NAME_UPPER" -v lower="$MODULE_NAME_LOWER" '
/public var name: String \{ rawValue \}/ {
    print "    case " lower " = \"" upper "\""
}
{ print }
' "$PROJECT_ID_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$PROJECT_ID_FILE"

# 4. TargetDependency+Extension.swift 수정
echo -e "   ${YELLOW}[4/6]${NC} TargetDependency+Extension.swift 수정 중..."

TEMP_FILE=$(mktemp)
awk -v upper="$MODULE_NAME_UPPER" -v lower="$MODULE_NAME_LOWER" '
/^}$/ && !added {
    print ""
    print "    public static func " lower "(_ module: " upper "Module) -> TargetDependency {"
    print "        return .project(target: module.rawValue, path: ProjectID." lower ".path)"
    print "    }"
    added = 1
}
{ print }
' "$DEPENDENCY_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$DEPENDENCY_FILE"

# 5. Projects 디렉토리 생성
echo -e "   ${YELLOW}[5/6]${NC} Projects/${MODULE_NAME_UPPER} 디렉토리 생성 중..."

MODULE_DIR="$PROJECT_ROOT/Projects/${MODULE_NAME_UPPER}"
mkdir -p "$MODULE_DIR"

$CREATE_DATA && mkdir -p "$MODULE_DIR/${MODULE_NAME_UPPER}Data/Sources"
$CREATE_DOMAIN && mkdir -p "$MODULE_DIR/${MODULE_NAME_UPPER}Domain/Sources"
$CREATE_FEATURE && mkdir -p "$MODULE_DIR/${MODULE_NAME_UPPER}Feature/Sources"

# Project.swift 생성
TARGETS=""

if $CREATE_DATA; then
    TARGETS="${TARGETS}
        .make(
            target: .${MODULE_NAME_LOWER}(.${MODULE_NAME_LOWER}Data),
            product: .framework,
            dependencies: ["
    $CREATE_DOMAIN && TARGETS="${TARGETS}
                .${MODULE_NAME_LOWER}(.${MODULE_NAME_LOWER}Domain),"
    TARGETS="${TARGETS}
                .core(.livithNetwork)
            ]
        ),"
fi

if $CREATE_DOMAIN; then
    TARGETS="${TARGETS}
        .make(
            target: .${MODULE_NAME_LOWER}(.${MODULE_NAME_LOWER}Domain),
            product: .framework
        ),"
fi

if $CREATE_FEATURE; then
    TARGETS="${TARGETS}
        .make(
            target: .${MODULE_NAME_LOWER}(.${MODULE_NAME_LOWER}Feature),
            product: .framework,
            dependencies: ["
    $CREATE_DOMAIN && TARGETS="${TARGETS}
                .${MODULE_NAME_LOWER}(.${MODULE_NAME_LOWER}Domain),"
    TARGETS="${TARGETS}
                .external(.livithDesignSystem),
                .core(.coordinator),
                .core(.diContainer),
                .core(.livithFoundation)
            ]
        ),"
fi

# 마지막 콤마 제거
TARGETS=$(echo "$TARGETS" | sed '$ s/,$//')

cat > "$MODULE_DIR/Project.swift" << EOF
//
//  Project.swift
//  Manifests
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .${MODULE_NAME_LOWER},
    targets: [${TARGETS}
    ]
)
EOF

# 6. Placeholder 파일 생성
echo -e "   ${YELLOW}[6/6]${NC} Placeholder 파일 생성 중..."

if $CREATE_DATA; then
    cat > "$MODULE_DIR/${MODULE_NAME_UPPER}Data/Sources/Placeholder.swift" << EOF
//
//  Placeholder.swift
//  ${MODULE_NAME_UPPER}Data
//

import Foundation
EOF
fi

if $CREATE_DOMAIN; then
    cat > "$MODULE_DIR/${MODULE_NAME_UPPER}Domain/Sources/Placeholder.swift" << EOF
//
//  Placeholder.swift
//  ${MODULE_NAME_UPPER}Domain
//

import Foundation
EOF
fi

if $CREATE_FEATURE; then
    cat > "$MODULE_DIR/${MODULE_NAME_UPPER}Feature/Sources/Placeholder.swift" << EOF
//
//  Placeholder.swift
//  ${MODULE_NAME_UPPER}Feature
//

import Foundation
EOF
fi

# 완료 메시지
echo ""
echo -e "${BOLD}${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║       ✅ 모듈 생성 완료!                   ║${NC}"
echo -e "${BOLD}${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "   ${BOLD}생성된 구조:${NC}"
echo -e "   ${YELLOW}Projects/${MODULE_NAME_UPPER}/${NC}"
echo "   ├── Project.swift"
$CREATE_DATA && echo "   ├── ${MODULE_NAME_UPPER}Data/Sources/"
$CREATE_DOMAIN && echo "   ├── ${MODULE_NAME_UPPER}Domain/Sources/"
$CREATE_FEATURE && echo "   └── ${MODULE_NAME_UPPER}Feature/Sources/"
echo ""
echo -e "   ${BOLD}의존성 사용법:${NC}"
$CREATE_DATA && echo -e "   ${CYAN}.${MODULE_NAME_LOWER}(.${MODULE_NAME_LOWER}Data)${NC}"
$CREATE_DOMAIN && echo -e "   ${CYAN}.${MODULE_NAME_LOWER}(.${MODULE_NAME_LOWER}Domain)${NC}"
$CREATE_FEATURE && echo -e "   ${CYAN}.${MODULE_NAME_LOWER}(.${MODULE_NAME_LOWER}Feature)${NC}"
echo ""
echo -e "   ${BOLD}다음 단계:${NC}"
echo -e "   ${YELLOW}tuist generate${NC}"
echo ""
