//
//  FleetView.swift
//  MQTTFleetTracker
//
//  Created by Kusal on 2026-09-11.
//

import SwiftUI

struct FleetView: View {

    let viewModel: FleetViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Vehicles") {
                    if viewModel.vehicles.isEmpty {
                        Text("Waiting for vehicles...")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(
                            Array(viewModel.vehicles.values),
                            id: \.id
                        ) { vehicle in

                            VStack(alignment: .leading, spacing: 6) {
                                Text(vehicle.id)
                                    .font(.headline)

                                Text(
                                    "Latitude: \(vehicle.location.latitude)"
                                )

                                Text(
                                    "Longitude: \(vehicle.location.longitude)"
                                )

                                Text(
                                    "Speed: \(vehicle.location.speed) km/h"
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle("Fleet Tracker")
        }
        .onAppear {
            viewModel.start()
        }
    }
}
