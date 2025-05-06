//
//  DistanceMultiplierRuleKey.swift
//  Modules
//
//  Created by Christian Alsaybar on 21/04/2025.
//

import SharingGRDB
import DatabaseClient

extension SharedReaderKey where Self == FetchKey<[DistanceMultiplierRule]> {
    public static func bookingClasses(
        for airline: Airline,
        travelClass: TravelClass
    ) -> Self {
        @Dependency(\.appDB) var db
        return .fetch(
            BookingClassesRequest(
                airline: airline,
                travelClass: travelClass
            ),
            database: db
        )
    }
}

// Booking classes are tied a distance multiplier rule, and are unique given an airline and travel class
struct BookingClassesRequest: FetchKeyRequest {
    let airline: Airline
    let travelClass: TravelClass

    func fetch(_ db: Database) throws -> [DistanceMultiplierRule] {
        try DistanceMultiplierRule
            .filter(Column("airline_id") == airline.id)
            .filter(Column("travel_class_id") == travelClass.id)
            .fetchAll(db)
    }
}

extension SharedReaderKey where Self == FetchKey<DistanceMultiplierRule?> {
    public static func distanceMultiplierRule(
        for airline: Airline,
        travelClass: TravelClass,
        bookingClass: String
    ) -> Self {
        @Dependency(\.appDB) var db
        return .fetch(
            DistanceMultiplierPointsRequest(
                airline: airline,
                travelClass: travelClass,
                bookingClass: bookingClass
            ),
            database: db
        )
    }
}


struct DistanceMultiplierPointsRequest: FetchKeyRequest {
    let airline: Airline
    let travelClass: TravelClass
    let bookingClass: String

    func fetch(_ db: Database) throws -> DistanceMultiplierRule? {
        try DistanceMultiplierRule
            .filter(Column("airline_id") == airline.id)
            .filter(Column("travel_class_id") == travelClass.id)
            .filter(Column("booking_class") == bookingClass)
            .fetchOne(db)
    }
}
