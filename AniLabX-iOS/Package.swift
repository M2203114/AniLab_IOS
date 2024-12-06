// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "AniLabX",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AniLabX",
            targets: ["AniLabX"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.12.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "AniLabX",
            dependencies: [
                "SDWebImage",
                "SDWebImageSwiftUI"
            ]),
        .testTarget(
            name: "AniLabXTests",
            dependencies: ["AniLabX"]),
    ]
)
