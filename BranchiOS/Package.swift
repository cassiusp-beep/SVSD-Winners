// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "BranchiOS",
    platforms: [
        .iOS(.v26),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "BranchiOS",
            targets: ["BranchiOS"]
        ),
        .executable(
            name: "BranchApp",
            targets: ["BranchApp"]
        )
    ],
    targets: [
        .target(
            name: "BranchiOS",
            dependencies: [],
            path: "Sources/BranchiOS",
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "BranchApp",
            dependencies: ["BranchiOS"],
            path: "Sources/BranchApp"
        )
    ]
)
