// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: .models, targets: [.models]),
        .library(name: .databaseClient, targets: [.databaseClient]),
        .library(name: .databaseClient.live, targets: [.databaseClient.live]),
        .library(name: .dataObservation, targets: [.dataObservation]),
        .library(name: .flightInputFeature, targets: [.flightInputFeature]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.19.0"),
        .package(url: "https://github.com/groue/GRDB.swift", from: "7.0.3"),
        .package(url: "https://github.com/pointfreeco/sharing-grdb.git", from: "0.1.1"),
    ],
    targets: [
        .target(
            name: .models,
            dependencies: [
                .composableArchitecture,
            ]
        ),
        .target(
            name: .databaseClient,
            dependencies: [
                .composableArchitecture,
                .models,
                .grdb,
            ]
        ),
        .target(
            name: .databaseClient.live,
            dependencies: [
                .composableArchitecture,
                //                .models,
                .databaseClient,
                .grdb,
            ]
        ),
        .testTarget(
            name: .databaseClient.tests,
            dependencies: [
                .databaseClient,
                .models,
            ]
        ),
        .target(
            name: .dataObservation,
            dependencies: [
                .models,
                .databaseClient,
                .sharingGRDB,
            ]
        ),
        .target(
            name: .flightInputFeature,
            dependencies: [
                .composableArchitecture,
                .models,
                .dataObervation,
            ]
        )
    ]
)

// MARK: - External Packages

extension String {
    static let composableArchitecture = "ComposableArchitecture"
    static let grdb = "GRDB"
    static let sharingGRDB = "SharingGRDB"
}

@MainActor
extension Target.Dependency {
    static let composableArchitecture = product(name: .composableArchitecture, package: "swift-composable-architecture")
    static let grdb = product(name: .grdb, package: "GRDB.swift")
    static let sharingGRDB = product(name: .sharingGRDB, package: "sharing-grdb")
}

// MARK: - Modules

extension String {
    // Core
    static let models = "Models"
    static let databaseClient = "DatabaseClient"
    static let dataObservation = "DataObservation"

    // Features
    static let flightInputFeature = "FlightInputFeature"
}

@MainActor
extension Target.Dependency {
    // Core
    static let models = byName(name: .models)
    static let databaseClient = byName(name: .databaseClient)
    static let dataObervation = byName(name: .dataObservation)

    // Features
    static let flightInputFeature = byName(name: .flightInputFeature)
}

extension String {
    var tests: String { self + "Tests" }
    var live: String { self + "Live" }
}
