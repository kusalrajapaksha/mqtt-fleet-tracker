//
//  VehicleLocation.swift
//  MQTTFleetTracker
//
//  Created by Kusal on 2026-09-11.
//

import Foundation

struct VehicleLocation: Codable, Sendable {
    let vehicleId: String
    let latitude: Double
    let longitude: Double
    let speed: Double
    let heading: Double
    let timestamp: Date
}

