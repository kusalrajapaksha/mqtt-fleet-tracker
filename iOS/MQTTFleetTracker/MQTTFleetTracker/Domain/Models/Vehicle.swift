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
}
