//
//  SASBookingClassesKey.swift
//  Modules
//
//  Created by Christian Alsaybar on 20/04/2025.
//

import SharingGRDB
import DatabaseClient

extension SharedReaderKey where Self == FetchKey<[FixedPointRule]> {
    public static func sasBookingClasses(
        for destination: SasDestination,
        ticketType: SasTicketType
    ) -> Self {
        @Dependency(\.appDB) var db
        return .fetch(
            SasBookingClassesRequest(
                destination: destination,
                ticketType: ticketType
            ),
            database: db
        )
    }
}

// Booking classes are tied a fixed point rule, and are unique given a destination and ticket type
struct SasBookingClassesRequest: FetchKeyRequest {
    let destination: SasDestination
    let ticketType: SasTicketType

    func fetch(_ db: Database) throws -> [FixedPointRule] {
        try FixedPointRule
            .filter(Column("destination_id") == destination.id)
            .filter(Column("ticket_type_id") == ticketType.id)
            .fetchAll(db)
    }
}

extension SharedReaderKey where Self == FetchKey<FixedPointRule?> {
    public static func fixedPointsRule(
        for destination: SasDestination,
        ticketType: SasTicketType,
        bookingClass: String
    ) -> Self {
        @Dependency(\.appDB) var db
        return .fetch(
            SasFixedPointsRequest(
                destination: destination,
                ticketType: ticketType,
                bookingClass: bookingClass
            ),
            database: db
        )
    }
}


struct SasFixedPointsRequest: FetchKeyRequest {
    let destination: SasDestination
    let ticketType: SasTicketType
    let bookingClass: String

    func fetch(_ db: Database) throws -> FixedPointRule? {
        try FixedPointRule
            .filter(Column("destination_id") == destination.id)
            .filter(Column("ticket_type_id") == ticketType.id)
            .filter(Column("booking_class") == bookingClass)
            .fetchOne(db)
    }
}
