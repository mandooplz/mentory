# Watch Removal Audit

Watch removal scope identified on 2026-03-09.

## Targets and modules

- `MentoryApp/Project.swift`
  - `MentoryWatchApp` watchOS app target
  - `MentoryWatchCore` watchOS framework target
  - `MentoryToWatch` iOS payload bridge target
  - `MentoryCore` dependency on `WatchManager`
  - `MentoryApp` dependency on `MentoryWatchApp` and `WatchManager`
- `MentoryDevice/Project.swift`
  - `WatchManager` framework target
- `Tuist/ProjectDescriptionHelpers/Target+Mentory.swift`
  - `Target.mentoryWatchApp(...)`
- `Tuist/ProjectDescriptionHelpers/Mentory+Constants.swift`
  - `Mentory.watchOSDeploymentTargets`

## iOS references

- `MentoryApp/MentoryCore/Sources/Mentory.swift`
  - `WatchManager` import and `watchConnectivity` property
- `MentoryApp/MentoryCore/Sources/TodayBoard/TodayBoard.swift`
  - `MentoryToWatch` and `WatchManager` imports
  - watch sync methods
- `MentoryApp/MentoryCore/Sources/TodayBoard/MentorMessage/MentorMessage.swift`
  - watch payload creation and sync
- `MentoryApp/MentoryApp/Presentation/TodayBoard/TodayBoardView/TodayBoardView.swift`
  - watch setup and todo handler wiring
- `MentoryApp/MentoryApp/Presentation/TodayBoard/RecordFormView/MindAnalyzerView/MindAnalyzerView.swift`
  - suggestion sync trigger
- `MentoryApp/MentoryCore/Sources/TodayBoard/Suggestion/Suggestion.swift`
  - watch sync trigger

## Watch-only source trees

- `MentoryApp/MentoryWatchApp`
- `MentoryApp/MentoryWatchCore`
- `MentoryApp/MentoryWatch`
- `MentoryDevice/WatchManager`

## Documentation

- `README.md`
  - watchOS badge, run instructions, platform/module descriptions
