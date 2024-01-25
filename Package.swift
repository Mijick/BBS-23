// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BBS-Signature",
    products: [
        .library(name: "MijickBBS-Signature", targets: ["MijickBBS-Signature"]),
    ],
    dependencies: [
        .package(url: "https://github.com/leif-ibsen/BigInt", branch: "master")
    ],
    targets: [
        .target(name: "MijickBBS-Signature", dependencies: [.product(name: "BigInt", package: "BigInt")], path: "Sources"),
        .testTarget(name: "MijickBBS-SignatureTests", dependencies: ["MijickBBS-Signature", .product(name: "BigInt", package: "BigInt")], path: "Tests")
    ]
)
