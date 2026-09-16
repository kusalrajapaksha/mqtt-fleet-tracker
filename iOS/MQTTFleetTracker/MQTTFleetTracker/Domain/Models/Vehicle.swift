//
//  Vehicle.swift
//  MQTTFleetTracker
//
//  Created by Kusal on 2026-09-11.
//

import Foundation

struct Vehicle: Identifiable, Sendable {
    let id: String
    var location: VehicleLocation
    
    var lastUpdate: Date {
        location.timestamp
    }
    
    func isOnline(at currentTime: Date) -> Bool {
        currentTime.timeIntervalSince(lastUpdate) < 10
    }
}
