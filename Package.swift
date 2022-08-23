// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GirdersSwift",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "GirdersSwift",
            targets: ["GirdersSwift", "GRSecurity"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", exact: "1.9.5"),
        .package(url: "https://github.com/mxcl/PromiseKit.git", exact: "6.17.1"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", exact: "4.2.2"),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", exact: "9.0.0")
    ],
    targets: [
        .target(
            name: "GirdersSwift",
            dependencies: ["SwiftyBeaver", "PromiseKit", "KeychainAccess"]),
        .binaryTarget(
            name: "GRSecurity",
            path: "Sources/GRSecurity.xcframework"
        ),
        .testTarget(
            name: "GirdersSwiftTests",
            dependencies: [
                "GirdersSwift",
                "SwiftyBeaver",
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs")
            ],
            resources: [
                .process("resources")
            ]
        )
    ]
)
