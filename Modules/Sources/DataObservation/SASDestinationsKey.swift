//
//  SASDestinationsKey.swift
//  Modules
//
//  Created by Christian Alsaybar on 20/04/2025.
//

import SharingGRDB
import DatabaseClient

extension SharedReaderKey where Self == FetchKey<[SasDestination]> {
    public static var sasDestinations: Self {
        @Dependency(\.appDB) var db
        return .fetch(SasDestinationsRequest(), database: db)
    }
}

struct SasDestinationsRequest: FetchKeyRequest {
    func fetch(_ db: Database) throws -> [SasDestination] {
        try SasDestination.fetchAll(db)
    }
}
