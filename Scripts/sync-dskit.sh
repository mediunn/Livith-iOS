#!/bin/bash

# DSKit 에셋 동기화 스크립트
# TuistAssets+DSKit.swift를 읽어서 Image+.swift, Color+.swift에 누락된 에셋을 추가합니다.
#
# 사용법: make sync-dskit

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

TUIST_ASSETS="$PROJECT_ROOT/Projects/DSKit/Derived/Sources/TuistAssets+DSKit.swift"
IMAGE_EXT="$PROJECT_ROOT/Projects/DSKit/Sources/SwiftUIHelper/Image+.swift"
COLOR_EXT="$PROJECT_ROOT/Projects/DSKit/Sources/SwiftUIHelper/Color+.swift"
IMAGE_ASSETS_DIR="$PROJECT_ROOT/Projects/DSKit/Resources/ImageAssets.xcassets"

# 색상 출력
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo "🔄 DSKit 에셋 동기화 시작..."
echo ""

# 파일 존재 확인
if [ ! -f "$TUIST_ASSETS" ]; then
    echo -e "${RED}❌ TuistAssets+DSKit.swift 파일을 찾을 수 없습니다.${NC}"
    echo "   tuist generate를 먼저 실행해주세요."
    exit 1
fi

# 수동 매핑된 예외 케이스 (Tuist변수=실제enum케이스)
# 네이밍이 자동 변환과 다른 경우 여기에 추가
ICON_EXCEPTIONS="icnDown15LineSmall=down1_5LineSmall icnLineSmallUp=upLineSmall"

# 예외 매핑에서 enum case 찾기
get_exception_case() {
    local tuist_var="$1"
    local exceptions="$2"
    for pair in $exceptions; do
        key="${pair%%=*}"
        value="${pair#*=}"
        if [ "$key" = "$tuist_var" ]; then
            echo "$value"
            return
        fi
    done
    echo ""
}

# 첫글자를 소문자로 변환
lowercase_first() {
    local str="$1"
    local first=$(echo "${str:0:1}" | tr '[:upper:]' '[:lower:]')
    echo "${first}${str:1}"
}

# camelCase를 snake_case로 변환 (파일명 찾기용)
to_snake_case() {
    echo "$1" | sed 's/\([A-Z]\)/_\1/g' | tr '[:upper:]' '[:lower:]' | sed 's/^_//'
}

# 에셋이 Icon 폴더에 있는지 확인
is_in_icon_folder() {
    local tuist_var="$1"
    local file_name=$(to_snake_case "$tuist_var")

    if [ -d "$IMAGE_ASSETS_DIR/Icon/${file_name}.imageset" ]; then
        return 0  # true - Icon 폴더에 있음
    else
        return 1  # false - Icon 폴더에 없음
    fi
}

echo "📦 이미지 에셋 동기화..."

# TuistAssets에서 이미지 에셋 추출 (ImageAssets 블록에서)
# icn_, btn_, image_ 모두 추출
ALL_ASSETS=$(sed -n '/enum ImageAssets/,/}/p' "$TUIST_ASSETS" | grep -oE 'static let [a-zA-Z0-9]+' | sed 's/static let //' | sort -u)

# Image+.swift 전체 내용
IMAGE_CONTENT=$(cat "$IMAGE_EXT")

# 누락된 아이콘/이미지 분류
MISSING_ICONS=""
MISSING_IMAGES=""

for tuist_var in $ALL_ASSETS; do
    # 접두사에 따라 enum case 이름 생성
    if [[ "$tuist_var" == icn* ]]; then
        # 예외 매핑 확인
        exception_case=$(get_exception_case "$tuist_var" "$ICON_EXCEPTIONS")
        if [ -n "$exception_case" ]; then
            enum_case="$exception_case"
        else
            without_prefix="${tuist_var#icn}"
            enum_case=$(lowercase_first "$without_prefix")
        fi
    elif [[ "$tuist_var" == btn* ]]; then
        without_prefix="${tuist_var#btn}"
        enum_case=$(lowercase_first "$without_prefix")
    elif [[ "$tuist_var" == image* ]]; then
        without_prefix="${tuist_var#image}"
        enum_case=$(lowercase_first "$without_prefix")
    else
        continue
    fi

    # 이미 존재하는지 확인
    if echo "$IMAGE_CONTENT" | grep -qE "case[[:space:]].*${enum_case}|\.${enum_case}:"; then
        continue
    fi

    # 폴더 위치 확인해서 분류
    if is_in_icon_folder "$tuist_var"; then
        MISSING_ICONS="$MISSING_ICONS|$tuist_var:$enum_case"
    else
        MISSING_IMAGES="$MISSING_IMAGES|$tuist_var:$enum_case"
    fi
done

# 첫 번째 빈 항목 제거
MISSING_ICONS="${MISSING_ICONS#|}"
MISSING_IMAGES="${MISSING_IMAGES#|}"

# 아이콘 처리
if [ -n "$MISSING_ICONS" ]; then
    echo -e "${YELLOW}⚠️  누락된 아이콘 발견 (Icon 폴더):${NC}"
    echo "$MISSING_ICONS" | tr '|' '\n' | while read item; do
        if [ -n "$item" ]; then
            tuist_var=$(echo "$item" | cut -d':' -f1)
            enum_case=$(echo "$item" | cut -d':' -f2)
            echo "   - $enum_case (DSKitAsset.ImageAssets.$tuist_var)"
        fi
    done

    echo ""
    read -p "   추가할까요? (Y/n): " ADD_ICONS

    if [[ ! "$ADD_ICONS" =~ ^[Nn]$ ]]; then
        echo ""
        echo -e "${GREEN}🔧 추가 중...${NC}"

        echo "$MISSING_ICONS" | tr '|' '\n' | while read item; do
            if [ -n "$item" ]; then
                tuist_var=$(echo "$item" | cut -d':' -f1)
                enum_case=$(echo "$item" | cut -d':' -f2)

                # enum case 추가 (case trash 뒤에)
                sed -i '' "s/case trash$/case trash, $enum_case/" "$IMAGE_EXT"

                # switch case 추가 (case .trash: 블록 다음에)
                sed -i '' "/case \.trash:/,/swiftUIImage/{
                    /swiftUIImage/a\\
            case .$enum_case:\\
                DSKitAsset.ImageAssets.$tuist_var.swiftUIImage
                }" "$IMAGE_EXT"

                echo "   ✅ $enum_case 추가됨"
            fi
        done
    else
        echo -e "   ${CYAN}건너뜀${NC}"
    fi
else
    echo -e "${GREEN}✅ 모든 아이콘이 동기화되어 있습니다.${NC}"
fi

echo ""

# 이미지 처리
if [ -n "$MISSING_IMAGES" ]; then
    echo -e "${YELLOW}⚠️  누락된 이미지 발견 (Image 폴더):${NC}"
    echo "$MISSING_IMAGES" | tr '|' '\n' | while read item; do
        if [ -n "$item" ]; then
            tuist_var=$(echo "$item" | cut -d':' -f1)
            enum_case=$(echo "$item" | cut -d':' -f2)
            echo "   - $enum_case (DSKitAsset.ImageAssets.$tuist_var)"
        fi
    done

    echo ""
    read -p "   추가할까요? (Y/n): " ADD_IMAGES

    if [[ ! "$ADD_IMAGES" =~ ^[Nn]$ ]]; then
        echo ""
        echo -e "${GREEN}🔧 추가 중...${NC}"

        echo "$MISSING_IMAGES" | tr '|' '\n' | while read item; do
            if [ -n "$item" ]; then
                tuist_var=$(echo "$item" | cut -d':' -f1)
                enum_case=$(echo "$item" | cut -d':' -f2)

                # enum case 추가 (case splash 뒤에)
                sed -i '' "s/case splash$/case splash, $enum_case/" "$IMAGE_EXT"

                # switch case 추가 (case .splash: 블록 다음에)
                sed -i '' "/case \.splash:/,/swiftUIImage/{
                    /swiftUIImage/a\\
            case .$enum_case:\\
                DSKitAsset.ImageAssets.$tuist_var.swiftUIImage
                }" "$IMAGE_EXT"

                echo "   ✅ $enum_case 추가됨"
            fi
        done
    else
        echo -e "   ${CYAN}건너뜀${NC}"
    fi
else
    echo -e "${GREEN}✅ 모든 이미지가 동기화되어 있습니다.${NC}"
fi

echo ""
echo "🎨 컬러 에셋 동기화..."

# TuistAssets에서 컬러 에셋 추출 (ColorAssets 블록에서)
TUIST_COLORS=$(sed -n '/enum ColorAssets/,/}/p' "$TUIST_ASSETS" | grep -oE 'static let [a-z][a-zA-Z0-9]+' | sed 's/static let //' | sort -u)

# Color+.swift 전체 내용
COLOR_CONTENT=$(cat "$COLOR_EXT")

MISSING_COLORS=""
for color in $TUIST_COLORS; do
    if ! echo "$COLOR_CONTENT" | grep -qE "case[[:space:]].*${color}|\.${color}:"; then
        MISSING_COLORS="$MISSING_COLORS $color"
    fi
done

MISSING_COLORS=$(echo "$MISSING_COLORS" | xargs)

if [ -n "$MISSING_COLORS" ]; then
    echo -e "${YELLOW}⚠️  누락된 컬러 발견:${NC}"
    for color in $MISSING_COLORS; do
        echo "   - $color (DSKitAsset.ColorAssets.$color)"
    done

    echo ""
    read -p "   추가할까요? (Y/n): " ADD_COLORS

    if [[ ! "$ADD_COLORS" =~ ^[Nn]$ ]]; then
        echo ""
        echo -e "${GREEN}🔧 추가 중...${NC}"

        for color in $MISSING_COLORS; do
            # enum case 추가
            sed -i '' "s/case original$/case original, $color/" "$COLOR_EXT"

            # switch case 추가
            sed -i '' "/case \.original:/,/\.color)/{
                /\.color)/a\\
            case .$color:\\
                Color(DSKitAsset.ColorAssets.$color.color)
            }" "$COLOR_EXT"

            echo "   ✅ $color 추가됨"
        done
    else
        echo -e "   ${CYAN}건너뜀${NC}"
    fi
else
    echo -e "${GREEN}✅ 모든 컬러가 동기화되어 있습니다.${NC}"
fi

echo ""
echo "🎉 동기화 완료!"
