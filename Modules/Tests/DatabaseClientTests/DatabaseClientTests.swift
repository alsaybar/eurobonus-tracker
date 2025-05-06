@testable import DatabaseClient
import Foundation
import GRDB
import Testing
import ComposableArchitecture
import Models

@Suite("Database Client Tests")
struct DatabaseClientTests {
    @Test("Database creation succeeds and creates workflow table")
    // swiftlint:disable:next function_body_length
    func testDatabaseCreation() async throws {
        @Dependency(\.appDB) var db

        try await db.read { db in

            let pattern = FTS5Pattern(matchingAllPrefixesIn: "ohare")

            let ftsTableName = "airport_fts"
            let association = Airport
                .hasOne(Table(ftsTableName), using: ForeignKey([.rowID]))
                .matching(pattern)
                .order(sql: "bm25(\(ftsTableName), 0.1, 1.0, 0.5, 2.0)") // Rank IATA, then airport name highest


            let airportsSearch = try Airport
                .joining(required: association)
                .fetchAll(db)

            print("airportsSearch", airportsSearch)
        }

    }

    @Test
    func testDatabaseCreation2() async throws {

        @Dependency(\.appDB) var db

        try await db.read { db in
            print(try Airline.fetchAll(db))
            try db.execute(sql: """
            select * from SasDestination;
            """)
        }

        let levelAndBonusPoints = try await db.read { db in
            try FixedPointRule
                .including(required: FixedPointRule.destination
                    .including(required: SasDestination.airports
                        .filter(Column("id") == Airport.filter(Column("iata_code") == "ORD").select(Column("id")))))
                .including(required: FixedPointRule.ticketType
                    .filter(Column("name") == "Business Pro"))
                .filter(Column("booking_class") == "J")
                .fetchAll(db)
                .map { ($0.level_points, $0.bonus_points) }
        }

        print("Level and bonus points: \(levelAndBonusPoints)")
    }
}

