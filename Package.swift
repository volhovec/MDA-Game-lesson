//
//  Package.swift
//  MDA Game
//
//  Created by Leonid Stefanenko on 28.10.2020.
//

// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "MDA Game",
    products: [
        .library(name: "MDA Game", targets: ["MDA Game"]),
    ],
    targets: [
        .target(
            name: "PlayingCard",
            dependencies: [
                .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.12.0")
            ]),
    ]
)
