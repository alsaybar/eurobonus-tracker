//
//  Records.swift
//  Modules
//
//  Created by Christian Alsaybar on 05/04/2025.
//

import Models
import GRDB
import Foundation

public struct SasDestination: Codable, Sendable, Hashable, Identifiable, FetchableRecord, TableRecord {
    public var id: Int64
    public var name: String

    public static let airports = hasMany(Airport.self, through: hasMany(SasDestinationAirport.self), using: SasDestinationAirport.airport)
}

public struct SasTicketType: Codable, Sendable, Hashable, FetchableRecord, TableRecord {
    public var id: Int64
    public var name: String

    public static let fixedPointRules = hasMany(FixedPointRule.self, key: "fixedPointRules", using: ForeignKey(["ticket_type_id"]))
}

public struct FixedPointRule: Codable, Sendable, FetchableRecord, PersistableRecord {
    public var id: Int64
    public var airline_id: Int64
    public var destination_id: Int64
    public var ticket_type_id: Int64
    public var booking_class: String
    public var level_points: Int
    public var bonus_points: Int
    public var valid_from: Date
    public var valid_to: Date?

    public static let destination = belongsTo(SasDestination.self, key: "destination")
    public static let ticketType = belongsTo(SasTicketType.self, key: "ticketType")
}

public struct TravelClass: Codable, Sendable, Hashable, Identifiable, FetchableRecord, TableRecord {
    public var id: Int64
    public var name: String
    public var display_name: String
    public var display_order: Int?

    public static let distanceMultiplierRules = hasMany(DistanceMultiplierRule.self, key: "distanceMultiplierRules", using: ForeignKey(["travel_class_id"]))
}

public struct DistanceMultiplierRule: Codable, Sendable, FetchableRecord, TableRecord {
    public var id: Int64
    public var airline_id: Int64
    public var travel_class_id: Int64
    public var booking_class: String
    public var distance_multiplier: Double
    public var bonus_multiplier: Double
    public var flight_category_id: Int64?
    public var valid_from: Date
    public var valid_to: Date?

    public static let travelClass = belongsTo(TravelClass.self, key: "travelClass")
}

struct FlightCategory: Codable, FetchableRecord, PersistableRecord {
    var id: Int64?
    var code: String
    var display_name: String
}

public struct SasDestinationAirport: Codable, FetchableRecord, PersistableRecord {
    public var sas_destination_id: Int64
    public var airport_id: Int64

    public static let sasDestination = belongsTo(SasDestination.self, key: "sasDestination", using: ForeignKey(["sas_destination_id"]))
    public static let airport = belongsTo(Airport.self, key: "airport", using: ForeignKey(["airport_id"]))

}


public struct Airline: Codable, Sendable, Identifiable, Hashable, TableRecord, FetchableRecord {
    public let id: Int64
    public let name: String
    public let minimumPoints: Int?
}

extension Airport: Codable, TableRecord, FetchableRecord {
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case name = "name"
        case latitude = "latitude_deg"
        case longitude = "longitude_deg"
        case isoCountry = "iso_country"
        case icaoCode = "icao_code"
        case iataCode = "iata_code"
        case metroArea = "metro_area"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let type = try container.decode(String.self, forKey: .type)
        let name = try container.decode(String.self, forKey: .name)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        let isoCountry = try container.decode(String.self, forKey: .isoCountry)
        let icaoCode = try container.decodeIfPresent(String.self, forKey: .icaoCode)
        let iataCode = try container.decodeIfPresent(String.self, forKey: .iataCode)
        let metroArea = try container.decodeIfPresent(String.self, forKey: .metroArea)

        self.init(
            id: id,
            type: type,
            name: name,
            latitude: latitude,
            longitude: longitude,
            isoCountry: isoCountry,
            icaoCode: icaoCode,
            iataCode: iataCode,
            metroArea: metroArea
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(name, forKey: .name)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(isoCountry, forKey: .isoCountry)
        try container.encode(icaoCode, forKey: .icaoCode)
        try container.encode(iataCode, forKey: .iataCode)
        try container.encode(metroArea, forKey: .metroArea)
    }
}
