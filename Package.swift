// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Kofktu",
    platforms: [.iOS(.v9)],
    products: [
        .library(name: "KofktuSDK", targets: ["KofktuSDK"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "4.9.1")),
        .package(url: "https://github.com/tristanhimmelman/ObjectMapper.git", .exact("3.5.3")),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", .exact("5.9.5")),
        .package(url: "https://github.com/achernoprudov/Toaster.git", .branch("spm")),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", .upToNextMajor(from: "3.2.1")),
        .package(url: "https://github.com/Kofktu/Sniffer.git", .upToNextMajor(from: "2.1.2"))
    ],
    targets: [
        .target(
            name: "KofktuSDK",
            dependencies: [
                "Alamofire",
                "ObjectMapper",
                "SDWebImage",
                "KeychainAccess",
                "Sniffer",
                "Toaster",
            ],
            path: "KofktuSDK/Classes"
        )
    ],
    swiftLanguageVersions: [.v5]
)

