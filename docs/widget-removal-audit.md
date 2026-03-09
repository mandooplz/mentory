# Widget Removal Audit

Widget removal scope identified on 2026-03-09.

## Targets and project settings

- `MentoryApp/Project.swift`
  - `MentoryWidgetExtension` app extension target
  - `MentoryApp` dependency on `MentoryWidgetExtension`
  - widget signing settings and bundle display name
  - `MentoryWidgetExtension.entitlements` in additional files
- `MentoryApp/MentoryApp/Mentory.entitlements`
  - `com.apple.security.application-groups`
- `MentoryApp/MentoryWidgetExtension.entitlements`
  - `com.apple.security.application-groups`

## Widget source tree

- `MentoryApp/MentoryWidget`
  - `MentoryWidgetBundle.swift`
  - `Presentation/AppIntent.swift`
  - `Presentation/MentoryWidget.swift`
  - `Presentation/MentoryWidgetControl.swift`
  - `Presentation/MentoryWidgetLiveActivity.swift`
  - `Assets.xcassets`
  - `Info.plist`

## Widget framework/API usage

- `WidgetKit`
- `AppIntents`
- `AppIntentConfiguration`
- `AppIntentTimelineProvider`
- `TimelineEntry`
- `WidgetBundle`
- `WidgetCenter`
- `widgetURL`
- app group identifiers:
  - `group.cloud.mandooplz.mentory`
  - `group.com.sjs.mentory`

## Documentation

- `README.md`
  - widget badge, architecture language, run instructions, module description
