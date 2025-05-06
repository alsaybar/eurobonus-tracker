//
//  FlightInputView.swift
//  Modules
//
//  Created by Christian Alsaybar on 20/04/2025.
//

import SwiftUI
import SharingGRDB
import DatabaseClient
import Models
import CoreLocation

struct FlightInputView: View {

    enum FocusField {
        case airport
    }

    @FocusState
    var focusState: FocusField?

    @SharedReader(.airlines)
    var airlines: [Airline] = []

    @SharedReader(value: [])
    var travelClasses: [TravelClass]

    @State.SharedReader(value: [])
    var bookingClasses: [DistanceMultiplierRule]

    @State.SharedReader(value: nil)
    var pointsRule: DistanceMultiplierRule?

    @SharedReader(wrappedValue: [], .airports(matching: ""))
    var airports: [Airport]

    @State var selectedAirline: Airline?
    @State var selectedTravelClass: TravelClass?
    @State var selectedBookingClass: String?
    @State var selectedFrom: Airport?
    @State var selectedTo: Airport?


    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            HStack {
                VStack(alignment: .leading) {
                    Label("From", systemImage: "airplane.departure")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)

                    Menu {
                        ForEach(airports, id: \.id) { airport in
                            Button {
                                selectedFrom = airport
                            } label: {
                                Text(airport.name)
                            }
                        }
                    } label: {
                        Text(selectedFrom?.iataCode ?? selectedFrom?.name ?? "Select Airline")
                            .font(.headline.monospaced())
                            .tint(selectedFrom == nil ? .secondary : .primary)
                            .frame(maxWidth: .infinity)
                            .textFieldInputStyle()
                    }
                }

                VStack(alignment: .leading) {
                    Label("To", systemImage: "airplane.arrival")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)

                    Menu {
                        ForEach(airports, id: \.id) { airport in
                            Button {
                                selectedTo = airport
                            } label: {
                                Text(airport.name)
                            }
                        }
                    } label: {
                        Text(selectedTo?.iataCode ?? selectedTo?.name ?? "Select Airline")
                            .font(.headline.monospaced())
                            .tint(selectedTo == nil ? .secondary : .primary)
                            .frame(maxWidth: .infinity)
                            .textFieldInputStyle()
                    }
                }

            }

            VStack(alignment: .leading) {
                Label("Airline", systemImage: "airplane")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                Menu {
                    ForEach(airlines, id: \.id) { airline in
                        Button {
                            selectedAirline = airline
                            Task {
                                try? await $travelClasses.load(
                                    .travelClasses(for: airline)
                                )
                            }
                        } label: {
                            Text(airline.name)
                        }
                    }
                } label: {
                    Text(selectedAirline?.name ?? "Select Airline")
                        .font(.headline.monospaced())
                        .tint(selectedAirline == nil ? .secondary : .primary)
                        .frame(maxWidth: .infinity)
                        .textFieldInputStyle()
                }
            }


            HStack {
                VStack(alignment: .leading) {
                    Label("Travel class", systemImage: "tag")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    Menu {
                        ForEach(travelClasses, id: \.id) { travelClass in
                            Button {
                                selectedTravelClass = travelClass
                                Task {
                                    try? await $bookingClasses.load(
                                        .bookingClasses(
                                            for: selectedAirline!,
                                            travelClass: travelClass
                                        )
                                    )
                                }
                            } label: {
                                Text(travelClass.display_name)
                            }
                        }
                    } label: {
                        Text(selectedTravelClass?.display_name ?? "Select Class")
                            .font(.headline.monospaced())
                            .tint(selectedTravelClass == nil ? .secondary : .primary)
                            .frame(maxWidth: .infinity)
                            .textFieldInputStyle()
                    }
                }

                VStack(alignment: .leading) {
                    Label("Booking Class", systemImage: "rectangle.grid.1x2")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    Menu {
                        ForEach(bookingClasses, id: \.id) { bookingClass in
                            Button {
                                selectedBookingClass = bookingClass.booking_class
                                Task {
                                    try? await $pointsRule.load(
                                        .distanceMultiplierRule(
                                            for: selectedAirline!,
                                            travelClass: selectedTravelClass!,
                                            bookingClass: selectedBookingClass!
                                        )
                                    )
                                }
                            } label: {
                                Text(bookingClass.booking_class)
                            }
                        }
                    } label: {
                        Text(selectedBookingClass ?? "Class")
                            .font(.headline.monospaced())
                            .tint(selectedBookingClass == nil ? .secondary : .primary)
                            .frame(maxWidth: .infinity)
                            .textFieldInputStyle()
                    }
                }
            }

            if let pointsRule, let selectedFrom, let selectedTo {
                let miles = airportDistance(from: selectedFrom, to: selectedTo)
                let levelPoints = levelPoints(
                    miles: miles,
                    distanceMultiplier: pointsRule.distance_multiplier,
                    bookingClassMultiplier: pointsRule.bonus_multiplier
                )

                let bonusPoints = bonusPoints(
                    miles: miles,
                    distanceMultiplier: pointsRule.distance_multiplier,
                    bookingClassMultiplier: pointsRule.bonus_multiplier,
                    tierLevelMultiplier: 0.25
                )
                HStack {
                    VStack(alignment: .leading) {
                        Label("Level points", systemImage: "chart.bar.fill")
                            .foregroundStyle(.secondary)
                        Text("\(levelPoints)")
                            .contentTransition(.numericText())
                            .font(.title.monospacedDigit())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textFieldInputStyle()

                    VStack(alignment: .leading) {
                        Label("Bonus points", systemImage: "sparkles")
                            .foregroundStyle(.secondary)
                        Text("\(bonusPoints)")
                            .contentTransition(.numericText())
                            .font(.title.monospacedDigit())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textFieldInputStyle()
                }
                .transition(.scale.combined(with: .opacity))
                .onAppear {
                    print("p rule: \(pointsRule)")
                }
            }
        }
        .padding(.horizontal)
        .fontDesign(.rounded)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    func airportDistance(from: Airport, to: Airport) -> Double {
        let coordinate1 = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let coordinate2 = CLLocation(latitude: to.latitude, longitude: to.longitude)

        // Calculate distance in meters
        let distanceInMeters = coordinate1.distance(from: coordinate2)

        // Convert to a measurement for easy formatting
        let distance = Measurement(value: distanceInMeters, unit: UnitLength.meters)

        let miles = distance.converted(to: .miles)
        return miles.value
    }

    func levelPoints(
        miles: Double,
        distanceMultiplier: Double,
        bookingClassMultiplier: Double
    ) -> Int {
        print("Dist mult: \(distanceMultiplier)")
        print("class mult: \(bookingClassMultiplier)")
        let points = miles * (distanceMultiplier + bookingClassMultiplier)

        return Int(points)
    }

    func bonusPoints(
        miles: Double,
        distanceMultiplier: Double,
        bookingClassMultiplier: Double,
        tierLevelMultiplier: Double = .zero
    ) -> Int {
        let tierLevelBoost = distanceMultiplier * tierLevelMultiplier
        let points = miles * (distanceMultiplier + bookingClassMultiplier + tierLevelBoost)

        return Int(points)
    }
}

extension View {
    func textFieldInputStyle() -> some View {
        self
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    FlightInputView()
}
