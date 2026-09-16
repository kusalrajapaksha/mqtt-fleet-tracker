//
//  MQTTManager.swift
//  MQTTFleetTracker
//
//  Created by Kusal on 2026-09-11.
//

import Foundation
import CocoaMQTT

final class MQTTManager: NSObject {
    
    private var mqtt: CocoaMQTT?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    
    var onLocationReceived: ((VehicleLocation) -> Void)?
    var onConnectionStatusChanged: ((Bool) -> Void)?
    
    func connect() {
        let clientID = "ios-fleet-tracker-\(UUID().uuidString)"
        
        let mqtt = CocoaMQTT(
            clientID: clientID,
            host: "127.0.0.1",
            port: 1883
        )
        
        mqtt.username = nil
        mqtt.password = nil
        
        mqtt.keepAlive = 60
        mqtt.autoReconnect = true
        
        mqtt.delegate = self
        
        self.mqtt = mqtt
        
        print("Connecting to MQTT broker...")
        _ = mqtt.connect()
    }
    
    func reconnectIfNeeded() {
        guard reconnectAttempts < maxReconnectAttempts else {
            print("Max reconnect attempts reached. Giving up.")
            return
        }
        
        reconnectAttempts += 1
        
        let delay = min(Double(reconnectAttempts) * 2.0, 10)
        
        print("Reconnecting in \(delay) seconds...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else {
                return
            }
            self.connect()
        }

    }
    
    func subscribe(to topic: String) {
        mqtt?.subscribe(
            [
                (topic, qos: .qos1),
            ]
        )
    }
}

extension MQTTManager: CocoaMQTTDelegate {

    func mqtt(
        _ mqtt: CocoaMQTT,
        didConnectAck ack: CocoaMQTTConnAck
    ) {
        print("MQTT connected!")
        reconnectAttempts = 0
        onConnectionStatusChanged?(true)
        subscribe(to: "fleet/+/location")
        //+ is an MQTT wildcard for one level.
    }

    func mqtt(
        _ mqtt: CocoaMQTT,
        didPublishMessage message: CocoaMQTTMessage,
        id: UInt16
    ) {
        print("Message published: \(message)")
    }

    func mqtt(
        _ mqtt: CocoaMQTT,
        didPublishAck id: UInt16
    ) {
        print("Publish acknowledged: \(id)")
    }

    func mqtt(
        _ mqtt: CocoaMQTT,
        didReceiveMessage message: CocoaMQTTMessage,
        id: UInt16
    ) {
        print("Received message!")
        print("Topic: \(message.topic)")
        print("Message: \(message.string ?? "")")
        
        guard let string = message.string,
              let data = string.data(using: .utf8) else {
            print("Invalid MQTT message")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let location = try decoder.decode(
                VehicleLocation.self,
                from: data
            )
            
            onLocationReceived?(location)
            print("Vehicle: \(location.vehicleId)")
            print("Latitude: \(location.latitude)")
            print("Longitude: \(location.longitude)")
            print("Speed: \(location.speed)")
            print("Heading: \(location.heading)")
            print("Timestamp: \(location.timestamp)")
            
        } catch {
            print("Failed to decode vehicle location:")
            print(error)
        }
    }

    func mqtt(
        _ mqtt: CocoaMQTT,
        didSubscribeTopics success: NSDictionary,
        failed: [String]
    ) {
        print("Subscribed successfully: \(success)")
        print("Subscription failures: \(failed)")
    }

    func mqtt(
        _ mqtt: CocoaMQTT,
        didUnsubscribeTopics topics: [String]
    ) {
        print("Unsubscribed: \(topics)")
    }

    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("MQTT ping")
    }

    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("MQTT pong")
    }

    func mqttDidDisconnect(
        _ mqtt: CocoaMQTT,
        withError err: Error?
    ) {
        print("MQTT disconnected")
        onConnectionStatusChanged?(false)
        reconnectIfNeeded()
        if let err {
            print("Error: \(err)")
        }
    }
}
