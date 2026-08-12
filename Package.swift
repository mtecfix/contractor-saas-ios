// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ContractorApp",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "ContractorApp", targets: ["ContractorApp"])
    ],
    targets: [
        .target(
            name: "ContractorApp",
            path: "ContractorApp"
        )
    ]
)
