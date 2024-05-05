// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "glide-sdk-swift",
    platforms: [.macOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "glide-sdk-swift",
            targets: ["glide-sdk-swift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/auth0/JWTDecode.swift", .upToNextMajor(from: "3.1.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "glide-sdk-swift",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "JWTDecode", package: "JWTDecode.swift")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "glide-sdk-swiftTests",
            dependencies: [
                "glide-sdk-swift"
            ]
        ),
    ]
)
