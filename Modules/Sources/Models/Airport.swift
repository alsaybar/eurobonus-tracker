//
//  Airport.swift
//  Modules
//
//  Created by Christian Alsaybar on 05/04/2025.
//

public struct Airport: Sendable, Identifiable, Hashable {
    public let id: String
    public let type: String
    public let name: String
    public let latitude: Double
    public let longitude: Double
    public let isoCountry: String
    public let icaoCode: String?
    public let iataCode: String?
    public let metroArea: String?

    public init(
        id: String,
        type: String,
        name: String,
        latitude: Double,
        longitude: Double,
        isoCountry: String,
        icaoCode: String?,
        iataCode: String?,
        metroArea: String?
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.isoCountry = isoCountry
        self.icaoCode = icaoCode
        self.iataCode = iataCode
        self.metroArea = metroArea
    }
}
