// swift-tools-version: 5.9
import PackageDescription

let dependencies: [Target.Dependency] = [
    .product(name: "Algorithms", package: "swift-algorithms"),
    .product(name: "Collections", package: "swift-collections"),
    .product(name: "ArgumentParser", package: "swift-argument-parser"),
	.product(name: "AppUtils", package: "AppUtils"),
	.product(name: "SwiftPriorityQueue", package: "SwiftPriorityQueue")
]

let package = Package(
    name: "AdventOfCode",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-algorithms.git",
            .upToNextMajor(from: "1.2.0")),
        .package(
            url: "https://github.com/apple/swift-collections.git",
            .upToNextMajor(from: "1.0.0")),
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            .upToNextMajor(from: "1.2.0")),
        .package(
            url: "https://github.com/apple/swift-format.git",
            .upToNextMajor(from: "509.0.0")),
		.package(
			url: "https://github.com/eriksargent/AppUtils.git",
			.upToNextMajor(from: "1.0.0")),
		.package(
			url: "https://github.com/davecom/SwiftPriorityQueue.git",
			.upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .executableTarget(
            name: "AdventOfCode",
            dependencies: dependencies,
            resources: [.copy("Data")]),
        .testTarget(
            name: "AdventOfCodeTests",
            dependencies: ["AdventOfCode"] + dependencies
        )
    ]
)

// https://stackoverflow.com/a/75608198/866149
let swiftSettings: [SwiftSetting] = [
	.enableUpcomingFeature("BareSlashRegexLiterals")
]

for target in package.targets {
	target.swiftSettings = target.swiftSettings ?? []
	target.swiftSettings?.append(contentsOf: swiftSettings)
}
