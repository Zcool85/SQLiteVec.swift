// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "SQLiteVec",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        // Produit principal qui réexporte SQLite + Vec
        .library(
            name: "SQLiteVec",
            targets: ["SQLiteVec"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.15.4")
    ],
    targets: [
        // Target C pour sqlite-vec uniquement (pas tout SQLite)
        .target(
            name: "CSQLiteVec",
            dependencies: [],
            path: "Sources/CSQLiteVec",
            sources: ["sqlite-vec.c"],
            publicHeadersPath: "include",
            cSettings: [
                .define("SQLITE_CORE"),
                .define("SQLITE_ENABLE_FTS5"),
                .unsafeFlags(["-w"])
            ],
            linkerSettings: [
                .linkedLibrary("c++")
            ]
        ),
        
        // Target Swift qui étend SQLite.swift avec Vec
        .target(
            name: "SQLiteVec",
            dependencies: [
                "CSQLiteVec",
                .product(name: "SQLite", package: "SQLite.swift")
            ],
            path: "Sources/SQLiteVec"
        ),
        
        .testTarget(
            name: "SQLiteVecTests",
            dependencies: ["SQLiteVec"],
            path: "Tests/SQLiteVecTests"
        )
    ],
    cLanguageStandard: .c11,
    cxxLanguageStandard: .cxx14
)