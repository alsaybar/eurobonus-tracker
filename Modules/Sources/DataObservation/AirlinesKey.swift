//
//  AirlinesKey.swift
//  Modules
//
//  Created by Christian Alsaybar on 21/04/2025.
//

import SharingGRDB
import DatabaseClient

extension SharedReaderKey where Self == FetchKey<[Airline]> {
    public static var airlines: Self {
        @Dependency(\.appDB) var db
        return .fetch(AirlinesRequest(), database: db)
    }
}

struct AirlinesRequest: FetchKeyRequest {
    func fetch(_ db: Database) throws -> [Airline] {
        try Airline.fetchAll(db)
    }
}
