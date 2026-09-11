//
//  MQTTConfiguration.swift
//  MQTTFleetTracker
//
//  Created by Kusal on 2026-09-11.
//

import Foundation

struct MQTTConfiguration: Sendable {
    let host: String
    let port: UInt16
    let clientID: String
    
    static let local = MQTTConfiguration(
        host: "localhost",
        port: 1883,
        clientID: "ios-fleet-tracker"
    )
}
