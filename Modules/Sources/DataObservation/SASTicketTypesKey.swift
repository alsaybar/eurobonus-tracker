//
//  SASTicketTypesKey.swift
//  Modules
//
//  Created by Christian Alsaybar on 20/04/2025.
//

import SharingGRDB
import DatabaseClient

extension SharedReaderKey where Self == FetchKey<[SasTicketType]> {
    public static var sasTicketTypes: Self {
        @Dependency(\.appDB) var db
        return .fetch(SasTicketTypesRequest(), database: db)
    }

    public static func sasTicketTypes(for destination: SasDestination) -> Self {
        @Dependency(\.appDB) var db
        return .fetch(SasTicketTypesForDestinationRequest(destination: destination), database: db)
    }
}

struct SasTicketTypesRequest: FetchKeyRequest {
    func fetch(_ db: Database) throws -> [SasTicketType] {
        try SasTicketType.fetchAll(db)
    }
}

struct SasTicketTypesForDestinationRequest: FetchKeyRequest {
    let destination: SasDestination

    func fetch(_ db: Database) throws -> [SasTicketType] {
        let tickettypes = try SasTicketType
            .joining(required: SasTicketType.fixedPointRules
                .joining(required: FixedPointRule.destination)
                    .filter(Column("destination_id") == destination.id)
            )
            .distinct()
            .asRequest(of: SasTicketType.self)
            .fetchAll(db)
        print("Fetched ticket types: \(tickettypes)")

        return tickettypes
    }
}
