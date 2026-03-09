import ProjectDescription

extension Target {
    public static func mentoryTarget(
        name: String,
        destinations: Destinations,
        product: Product,
        productName: String? = nil,
        bundleId: String? = nil,
        deploymentTargets: DeploymentTargets,
        infoPlist: InfoPlist? = nil,
        sources: SourceFilesList? = nil,
        resources: ResourceFileElements? = nil,
        entitlements: Entitlements? = nil,
        dependencies: [TargetDependency] = [],
        settings: Settings? = nil
    ) -> Target {
        .target(
            name: name,
            destinations: destinations,
            product: product,
            productName: productName,
            bundleId: bundleId ?? Mentory.bundleId(name),
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            entitlements: entitlements,
            dependencies: dependencies,
            settings: settings
        )
    }

    public static func mentoryStaticLibrary(
        name: String,
        sources: SourceFilesList,
        resources: ResourceFileElements? = [],
        dependencies: [TargetDependency] = [],
        destinations: Destinations = .iOS,
        deploymentTargets: DeploymentTargets = Mentory.iOSDeploymentTargets,
        bundleId: String? = nil,
        settings: Settings? = nil
    ) -> Target {
        .mentoryTarget(
            name: name,
            destinations: destinations,
            product: .staticLibrary,
            bundleId: bundleId,
            deploymentTargets: deploymentTargets,
            sources: sources,
            resources: resources,
            dependencies: dependencies,
            settings: settings
        )
    }

    public static func mentoryFramework(
        name: String,
        sources: SourceFilesList,
        resources: ResourceFileElements? = [],
        dependencies: [TargetDependency] = [],
        destinations: Destinations = .iOS,
        deploymentTargets: DeploymentTargets = Mentory.iOSDeploymentTargets,
        product: Product = .framework,
        bundleId: String? = nil,
        infoPlist: InfoPlist = .default,
        entitlements: Entitlements? = nil,
        settings: Settings? = nil
    ) -> Target {
        .mentoryTarget(
            name: name,
            destinations: destinations,
            product: product,
            bundleId: bundleId,
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            entitlements: entitlements,
            dependencies: dependencies,
            settings: settings
        )
    }

    public static func mentoryApp(
        name: String,
        productName: String,
        bundleId: String,
        sources: SourceFilesList,
        resources: ResourceFileElements? = [],
        dependencies: [TargetDependency] = [],
        infoPlist: InfoPlist,
        entitlements: Entitlements? = nil,
        deploymentTargets: DeploymentTargets = Mentory.iOSDeploymentTargets,
        settings: Settings? = nil
    ) -> Target {
        .mentoryTarget(
            name: name,
            destinations: .iOS,
            product: .app,
            productName: productName,
            bundleId: Mentory.bundleId(bundleId),
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            entitlements: entitlements,
            dependencies: dependencies,
            settings: settings
        )
    }

    public static func mentoryUnitTests(
        name: String,
        sources: SourceFilesList,
        resources: ResourceFileElements? = [],
        dependencies: [TargetDependency] = [],
        infoPlist: InfoPlist = .default,
        deploymentTargets: DeploymentTargets = Mentory.iOSDeploymentTargets,
        settings: Settings? = nil
    ) -> Target {
        .mentoryTarget(
            name: name,
            destinations: .iOS,
            product: .unitTests,
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            dependencies: dependencies,
            settings: settings
        )
    }

    public static func mentoryAppExtension(
        name: String,
        bundleId: String,
        sources: SourceFilesList,
        resources: ResourceFileElements? = [],
        dependencies: [TargetDependency] = [],
        infoPlist: InfoPlist,
        entitlements: Entitlements? = nil,
        deploymentTargets: DeploymentTargets = Mentory.iOSDeploymentTargets,
        settings: Settings? = nil
    ) -> Target {
        .mentoryTarget(
            name: name,
            destinations: .iOS,
            product: .appExtension,
            bundleId: Mentory.bundleId(bundleId),
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            entitlements: entitlements,
            dependencies: dependencies,
            settings: settings
        )
    }
}
