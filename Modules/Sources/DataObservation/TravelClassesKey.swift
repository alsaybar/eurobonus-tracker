//
//  TravelClassesKey.swift
//  Modules
//
//  Created by Christian Alsaybar on 21/04/2025.
//

import SharingGRDB
import DatabaseClient

extension SharedReaderKey where Self == FetchKey<[TravelClass]> {
    public static func travelClasses(for airline: Airline) -> Self {
        @Dependency(\.appDB) var db
        return .fetch(
            TravelClassesRequest(airline: airline),
            database: db
        )
    }
}

// Travel classes are tied a distance multiplier rule, and are unique given an airline
struct TravelClassesRequest: FetchKeyRequest {
    let airline: Airline

    func fetch(_ db: Database) throws -> [TravelClass] {
        try TravelClass
            .joining(required: TravelClass.distanceMultiplierRules
                .filter(Column("airline_id") == airline.id)
            )
            .asRequest(of: TravelClass.self)
            .distinct()
            .fetchAll(db)
    }
}
