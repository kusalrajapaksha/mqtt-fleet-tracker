//
//  MQTTMessage.swift
//  MQTTFleetTracker
//
//  Created by Kusal on 2026-09-11.
//

import Foundation

struct MQTTMessage: Sendable {
    let topic: String
    let payload: Data
    let receivedAt: Date
    
    init(
        topic: String,
        payload: Data,
        receivedAt: Date = .now
    ) {
        self.topic = topic
        self.payload = payload
        self.receivedAt = receivedAt
    }
}
