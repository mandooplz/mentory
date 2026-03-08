import ProjectDescription

private func merged(
    _ base: SettingsDictionary,
    with overrides: SettingsDictionary
) -> SettingsDictionary {
    base.merging(overrides) { _, new in new }
}

private func stringSettings(
    _ values: [String: String]
) -> SettingsDictionary {
    values.reduce(into: [:]) { partialResult, element in
        partialResult[element.key] = .string(element.value)
    }
}

private func arraySettings(
    _ values: [String: [String]]
) -> SettingsDictionary {
    values.reduce(into: [:]) { partialResult, element in
        partialResult[element.key] = .array(element.value)
    }
}

extension Settings {
    public static func mentoryProject(
        configurations: [Configuration] = []
    ) -> Settings {
        .settings(
            base: .mentoryProjectBase,
            configurations: configurations
        )
    }

    public static func mentoryTarget(
        base: SettingsDictionary
    ) -> Settings {
        .settings(
            base: merged(.mentoryProjectBase, with: base)
        )
    }
}

extension SettingsDictionary {
    public static let mentoryProjectBase = stringSettings([
        "SWIFT_VERSION": Mentory.swiftVersion,
    ])

    public static func mentoryFrameworkModule(
        currentVersion: String = "1",
        marketingVersion: String = "1.0",
        targetedDeviceFamily: String = "1,2",
        dependencies: SettingsDictionary = [:]
    ) -> SettingsDictionary {
        merged(
            stringSettings([
                "BUILD_LIBRARY_FOR_DISTRIBUTION": "YES",
                "CODE_SIGN_STYLE": "Automatic",
                "CURRENT_PROJECT_VERSION": currentVersion,
                "DEVELOPMENT_TEAM": Mentory.developmentTeam,
                "DYLIB_COMPATIBILITY_VERSION": "1",
                "DYLIB_CURRENT_VERSION": "1",
                "DYLIB_INSTALL_NAME_BASE": "@rpath",
                "ENABLE_MODULE_VERIFIER": "YES",
                "INSTALL_PATH": "$(LOCAL_LIBRARY_DIR)/Frameworks",
                "MARKETING_VERSION": marketingVersion,
                "SKIP_INSTALL": "YES",
                "STRING_CATALOG_GENERATE_SYMBOLS": "YES",
                "SWIFT_INSTALL_MODULE": "YES",
                "SWIFT_INSTALL_OBJC_HEADER": "YES",
                "TARGETED_DEVICE_FAMILY": targetedDeviceFamily,
            ]).merging(
                arraySettings([
                    "LD_RUNPATH_SEARCH_PATHS": [
                        "$(inherited)",
                        "@executable_path/Frameworks",
                        "@loader_path/Frameworks",
                    ],
                ]),
                uniquingKeysWith: { _, new in new }
            ),
            with: dependencies
        )
    }

    public static func mentoryManualSigning(
        sdk: String,
        currentVersion: String,
        marketingVersion: String,
        targetedDeviceFamily: String,
        provisioningProfile: String? = nil,
        supportedPlatforms: String? = nil,
        extra: SettingsDictionary = [:]
    ) -> SettingsDictionary {
        var base = stringSettings([
            "CODE_SIGN_STYLE": "Manual",
            "CURRENT_PROJECT_VERSION": currentVersion,
            "DEVELOPMENT_TEAM[sdk=\(sdk)]": Mentory.developmentTeam,
            "MARKETING_VERSION": marketingVersion,
            "TARGETED_DEVICE_FAMILY": targetedDeviceFamily,
        ])

        if let provisioningProfile {
            base["PROVISIONING_PROFILE_SPECIFIER[sdk=\(sdk)]"] = .string(
                provisioningProfile
            )
        }

        if let supportedPlatforms {
            base["SUPPORTED_PLATFORMS"] = .string(supportedPlatforms)
        }

        return merged(base, with: extra)
    }
}
