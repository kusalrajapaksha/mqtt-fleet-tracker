//
//  MQTTFleetTrackerApp.swift
//  MQTTFleetTracker
//
//  Created by Kusal on 2026-09-10.
//

import SwiftUI

@main
struct MQTTFleetTrackerApp: App {
    
    private let mqttManager = MQTTManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear{
                    mqttManager.conncect()
                }
        }
    }
}
