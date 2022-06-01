// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GameTest",
    platforms: [.macOS("10.15")],
    dependencies: [
        .package(url: "https://github.com/mikolasstuchlik/NoobECS.git", branch: "master")
    ],
    targets: [
        .systemLibrary(
            name: "CSDL2",
            pkgConfig: "sdl2 sdl2_image sdl2_ttf",
            providers: [
                .apt(["libsdl2-dev", "libsdl2-image-dev", "libsdl2-ttf-dev"]),
                .brew(["sdl2", "sdl2_image", "sdl2_ttf"])
            ]
        ),
        .executableTarget(
            name: "GameTest", 
            dependencies: [
                "CSDL2",
                .product(name: "NoobECS", package: "NoobECS"),
                .product(name: "NoobECSStores", package: "NoobECS")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
