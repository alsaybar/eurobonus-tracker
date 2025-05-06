//
//  AirportSearchKey.swift
//  Modules
//
//  Created by Christian Alsaybar on 05/04/2025.
//

import SharingGRDB
import Models
import DatabaseClient

extension SharedReaderKey where Self == FetchKey<[Airport]> {
    public static func airports(matching term: String) -> Self {
        @Dependency(\.appDB) var db
        return .fetch(AirportSearchRequest(searchTerm: term), database: db)
    }
}

struct AirportSearchRequest: FetchKeyRequest {
    let searchTerm: String

    func fetch(_ db: Database) throws -> [Airport] {
        guard !searchTerm.isEmpty else {
            return try Airport
                .order(Column("iata_code").ascNullsLast)
                .fetchAll(db)
        }

        let pattern = FTS5Pattern(matchingAllPrefixesIn: searchTerm)

        let ftsTableName = "airport_fts"
        let association = Airport
            .hasOne(Table(ftsTableName), using: ForeignKey([.rowID]))
            .matching(pattern)
            .order(sql: "bm25(\(ftsTableName), 1.0, 0.5, 2.0, 1.5)") // Weights: name, icao_code, iata_code, metro_area


        let airportsSearch = try Airport
            .joining(required: association)
            .fetchAll(db)

        return airportsSearch
    }
}
