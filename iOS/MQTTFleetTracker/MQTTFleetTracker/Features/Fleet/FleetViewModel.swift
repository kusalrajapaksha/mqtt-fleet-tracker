//
//  FleetViewModel.swift
//  MQTTFleetTracker
//
//  Created by Kusal on 2026-09-11.
//

import Foundation
import Observation

@Observable
final class FleetViewModel {
    
    private(set) var vehicles: [String: Vehicle] = [:]
    
    private let mqttManager: MQTTManager
    
    init(mqttManager: MQTTManager) {
        self.mqttManager = mqttManager
        
        mqttManager.onLocationReceived = {[weak self] location in
            self?.updateLocation(location)
        }
    }
    
    func start() {
        mqttManager.conncect()
    }
    
    func updateLocation(_ location: VehicleLocation) {
        let vehicle = Vehicle(id: location.vehicleId, location: location)
        vehicles[location.vehicleId] = vehicle
    }
}
