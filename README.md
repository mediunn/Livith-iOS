<img width="1920" height="399" alt="Image" src="https://github.com/user-attachments/assets/3f40e89b-cdcb-4cfa-8478-ecde627445b8" />

# Livith 라이빗

```swift
print("모두가 라이브를 통해 빛나는 순간! 라이빗 iOS 레포지토리입니다.")
```

[![iOS 17.0+](https://img.shields.io/badge/iOS-17.0+-000000?style=flat&logo=apple&logoColor=white)](https://www.apple.com/ios) [![Swift 6.0](https://img.shields.io/badge/Swift-6.0-F05138?style=flat&logo=swift&logoColor=white)](https://swift.org) [![SwiftUI](https://img.shields.io/badge/SwiftUI-blue?style=flat&logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/) [![Tuist](https://img.shields.io/badge/Tuist-4.x-6236FF?style=flat)](https://tuist.io)

[<img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" height="40">](앱스토어_링크)

</div>

<br/>

<div align="center">

## Team iOS

| <img src="https://github.com/user-attachments/assets/f734adaf-ca51-4d87-925e-c868f649f094" width="200"/> | <img src="https://github.com/user-attachments/assets/7c76b32c-8979-43c3-82ff-bca9643d3121" width="200"/> |
|:---:|:---:|
| [@youz2me](https://github.com/youz2me) | [@JinUng41](https://github.com/JinUng41) |

</div>

<br/>

<img align="right" width="320" src="https://github.com/user-attachments/assets/75a0cc78-f2df-4403-b995-3d644de5ceb1" alt="App Screenshot">

## Key Features

- [x] 나의 관심 공연을 설정하고 홈 화면에서 간편하게 확인해요.
- [x] 콘서트 정보부터 아티스트 정보까지, 흩어진 정보를 한번에 확인해요.
- [x] 콘서트의 지난, 예상 셋리스트부터 가사까지! 라이빗에서 제공해요.
- [x] 팬문화부터 응원법까지 쉽게 접하지 못하는 정보를 모아볼 수 있어요.
- [x] 콘서트마다 열리는 커뮤니티 탭에서 사람들과 의견 및 정보를 나눠요.
- [x] 보고 싶은 콘서트를 필터와 정렬 기능을 통해 간편하게 탐색해요.

<br/>

## Tech Stack

| Category | Technologies |
|:---|:---|
| **Architecture** | MVI Pattern, Clean Architecture |
| **UI** | SwiftUI |
| **Concurrency** | Swift Concurrency |
| **Modularization** | Tuist |
| **Networking** | Alamofire, URLSession |
| **Dependencies** | Alamofire, KakaoOpenSDK, <br/> Kingfisher, YoutubePlayerKit |

<br/>

<div align="center">

## Livith iOS Architecture

### Data Flow
<img width="1920" height="823" alt="Image" src="https://github.com/user-attachments/assets/96c4332f-c494-4670-a898-eb7fd52bd570" />

### Module Structure

<img width="1989" height="958" alt="Image" src="https://github.com/user-attachments/assets/d262fc0e-d29b-43b7-ab48-e5aab2807533" />

</div>

<br/>

> [!IMPORTANT]
> ➊ **DIContainer** - @Injected 프로퍼티 래퍼를 통한 의존성 주입 컨테이너
> ➋ **LivithNetwork** - Alamofire 기반 네트워크 레이어. API 통신 및 에러 처리 담당
> ➌ **LivithFoundation** - 공통 유틸리티 및 Extension. Task 확장 등 비동기 유틸리티 포함
> ➍ **Auth** - KakaoSDK 기반 소셜 로그인 처리
> ➎ **Persistence** - UserDefaults 기반 로컬 데이터 저장

<br/>
