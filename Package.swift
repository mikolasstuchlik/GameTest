// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GameTest",
    dependencies: [
    ],
    targets: [
        .systemLibrary(
            name: "CSDL2",
            pkgConfig: "sdl2 SDL2_image",
            providers: [
                .apt(["libsdl2-dev", "libsdl2-image-dev"]),
                .brew(["sdl2", "sdl2_image"])
            ]
        ),
        .executableTarget(
            name: "GameTest", 
            dependencies: [
                "CSDL2"
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
