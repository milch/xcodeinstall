// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xcodeinstall",
    platforms: [
        .macOS(.v12)
    ],    
    products: [
        .executable(name: "xcodeinstall", targets: ["xcodeinstall"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/soto-project/soto.git", from: "6.8.0"),
        .package(url: "https://github.com/sebsto/CLIlib/", from: "0.1.2"),
        .package(url: "https://github.com/adam-fowler/swift-srp", branch: "padding"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", from: "1.8.3")
        
        //.package(path: "../CLIlib")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "xcodeinstall",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SotoSecretsManager", package: "soto"),
                .product(name: "SRP", package: "swift-srp"),
                .product(name: "CLIlib", package: "CLIlib"),
                .product(name: "CryptoSwift", package: "CryptoSwift")
//                .product(name: "_CryptoExtras", package: "swift-crypto")
            ]
        ),
        .testTarget(
            name: "xcodeinstallTests",
            dependencies: ["xcodeinstall"],
            // https://stackoverflow.com/questions/47177036/use-resources-in-unit-tests-with-swift-package-manager
            resources: [.process("data/download-list-20220723.json"),
                        .process("data/download-list-20231115.json"),
                        .process("data/download-error.json"),
                        .process("data/download-unknown-error.json")] //,
            // swiftSettings: [
            //     .define("SWIFTPM_COMPILATION")
            // ]
        )
    ],
    swiftLanguageModes: [.v5]
)
