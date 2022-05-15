// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GameTest",
    dependencies: [
    ],
    targets: [
        .systemLibrary(
            name: "CLibs",
            pkgConfig: "libpng sdl2 SDL2_image",
            providers: [.apt(["libpng-dev", "libsdl2-dev", "libsdl2-image-dev"])]
        ),
        .executableTarget(
            name: "GameTest", 
            dependencies: [
                "CLibs"
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
