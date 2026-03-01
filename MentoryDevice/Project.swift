import ProjectDescription

let project = Project(
    name: "MentoryDevice",
    targets: [
        .target(
            name: "iOSReminder",
            destinations: .iOS,
            product: .framework,
            bundleId: "cloud.mandooplz.iOSReminder",
            deploymentTargets: .iOS("26.1"),
            infoPlist: .default,
            sources: ["iOSReminder/**/*.swift"],
            resources: [],
            dependencies: [
                .project(target: "Values", path: "../MentoryShared"),
            ],
            settings: .settings(
                base: [
                    "BUILD_LIBRARY_FOR_DISTRIBUTION": "YES",
                    "CODE_SIGN_STYLE": "Automatic",
                    "CURRENT_PROJECT_VERSION": "1",
                    "DEVELOPMENT_TEAM": "3X262XJF5T",
                    "DYLIB_COMPATIBILITY_VERSION": "1",
                    "DYLIB_CURRENT_VERSION": "1",
                    "DYLIB_INSTALL_NAME_BASE": "@rpath",
                    "ENABLE_MODULE_VERIFIER": "YES",
                    "INSTALL_PATH": "$(LOCAL_LIBRARY_DIR)/Frameworks",
                    "LD_RUNPATH_SEARCH_PATHS": [
                        "$(inherited)",
                        "@executable_path/Frameworks",
                        "@loader_path/Frameworks",
                    ],
                    "MARKETING_VERSION": "1.0",
                    "SKIP_INSTALL": "YES",
                    "STRING_CATALOG_GENERATE_SYMBOLS": "YES",
                    "SWIFT_INSTALL_OBJC_HEADER": "YES",
                    "SWIFT_INSTALL_MODULE": "YES",
                    "SWIFT_VERSION": "5.0",
                    "TARGETED_DEVICE_FAMILY": "1,2",
                ]
            )
        ),
    ]
)
