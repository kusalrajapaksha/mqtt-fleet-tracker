//
//  FleetViewModel.swift
//  MQTTFleetTracker
//
//  Created by Kusal on 2026-09-11.
//

import Foundation
import Observation
import CoreLocation

@Observable
final class FleetViewModel {
    
    private(set) var vehicles: [String: Vehicle] = [:]
    private(set) var isConnected = false
    private(set) var vehicleHistory: [String: [VehicleLocation]] = [:]
    
    private let mqttManager: MQTTManager
    
    init(mqttManager: MQTTManager) {
        self.mqttManager = mqttManager
        
        mqttManager.onLocationReceived = {[weak self] location in
            self?.updateLocation(location)
        }
        
        mqttManager.onConnectionStatusChanged = {[weak self] isConnected in
            self?.isConnected = isConnected
        }
    }
    
    func start() {
        mqttManager.connect()
    }
    
    func updateLocation(_ location: VehicleLocation) {
        let vehicle = Vehicle(id: location.vehicleId, location: location)
        vehicles[location.vehicleId] = vehicle
        
        var history = vehicleHistory[location.vehicleId, default: []]
        history.append(location)
        if history.count > 100 {
            history.removeFirst(history.count - 100)
        }
        vehicleHistory[location.vehicleId] = history
    }
    
    func distanceTravelled(for vehicleID: String) -> Double {
        guard let history = vehicleHistory[vehicleID],
              history.count > 1 else {
            return 0
        }

        var totalDistance = 0.0

        for index in 1..<history.count {
            let previous = history[index - 1]
            let current = history[index]

            let previousLocation = CLLocation(
                latitude: previous.latitude,
                longitude: previous.longitude
            )

            let currentLocation = CLLocation(
                latitude: current.latitude,
                longitude: current.longitude
            )

            totalDistance += currentLocation.distance(
                from: previousLocation
            )
        }

        return totalDistance
    }
}
