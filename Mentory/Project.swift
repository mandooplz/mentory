import ProjectDescription

let project = Project(
    name: "Mentory",
    packages: [
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.3.0")),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", .upToNextMajor(from: "1.1.0")),
        .package(path: "../FirebaseLLM"),
        .package(path: "../MentoryDB"),
        .package(path: "../Values"),
    ],
    settings: .settings(
        configurations: [
            .debug(name: "Debug", xcconfig: "Secrets.xcconfig"),
            .release(name: "Release", xcconfig: "Secrets.xcconfig"),
        ]
    ),
    targets: [
        .target(
            name: "Mentory",
            destinations: .iOS,
            product: .app,
            bundleId: "cloud.mandooplz.Mentory",
            deploymentTargets: .iOS("26.1"),
            infoPlist: .file(path: "Mentory/Info.plist"),
            sources: ["Mentory/**/*.swift"],
            resources: [
                "Mentory/Assets.xcassets",
                "Mentory/GoogleService-Info.plist",
                "Secrets.xcconfig.sample",
            ],
            entitlements: .file(path: "Mentory/Mentory.entitlements"),
            dependencies: [
                .target(name: "MentoryWatch Watch App"),
                .target(name: "MentoryWidgetExtension"),
                .project(target: "iOSManager", path: "../iOSManager"),
                .package(product: "Collections"),
                .package(product: "DequeModule"),
                .package(product: "AsyncAlgorithms"),
                .package(product: "FirebaseLLMAdapter"),
                .package(product: "MentoryDBAdapter"),
                .package(product: "Values"),
            ],
            settings: .settings(
                base: [
                    "CODE_SIGN_STYLE": "Manual",
                    "DEVELOPMENT_TEAM[sdk=iphoneos*]": "3X262XJF5T",
                    "PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]": "Mentory-Dev-Profile",
                    "CURRENT_PROJECT_VERSION": "2",
                    "MARKETING_VERSION": "25.12",
                    "SWIFT_VERSION": "6.0",
                    "TARGETED_DEVICE_FAMILY": "1",
                    "SUPPORTED_PLATFORMS": "iphoneos iphonesimulator",
                    "STRING_CATALOG_GENERATE_SYMBOLS": "YES",
                    "INFOPLIST_KEY_NSCameraUsageDescription": "사진 촬영을 위해 카메라 접근 권한이 필요합니다.",
                    "INFOPLIST_KEY_NSMicrophoneUsageDescription": "음성 입력을 위해 마이크 접근 권한이 필요합니다.",
                    "INFOPLIST_KEY_NSSpeechRecognitionUsageDescription": "음성 인식을 위해 권한이 필요합니다.",
                    "INFOPLIST_KEY_UIApplicationSceneManifest_Generation": "YES",
                    "INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents": "YES",
                    "INFOPLIST_KEY_UILaunchScreen_Generation": "YES",
                    "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad": "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight",
                    "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone": "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight",
                ]
            )
        ),
        .target(
            name: "MentoryTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "cloud.mandooplz.MentoryTests",
            deploymentTargets: .iOS("26.1"),
            infoPlist: .default,
            sources: ["MentoryTests/**/*.swift"],
            resources: [],
            dependencies: [
                .target(name: "Mentory"),
                .package(product: "Values"),
                .package(product: "MentoryDBAdapter"),
            ],
            settings: .settings(
                base: [
                    "CODE_SIGN_STYLE": "Manual",
                    "DEVELOPMENT_TEAM[sdk=iphoneos*]": "3X262XJF5T",
                    "CURRENT_PROJECT_VERSION": "1",
                    "MARKETING_VERSION": "1.0",
                    "SWIFT_VERSION": "6.0",
                    "TARGETED_DEVICE_FAMILY": "1",
                    "SUPPORTED_PLATFORMS": "iphoneos iphonesimulator",
                    "STRING_CATALOG_GENERATE_SYMBOLS": "NO",
                    "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/Mentory.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Mentory",
                    "BUNDLE_LOADER": "$(TEST_HOST)",
                ]
            )
        ),
        .target(
            name: "MentoryWidgetExtension",
            destinations: .iOS,
            product: .appExtension,
            bundleId: "cloud.mandooplz.Mentory.widget",
            deploymentTargets: .iOS("26.1"),
            infoPlist: .file(path: "MentoryWidget/Info.plist"),
            sources: ["MentoryWidget/**/*.swift"],
            resources: ["MentoryWidget/Assets.xcassets"],
            entitlements: .file(path: "MentoryWidgetExtension.entitlements"),
            settings: .settings(
                base: [
                    "CODE_SIGN_STYLE": "Manual",
                    "DEVELOPMENT_TEAM[sdk=iphoneos*]": "3X262XJF5T",
                    "PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]": "Mentory-Dev-Widget-Profile",
                    "CURRENT_PROJECT_VERSION": "2",
                    "MARKETING_VERSION": "25.11",
                    "SWIFT_VERSION": "6.0",
                    "TARGETED_DEVICE_FAMILY": "1,2",
                    "ASSETCATALOG_COMPILER_WIDGET_BACKGROUND_COLOR_NAME": "WidgetBackground",
                    "INFOPLIST_KEY_CFBundleDisplayName": "MentoryWidget",
                    "STRING_CATALOG_GENERATE_SYMBOLS": "YES",
                ]
            )
        ),
        .target(
            name: "MentoryWatch Watch App",
            destinations: .watchOS,
            product: .watch2App,
            bundleId: "cloud.mandooplz.Mentory.watch",
            deploymentTargets: .watchOS("26.2"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "MentoryWatch",
                    "WKCompanionAppBundleIdentifier": "cloud.mandooplz.Mentory",
                    "UISupportedInterfaceOrientations": "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown",
                ]
            ),
            sources: ["MentoryWatch Watch App/**/*.swift"],
            resources: ["MentoryWatch Watch App/Presentation/Assets.xcassets"],
            entitlements: .file(path: "MentoryWatch Watch App/MentoryWatch Watch App.entitlements"),
            settings: .settings(
                base: [
                    "CODE_SIGN_STYLE": "Manual",
                    "DEVELOPMENT_TEAM[sdk=watchos*]": "3X262XJF5T",
                    "PROVISIONING_PROFILE_SPECIFIER[sdk=watchos*]": "Mentory-Dev-Watch-Profile",
                    "CURRENT_PROJECT_VERSION": "1",
                    "MARKETING_VERSION": "1.0",
                    "SWIFT_VERSION": "6.0",
                    "TARGETED_DEVICE_FAMILY": "4",
                    "STRING_CATALOG_GENERATE_SYMBOLS": "YES",
                ]
            )
        ),
    ],
    additionalFiles: [
        "Mentory.xctestplan",
        "Secrets.xcconfig",
        "Secrets.xcconfig.sample",
        "GoogleService-Info.plist",
        "MentoryWidgetExtension.entitlements",
    ]
)
