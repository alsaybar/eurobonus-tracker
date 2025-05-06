//
//  SASFlightInputView.swift
//  Modules
//
//  Created by Christian Alsaybar on 20/04/2025.
//

import SwiftUI
import DatabaseClient
import DataObservation
import ComposableArchitecture

struct SASFlightInputView: View {

    enum FocusField {
        case airport
    }

    @FocusState
    var focusState: FocusField?

    @State var destinationSearchText = ""
    @State var toSearch = ""

    @State var selectedDestination: SasDestination?
    @State var selectedTicketType: SasTicketType?
    @State var selectedBookingClass: String?

    @SharedReader(.sasDestinations)
    var destinations: [SasDestination] = []

    @State.SharedReader(value: [])
    var ticketTypes: [SasTicketType]

    @State.SharedReader(value: [])
    var bookingClasses: [FixedPointRule]

    @State.SharedReader(value: nil)
    var pointsRule: FixedPointRule?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading) {
                    Label("From", systemImage: "airplane.departure")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)

                    TextField(text: $destinationSearchText, prompt: Text("Airport")) {
                        Text("Airport")
                            .font(.subheadline)
                    }
                    .textFieldInputStyle()
                    .focused($focusState, equals: .airport)
                }

                if selectedDestination != nil {
                    VStack(alignment: .leading) {
                        Label("To", systemImage: "airplane.arrival")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        TextField("", text: $toSearch, prompt: Text("Airport"))
                            .textFieldInputStyle()
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }

            }

            if selectedDestination != nil && !toSearch.isEmpty {

                HStack {
                    VStack(alignment: .leading) {
                        Label("Ticket Type", systemImage: "tag")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        Menu {
                            ForEach(ticketTypes, id: \.id) { ticket in
                                Button {
                                    selectedTicketType = ticket
                                    Task {
                                        try? await $bookingClasses.load(
                                            .sasBookingClasses(
                                                for: selectedDestination!,
                                                ticketType: ticket
                                            )
                                        )
                                    }
                                } label: {
                                    Text(ticket.name)
                                }
                            }
                        } label: {
                            Text(selectedTicketType?.name ?? "Select Ticket")
                                .font(.headline.monospaced())
                                .tint(selectedTicketType == nil ? .secondary : .primary)
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
                                            .fixedPointsRule(
                                                for: selectedDestination!,
                                                ticketType: selectedTicketType!,
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
                    .fixedSize()

                }
                .transition(.scale.combined(with: .opacity))
            }

            if focusState == .airport {
                List(destinations) { destination in
                    Button {
                        selectedDestination = destination
                        destinationSearchText = destination.name
                        focusState = nil
                        Task {
                            try? await $ticketTypes.load(
                                .sasTicketTypes(for: destination)
                            )
                        }
                    } label: {
                        VStack(alignment: .leading) {
                            Text(destination.name)
                                .foregroundStyle(Color.primary)
                            Text(destination.name.prefix(3))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                        }

                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .transition(.scale.combined(with: .opacity))
            }

            if let pointsRule {
                HStack {
                    VStack(alignment: .leading) {
                        Label("Level points", systemImage: "chart.bar.fill")
                            .foregroundStyle(.secondary)
                        Text("\(pointsRule.level_points)")
                            .contentTransition(.numericText())
                            .font(.title.monospacedDigit())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textFieldInputStyle()

                    VStack(alignment: .leading) {
                        Label("Bonus points", systemImage: "sparkles")
                            .foregroundStyle(.secondary)
                        Text("\(pointsRule.bonus_points)")
                            .contentTransition(.numericText())
                            .font(.title.monospacedDigit())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textFieldInputStyle()
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .fontDesign(.rounded)
        .animation(.snappy(duration: 0.2, extraBounce: .zero), value: destinationSearchText.isEmpty)
        .animation(.snappy(duration: 0.2, extraBounce: .zero), value: toSearch)
        .animation(.snappy(duration: 0.2, extraBounce: .zero), value: pointsRule?.id)
        .animation(.snappy(duration: 0.2, extraBounce: .zero), value: focusState)
        .frame(maxHeight: .infinity, alignment: .top)

    }
}

#Preview {
    SASFlightInputView()
}
