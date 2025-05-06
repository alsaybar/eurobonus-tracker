import ComposableArchitecture
import DatabaseClient
import Foundation
import GRDB

extension AnyDatabaseWriter: @retroactive DependencyKey {
    public static var liveValue: AnyDatabaseWriter {
        do {
            let fileManager = FileManager.default
            let folderURL = try fileManager
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("database", isDirectory: true)

            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)

            let dbURL = folderURL.appendingPathComponent("db.sqlite")
            let config = makeConfiguration()
            let dbPool = try DatabasePool(path: dbURL.path, configuration: config)

            return try AnyDatabaseWriter(makeAppDatabase(dbPool))
        } catch {
            fatalError("Failed to create database: \(error)")
        }
    }
}
