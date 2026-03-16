import ProjectDescription
import ProjectDescriptionHelpers

let appConfigurations: [Configuration] = [
    .debug(name: "Debug", xcconfig: "Secrets.xcconfig"),
    .release(name: "Release", xcconfig: "Secrets.xcconfig"),
]

let appSettings = Settings.mentoryTarget(
    base: .mentoryManualSigning(
        sdk: "iphoneos*",
        currentVersion: "2",
        marketingVersion: "25.12",
        targetedDeviceFamily: "1",
        provisioningProfile: "Mentory-Dev-Profile",
        supportedPlatforms: "iphoneos iphonesimulator",
        extra: [
            "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": .string(
                "YES"
            ),
            "INFOPLIST_KEY_NSCameraUsageDescription": .string(
                "사진 촬영을 위해 카메라 접근 권한이 필요합니다."
            ),
            "INFOPLIST_KEY_NSMicrophoneUsageDescription": .string(
                "음성 입력을 위해 마이크 접근 권한이 필요합니다."
            ),
            "INFOPLIST_KEY_NSSpeechRecognitionUsageDescription": .string(
                "음성 인식을 위해 권한이 필요합니다."
            ),
            "INFOPLIST_KEY_UIApplicationSceneManifest_Generation": .string("YES"),
            "INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents": .string(
                "YES"
            ),
            "INFOPLIST_KEY_UILaunchScreen_Generation": .string("YES"),
            "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad": .string(
                "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight"
            ),
            "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone": .string(
                "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight"
            ),
            "STRING_CATALOG_GENERATE_SYMBOLS": .string("YES"),
            "SWIFT_APPROACHABLE_CONCURRENCY": .string("YES"),
            "SWIFT_DEFAULT_ACTOR_ISOLATION": .string("MainActor"),
            "SWIFT_EMIT_LOC_STRINGS": .string("YES"),
            "SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY": .string("YES"),
        ]
    )
)

let testSettings = Settings.mentoryTarget(
    base: .mentoryManualSigning(
        sdk: "iphoneos*",
        currentVersion: "1",
        marketingVersion: "1.0",
        targetedDeviceFamily: "1",
        supportedPlatforms: "iphoneos iphonesimulator",
        extra: [
            "BUNDLE_LOADER": .string("$(TEST_HOST)"),
            "STRING_CATALOG_GENERATE_SYMBOLS": .string("NO"),
            "TEST_HOST": .string(
                "$(BUILT_PRODUCTS_DIR)/Mentory.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Mentory"
            ),
        ]
    )
)

let project = Project.mentory(
    name: "MentoryApp",
    packages: [
        .package(
            url: "https://github.com/apple/swift-async-algorithms.git",
            .upToNextMajor(from: "1.1.0")
        ),
    ],
    configurations: appConfigurations,
    targets: [
        .mentoryFramework(
            name: "MentoryCore",
            sources: ["MentoryCore/Sources/**"],
            dependencies: [
                .mentoryShared("Values"),
                .mentoryDB("NewMentoryDBCore"),
                .mentoryDB("NewMentoryDBFake"),
                .mentoryLLM("NewFirebaseLLM"),
                .mentoryLLM("NewFirebaseLLMFake"),
                .mentoryDevice("iOSReminder"),
            ],
            product: .staticFramework
        ),
        .mentoryApp(
            name: "MentoryApp",
            productName: "Mentory",
            bundleId: "Mentory",
            sources: ["MentoryApp/**/*.swift"],
            resources: [
                "MentoryApp/Assets.xcassets",
                "MentoryApp/GoogleService-Info.plist",
                "Secrets.xcconfig.sample",
            ],
            dependencies: [
                .target(name: "MentoryCore"),
                .mentoryDevice("iOSReminder"),
                .package(product: "AsyncAlgorithms"),
                .mentoryShared("Values"),
            ],
            infoPlist: .extendingDefault(
                with: [
                    "ALAN_API_TOKEN": "$(TOKEN)",
                    "NSMicrophoneUsageDescription": "음성 기록을 녹음하고 음성을 텍스트로 변환하기 위해 마이크를 사용합니다.",
                    "NSSpeechRecognitionUsageDescription": "녹음한 음성을 텍스트로 변환해 오늘의 기록 작성에 활용합니다.",
                    "UIApplicationSupportsIndirectInputEvents": true,
                    "UILaunchScreen": [:],
                    "CFBundleURLTypes": [
                        [
                            "CFBundleTypeRole": "Editor",
                            "CFBundleURLName": "Mentory",
                            "CFBundleURLSchemes": ["mentory"],
                        ],
                    ],
                ]
            ),
            entitlements: .file(path: "MentoryApp/Mentory.entitlements"),
            settings: appSettings
        ),
        .mentoryUnitTests(
            name: "MentoryTests",
            sources: ["MentoryTests/**/*.swift"],
            dependencies: [
                .target(name: "MentoryApp"),
                .target(name: "MentoryCore"),
                .mentoryShared("Values"),
                .mentoryDB("NewMentoryDBCore"),
            ],
            settings: testSettings
        ),
    ],
    additionalFiles: [
        "Mentory.xctestplan",
        "Secrets.xcconfig",
        "Secrets.xcconfig.sample",
        "GoogleService-Info.plist",
    ]
)
