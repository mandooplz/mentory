# 2025-11-18 설정 탭 화면이 표시되지 않는 문제

## 이슈 개요

- **증상**: 온보딩 완료 후 SettingBoardView가 탭바에 표시되지 않고 “설정 화면을 준비 중입니다.” 텍스트만 나옴.
- **영향 범위**: 앱 초기 Onboarding → TabView 전환 흐름 전체.
- **감지 배경**: 기능 개발 중 설정 화면이 전혀 나타나지 않아 디버깅 시작.

## 진단 과정

1. MentoryiOSView에서 설정 탭이 mentoryiOS.settingBoard가 nil일 때 fallback 문구를 보여주는 구조임을 확인.

2. Onboarding.next() 안에 todayBoard 초기화는 있으나 settingBoard 생성 코드가 없는 것을 발견.

3. 따라서 온보딩 이후에도 설정 모델이 초기화되지 않아 설정 UI가 생성되지 않는다는 결론에 도달

## 해결 방법

- Onboarding.next()에 아래와 같이 한 줄을 추가하여 설정 보드를 초기화함 
- mentoryiOS.settingBoard = SettingBoard(owner: mentoryiOS)
- 이후 정상적으로 설정 탭에서 SettingBoardView가 표시됨을 확인.

## 회고 및 예방

- 탭 구조에서 각 화면에 대응하는 모델이 반드시 초기화되어야 한다는 점을 다시 확인.
- 온보딩처럼 여러 상태를 한 번에 세팅하는 구간에서는 누락이 없는지 체크리스트가 필요함.
