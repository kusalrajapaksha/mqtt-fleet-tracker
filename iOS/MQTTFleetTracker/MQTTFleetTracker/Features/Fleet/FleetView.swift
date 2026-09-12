//
//  FleetView.swift
//  MQTTFleetTracker
//
//  Created by Kusal on 2026-09-11.
//

import SwiftUI
import MapKit

import SwiftUI
import MapKit

struct FleetView: View {
    let viewModel: FleetViewModel

    @State private var selectedVehicleID: String?

    @State private var cameraPosition: MapCameraPosition =
        .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: 59.3293,
                    longitude: 18.0686
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: 0.05,
                    longitudeDelta: 0.05
                )
            )
        )
    
    @State private var searchText = ""

    var selectedVehicle: Vehicle? {
        guard let selectedVehicleID else {
            return nil
        }

        return viewModel.vehicles[selectedVehicleID]
    }
    
    var filteredVehicles: [Vehicle] {
        let vehicles = Array(viewModel.vehicles.values)

        if searchText.isEmpty {
            return vehicles
        }

        return vehicles.filter {
            $0.id.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Map(
                    position: $cameraPosition,
                    selection: $selectedVehicleID
                ) {
                    ForEach(
                        Array(viewModel.vehicles.values),
                        id: \.id
                    ) { vehicle in
                        Marker(
                            vehicle.id,
                            systemImage: "car.fill",
                            coordinate: CLLocationCoordinate2D(
                                latitude: vehicle.location.latitude,
                                longitude: vehicle.location.longitude
                            )
                        )
                        .tag(vehicle.id)
                    }
                }
                .frame(maxHeight: .infinity)

                TextField("Search vehicles", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                List {
                    Section("Vehicles") {
                        ForEach(
                            Array(filteredVehicles),
                            id: \.id
                        ) { vehicle in
                            VehicleRow(vehicle: vehicle)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedVehicleID = vehicle.id

                                    cameraPosition = .region(
                                        MKCoordinateRegion(
                                            center: CLLocationCoordinate2D(
                                                latitude: vehicle.location.latitude,
                                                longitude: vehicle.location.longitude
                                            ),
                                            span: MKCoordinateSpan(
                                                latitudeDelta: 0.01,
                                                longitudeDelta: 0.01
                                            )
                                        )
                                    )
                                }
                        }
                    }
                }
//                .listStyle(.insetGrouped)
            }
//            .navigationTitle("Fleet Tracker")
            .onAppear {
                viewModel.start()
            }
            .sheet(item: Binding(
                get: {
                    selectedVehicle
                },
                set: { vehicle in
                    selectedVehicleID = vehicle?.id
                }
            )) { vehicle in
                VStack {
                    VehicleDetailsCard(vehicle: vehicle)
                        .presentationDetents([.height(250)])
                    Spacer()
                }
                
            }
        }
    }
}

struct VehicleDetailsCard: View {
    let vehicle: Vehicle

    var vehicleStatus: String {
        vehicle.location.speed > 0 ? "Moving" : "Stopped"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "car.fill")
                    .font(.title2)

                Text(vehicle.id)
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()
            }
            

            Divider()
            
            HStack {
                Label("Status", systemImage: "circle.fill")

                Spacer()

                Text(vehicleStatus)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        vehicle.location.speed > 0 ? .green : .secondary
                    )
            }

            HStack {
                Label("Speed", systemImage: "speedometer")

                Spacer()

                Text(
                    "\(vehicle.location.speed, specifier: "%.1f") km/h"
                )
                .fontWeight(.semibold)
            }

            HStack {
                Label("Heading", systemImage: "location.north.fill")

                Spacer()

                Text(
                    "\(vehicle.location.heading, specifier: "%.0f")°"
                )
                .fontWeight(.semibold)
            }

            HStack {
                Label("Latitude", systemImage: "globe")

                Spacer()

                Text(
                    "\(vehicle.location.latitude, specifier: "%.5f")"
                )
                .font(.caption)
            }

            HStack {
                Label("Longitude", systemImage: "globe")

                Spacer()

                Text(
                    "\(vehicle.location.longitude, specifier: "%.5f")"
                )
                .font(.caption)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 8)
    }
}

struct DashboardStat: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct VehicleRow: View {
    let vehicle: Vehicle

    var isMoving: Bool {
        vehicle.location.speed > 0
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "car.fill")
                .font(.title2)
                .foregroundStyle(isMoving ? .green : .secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text(vehicle.id)
                    .font(.headline)

                Text(
                    "\(vehicle.location.speed, specifier: "%.1f") km/h"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(isMoving ? "Moving" : "Stopped")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(isMoving ? .green : .secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let mqttManager = MQTTManager()
    FleetView(viewModel: FleetViewModel(mqttManager: mqttManager))
}
