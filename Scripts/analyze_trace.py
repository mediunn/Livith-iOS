#!/usr/bin/env python3
"""
Instruments Trace 분석 스크립트
.trace 파일을 분석하여 SwiftUI View 업데이트 및 Hang 리포트를 생성합니다.

주요 기능:
- 프레임 데드라인 기반 히치 위험도 분석
- 불필요한 업데이트 패턴 감지
- View 타입별 맞춤 원인 분석 및 개선 방안 제시

사용법:
    python3 analyze_trace.py                     # GUI로 파일 선택
    python3 analyze_trace.py <trace_file_path>   # 직접 파일 지정
    python3 analyze_trace.py <trace_file_path> <output_path>
"""

import subprocess
import xml.etree.ElementTree as ET
import sys
import os
import tempfile
from collections import defaultdict
from datetime import datetime
from pathlib import Path

# 프레임 데드라인 상수
FRAME_DEADLINE_60FPS = 16.67   # 60fps 기준 프레임 마감 시간 (ms)
FRAME_DEADLINE_120FPS = 8.33   # 120fps (ProMotion) 기준 프레임 마감 시간 (ms)

# 히치 심각도 임계값 (ms)
HITCH_THRESHOLD_MICRO = 100    # micro hang: 100ms ~ 250ms
HITCH_THRESHOLD_MINOR = 250    # minor hang: 250ms ~ 500ms
HITCH_THRESHOLD_MAJOR = 500    # major hang: 500ms 이상

# View Body 업데이트 위험도 임계값 (ms)
VIEW_UPDATE_WARNING = 4.0      # 경고: 프레임 예산의 ~25%
VIEW_UPDATE_CAUTION = 8.0      # 주의: 프레임 예산의 ~50%
VIEW_UPDATE_CRITICAL = 16.0    # 위험: 프레임 예산 초과

# 불필요한 업데이트 감지 임계값
EXCESSIVE_UPDATE_THRESHOLD = 50  # 과도한 업데이트 횟수 기준

# Time Profiler 관련 상수
SAMPLE_INTERVAL_US = 100  # 샘플링 간격 (마이크로초)
APP_CODE_ADDRESS_THRESHOLD = 0x200000000  # 앱 코드 주소 범위 상한 (대략적)

# 주소 범위별 모듈 추정 (ARM64 iOS, ASLR 적용 후 대략적 범위)
ADDRESS_RANGES = {
    "app": (0x100000000, 0x200000000),       # 앱 코드
    "dyld": (0x1FC000000, 0x200000000),      # dyld
    "system": (0x180000000, 0x1FC000000),    # 시스템 프레임워크
    "objc": (0x1A0000000, 0x1B0000000),      # Objective-C 런타임
}

# 신뢰도 레벨
CONFIDENCE_HIGH = "high"      # Time Profiler 샘플로 확인됨
CONFIDENCE_MEDIUM = "medium"  # 시간대 겹침 + 패턴 매칭
CONFIDENCE_LOW = "low"        # 시간대 겹침만으로 추정


def get_script_dir() -> Path:
    """스크립트가 위치한 디렉토리 반환"""
    return Path(__file__).parent.resolve()


def get_project_root() -> Path:
    """프로젝트 루트 디렉토리 반환"""
    return get_script_dir().parent


def get_analyze_dir() -> Path:
    """Analyze 디렉토리 반환"""
    return get_project_root() / "Analyze"


def get_result_dir() -> Path:
    """결과 저장 디렉토리 반환"""
    result_dir = get_analyze_dir() / "result"
    result_dir.mkdir(parents=True, exist_ok=True)
    return result_dir


def select_trace_file_gui() -> str:
    """macOS GUI를 사용하여 trace 파일 선택 (리스트 다이얼로그)"""
    trace_files = list_trace_files()

    if not trace_files:
        print("Analyze 폴더에 .trace 파일이 없습니다.")
        return ""

    # 파일 목록을 AppleScript 리스트로 변환
    file_names = [f.name for f in trace_files]
    file_list_str = '", "'.join(file_names)

    applescript = f'''
    set fileList to {{"{file_list_str}"}}
    set selectedItem to choose from list fileList with prompt "분석할 .trace 파일을 선택하세요:" with title "Instruments Trace 분석기"
    if selectedItem is false then
        return ""
    else
        return item 1 of selectedItem
    end if
    '''

    try:
        result = subprocess.run(
            ["osascript", "-e", applescript],
            capture_output=True,
            text=True,
            timeout=300
        )

        if result.returncode == 0:
            selected_name = result.stdout.strip()
            if selected_name:
                # 선택된 파일명으로 전체 경로 찾기
                for trace_file in trace_files:
                    if trace_file.name == selected_name:
                        return str(trace_file)
        return ""
    except subprocess.TimeoutExpired:
        print("파일 선택 시간이 초과되었습니다.")
        return ""
    except Exception as e:
        print(f"파일 선택 중 오류 발생: {e}")
        return ""


def list_trace_files() -> list:
    """Analyze 폴더 내 trace 파일 목록 반환"""
    analyze_dir = get_analyze_dir()
    trace_files = []

    if analyze_dir.exists():
        for item in analyze_dir.iterdir():
            if item.is_dir() and item.suffix == ".trace":
                trace_files.append(item)

    return sorted(trace_files, key=lambda x: x.stat().st_mtime, reverse=True)


def select_trace_file_cli() -> str:
    """CLI에서 trace 파일 선택 (GUI 실패 시 폴백)"""
    trace_files = list_trace_files()

    if not trace_files:
        print("Analyze 폴더에 .trace 파일이 없습니다.")
        return ""

    print("\n사용 가능한 trace 파일:")
    for i, trace_file in enumerate(trace_files, 1):
        mtime = datetime.fromtimestamp(trace_file.stat().st_mtime)
        print(f"  {i}. {trace_file.name} ({mtime.strftime('%Y-%m-%d %H:%M')})")

    while True:
        try:
            choice = input("\n분석할 파일 번호를 입력하세요 (0: 취소): ").strip()
            if choice == "0":
                return ""
            idx = int(choice) - 1
            if 0 <= idx < len(trace_files):
                return str(trace_files[idx])
            else:
                print("잘못된 번호입니다.")
        except ValueError:
            print("숫자를 입력하세요.")
        except KeyboardInterrupt:
            return ""


def run_xctrace_export_to_file(trace_path: str, xpath: str) -> str:
    """xctrace export 실행하여 XML 파일로 저장"""
    with tempfile.NamedTemporaryFile(suffix=".xml", delete=False) as tmp:
        tmp_path = tmp.name

    # shell=True와 리디렉션 사용 (대용량 파일에서 안정적)
    cmd = f'xctrace export --input "{trace_path}" --xpath \'{xpath}\' > "{tmp_path}" 2>/dev/null'
    try:
        # 대용량 trace 파일은 시간이 오래 걸릴 수 있음
        result = subprocess.run(cmd, shell=True, timeout=1200)
        if os.path.exists(tmp_path) and os.path.getsize(tmp_path) > 0:
            return tmp_path
    except subprocess.TimeoutExpired:
        print("    xctrace export 타임아웃 (20분 초과)")
    except Exception as e:
        print(f"    xctrace export 오류: {e}")

    if os.path.exists(tmp_path):
        os.unlink(tmp_path)
    return ""


def estimate_module_from_address(address: int) -> str:
    """주소 범위로 모듈 추정"""
    if address == 0:
        return "unknown"

    for module, (start, end) in ADDRESS_RANGES.items():
        if start <= address < end:
            return module

    if address < 0x100000000:
        return "kernel"
    elif address >= 0x200000000:
        return "system"

    return "unknown"


def group_addresses_by_function(addresses: list, threshold: int = 0x100) -> list:
    """
    인접한 주소들을 같은 함수로 그룹화
    threshold: 같은 함수로 간주할 주소 차이 (기본 256바이트)
    """
    if not addresses:
        return []

    sorted_addrs = sorted(set(addresses))
    groups = []
    current_group = [sorted_addrs[0]]

    for addr in sorted_addrs[1:]:
        if addr - current_group[-1] <= threshold:
            current_group.append(addr)
        else:
            groups.append({
                "base": current_group[0],
                "count": len(current_group),
                "range": (current_group[0], current_group[-1]),
                "module": estimate_module_from_address(current_group[0])
            })
            current_group = [addr]

    # 마지막 그룹 추가
    if current_group:
        groups.append({
            "base": current_group[0],
            "count": len(current_group),
            "range": (current_group[0], current_group[-1]),
            "module": estimate_module_from_address(current_group[0])
        })

    return sorted(groups, key=lambda x: x["count"], reverse=True)


def get_actionable_code_example(view_type: str, issue_type: str) -> dict:
    """
    View 타입과 이슈 타입에 따른 구체적인 코드 예시 반환
    """
    examples = {
        ("입력 필드", "slow"): {
            "problem": "TextField 입력마다 View Body 재실행",
            "before": '''struct SearchView: View {
    @Bindable var store: SearchStore

    var body: some View {
        // 매 키 입력마다 전체 View 재렌더링
        TextField("검색", text: $store.searchText)
    }
}''',
            "after": '''struct SearchView: View {
    @Bindable var store: SearchStore
    @State private var localText = ""  // 로컬 상태로 분리

    var body: some View {
        TextField("검색", text: $localText)
            .onSubmit {
                store.send(.search(localText))  // 제출 시에만 Store 업데이트
            }
            .onChange(of: localText) { _, newValue in
                // 디바운싱 적용
                store.send(.updateSearchTextDebounced(newValue))
            }
    }
}''',
            "explanation": "입력값을 로컬 @State로 관리하고, 디바운싱을 적용하여 불필요한 Store 업데이트 방지"
        },
        ("이미지", "slow"): {
            "problem": "이미지 로딩/디코딩이 View Body에서 실행",
            "before": '''struct ConcertCard: View {
    let concert: Concert

    var body: some View {
        KFImage(URL(string: concert.imageURL))
            .resizable()  // 매번 리사이징 발생
    }
}''',
            "after": '''struct ConcertCard: View {
    let concert: Concert

    var body: some View {
        KFImage(URL(string: concert.imageURL))
            .placeholder { ProgressView() }
            .downsampling(size: CGSize(width: 200, height: 200))  // 다운샘플링
            .cacheMemoryOnly()  // 메모리 캐시 우선
            .fade(duration: 0.2)
            .resizable()
    }
}''',
            "explanation": "Kingfisher의 downsampling으로 메모리 최적화, placeholder로 레이아웃 점프 방지"
        },
        ("스크롤/리스트", "excessive"): {
            "problem": "ForEach에서 불안정한 id로 인한 전체 리스트 재생성",
            "before": '''struct ConcertListView: View {
    let concerts: [Concert]

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(concerts, id: \\.self) {  // ❌ 불안정한 id
                    ConcertRow(concert: $0)
                }
            }
        }
    }
}''',
            "after": '''struct ConcertListView: View {
    let concerts: [Concert]

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(concerts, id: \\.id) {  // ✅ 서버 ID 사용
                    ConcertRow(concert: $0)
                }
            }
        }
    }
}

// Concert가 Identifiable 준수
extension Concert: Identifiable {}''',
            "explanation": "안정적인 서버 ID를 사용하여 불필요한 셀 재생성 방지"
        },
        ("버튼", "excessive"): {
            "problem": "ButtonStyle이 매 렌더링마다 재생성",
            "before": '''struct ActionButton: View {
    var body: some View {
        Button("확인") { }
            .buttonStyle(CustomButtonStyle())  // 매번 새 인스턴스
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.gray : Color.blue)
    }
}''',
            "after": '''struct ActionButton: View {
    var body: some View {
        Button("확인") { }
            .buttonStyle(.custom)  // static으로 재사용
    }
}

extension ButtonStyle where Self == CustomButtonStyle {
    static var custom: CustomButtonStyle { CustomButtonStyle() }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.gray : Color.blue)
    }
}''',
            "explanation": "ButtonStyle을 static extension으로 정의하여 인스턴스 재사용"
        },
        ("셀/카드", "excessive"): {
            "problem": "부모 상태 변경이 모든 셀에 전파",
            "before": '''struct ConcertRow: View {
    @Bindable var store: ConcertListStore  // 전체 Store 구독
    let concert: Concert

    var body: some View {
        // store의 어떤 상태가 변경되어도 재렌더링
        Text(concert.title)
    }
}''',
            "after": '''struct ConcertRow: View {
    let concert: Concert
    let onTap: () -> Void

    var body: some View {
        Text(concert.title)
            .onTapGesture(perform: onTap)
    }
}

// Equatable 준수로 실제 변경 시에만 업데이트
extension ConcertRow: Equatable {
    static func == (lhs: ConcertRow, rhs: ConcertRow) -> Bool {
        lhs.concert.id == rhs.concert.id
    }
}''',
            "explanation": "셀에서 Store 직접 구독 제거, Equatable로 불필요한 업데이트 방지"
        },
        ("탭", "slow"): {
            "problem": "탭 전환 시 모든 탭 콘텐츠가 재렌더링",
            "before": '''struct MainTabView: View {
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            HomeView()      // 항상 body 실행
            SearchView()    // 항상 body 실행
            ProfileView()   // 항상 body 실행
        }
    }
}''',
            "after": '''struct MainTabView: View {
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            LazyView { HomeView() }
                .tag(0)
            LazyView { SearchView() }
                .tag(1)
            LazyView { ProfileView() }
                .tag(2)
        }
    }
}

// 지연 로딩 래퍼
struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @escaping () -> Content) { self.build = build }
    var body: Content { build() }
}''',
            "explanation": "LazyView로 선택된 탭만 렌더링하여 불필요한 View 생성 방지"
        },
    }

    # 기본값
    default_example = {
        "problem": "View Body에서 비싼 작업 실행",
        "before": '''var body: some View {
    // 매 렌더링마다 실행
    let formatted = DateFormatter().string(from: date)
    Text(formatted)
}''',
        "after": '''// Formatter를 static으로 캐싱
private static let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy.MM.dd"
    return f
}()

var body: some View {
    Text(Self.dateFormatter.string(from: date))
}''',
        "explanation": "비싼 객체 생성을 static으로 캐싱하여 재사용"
    }

    # issue_type: "slow" (느린 단일 업데이트), "excessive" (과도한 업데이트)
    key = (view_type, issue_type)
    return examples.get(key, default_example)


def calculate_confidence(
    has_time_profiler_match: bool,
    has_view_overlap: bool,
    sample_count: int,
    overlap_ratio: float
) -> tuple:
    """
    분석 결과의 신뢰도 계산

    Returns:
        tuple: (confidence_level, confidence_score, explanation)
    """
    score = 0
    reasons = []

    if has_time_profiler_match and sample_count > 10:
        score += 50
        reasons.append(f"Time Profiler 샘플 {sample_count}개로 확인")

    if has_view_overlap:
        overlap_score = min(30, overlap_ratio * 30)
        score += overlap_score
        reasons.append(f"View 업데이트 시간 {overlap_ratio*100:.0f}% 겹침")

    if sample_count > 50:
        score += 10
        reasons.append("충분한 샘플 수")

    if score >= 70:
        level = CONFIDENCE_HIGH
    elif score >= 40:
        level = CONFIDENCE_MEDIUM
    else:
        level = CONFIDENCE_LOW

    return (level, score, ", ".join(reasons) if reasons else "추정")


def analyze_time_profiler(trace_path: str, hangs: list = None) -> dict:
    """
    Time Profiler 데이터 분석

    Returns:
        dict: {
            "main_thread_samples": [...],      # 메인 스레드 샘플 목록
            "running_ratio": float,            # Running 상태 비율
            "blocked_ratio": float,            # Blocked 상태 비율
            "app_code_ratio": float,           # 앱 코드 실행 비율
            "system_code_ratio": float,        # 시스템 코드 실행 비율
            "hang_analysis": [...],            # Hang별 상세 분석
            "hot_addresses": [...],            # 자주 등장하는 주소 (Top N)
        }
    """
    result = {
        "main_thread_samples": [],
        "running_ratio": 0.0,
        "blocked_ratio": 0.0,
        "app_code_ratio": 0.0,
        "system_code_ratio": 0.0,
        "hang_analysis": [],
        "hot_addresses": [],
        "total_samples": 0,
        "running_samples": 0,
        "blocked_samples": 0,
    }

    tmp_path = run_xctrace_export_to_file(trace_path, '//table[@schema="time-sample"]')
    if not tmp_path:
        return result

    try:
        samples = []
        address_counter = defaultdict(int)
        id_map = {}

        def process_sample_row(row, id_map):
            # 메인 스레드 샘플만 수집
            thread_elem = row.find("thread")
            if thread_elem is None:
                return

            thread_fmt = resolve_ref(thread_elem, id_map)
            if "Main Thread" not in thread_fmt:
                return

            # 타임스탬프 파싱
            time_elem = row.find("sample-time")
            if time_elem is None:
                return

            time_fmt = resolve_ref(time_elem, id_map)
            time_ns = 0
            try:
                time_ns = int(time_elem.text or "0")
            except (ValueError, TypeError):
                pass
            time_ms = time_ns / 1_000_000

            # 스레드 상태
            state_elem = row.find("thread-state")
            state = resolve_ref(state_elem, id_map) if state_elem is not None else "Unknown"

            # 콜스택 (user callstack)
            backtrace_elem = row.find("kperf-bt")
            addresses = []
            top_address = 0
            is_app_code = False

            if backtrace_elem is not None:
                # text-address 요소에서 PC (최상위 주소) 추출
                text_addr = backtrace_elem.find("text-address")
                if text_addr is not None:
                    addr_fmt = resolve_ref(text_addr, id_map)
                    try:
                        top_address = int(text_addr.text or "0")
                    except (ValueError, TypeError):
                        pass

                # text-addresses에서 전체 스택 추출
                text_addrs = backtrace_elem.find("text-addresses")
                if text_addrs is not None:
                    try:
                        addrs_text = text_addrs.text or ""
                        addresses = [int(a) for a in addrs_text.split() if a.isdigit()]
                    except (ValueError, TypeError):
                        pass

                # 앱 코드 여부 판단 (낮은 주소 범위가 앱 코드)
                if top_address > 0 and top_address < APP_CODE_ADDRESS_THRESHOLD:
                    is_app_code = True
                    address_counter[top_address] += 1

            sample = {
                "time_ms": time_ms,
                "time_fmt": time_fmt,
                "state": state,
                "top_address": top_address,
                "addresses": addresses,
                "is_app_code": is_app_code,
            }
            samples.append(sample)

        parse_xml_iteratively(tmp_path, process_sample_row, id_map)

        result["main_thread_samples"] = samples
        result["total_samples"] = len(samples)

        if samples:
            # Running/Blocked 비율 계산
            running_count = sum(1 for s in samples if s["state"] == "Running")
            blocked_count = sum(1 for s in samples if s["state"] == "Blocked")

            result["running_samples"] = running_count
            result["blocked_samples"] = blocked_count
            result["running_ratio"] = running_count / len(samples) * 100
            result["blocked_ratio"] = blocked_count / len(samples) * 100

            # 앱 코드 비율 (Running 상태에서만)
            running_samples = [s for s in samples if s["state"] == "Running"]
            if running_samples:
                app_code_count = sum(1 for s in running_samples if s["is_app_code"])
                result["app_code_ratio"] = app_code_count / len(running_samples) * 100
                result["system_code_ratio"] = 100 - result["app_code_ratio"]

            # Hot addresses (자주 실행되는 주소)
            result["hot_addresses"] = sorted(
                address_counter.items(),
                key=lambda x: x[1],
                reverse=True
            )[:20]

        # Hang 시간대와 샘플 매칭
        if hangs:
            for hang in hangs:
                hang_start = hang.get("start_ms", 0)
                hang_end = hang.get("end_ms", hang_start + hang.get("duration_ms", 0))

                # Hang 시간대의 샘플 필터링
                hang_samples = [
                    s for s in samples
                    if hang_start <= s["time_ms"] <= hang_end
                ]

                if hang_samples:
                    running_in_hang = sum(1 for s in hang_samples if s["state"] == "Running")
                    blocked_in_hang = sum(1 for s in hang_samples if s["state"] == "Blocked")
                    app_code_in_hang = sum(1 for s in hang_samples if s["is_app_code"] and s["state"] == "Running")

                    # Hang 시간대의 hot addresses
                    hang_addr_counter = defaultdict(int)
                    all_hang_addresses = []
                    for s in hang_samples:
                        if s["top_address"] > 0 and s["state"] == "Running":
                            hang_addr_counter[s["top_address"]] += 1
                            all_hang_addresses.append(s["top_address"])

                    # 함수 그룹화 (인접 주소를 같은 함수로 추정)
                    function_groups = group_addresses_by_function(all_hang_addresses)

                    # 모듈별 분류
                    module_counter = defaultdict(int)
                    for s in hang_samples:
                        if s["state"] == "Running" and s["top_address"] > 0:
                            module = estimate_module_from_address(s["top_address"])
                            module_counter[module] += 1

                    # 신뢰도 계산
                    has_view_overlap = bool(hang.get("affected_views"))
                    overlap_ratio = 0.0
                    if has_view_overlap and hang.get("affected_views"):
                        top_view = hang["affected_views"][0]
                        overlap_ratio = top_view.get("overlap_ms", 0) / hang["duration_ms"] if hang["duration_ms"] > 0 else 0

                    confidence_level, confidence_score, confidence_reason = calculate_confidence(
                        has_time_profiler_match=len(hang_samples) > 0,
                        has_view_overlap=has_view_overlap,
                        sample_count=len(hang_samples),
                        overlap_ratio=overlap_ratio
                    )

                    hang_analysis = {
                        "hang_start": hang["start_time"],
                        "hang_duration_ms": hang["duration_ms"],
                        "sample_count": len(hang_samples),
                        "running_count": running_in_hang,
                        "blocked_count": blocked_in_hang,
                        "running_ratio": running_in_hang / len(hang_samples) * 100 if hang_samples else 0,
                        "app_code_count": app_code_in_hang,
                        "hot_addresses": sorted(
                            hang_addr_counter.items(),
                            key=lambda x: x[1],
                            reverse=True
                        )[:10],
                        "function_groups": function_groups[:5],  # 상위 5개 함수 그룹
                        "module_breakdown": dict(module_counter),  # 모듈별 샘플 수
                        "confidence": {
                            "level": confidence_level,
                            "score": confidence_score,
                            "reason": confidence_reason
                        },
                        "diagnosis": "",
                    }

                    # 진단 메시지 생성
                    if hang_analysis["running_ratio"] > 80:
                        if app_code_in_hang > running_in_hang * 0.5:
                            hang_analysis["diagnosis"] = "앱 코드에서 CPU 집약적 작업 실행 중"
                        else:
                            hang_analysis["diagnosis"] = "시스템 프레임워크에서 무거운 작업 실행 중"
                    elif hang_analysis["running_ratio"] < 20:
                        hang_analysis["diagnosis"] = "메인 스레드가 블로킹됨 (I/O, 락 대기 등)"
                    else:
                        hang_analysis["diagnosis"] = "CPU 작업과 블로킹이 혼재"

                    result["hang_analysis"].append(hang_analysis)

    finally:
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)

    return result


def parse_duration_ns(duration_str: str) -> float:
    """나노초 문자열을 밀리초로 변환"""
    try:
        return float(duration_str) / 1_000_000
    except (ValueError, TypeError):
        return 0.0


def parse_fmt_duration(fmt: str) -> float:
    """fmt 속성의 시간 문자열을 밀리초로 변환"""
    if not fmt:
        return 0.0

    fmt = fmt.strip()

    if "ms" in fmt:
        try:
            return float(fmt.replace("ms", "").strip())
        except ValueError:
            return 0.0

    if " s" in fmt and "ms" not in fmt:
        try:
            return float(fmt.replace("s", "").strip()) * 1000
        except ValueError:
            return 0.0

    if "µs" in fmt:
        try:
            return float(fmt.replace("µs", "").strip()) / 1000
        except ValueError:
            return 0.0

    if "ns" in fmt:
        try:
            return float(fmt.replace("ns", "").strip()) / 1_000_000
        except ValueError:
            return 0.0

    return 0.0


def format_time(ms: float) -> str:
    """밀리초를 읽기 쉬운 형식으로 변환"""
    if ms < 0.001:
        return f"{ms * 1000000:.0f}ns"
    elif ms < 1:
        return f"{ms * 1000:.2f}µs"
    elif ms < 1000:
        return f"{ms:.2f}ms"
    else:
        return f"{ms / 1000:.2f}s"


def parse_start_time_to_ms(time_str: str) -> float:
    """
    시작 시간 문자열을 밀리초로 변환
    형식: "00:17.513.991" (분:초.밀리초.마이크로초) 또는 "1.234 s"
    """
    if not time_str:
        return 0.0

    time_str = time_str.strip()

    # "1.234 s" 형식
    if time_str.endswith(" s"):
        try:
            return float(time_str.replace(" s", "")) * 1000
        except ValueError:
            return 0.0

    # "00:17.513.991" 형식 (분:초.밀리초.마이크로초)
    if ":" in time_str:
        try:
            parts = time_str.split(":")
            if len(parts) == 2:
                minutes = int(parts[0])
                sec_parts = parts[1].split(".")
                seconds = int(sec_parts[0])
                ms = int(sec_parts[1]) if len(sec_parts) > 1 else 0
                # 마이크로초는 무시 (정밀도 충분)
                total_ms = minutes * 60 * 1000 + seconds * 1000 + ms
                return float(total_ms)
        except (ValueError, IndexError):
            return 0.0

    return 0.0


def extract_view_name(name: str) -> str:
    """View 이름에서 핵심 부분만 추출"""
    if not name:
        return "Unknown"

    if name.endswith(".body"):
        name = name[:-5]

    if "<" in name:
        name = name.split("<")[0]

    if " in " in name:
        name = name.split(" in ")[0]

    return name.strip()


def get_hitch_risk_level(duration_ms: float) -> tuple:
    """
    프레임 데드라인 기반 히치 위험도 분석

    Returns:
        tuple: (위험도 레벨, 설명, 이모지)
    """
    if duration_ms >= VIEW_UPDATE_CRITICAL:
        return ("critical", "프레임 데드라인 초과 - 히치 발생 확실", "🔴")
    elif duration_ms >= VIEW_UPDATE_CAUTION:
        return ("warning", "프레임 예산 50% 초과 - 히치 위험 높음", "🟠")
    elif duration_ms >= VIEW_UPDATE_WARNING:
        return ("caution", "프레임 예산 25% 초과 - 주의 필요", "🟡")
    else:
        return ("normal", "정상 범위", "🟢")


def analyze_update_pattern(views: dict) -> dict:
    """
    불필요한 업데이트 패턴 분석

    Returns:
        dict: 패턴 분석 결과
    """
    patterns = {
        "excessive_updates": [],      # 과도한 업데이트 (Observable 종속성 문제 의심)
        "slow_single_updates": [],    # 느린 단일 업데이트 (View Body 내 비싼 작업)
        "high_total_time": [],        # 총 시간 소비가 높은 View
        "potential_observable_issue": [],  # Observable 종속성 문제 의심
    }

    for name, data in views.items():
        count = data["count"]
        max_ms = data["max_ms"]
        total_ms = data["total_ms"]
        avg_ms = total_ms / count if count > 0 else 0

        # 과도한 업데이트 감지
        if count >= EXCESSIVE_UPDATE_THRESHOLD:
            patterns["excessive_updates"].append({
                "name": name,
                "count": count,
                "avg_ms": avg_ms,
                "total_ms": total_ms,
                "cause": "Observable 또는 Environment 종속성 문제 의심"
            })

        # 느린 단일 업데이트 감지
        if max_ms >= VIEW_UPDATE_WARNING:
            risk_level, risk_desc, _ = get_hitch_risk_level(max_ms)
            patterns["slow_single_updates"].append({
                "name": name,
                "max_ms": max_ms,
                "risk_level": risk_level,
                "risk_desc": risk_desc,
                "cause": "View Body 내 비싼 작업 (Formatter 생성, 복잡한 계산 등)"
            })

        # 총 시간 소비가 높은 View
        if total_ms >= 50:  # 50ms 이상
            patterns["high_total_time"].append({
                "name": name,
                "total_ms": total_ms,
                "count": count,
                "avg_ms": avg_ms
            })

        # Observable 종속성 문제 의심 (업데이트 많고 평균 시간이 짧은 경우)
        if count >= 20 and avg_ms < 1.0:
            patterns["potential_observable_issue"].append({
                "name": name,
                "count": count,
                "avg_ms": avg_ms,
                "cause": "광범위한 데이터 종속성으로 인한 불필요한 업데이트"
            })

    return patterns


def get_view_type_hint(view_name: str) -> dict:
    """
    View 이름을 분석하여 타입별 맞춤 원인과 해결책 반환
    """
    name_lower = view_name.lower()

    # Tab 관련 (우선순위 높음 - "TabView", "SetlistTabView" 등)
    if "tab" in name_lower and "table" not in name_lower:
        return {
            "type": "탭",
            "causes": [
                "탭 전환 시 모든 탭 콘텐츠가 재렌더링",
                "선택되지 않은 탭도 body가 실행",
                "탭 인디케이터 애니메이션 과부하"
            ],
            "solutions": [
                "LazyView로 탭 콘텐츠 지연 로딩",
                "선택된 탭만 활성화하는 조건부 렌더링",
                "@StateObject로 탭별 상태 유지"
            ]
        }

    # TextField / TextEditor 관련
    if "textfield" in name_lower or "texteditor" in name_lower or "input" in name_lower:
        return {
            "type": "입력 필드",
            "causes": [
                "키 입력마다 전체 View 재렌더링",
                "입력값 바인딩이 상위 Store까지 전파",
                "실시간 유효성 검사가 body에서 실행"
            ],
            "solutions": [
                "입력 디바운싱 적용 (300ms 권장)",
                "로컬 @State로 입력값 관리 후 onSubmit에서 Store 업데이트",
                "유효성 검사를 onChange에서 비동기로 처리"
            ]
        }

    # Image / KFImage 관련
    if "image" in name_lower or "kfimage" in name_lower or "kingfisher" in name_lower:
        return {
            "type": "이미지",
            "causes": [
                "이미지 다운로드/디코딩이 메인 스레드에서 실행",
                "캐시 미스로 인한 반복 로딩",
                "이미지 리사이징이 body에서 발생"
            ],
            "solutions": [
                "Kingfisher의 downsample 옵션으로 메모리 최적화",
                "placeholder 이미지로 레이아웃 점프 방지",
                "스크롤 중 이미지 로딩 우선순위 조정"
            ]
        }

    # List / ScrollView 관련
    if "list" in name_lower or "scroll" in name_lower or "lazy" in name_lower:
        return {
            "type": "스크롤/리스트",
            "causes": [
                "id() 변경으로 인한 전체 리스트 재생성",
                "비효율적인 ForEach 식별자 사용",
                "스크롤 중 불필요한 셀 재렌더링"
            ],
            "solutions": [
                "안정적인 id 사용 (UUID보다 서버 ID 권장)",
                "LazyVStack/LazyHStack으로 지연 로딩",
                "셀 내부 상태를 @StateObject로 분리"
            ]
        }

    # Button 관련
    if "button" in name_lower:
        return {
            "type": "버튼",
            "causes": [
                "ButtonStyle이 매 렌더링마다 재생성",
                "버튼 내부 View가 상위 상태에 종속",
                "disabled 상태 계산이 body에서 실행"
            ],
            "solutions": [
                "커스텀 ButtonStyle을 struct로 정의하여 재사용",
                "버튼 액션을 클로저 캡처 최소화",
                "disabled 조건을 computed property로 분리"
            ]
        }

    # Card / Cell 관련
    if "card" in name_lower or "cell" in name_lower or "row" in name_lower or "item" in name_lower:
        return {
            "type": "셀/카드",
            "causes": [
                "부모 리스트의 상태 변경이 모든 셀에 전파",
                "셀마다 개별 네트워크 요청 발생",
                "복잡한 레이아웃 계산이 반복 실행"
            ],
            "solutions": [
                "셀별 ViewModel 분리로 업데이트 격리",
                "Equatable 준수로 실제 변경 시에만 업데이트",
                "레이아웃을 고정 크기로 단순화"
            ]
        }

    # 기본값
    return None


def get_root_cause_analysis(view_name: str, data: dict) -> list:
    """
    View 타입과 패턴을 분석하여 맞춤 원인 및 해결책 제시
    """
    causes = []
    count = data["count"]
    max_ms = data["max_ms"]
    total_ms = data["total_ms"]
    avg_ms = total_ms / count if count > 0 else 0

    # View 타입별 힌트 가져오기
    type_hint = get_view_type_hint(view_name)

    # 1. 긴 View Body 업데이트 분석
    if max_ms >= VIEW_UPDATE_CRITICAL:
        cause_entry = {
            "type": "긴 View Body 업데이트",
            "severity": "critical",
            "description": f"단일 업데이트가 {max_ms:.2f}ms로 프레임 데드라인({FRAME_DEADLINE_60FPS}ms) 초과",
            "possible_causes": [],
            "solutions": []
        }

        if type_hint:
            cause_entry["possible_causes"] = type_hint["causes"]
            cause_entry["solutions"] = type_hint["solutions"]
        else:
            cause_entry["possible_causes"] = [
                "View Body 내에서 Formatter 객체 생성",
                "복잡한 계산이 body에서 직접 실행",
                "동기적 데이터 변환 작업"
            ]
            cause_entry["solutions"] = [
                "비싼 작업을 ViewModel로 이동",
                "Formatter를 static으로 캐싱",
                "계산 결과를 @State로 캐싱"
            ]

        causes.append(cause_entry)

    elif max_ms >= VIEW_UPDATE_CAUTION:
        cause_entry = {
            "type": "View Body 실행 시간 주의",
            "severity": "warning",
            "description": f"단일 업데이트가 {max_ms:.2f}ms로 프레임 예산의 50% 초과",
            "possible_causes": [],
            "solutions": []
        }

        if type_hint:
            cause_entry["possible_causes"] = type_hint["causes"][:2]
            cause_entry["solutions"] = type_hint["solutions"][:2]
        else:
            cause_entry["possible_causes"] = [
                "View Body 내 중간 복잡도의 계산",
                "반복되는 String 포맷팅"
            ]
            cause_entry["solutions"] = [
                "복잡한 로직을 ViewModel로 분리",
                "@State로 계산 결과 캐싱"
            ]

        causes.append(cause_entry)

    # 2. 과도한 업데이트 분석
    if count >= EXCESSIVE_UPDATE_THRESHOLD:
        cause_entry = {
            "type": "과도한 View 업데이트",
            "severity": "warning" if count < 100 else "critical",
            "description": f"{count}회 업데이트 - 불필요한 재렌더링 의심",
            "possible_causes": [],
            "solutions": []
        }

        if type_hint:
            cause_entry["possible_causes"] = [
                f"{type_hint['type']} 관련: {type_hint['causes'][0]}" if type_hint['causes'] else "상위 상태 변경이 전파"
            ]
            cause_entry["possible_causes"].append("@Observable의 광범위한 속성 종속")
            cause_entry["solutions"] = type_hint["solutions"][:2] if type_hint["solutions"] else []
            cause_entry["solutions"].append("Equatable 준수로 실제 변경 시에만 업데이트")
        else:
            cause_entry["possible_causes"] = [
                "상위 View 상태 변경이 하위로 전파",
                "@Observable의 광범위한 속성 종속",
                "Environment 값의 빈번한 변경"
            ]
            cause_entry["solutions"] = [
                "View별 개별 ViewModel로 종속성 분리",
                "Equatable 준수로 불필요한 업데이트 방지",
                "데이터 모델을 뷰별로 분리"
            ]

        causes.append(cause_entry)

    # 3. 총 시간 소비 분석
    if total_ms >= 100:
        causes.append({
            "type": "높은 총 시간 소비",
            "severity": "warning",
            "description": f"총 {total_ms:.2f}ms 소비 ({count}회, 평균 {avg_ms:.2f}ms)",
            "possible_causes": [
                f"{'빈번한 업데이트' if count > 50 else '느린 개별 업데이트'}가 주요 원인",
                "스크롤 중 반복적인 View 재생성"
            ],
            "solutions": [
                f"{'업데이트 빈도 줄이기' if count > 50 else '개별 업데이트 속도 개선'} 우선",
                "onAppear/onDisappear에서 상태 변경 최소화"
            ]
        })

    return causes


def parse_xml_iteratively(xml_file: str, callback, id_map: dict = None):
    """대용량 XML을 iterparse로 처리 (ref 참조 해결 지원)"""
    import re

    if id_map is None:
        id_map = {}

    row_count = 0
    try:
        context = ET.iterparse(xml_file, events=("end",))
        for event, elem in context:
            # id 속성을 가진 모든 요소를 id_map에 저장 (ref 참조 해결용)
            elem_id = elem.get("id")
            if elem_id:
                id_map[elem_id] = {
                    "fmt": elem.get("fmt", ""),
                    "text": elem.text or ""
                }

            if elem.tag == "row":
                callback(elem, id_map)
                row_count += 1
                elem.clear()
        return row_count
    except ET.ParseError as e:
        print(f"XML 파싱 에러 발생 (line {e.position[0]}), 복구 모드로 전환...")

    # 에러 발생 시 라인 단위로 파싱 시도
    try:
        with open(xml_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()

        # <row>...</row> 패턴 추출
        row_pattern = re.compile(r'<row[^>]*>.*?</row>', re.DOTALL)
        matches = row_pattern.findall(content)

        for match in matches:
            try:
                elem = ET.fromstring(match)
                # id 속성 수집
                for child in elem.iter():
                    child_id = child.get("id")
                    if child_id:
                        id_map[child_id] = {
                            "fmt": child.get("fmt", ""),
                            "text": child.text or ""
                        }
                callback(elem, id_map)
                row_count += 1
            except ET.ParseError:
                continue

        print(f"복구 모드로 {row_count}개 row 파싱 완료")
    except Exception as e:
        print(f"복구 모드 실패: {e}")

    return row_count


def resolve_ref(elem, id_map: dict, attr: str = "fmt") -> str:
    """ref 속성을 해결하여 실제 값 반환"""
    if elem is None:
        return ""

    # 직접 fmt 속성이 있으면 반환
    fmt = elem.get("fmt")
    if fmt:
        return fmt

    # ref 속성이 있으면 id_map에서 찾기
    ref = elem.get("ref")
    if ref and ref in id_map:
        return id_map[ref].get(attr, "")

    return ""


def analyze_all_data(trace_path: str) -> tuple:
    """모든 데이터를 한 번의 export로 분석 (//table xpath 사용, ref 참조 해결)"""
    views = defaultdict(lambda: {"count": 0, "total_ms": 0.0, "max_ms": 0.0, "module": ""})
    hangs = []
    # View 업데이트 시간 기록 (Hang 발생 시 View 매칭용)
    view_updates_timeline = []  # [(start_ns, duration_ns, view_name), ...]
    lifecycle = {
        "process_creation": 0,
        "system_init": 0,
        "static_init": 0,
        "uikit_init": 0,
        "scene_creation": 0,
        "initial_frame": 0,
        "total_launch": 0
    }

    # View Body Updates의 id를 추적 (ref 참조 해결용)
    view_body_update_ids = set()

    # 모든 테이블을 한 번에 export
    tmp_path = run_xctrace_export_to_file(trace_path, '//table')
    if not tmp_path:
        return dict(views), hangs, lifecycle

    try:
        def process_row(row, id_map):
            # 1. SwiftUI View Body Updates 분석
            swiftui_update = row.find("swiftui-update")
            if swiftui_update is not None:
                # fmt 또는 ref를 통해 update type 확인
                update_type = resolve_ref(swiftui_update, id_map)

                # View Body Updates ID 추적
                update_id = swiftui_update.get("id")
                if update_id and "View Body" in update_type:
                    view_body_update_ids.add(update_id)

                # ref로 참조되는 경우도 View Body Updates로 처리
                ref_id = swiftui_update.get("ref")
                is_view_body = "View Body" in update_type or ref_id in view_body_update_ids

                if is_view_body:
                    # duration 추출
                    duration_elem = row.find("duration")
                    duration_ms = 0.0
                    if duration_elem is not None:
                        duration_fmt = resolve_ref(duration_elem, id_map)
                        duration_ms = parse_fmt_duration(duration_fmt)
                        if duration_ms == 0:
                            duration_ms = parse_duration_ns(duration_elem.text or "0")

                    # View 이름 추출 (첫 번째 string이 보통 description)
                    view_name = None
                    module = ""

                    strings = row.findall("string")
                    for string_elem in strings:
                        fmt = resolve_ref(string_elem, id_map)
                        if not fmt:
                            continue

                        # .body로 끝나는 것이 View description (예: "AppRootView.body")
                        if ".body" in fmt and not view_name:
                            view_name = fmt
                        # 모듈 이름
                        elif ".dylib" in fmt or fmt.startswith("Livith") or fmt == "LivithDesignSystem":
                            module = fmt
                        # View 또는 Modifier가 포함된 이름
                        elif ("View" in fmt or "Modifier" in fmt) and not view_name:
                            view_name = fmt

                    if view_name:
                        clean_name = extract_view_name(view_name)
                        views[clean_name]["count"] += 1
                        views[clean_name]["total_ms"] += duration_ms
                        views[clean_name]["max_ms"] = max(views[clean_name]["max_ms"], duration_ms)
                        if module and not views[clean_name]["module"]:
                            views[clean_name]["module"] = module

                        # View 업데이트 타임라인 기록 (Hang 매칭용)
                        start_time_elem = row.find("start-time")
                        if start_time_elem is not None:
                            start_fmt = resolve_ref(start_time_elem, id_map)
                            start_ms = parse_start_time_to_ms(start_fmt)
                            if start_ms > 0 and duration_ms > 0:
                                view_updates_timeline.append({
                                    "start_ms": start_ms,
                                    "duration_ms": duration_ms,
                                    "end_ms": start_ms + duration_ms,
                                    "view_name": clean_name
                                })

            # 2. Life Cycle 분석
            app_period = row.find("app-period")
            if app_period is not None:
                period_name = resolve_ref(app_period, id_map)
                duration_elem = row.find("duration")

                if duration_elem is not None:
                    duration_fmt = resolve_ref(duration_elem, id_map)
                    duration_ms = parse_fmt_duration(duration_fmt)

                    if "Process Creation" in period_name:
                        lifecycle["process_creation"] = max(lifecycle["process_creation"], duration_ms)
                    elif "System Interface Initialization" in period_name:
                        lifecycle["system_init"] = max(lifecycle["system_init"], duration_ms)
                    elif "Static Runtime Initialization" in period_name:
                        lifecycle["static_init"] = max(lifecycle["static_init"], duration_ms)
                    elif "UIKit Initialization" in period_name:
                        lifecycle["uikit_init"] = max(lifecycle["uikit_init"], duration_ms)
                    elif "UIKit Scene Creation" in period_name:
                        lifecycle["scene_creation"] += duration_ms
                    elif "Initial Frame Rendering" in period_name:
                        lifecycle["initial_frame"] = max(lifecycle["initial_frame"], duration_ms)

            # 3. Hang 분석 (narrative 요소)
            narrative = row.find("narrative")
            if narrative is not None:
                narrative_text = resolve_ref(narrative, id_map)
                duration_elem = row.find("duration")

                if duration_elem is not None and "took" in narrative_text.lower():
                    duration_fmt = resolve_ref(duration_elem, id_map)
                    duration_ms = parse_fmt_duration(duration_fmt)

                    if duration_ms >= 100:
                        start_time = row.find("start-time")
                        start_fmt = resolve_ref(start_time, id_map) if start_time is not None else "00:00.000"

                        severity = "micro"
                        if duration_ms >= 500:
                            severity = "major"
                        elif duration_ms >= 250:
                            severity = "minor"

                        # 시작 시간을 밀리초로 변환 (View 매칭용)
                        start_ms = parse_start_time_to_ms(start_fmt)

                        # app-period에서 실제 원인 추출
                        app_period_elem = row.find("app-period")
                        cause = ""
                        if app_period_elem is not None:
                            cause = resolve_ref(app_period_elem, id_map)

                        # 중복 체크
                        is_dup = any(h["start_time"] == start_fmt and abs(h["duration_ms"] - duration_ms) < 1 for h in hangs)
                        if not is_dup:
                            hangs.append({
                                "start_time": start_fmt,
                                "start_ms": start_ms,
                                "end_ms": start_ms + duration_ms,
                                "duration_ms": duration_ms,
                                "severity": severity,
                                "description": narrative_text,
                                "cause": cause,  # 실제 원인 (app-period)
                                "affected_views": []  # 나중에 채워짐
                            })

        # id_map을 공유하여 ref 참조 해결
        id_map = {}
        parse_xml_iteratively(tmp_path, process_row, id_map)

    finally:
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)

    lifecycle["total_launch"] = sum([
        lifecycle["process_creation"],
        lifecycle["system_init"],
        lifecycle["static_init"],
        lifecycle["uikit_init"],
        lifecycle["scene_creation"],
        lifecycle["initial_frame"]
    ])

    # Hitches 스키마에서 런타임 Hang 추출 (100ms 이상)
    hitches_tmp = run_xctrace_export_to_file(
        trace_path,
        '/trace-toc/run[@number="1"]/data/table[@schema="hitches"]'
    )
    if hitches_tmp:
        try:
            hitch_id_map = {}

            def process_hitch_row(row, id_map):
                # start-time, duration 추출
                start_time_elem = row.find("start-time")
                duration_elem = row.find("duration")
                narrative_elem = row.find("narrative-description")

                if start_time_elem is not None and duration_elem is not None:
                    start_fmt = resolve_ref(start_time_elem, id_map)
                    duration_fmt = resolve_ref(duration_elem, id_map)
                    duration_ms = parse_fmt_duration(duration_fmt)
                    narrative = resolve_ref(narrative_elem, id_map) if narrative_elem is not None else "Hitch"

                    # 100ms 이상의 Hitch만 Hang으로 추가
                    if duration_ms >= 100:
                        start_ms = parse_start_time_to_ms(start_fmt)

                        severity = "micro"
                        if duration_ms >= 500:
                            severity = "major"
                        elif duration_ms >= 250:
                            severity = "minor"

                        # 중복 체크 (기존 hangs와 비교)
                        is_dup = any(
                            abs(h["start_ms"] - start_ms) < 100 and abs(h["duration_ms"] - duration_ms) < 50
                            for h in hangs
                        )
                        if not is_dup:
                            hangs.append({
                                "start_time": start_fmt,
                                "start_ms": start_ms,
                                "end_ms": start_ms + duration_ms,
                                "duration_ms": duration_ms,
                                "severity": severity,
                                "description": f"Brief Unresponsiveness - {narrative}",
                                "cause": "",  # 런타임 Hang은 cause 없음
                                "affected_views": []
                            })

            parse_xml_iteratively(hitches_tmp, process_hitch_row, hitch_id_map)
        finally:
            if os.path.exists(hitches_tmp):
                os.unlink(hitches_tmp)

    # Hang 발생 시간대와 View 업데이트 매칭
    for hang in hangs:
        hang_start = hang["start_ms"]
        hang_end = hang["end_ms"]
        affected = []

        for update in view_updates_timeline:
            # View 업데이트가 Hang 시간대와 겹치는지 확인
            # 겹치는 조건: update_start < hang_end AND update_end > hang_start
            if update["start_ms"] < hang_end and update["end_ms"] > hang_start:
                # 겹치는 시간 계산
                overlap_start = max(update["start_ms"], hang_start)
                overlap_end = min(update["end_ms"], hang_end)
                overlap_ms = overlap_end - overlap_start

                affected.append({
                    "view_name": update["view_name"],
                    "update_duration_ms": update["duration_ms"],
                    "overlap_ms": overlap_ms
                })

        # 겹치는 시간 기준으로 정렬 (가장 많이 겹치는 View가 원인일 가능성 높음)
        affected.sort(key=lambda x: x["overlap_ms"], reverse=True)
        hang["affected_views"] = affected[:10]  # 상위 10개만 유지

    return dict(views), hangs, lifecycle


def get_trace_info(trace_path: str) -> dict:
    """Trace 파일 메타데이터 추출"""
    info = {
        "file_name": os.path.basename(trace_path),
        "file_size": 0,
        "analysis_date": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "device": "Unknown"
    }

    if os.path.exists(trace_path):
        if os.path.isdir(trace_path):
            total_size = 0
            for dirpath, dirnames, filenames in os.walk(trace_path):
                for f in filenames:
                    fp = os.path.join(dirpath, f)
                    total_size += os.path.getsize(fp)
            info["file_size"] = total_size
        else:
            info["file_size"] = os.path.getsize(trace_path)

    return info


def generate_markdown_report(trace_path: str, hangs: list, views: dict, lifecycle: dict, time_profiler: dict = None) -> str:
    """마크다운 리포트 생성"""
    info = get_trace_info(trace_path)
    if time_profiler is None:
        time_profiler = {}

    report = []
    report.append("# Instruments Trace 분석 리포트\n")
    report.append(f"- **파일**: {info['file_name']}")
    report.append(f"- **분석일**: {info['analysis_date']}")
    report.append(f"- **파일 크기**: {info['file_size'] / 1024 / 1024:.1f} MB")
    report.append("\n---\n")

    # 요약 섹션
    report.append("## 📊 분석 요약\n")
    if views:
        total_updates = sum(v["count"] for v in views.values())
        total_time = sum(v["total_ms"] for v in views.values())
        critical_views = len([v for v in views.values() if v["max_ms"] >= VIEW_UPDATE_CRITICAL])
        warning_views = len([v for v in views.values() if VIEW_UPDATE_CAUTION <= v["max_ms"] < VIEW_UPDATE_CRITICAL])
        excessive_views = len([v for v in views.values() if v["count"] >= EXCESSIVE_UPDATE_THRESHOLD])

        report.append(f"| 지표 | 값 |")
        report.append(f"|------|-----|")
        report.append(f"| 총 View 업데이트 | {total_updates}회 |")
        report.append(f"| 총 소요 시간 | {format_time(total_time)} |")
        report.append(f"| 🔴 프레임 초과 View | {critical_views}개 |")
        report.append(f"| 🟠 주의 필요 View | {warning_views}개 |")
        report.append(f"| ⚠️ 과도한 업데이트 View | {excessive_views}개 |")
        report.append(f"| Hang 발생 | {len(hangs)}건 |")
    report.append("\n---\n")

    # 앱 시작 분석
    if lifecycle["total_launch"] > 0:
        report.append("## 1. 앱 시작 분석\n")
        report.append(f"**총 시작 시간**: {format_time(lifecycle['total_launch'])}\n")
        report.append("| 단계 | 소요 시간 |")
        report.append("|------|-----------|")
        if lifecycle["process_creation"] > 0:
            report.append(f"| Process Creation | {format_time(lifecycle['process_creation'])} |")
        if lifecycle["system_init"] > 0:
            report.append(f"| System Interface Init | {format_time(lifecycle['system_init'])} |")
        if lifecycle["static_init"] > 0:
            report.append(f"| Static Runtime Init | {format_time(lifecycle['static_init'])} |")
        if lifecycle["uikit_init"] > 0:
            report.append(f"| UIKit Initialization | {format_time(lifecycle['uikit_init'])} |")
        if lifecycle["scene_creation"] > 0:
            report.append(f"| Scene Creation | {format_time(lifecycle['scene_creation'])} |")
        if lifecycle["initial_frame"] > 0:
            report.append(f"| Initial Frame Rendering | {format_time(lifecycle['initial_frame'])} |")
        report.append("\n---\n")

    # Hang 섹션
    report.append("## 2. Hang 분석\n")
    if hangs:
        report.append(f"총 **{len(hangs)}건**의 Hang이 감지되었습니다.\n")

        # 기본 테이블
        report.append("| 시작 시간 | 지속 시간 | 심각도 | 원인 |")
        report.append("|-----------|-----------|--------|------|")
        for hang in hangs:
            severity_emoji = "🔴" if hang["severity"] == "major" else "🟠" if hang["severity"] == "minor" else "🟡"

            # 원인 결정: app-period > affected_views > 알 수 없음
            cause = hang.get("cause", "")
            affected = hang.get("affected_views", [])

            if cause:
                # app-period가 있으면 간략하게 표시
                cause_short = cause.replace("Initializing - ", "").replace("Foreground - ", "")
                cause_info = cause_short
            elif affected:
                top_view = affected[0]["view_name"]
                view_count = len(affected)
                cause_info = f"{top_view}" + (f" 외 {view_count-1}개" if view_count > 1 else "")
            else:
                cause_info = "알 수 없음"

            report.append(f"| {hang['start_time']} | {format_time(hang['duration_ms'])} | {severity_emoji} {hang['severity']} | {cause_info} |")
        report.append("")

        # 각 Hang별 상세 분석
        report.append("### 2.1 Hang 상세 분석\n")

        for i, hang in enumerate(hangs, 1):
            severity_emoji = "🔴" if hang["severity"] == "major" else "🟠" if hang["severity"] == "minor" else "🟡"
            report.append(f"#### {severity_emoji} Hang #{i} ({hang['start_time']}, {format_time(hang['duration_ms'])})\n")

            cause = hang.get("cause", "")
            affected = hang.get("affected_views", [])

            # 앱 시작/시스템 관련 Hang인 경우
            if cause:
                report.append(f"**원인**: {cause}\n")

                if "Process Creation" in cause:
                    report.append("- 시스템이 앱 프로세스를 생성하는 단계")
                    report.append("- dyld가 앱과 의존성 프레임워크를 로드")
                    report.append("")
                    report.append("**개선 방안**:")
                    report.append("- 불필요한 프레임워크 의존성 제거")
                    report.append("- Static linking으로 dylib 수 줄이기")
                    report.append("- +load 메서드 사용 최소화")

                elif "System Interface Initialization" in cause:
                    report.append("- 시스템 프레임워크 초기화 단계")
                    report.append("- UIKit, Foundation 등 기본 프레임워크 설정")
                    report.append("")
                    report.append("**개선 방안**:")
                    report.append("- AppDelegate/SceneDelegate 초기화 로직 최소화")
                    report.append("- 무거운 초기화를 lazy loading으로 변경")

                elif "Static Runtime Initialization" in cause:
                    report.append("- Swift/ObjC 런타임 초기화 단계")
                    report.append("- 정적 초기화 코드 실행")
                    report.append("")
                    report.append("**개선 방안**:")
                    report.append("- static let 초기화를 lazy로 변경")
                    report.append("- 전역 변수 초기화 최소화")

                elif "UIKit Initialization" in cause:
                    report.append("- UIKit 프레임워크 초기화 단계")
                    report.append("")
                    report.append("**개선 방안**:")
                    report.append("- 앱 시작 시 생성하는 UI 컴포넌트 최소화")

                elif "Scene Creation" in cause:
                    report.append("- Scene 및 Window 생성 단계")
                    report.append("")
                    report.append("**개선 방안**:")
                    report.append("- 초기 화면 복잡도 줄이기")
                    report.append("- 불필요한 View 지연 로딩")

                elif "Initial Frame Rendering" in cause:
                    report.append("- 첫 화면 렌더링 단계")
                    report.append("")
                    report.append("**개선 방안**:")
                    report.append("- 초기 화면의 View 계층 단순화")
                    report.append("- 이미지/데이터 로딩을 비동기로 처리")

                else:
                    report.append(f"- {hang.get('description', '')}")
                report.append("")

            # View Body 업데이트와 관련된 Hang인 경우
            elif affected:
                report.append("**관련 View Body 업데이트**:\n")
                report.append("| View | 업데이트 시간 | Hang과 겹친 시간 |")
                report.append("|------|--------------|-----------------|")
                for view in affected[:5]:
                    report.append(f"| {view['view_name']} | {format_time(view['update_duration_ms'])} | {format_time(view['overlap_ms'])} |")
                report.append("")

                top_view = affected[0]
                if top_view["overlap_ms"] > 10:
                    type_hint = get_view_type_hint(top_view["view_name"])
                    report.append(f"**🎯 의심 원인**: `{top_view['view_name']}`")
                    report.append(f"- Hang 시간 중 {format_time(top_view['overlap_ms'])} 차지")
                    if type_hint:
                        report.append(f"- View 타입: {type_hint['type']}")
                        report.append(f"- 가능한 원인: {type_hint['causes'][0]}")
                    report.append("")

            # 원인을 알 수 없는 경우
            else:
                report.append("**원인**: 알 수 없음\n")
                report.append("- View Body 업데이트 시간대와 겹치지 않음")
                report.append("- 가능한 원인: 네트워크 요청, 디스크 I/O, 백그라운드 작업")
                report.append("")

        report.append("> **Hang 심각도 기준**: 🟡 micro (100~250ms) / 🟠 minor (250~500ms) / 🔴 major (500ms+)")
    else:
        report.append("✅ Hang이 감지되지 않았습니다.")
    report.append("\n---\n")

    # Time Profiler 섹션
    report.append("## 3. Time Profiler 분석\n")

    if time_profiler.get("total_samples", 0) > 0:
        report.append("### 3.1 메인 스레드 상태 분포\n")
        report.append("| 상태 | 샘플 수 | 비율 |")
        report.append("|------|---------|------|")
        report.append(f"| 🟢 Running | {time_profiler['running_samples']} | {time_profiler['running_ratio']:.1f}% |")
        report.append(f"| 🔴 Blocked | {time_profiler['blocked_samples']} | {time_profiler['blocked_ratio']:.1f}% |")
        report.append(f"| **총 샘플** | **{time_profiler['total_samples']}** | |")
        report.append("")

        # 앱 코드 vs 시스템 코드 비율
        if time_profiler.get("app_code_ratio", 0) > 0 or time_profiler.get("system_code_ratio", 0) > 0:
            report.append("### 3.2 CPU 실행 위치 분석 (Running 상태)\n")
            report.append("| 실행 위치 | 비율 | 의미 |")
            report.append("|----------|------|------|")
            report.append(f"| 📱 앱 코드 | {time_profiler['app_code_ratio']:.1f}% | 직접 최적화 가능 |")
            report.append(f"| ⚙️ 시스템 프레임워크 | {time_profiler['system_code_ratio']:.1f}% | API 사용 방식 개선 필요 |")
            report.append("")

            if time_profiler['app_code_ratio'] > 60:
                report.append("> 💡 **앱 코드 실행 비율이 높습니다.** 직접적인 코드 최적화가 효과적입니다.")
            elif time_profiler['system_code_ratio'] > 70:
                report.append("> 💡 **시스템 프레임워크 호출 비율이 높습니다.** API 사용 방식(비동기 처리, 캐싱 등)을 검토하세요.")
            report.append("")

        # Hang별 Time Profiler 분석
        if time_profiler.get("hang_analysis"):
            report.append("### 3.3 Hang 시간대 상세 분석\n")
            report.append("> Time Profiler 샘플을 통해 Hang 발생 시점의 메인 스레드 상태를 분석합니다.\n")
            report.append("")

            for i, analysis in enumerate(time_profiler["hang_analysis"], 1):
                severity_emoji = "🔴" if analysis["hang_duration_ms"] >= 500 else "🟠" if analysis["hang_duration_ms"] >= 250 else "🟡"
                report.append(f"#### {severity_emoji} Hang @ {analysis['hang_start']} ({format_time(analysis['hang_duration_ms'])})\n")

                # 신뢰도 표시
                confidence = analysis.get("confidence", {})
                confidence_emoji = "🟢" if confidence.get("level") == CONFIDENCE_HIGH else "🟡" if confidence.get("level") == CONFIDENCE_MEDIUM else "⚪"
                report.append(f"**진단**: {analysis['diagnosis']} {confidence_emoji} `{confidence.get('level', 'low')}` ({confidence.get('reason', '추정')})\n")

                report.append("| 지표 | 값 |")
                report.append("|------|-----|")
                report.append(f"| 샘플 수 | {analysis['sample_count']} |")
                report.append(f"| Running | {analysis['running_count']} ({analysis['running_ratio']:.1f}%) |")
                report.append(f"| Blocked | {analysis['blocked_count']} ({100 - analysis['running_ratio']:.1f}%) |")
                report.append(f"| 앱 코드 Running | {analysis['app_code_count']} |")
                report.append("")

                # 모듈별 분류
                module_breakdown = analysis.get("module_breakdown", {})
                if module_breakdown:
                    report.append("**모듈별 CPU 사용**:")
                    module_names = {"app": "📱 앱 코드", "system": "⚙️ 시스템", "objc": "🔧 ObjC 런타임", "dyld": "📦 dyld", "unknown": "❓ 기타"}
                    total_module = sum(module_breakdown.values())
                    for module, count in sorted(module_breakdown.items(), key=lambda x: x[1], reverse=True):
                        if count > 0:
                            ratio = count / total_module * 100 if total_module > 0 else 0
                            report.append(f"- {module_names.get(module, module)}: {count}회 ({ratio:.1f}%)")
                    report.append("")

                # 진단에 따른 개선 방안
                if "CPU 집약적" in analysis["diagnosis"]:
                    report.append("**개선 방안**:")
                    report.append("1. 해당 시간대의 앱 코드 로직 확인 (Instruments에서 Call Tree 분석)")
                    report.append("2. 복잡한 계산을 백그라운드 스레드로 이동")
                    report.append("3. 알고리즘 최적화 또는 캐싱 적용")
                elif "블로킹" in analysis["diagnosis"]:
                    report.append("**개선 방안**:")
                    report.append("1. 동기 I/O를 비동기로 변경 (async/await)")
                    report.append("2. 네트워크 요청이 메인 스레드에서 실행되는지 확인")
                    report.append("3. 락 경합이 있는지 Thread Sanitizer로 확인")
                elif "시스템 프레임워크" in analysis["diagnosis"]:
                    report.append("**개선 방안**:")
                    report.append("1. 시스템 API 호출 빈도 줄이기")
                    report.append("2. 결과 캐싱 적용")
                    report.append("3. 배치 처리로 API 호출 횟수 감소")
                report.append("")

    else:
        report.append("Time Profiler 데이터가 없습니다. Instruments에서 Time Profiler를 활성화하고 다시 녹화하세요.")
    report.append("\n---\n")

    # SwiftUI View 섹션
    report.append("## 4. SwiftUI View Body 업데이트 분석\n")

    if views:
        # 사용자 View만 필터링
        user_views = {k: v for k, v in views.items()
                     if not k.startswith("_") and
                        not k.startswith("Dynamic") and
                        not k.startswith("Static") and
                        "Modifier" not in k and
                        "Container" not in k and
                        "Environment" not in k and
                        "List" not in k.split("<")[0]}

        all_views_for_report = views if len(user_views) < 5 else user_views

        # 프레임 데드라인 기준 분석
        report.append("### 4.1 🎯 프레임 데드라인 기준 분석\n")
        report.append(f"> 60fps: **{FRAME_DEADLINE_60FPS}ms** / 120fps (ProMotion): **{FRAME_DEADLINE_120FPS}ms**\n")
        report.append("")
        report.append("| 위험도 | View | 최대 시간 | 프레임 영향 | 업데이트 수 |")
        report.append("|--------|------|-----------|-------------|-------------|")

        sorted_by_max = sorted(all_views_for_report.items(), key=lambda x: x[1]["max_ms"], reverse=True)[:15]
        for name, data in sorted_by_max:
            if data["max_ms"] > 0.01:
                risk_level, risk_desc, emoji = get_hitch_risk_level(data["max_ms"])
                frames_affected = data["max_ms"] / FRAME_DEADLINE_60FPS
                frame_impact = f"{frames_affected:.1f}프레임" if frames_affected >= 1 else f"{frames_affected*100:.0f}%"
                report.append(f"| {emoji} | {name} | {format_time(data['max_ms'])} | {frame_impact} | {data['count']} |")
        report.append("")

        # 가장 많이 업데이트되는 View (불필요한 업데이트 의심)
        report.append("### 4.2 ⚠️ 과도한 업데이트 감지\n")
        report.append("> 불필요한 View Body 업데이트가 누적되면 히치가 발생합니다.\n")
        report.append("")

        sorted_by_count = sorted(all_views_for_report.items(), key=lambda x: x[1]["count"], reverse=True)[:10]
        excessive_found = False
        for name, data in sorted_by_count:
            if data["count"] >= EXCESSIVE_UPDATE_THRESHOLD:
                excessive_found = True
                break

        if excessive_found:
            report.append("| View | 업데이트 수 | 평균 시간 | 총 시간 | 의심 원인 |")
            report.append("|------|-------------|----------|---------|-----------|")
            for name, data in sorted_by_count:
                if data["count"] >= EXCESSIVE_UPDATE_THRESHOLD:
                    avg = data["total_ms"] / data["count"] if data["count"] > 0 else 0
                    cause = "Observable 종속성" if avg < 1.0 else "상태 변경 과다"
                    report.append(f"| {name} | {data['count']} | {format_time(avg)} | {format_time(data['total_ms'])} | {cause} |")
        else:
            report.append("✅ 과도한 업데이트가 감지되지 않았습니다.")
        report.append("")

        # 총 시간 소비 기준
        report.append("### 4.3 📈 총 시간 소비 기준\n")
        sorted_by_total = sorted(all_views_for_report.items(), key=lambda x: x[1]["total_ms"], reverse=True)[:10]
        report.append("| View | 총 시간 | 업데이트 수 | 평균 시간 |")
        report.append("|------|---------|-------------|----------|")
        for name, data in sorted_by_total:
            if data["total_ms"] > 0.1:
                avg = data["total_ms"] / data["count"] if data["count"] > 0 else 0
                report.append(f"| {name} | {format_time(data['total_ms'])} | {data['count']} | {format_time(avg)} |")
    else:
        report.append("SwiftUI View Body 업데이트 데이터가 없습니다.")

    report.append("\n---\n")

    # 패턴 분석 섹션
    report.append("## 5. 🔍 원인 분석\n")

    if views:
        patterns = analyze_update_pattern(views)

        # 긴 View Body 업데이트 원인 - View 타입별 맞춤 분석
        if patterns["slow_single_updates"]:
            report.append("### 5.1 긴 View Body 업데이트\n")

            for item in sorted(patterns["slow_single_updates"], key=lambda x: x["max_ms"], reverse=True)[:5]:
                risk_level, risk_desc, emoji = get_hitch_risk_level(item["max_ms"])
                type_hint = get_view_type_hint(item["name"])

                report.append(f"#### {emoji} {item['name']}\n")
                report.append(f"- **최대 실행 시간**: {format_time(item['max_ms'])}")
                report.append(f"- **위험도**: {risk_desc}")
                if type_hint:
                    report.append(f"- **View 타입**: {type_hint['type']}")
                report.append("")

                if type_hint:
                    report.append("**가능한 원인**:")
                    for cause in type_hint["causes"][:3]:
                        report.append(f"- {cause}")
                    report.append("")
                    report.append("**해결 방안**:")
                    for i, sol in enumerate(type_hint["solutions"][:3], 1):
                        report.append(f"{i}. {sol}")
                else:
                    report.append("**가능한 원인**:")
                    report.append("- View Body 내에서 Formatter 생성")
                    report.append("- 복잡한 계산이 body에서 직접 실행")
                    report.append("")
                    report.append("**해결 방안**:")
                    report.append("1. 비싼 작업을 ViewModel로 이동")
                    report.append("2. Formatter를 static으로 캐싱")
                report.append("")

        # 불필요한 업데이트 원인 (Observable 문제) - View 타입별 맞춤 분석
        if patterns["potential_observable_issue"]:
            report.append("### 5.2 Observable 종속성 문제 의심\n")

            for item in sorted(patterns["potential_observable_issue"], key=lambda x: x["count"], reverse=True)[:5]:
                type_hint = get_view_type_hint(item["name"])

                report.append(f"#### ⚠️ {item['name']}\n")
                report.append(f"- **업데이트 횟수**: {item['count']}회")
                report.append(f"- **평균 실행 시간**: {format_time(item['avg_ms'])}")
                if type_hint:
                    report.append(f"- **View 타입**: {type_hint['type']}")
                report.append("")

                if type_hint:
                    report.append("**가능한 원인**:")
                    report.append(f"- {type_hint['causes'][0]}")
                    report.append("- 상위 상태 변경이 하위 View로 전파")
                    report.append("")
                    report.append("**해결 방안**:")
                    for i, sol in enumerate(type_hint["solutions"][:2], 1):
                        report.append(f"{i}. {sol}")
                    report.append("3. Equatable 준수로 실제 변경 시에만 업데이트")
                else:
                    report.append("**가능한 원인**:")
                    report.append("- @Observable의 광범위한 속성 종속")
                    report.append("- 상위 상태 변경이 하위 View로 전파")
                    report.append("")
                    report.append("**해결 방안**:")
                    report.append("1. View별 개별 ViewModel로 종속성 분리")
                    report.append("2. Equatable 준수로 불필요한 업데이트 방지")
                report.append("")

        # 과도한 업데이트
        if patterns["excessive_updates"]:
            report.append("### 5.3 과도한 업데이트 경고\n")

            for item in sorted(patterns["excessive_updates"], key=lambda x: x["count"], reverse=True)[:5]:
                type_hint = get_view_type_hint(item["name"])
                type_info = f" ({type_hint['type']})" if type_hint else ""
                report.append(f"- **{item['name']}{type_info}**: {item['count']}회 (총 {format_time(item['total_ms'])})")

            report.append("")
            report.append("> 💡 개별 업데이트가 빨라도 누적되면 프레임 마감을 놓칠 수 있습니다.")
            report.append("")

    report.append("\n---\n")

    # 개선 권고사항
    report.append("## 6. 📋 개선 권고사항 (우선순위별)\n")

    if views:
        priority_issues = []

        # 우선순위 1: 프레임 데드라인 초과 View
        for name, data in views.items():
            if data["max_ms"] >= VIEW_UPDATE_CRITICAL:
                causes = get_root_cause_analysis(name, data)
                priority_issues.append({
                    "priority": 1,
                    "name": name,
                    "data": data,
                    "causes": causes,
                    "type": "프레임 데드라인 초과"
                })
            elif data["max_ms"] >= VIEW_UPDATE_CAUTION:
                causes = get_root_cause_analysis(name, data)
                priority_issues.append({
                    "priority": 2,
                    "name": name,
                    "data": data,
                    "causes": causes,
                    "type": "프레임 예산 50% 초과"
                })
            elif data["count"] >= EXCESSIVE_UPDATE_THRESHOLD:
                causes = get_root_cause_analysis(name, data)
                priority_issues.append({
                    "priority": 3,
                    "name": name,
                    "data": data,
                    "causes": causes,
                    "type": "과도한 업데이트"
                })

        # 우선순위별 정렬
        priority_issues.sort(key=lambda x: (x["priority"], -x["data"]["max_ms"]))

        for i, issue in enumerate(priority_issues[:5], 1):
            priority_label = "🔴 높음" if issue["priority"] == 1 else "🟠 중간" if issue["priority"] == 2 else "🟡 낮음"
            report.append(f"### 6.{i} {issue['name']} ({priority_label})\n")
            report.append(f"**문제 유형**: {issue['type']}")
            report.append(f"- 최대 실행 시간: {format_time(issue['data']['max_ms'])}")
            report.append(f"- 업데이트 횟수: {issue['data']['count']}회")
            report.append(f"- 총 소요 시간: {format_time(issue['data']['total_ms'])}")
            report.append("")

            for cause in issue["causes"]:
                report.append(f"**{cause['type']}**")
                report.append(f"> {cause['description']}")
                report.append("")
                report.append("가능한 원인:")
                for pc in cause["possible_causes"][:3]:
                    report.append(f"- {pc}")
                report.append("")
                report.append("해결 방안:")
                for sol in cause["solutions"][:3]:
                    report.append(f"- {sol}")
                report.append("")

            # Actionable 코드 예시 추가
            view_type_hint = get_view_type_hint(issue["name"])
            if view_type_hint:
                issue_type = "slow" if issue["data"]["max_ms"] >= VIEW_UPDATE_CAUTION else "excessive"
                code_example = get_actionable_code_example(view_type_hint["type"], issue_type)

                report.append(f"<details>")
                report.append(f"<summary>📝 코드 예시: {code_example['problem']}</summary>")
                report.append("")
                report.append("**Before (문제 코드)**:")
                report.append("```swift")
                report.append(code_example["before"])
                report.append("```")
                report.append("")
                report.append("**After (개선 코드)**:")
                report.append("```swift")
                report.append(code_example["after"])
                report.append("```")
                report.append("")
                report.append(f"> 💡 {code_example['explanation']}")
                report.append("")
                report.append("</details>")
                report.append("")

        if not priority_issues:
            report.append("✅ 심각한 성능 이슈가 감지되지 않았습니다.")

    return "\n".join(report)


def main():
    trace_path = None
    output_path = None

    # 인자 처리
    if len(sys.argv) >= 2:
        trace_path = sys.argv[1]
    if len(sys.argv) >= 3:
        output_path = sys.argv[2]

    # trace 파일이 지정되지 않았으면 GUI로 선택
    if not trace_path:
        print("=" * 50)
        print("  Instruments Trace 분석기")
        print("=" * 50)
        print("\n파일 선택 다이얼로그를 여는 중...")

        trace_path = select_trace_file_gui()

        # GUI 실패 시 CLI 폴백
        if not trace_path:
            trace_path = select_trace_file_cli()

        if not trace_path:
            print("\n분석이 취소되었습니다.")
            sys.exit(0)

    # 경로 검증
    if not os.path.exists(trace_path):
        print(f"Error: 파일을 찾을 수 없습니다: {trace_path}")
        sys.exit(1)

    # 출력 경로 결정
    if not output_path:
        result_dir = get_result_dir()
        base_name = os.path.splitext(os.path.basename(trace_path))[0]
        if base_name.startswith("#"):
            base_name = base_name[1:]
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        output_path = str(result_dir / f"{base_name}_{timestamp}.md")

    print(f"\n분석 중: {trace_path}")
    print("(대용량 파일의 경우 몇 분이 소요될 수 있습니다...)\n")

    # 모든 데이터 분석
    print("  - 데이터 추출 및 분석 중...")
    views, hangs, lifecycle = analyze_all_data(trace_path)

    if lifecycle["total_launch"] > 0:
        print(f"    앱 시작 시간: {format_time(lifecycle['total_launch'])}")
    print(f"    {len(hangs)}건의 Hang 발견")
    print(f"    {len(views)}개의 View 분석 완료")

    # Time Profiler 분석
    print("  - Time Profiler 데이터 분석 중...")
    time_profiler = analyze_time_profiler(trace_path, hangs)
    if time_profiler["total_samples"] > 0:
        print(f"    {time_profiler['total_samples']}개의 샘플 분석 완료")
        print(f"    메인 스레드 Running: {time_profiler['running_ratio']:.1f}%")
    else:
        print("    Time Profiler 데이터 없음")

    # 리포트 생성
    report = generate_markdown_report(trace_path, hangs, views, lifecycle, time_profiler)

    # 파일 저장
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(report)

    print(f"\n리포트 저장 완료: {output_path}")

    # 요약 출력
    print("\n" + "=" * 50)
    print("  분석 요약")
    print("=" * 50)
    if lifecycle["total_launch"] > 0:
        print(f"앱 시작 시간: {format_time(lifecycle['total_launch'])}")
    print(f"Hang: {len(hangs)}건")
    print(f"분석된 View: {len(views)}개")
    if views:
        total_updates = sum(v["count"] for v in views.values())
        total_time = sum(v["total_ms"] for v in views.values())
        print(f"총 View 업데이트: {total_updates}회")
        print(f"총 소요 시간: {format_time(total_time)}")

        sorted_views = sorted(views.items(), key=lambda x: x[1]["max_ms"], reverse=True)[:3]
        if sorted_views:
            print("\n가장 느린 View:")
            for name, data in sorted_views:
                if data["max_ms"] > 0.001:
                    print(f"  - {name}: {format_time(data['max_ms'])} (최대)")

    # 결과 파일 열기 옵션
    print(f"\n결과 파일: {output_path}")


if __name__ == "__main__":
    main()
