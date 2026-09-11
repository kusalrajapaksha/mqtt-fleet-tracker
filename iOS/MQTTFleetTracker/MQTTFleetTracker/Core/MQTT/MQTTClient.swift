//
//  MQTTClient.swift
//  MQTTFleetTracker
//
//  Created by Kusal on 2026-09-11.
//

import Foundation

protocol MQTTClient: AnyObject {
    /// AsyncStream = a belt that lets non-async code feed data into async code.
    /*
     AsyncStream is a type that allows you to create an asynchronous sequence of values that can be produced over time. It provides a way to bridge non-async code with async code by allowing you to feed data into an async context.
     The kitchen (producer) puts dishes on a conveyor belt whenever they're ready. The waiter (consumer) stands at the other end and grabs dishes as they arrive. The kitchen doesn't need to know who's taking the food — it just keeps yielding. When the kitchen closes, it finishes the belt.
     */
    var connectionState: AsyncStream<MQTTConnectionState> { get }
    
    var message: AsyncStream<MQTTMessage> { get }
    
    func connect() async throws
    
    func disconnect()
    
    /*
     UInt8 is a whole number that fits in 8 bits — so it can only hold values from 0 to 255.
         Breaking down the name:
         U = Unsigned → no negative numbers
         Int = Integer → whole number
         8 = 8 bits of storage

         What 8 bits means:
         8 bits = 2⁸ = 256 possible values → 0 through 255.
     */
    func subscribe(
        to topic: String,
        qos: UInt8
    ) async throws
    
    func publish(
        topic: String,
        payload: Data,
        qos: UInt8,
        retain: Bool
    ) async throws
}
