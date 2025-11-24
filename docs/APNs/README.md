# APNs(Apple Push Notification service) 개발 문서

*Mentory 프로젝트용* 

---

## 📌 1. APNs란 무엇인가?

- *APNs(Apple Push Notification service)**는

Apple이 제공하는 **푸시 알림 전송 서비스**로,

서버에서 iOS 기기의 앱으로 메시지를 전달하는 가장 공식적이고 유일한 방법이다.

즉,

> "우리 서버가 사용자에게 알림을 보내고 싶을 때 Apple이 대신 전달해 주는 서비스"
> 

라고 이해하면 가장 쉽다.

Mentory에서는 사용자가 지정한 알림 시간에

서버가 APNs를 통해 감정 기록 리마인더 알림을 보내는 구조를 사용한다.

---

## 📌 2. APNs가 필요한 이유

로컬 알림(Local Notification)은 앱 내부에서 자체적으로 예약하는 방식이다.

하지만 우리는 다음 이유로 **APNs 기반 서버 알림**을 선택한다:

- 사용자가 **앱을 삭제하거나 기기 변경**해도 서버에서 관리 가능
- 사용자 맞춤 메시지, 분석 결과 연동 등 **동적 메시지** 전달 가능
- 향후 머신러닝, 사용자 상태 기반 알림 확장에도 유리
- iOS의 백그라운드 제한을 받지 않음
- 알림 실패/성공을 서버에서 추적할 수 있음

---

## 📌 3. APNs 동작 흐름 (Mentory 기준)

```
1. iOS 앱이 APNs에 “푸시 토큰(기기 토큰)”을 요청
2. APNs가 기기 고유 토큰(Device Token)을 앱에게 제공
3. 앱은 해당 토큰을 우리 서버로 전송
4. 알림 시간이 되면 서버에서 APNs로 알림 요청을 보냄
5. APNs가 해당 기기로 알림 전달
6. 사용자가 Mentory 알림을 수신함

```

이 중 개발자가 실제로 구현해야 하는 단계는:

- iOS 앱 → Device Token 받기
- Device Token → 서버로 저장
- 서버에서 APNs에 알림 요청 API 호출

---

## 📌 4. 필수 개념 정리

### 🔑 Device Token

- APNs가 특정 기기를 식별하기 위한 고유 값
- 앱 설치/재설치 또는 기기 변경 시 변경될 수 있음
- 앱에서 서버로 계속 최신 토큰을 보내주어야 함

### 🔐 인증 방식 (Server → APNs)

서버가 알림을 보낼 때 인증에 두 가지 방식이 있음:

| 방식 | 설명 | 장점 | 단점 |
| --- | --- | --- | --- |
| **Auth Key (추천)** | .p8 파일 기반 JWT 토큰 인증 | 쉽고 유지관리 편함 | 없음 |
| Certificate | .pem 인증서 방식 | 기존 방식 | 갱신 필요 |

대부분 최신 서버에서는 **Auth Key(.p8)** 방식 사용.

Mentory도 이 방식으로 설계하면 좋음.

---

## 📌 5. APNs 구성(Development Portal)

### 1) Developer 계정에서 필요한 작업

- Team Agent 계정 필요
- App Identifier에서 “Push Notifications” 활성화
- **Key → APNs Auth Key 생성(.p8 다운로드)**
- Key ID, Team ID, Bundle ID 저장

### 2) Xcode에서 설정

- Signing & Capabilities에서 Push Notifications 켜기
- Background Modes → Remote Notifications 활성화(선택)

---

## 📌 6. iOS 앱 구현 단계

### 📘 1) 알림 권한 요청

```swift
import UserNotifications

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            print("알림 권한 허용됨")
        } else {
            print("알림 권한 거부됨")
        }
    }
}

```

앱 실행 시 또는 설정 화면에서 호출.

---

### 📘 2) APNs에 Device Token 요청

```swift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        // APNs 등록 요청
        UIApplication.shared.registerForRemoteNotifications()
        return true
    }

    // 기기 토큰 수신
    func application(_ application: UIApplication,
                    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📱 Device Token:", tokenString)

        // 서버로 전송하는 로직 필요
    }
}

```

SwiftUI App 생명주기를 쓰는 경우도 AppDelegate 연결로 동일하게 구현 가능.

---

### 📘 3) 서버로 Device Token 전송

토큰을 서버에서 저장해야 특정 사용자에게 알림을 보낼 수 있음.

예시(JSON):

```json
{
  "userId": "1234",
  "deviceToken": "xxxxx..."
}

```

---

## 📌 7. 서버에서 알림 보내는 방식(APNs HTTP/2 API)

### HTTP Request 예시 (Auth Key 기반)

```
POST https://api.push.apple.com/3/device/{deviceToken}
Authorization: bearer {JWT}
apns-topic: {Bundle ID}
Content-Type: application/json

{
  "aps": {
    "alert": {
      "title": "오늘은 어떤 하루였나요?",
      "body": "지금 감정 기록을 남겨보는 건 어때요?"
    },
    "sound": "default"
  }
}

```

Mentory에서는

“설정한 알림 시간마다 서버에서 위 API를 호출”

하는 로직을 구현하면 된다.

---

## 📌 8. Mentory에서 APNs가 어떻게 사용될 예정인가?

### 🔔 사용 시나리오

1. 사용자가 설정 화면에서 “알림 시간”을 정함
2. 앱이 서버로 알림 시간 + 사용자 Device Token 전달
3. 서버는 스케줄러(Cron 등)로 알림 시간을 체크
4. 해당 시각에 APNs API를 호출하여 알림 발송
5. 사용자에게 감정 기록 리마인더 도착

### 🔔 APNs로 보내는 알림의 특징

- 앱이 실행 중이 아니어도 도착 가능
- 인터넷 연결 필요
- 메시지 커스텀 가능
- 다국어 설정 가능
- 향후 “AI 분석 기반 알림” 같은 기능 확장에 유리

---

## 📌 9. 개발 중 주의사항

### ❗ 1) Device Token은 자주 바뀔 수 있음

- 앱 재설치
- iOS 업데이트
- 백업 복원

→ 앱 실행 때 token이 바뀔 가능성이 있어

**항상 서버로 최신 토큰을 동기화**해야 함.

---

### ❗ 2) 푸시 권한을 사용자가 꺼버리면 알림 안 옴

→ 설정 앱에서 다시 켜달라고 안내 필요

---

### ❗ 3) Debug / Release 환경 토큰 다름

- Sandbox(개발)
- Production(배포)

서버 설정도 두 개를 구분해야 함.

---

### ❗ 4) iOS는 알림을 지나치게 많이 보내면 사용자 경험 저하

Mentory에서는 “하루 1~2회” 정도가 적당.

---

## 📌 10. 테스트 방법

1. Xcode → device logs에서 토큰 확인
2. curl로 직접 APNs API 호출 가능

(단, JWT 생성이 필요함)

---

## 📌 11. 참고 자료

- Apple Official Docs
    - https://developer.apple.com/documentation/usernotifications
    - https://developer.apple.com/documentation/usernotifications/registering_your_app_with_apns
    - https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server

---

# 📦 최종 요약

> APNs는 iOS 푸시 알림을 전달하는 Apple의 공식 서비스
> 
> 
> Mentory는 “사용자가 정한 알림 시간 → 서버 → APNs → 기기” 흐름으로 알림을 보냄
> 
> 앱에서는 Device Token 받기 + 서버로 전달 기능만 구현하면 됨
> 
> 서버에서는 APNs HTTP/2 API를 이용해 알림을 발송하면 됨
>