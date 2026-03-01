// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "HOTH Project",
    platforms: [
        .iOS(.v16)
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.20.0")
    ],
    targets: [
        .target(
            name: "HOTH Project",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk")
            ]
        )
    ]
)
