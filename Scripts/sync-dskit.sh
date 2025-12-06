#!/bin/bash

# DSKit 에셋 동기화 스크립트
# TuistAssets+DSKit.swift를 읽어서 Image+.swift, Color+.swift에 누락된 에셋을 추가합니다.
#
# 사용법:
#   make sync-dskit        # 누락된 에셋 확인만
#   make sync-dskit-auto   # 누락된 에셋 자동 추가

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

TUIST_ASSETS="$PROJECT_ROOT/Projects/DSKit/Derived/Sources/TuistAssets+DSKit.swift"
IMAGE_EXT="$PROJECT_ROOT/Projects/DSKit/Sources/SwiftUIHelper/Image+.swift"
COLOR_EXT="$PROJECT_ROOT/Projects/DSKit/Sources/SwiftUIHelper/Color+.swift"

# 자동 추가 모드 확인
AUTO_MODE=false
if [ "$1" = "--auto" ] || [ "$1" = "-a" ]; then
    AUTO_MODE=true
fi

# 색상 출력
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

echo "📦 이미지 에셋 동기화..."

# TuistAssets에서 이미지 에셋 추출 (ImageAssets 블록에서)
TUIST_ICONS=$(sed -n '/enum ImageAssets/,/}/p' "$TUIST_ASSETS" | grep -oE 'static let icn[A-Za-z0-9]+' | sed 's/static let //' | sort -u)
TUIST_IMAGES=$(sed -n '/enum ImageAssets/,/}/p' "$TUIST_ASSETS" | grep -oE 'static let image[A-Za-z0-9]+' | sed 's/static let //' | sort -u)

# Image+.swift 전체 내용
IMAGE_CONTENT=$(cat "$IMAGE_EXT")

# 누락된 아이콘 찾기
MISSING_ICONS=""
for tuist_var in $TUIST_ICONS; do
    # 예외 매핑 확인
    exception_case=$(get_exception_case "$tuist_var" "$ICON_EXCEPTIONS")
    if [ -n "$exception_case" ]; then
        enum_case="$exception_case"
    else
        # icnApple -> Apple -> apple
        without_prefix="${tuist_var#icn}"
        enum_case=$(lowercase_first "$without_prefix")
    fi

    # 실제 파일에서 해당 케이스가 있는지 확인 (다양한 패턴)
    if ! echo "$IMAGE_CONTENT" | grep -qE "case[[:space:]].*${enum_case}|\.${enum_case}:"; then
        MISSING_ICONS="$MISSING_ICONS|$tuist_var:$enum_case"
    fi
done

# 첫 번째 빈 항목 제거
MISSING_ICONS="${MISSING_ICONS#|}"

if [ -n "$MISSING_ICONS" ]; then
    echo -e "${YELLOW}⚠️  누락된 아이콘 발견:${NC}"
    echo "$MISSING_ICONS" | tr '|' '\n' | while read item; do
        if [ -n "$item" ]; then
            tuist_var=$(echo "$item" | cut -d':' -f1)
            enum_case=$(echo "$item" | cut -d':' -f2)
            echo "   - $enum_case (DSKitAsset.ImageAssets.$tuist_var)"
        fi
    done

    if [ "$AUTO_MODE" = true ]; then
        echo ""
        echo -e "${GREEN}🔧 자동으로 추가 중...${NC}"

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
        echo ""
        echo -e "${GREEN}📝 Image+.swift의 LivithIcon enum에 다음을 추가하세요:${NC}"
        echo ""
        echo "   // enum case 추가:"
        echo "$MISSING_ICONS" | tr '|' '\n' | while read item; do
            if [ -n "$item" ]; then
                enum_case=$(echo "$item" | cut -d':' -f2)
                echo "   case $enum_case"
            fi
        done
        echo ""
        echo "   // switch문에 추가:"
        echo "$MISSING_ICONS" | tr '|' '\n' | while read item; do
            if [ -n "$item" ]; then
                tuist_var=$(echo "$item" | cut -d':' -f1)
                enum_case=$(echo "$item" | cut -d':' -f2)
                echo "   case .$enum_case:"
                echo "       DSKitAsset.ImageAssets.$tuist_var.swiftUIImage"
            fi
        done
        echo ""
        echo -e "${YELLOW}💡 자동 추가하려면: make sync-dskit-auto${NC}"
    fi
else
    echo -e "${GREEN}✅ 모든 아이콘이 동기화되어 있습니다.${NC}"
fi

echo ""

# 누락된 이미지 찾기
MISSING_IMAGES=""
for tuist_var in $TUIST_IMAGES; do
    # imageLivithLogo -> LivithLogo -> livithLogo
    without_prefix="${tuist_var#image}"
    enum_case=$(lowercase_first "$without_prefix")

    # 실제 파일에서 해당 케이스가 있는지 확인
    if ! echo "$IMAGE_CONTENT" | grep -qE "case[[:space:]].*${enum_case}|\.${enum_case}:"; then
        MISSING_IMAGES="$MISSING_IMAGES|$tuist_var:$enum_case"
    fi
done

MISSING_IMAGES="${MISSING_IMAGES#|}"

if [ -n "$MISSING_IMAGES" ]; then
    echo -e "${YELLOW}⚠️  누락된 이미지 발견:${NC}"
    echo "$MISSING_IMAGES" | tr '|' '\n' | while read item; do
        if [ -n "$item" ]; then
            tuist_var=$(echo "$item" | cut -d':' -f1)
            enum_case=$(echo "$item" | cut -d':' -f2)
            echo "   - $enum_case (DSKitAsset.ImageAssets.$tuist_var)"
        fi
    done

    if [ "$AUTO_MODE" = true ]; then
        echo ""
        echo -e "${GREEN}🔧 자동으로 추가 중...${NC}"

        echo "$MISSING_IMAGES" | tr '|' '\n' | while read item; do
            if [ -n "$item" ]; then
                tuist_var=$(echo "$item" | cut -d':' -f1)
                enum_case=$(echo "$item" | cut -d':' -f2)

                # enum case 추가
                sed -i '' "s/case splash$/case splash, $enum_case/" "$IMAGE_EXT"

                # switch case 추가
                sed -i '' "/case \.splash:/,/swiftUIImage/{
                    /swiftUIImage/a\\
            case .$enum_case:\\
                DSKitAsset.ImageAssets.$tuist_var.swiftUIImage
                }" "$IMAGE_EXT"

                echo "   ✅ $enum_case 추가됨"
            fi
        done
    else
        echo ""
        echo -e "${GREEN}📝 Image+.swift의 LivithImage enum에 다음을 추가하세요:${NC}"
        echo ""
        echo "   // enum case 추가:"
        echo "$MISSING_IMAGES" | tr '|' '\n' | while read item; do
            if [ -n "$item" ]; then
                enum_case=$(echo "$item" | cut -d':' -f2)
                echo "   case $enum_case"
            fi
        done
        echo ""
        echo "   // switch문에 추가:"
        echo "$MISSING_IMAGES" | tr '|' '\n' | while read item; do
            if [ -n "$item" ]; then
                tuist_var=$(echo "$item" | cut -d':' -f1)
                enum_case=$(echo "$item" | cut -d':' -f2)
                echo "   case .$enum_case:"
                echo "       DSKitAsset.ImageAssets.$tuist_var.swiftUIImage"
            fi
        done
        echo ""
        echo -e "${YELLOW}💡 자동 추가하려면: make sync-dskit-auto${NC}"
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

    if [ "$AUTO_MODE" = true ]; then
        echo ""
        echo -e "${GREEN}🔧 자동으로 추가 중...${NC}"

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
        echo ""
        echo -e "${GREEN}📝 Color+.swift의 LivithColor enum에 다음을 추가하세요:${NC}"
        echo ""
        echo "   // enum case 추가:"
        for color in $MISSING_COLORS; do
            echo "   case $color"
        done
        echo ""
        echo "   // switch문에 추가:"
        for color in $MISSING_COLORS; do
            echo "   case .$color:"
            echo "       Color(DSKitAsset.ColorAssets.$color.color)"
        done
        echo ""
        echo -e "${YELLOW}💡 자동 추가하려면: make sync-dskit-auto${NC}"
    fi
else
    echo -e "${GREEN}✅ 모든 컬러가 동기화되어 있습니다.${NC}"
fi

echo ""
echo "🎉 동기화 검사 완료!"
