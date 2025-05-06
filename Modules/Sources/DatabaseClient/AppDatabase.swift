//
//  AppDatabase.swift
//  Modules
//
//  Created by Christian Alsaybar on 16/03/2025.
//

import Dependencies
import Foundation
import GRDB

public func makeAppDatabase(_ dbWriter: any DatabaseWriter) throws -> any DatabaseWriter {
    try makeMigrator().migrate(dbWriter)
    return dbWriter
}

extension AnyDatabaseWriter: @retroactive TestDependencyKey {
    public static let testValue: AnyDatabaseWriter = .previewValue
    public static var previewValue: AnyDatabaseWriter {
        do {
            let config = makeConfiguration()
            let dbQueue = try DatabaseQueue(configuration: config)

            // Seed mock data

            // TODO: makeAppDatabase is quite expensive, so consider seeding smaller dataset for preview and testing
            return try AnyDatabaseWriter(makeAppDatabase(dbQueue))
        } catch {
            fatalError("Failed to create in-memory database: \(error)")
        }
    }
}

extension DependencyValues {
    public var appDB: AnyDatabaseWriter {
        get { self[AnyDatabaseWriter.self] }
        set { self[AnyDatabaseWriter.self] = newValue }
    }
}
