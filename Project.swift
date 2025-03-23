import ProjectDescription

let majorVersion: Int = 1
let minorVersion: Int = 0
let patchVersion: Int = 0
let versionString: Plist.Value = "\(majorVersion).\(minorVersion).\(patchVersion)"

let plist: InfoPlist = .extendingDefault(
    with: [
        "UILaunchScreen": [
            "UIColorName": "LaunchScreenBackgroundColor",
        ],
        "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"],
        "UIUserInterfaceStyle": "Dark",
        "NSCameraUsageDescription": "Camera permission is needed.",
        "NSMicrophoneUsageDescription": "Mic permission is needed.",
        "NSPhotoLibraryUsageDescription": "Photos permission is needed.",
        "NSLocationWhenInUseUsageDescription": true,
        "ITSAppUsesNonExemptEncryption": false,
        "CFBundleShortVersionString": versionString,
    ]
)

let releasedDependencies: [TargetDependency] = [
    .external(name: "Obscura"),
    .external(name: "LightMeter"),
]

let devDependencies: [TargetDependency] = [
    .project(target: "Obscura", path: "../../Modules/Obscura"),
    .project(target: "LightMeter", path: "../../Modules/LightMeter"),
    .project(target: "HaebitUI", path: "../../Modules/HaebitUI"),
]

let settings: Settings = .settings(
    base: [
        "DEVELOPMENT_TEAM": "5HZQ3M82FA",
        "SWIFT_STRICT_CONCURRENCY": "complete"
    ],
    configurations: [
        .debug(name: .debug),
        .release(name: .release),
    ],
    defaultSettings: .recommended
)

let targets: [Target] = [
    Target(
        name: "MidnightExpDev",
        platform: .iOS,
        product: .app,
        bundleId: "com.seunghun.midnightexp.dev",
        deploymentTarget: .iOS(targetVersion: "17.0", devices: [.iphone]),
        infoPlist: plist,
        sources: ["MidnightExp/Sources/**"],
        resources: [
            "MidnightExp/Resources/Common/**",
            "MidnightExp/Resources/Dev/**"
        ],
        dependencies: devDependencies,
        settings: settings
    ),
    Target(
        name: "MidnightExp",
        platform: .iOS,
        product: .app,
        bundleId: "com.seunghun.midnightexp",
        deploymentTarget: .iOS(targetVersion: "17.0", devices: [.iphone]),
        infoPlist: plist,
        sources: ["MidnightExp/Sources/**"],
        resources: [
            "MidnightExp/Resources/Common/**",
            "MidnightExp/Resources/Real/**"
        ],
        dependencies: devDependencies,
        settings: settings
    )
]

let project = Project(
    name: "MidnightExp",
    organizationName: "seunghun",
    targets: targets,
    schemes: [
        Scheme(
            name: "MidnightExpDev",
            buildAction: .buildAction(targets: ["MidnightExpDev"]),
            runAction: .runAction(configuration: .debug),
            profileAction: .profileAction(configuration: .debug),
            analyzeAction: .analyzeAction(configuration: .debug)
        ),
        Scheme(
            name: "MidnightExp",
            buildAction: .buildAction(targets: ["MidnightExp"]),
            runAction: .runAction(configuration: .release),
            archiveAction: .archiveAction(configuration: .release),
            profileAction: .profileAction(configuration: .release)
        )
    ]
)
