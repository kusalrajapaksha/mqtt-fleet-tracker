//
//  MQTTFleetTrackerApp.swift
//  MQTTFleetTracker
//
//  Created by Kusal on 2026-09-10.
//

import SwiftUI

@main
struct MQTTFleetTrackerApp: App {
    
    private let viewModel: FleetViewModel
    
    init() {
        let mqttManager = MQTTManager()
        viewModel = FleetViewModel(mqttManager: mqttManager)
    }
    
    var body: some Scene {
        WindowGroup {
            FleetView(viewModel: viewModel)
        }
    }
}
