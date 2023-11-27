// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MijickBBS23",
    products: [
        .library(name: "MijickBBS23", targets: ["MijickBBS23"]),
    ],
    dependencies: [
        .package(url: "https://github.com/leif-ibsen/BigInt", branch: "master")
    ],
    targets: [
        .target(name: "MijickBBS23", dependencies: [.product(name: "BigInt", package: "BigInt")], path: "Sources"),
        .testTarget(name: "MijickBBS23Tests", dependencies: ["MijickBBS23", .product(name: "BigInt", package: "BigInt")], path: "Tests")
    ]
)
