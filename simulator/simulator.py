import json
import time
from datetime import datetime, timezone

import paho.mqtt.client as mqtt
from paho.mqtt.enums import CallbackAPIVersion


BROKER_HOST = "localhost"
BROKER_PORT = 1883

vehicles = {
    "VH-001": {
        "latitude": 59.3293,
        "longitude": 18.0686,
        "speed": 42.5,
        "heading": 90.0,
    },
    "VH-002": {
        "latitude": 59.3305,
        "longitude": 18.0650,
        "speed": 35.0,
        "heading": 180.0,
    },
    "VH-003": {
        "latitude": 59.3270,
        "longitude": 18.0700,
        "speed": 28.0,
        "heading": 270.0,
    },
}

client = mqtt.Client(
    CallbackAPIVersion.VERSION2,
     client_id="vehicle-simulator"
)

def connect():
    print("Connecting to MQTT broker...")
    
    client.connect(
        BROKER_HOST, 
        BROKER_PORT,
        keepalive=60
        )
    
    client.loop_start()
    
    print("Connected to MQTT broker.")
    

def publish_vehicle_location(vehicle_id, vehicle):
    topic = f"fleet/{vehicle_id}/location"
    payload = {
        "vehicleId": vehicle_id,
        "latitude": vehicle["latitude"],
        "longitude": vehicle["longitude"],
        "speed": vehicle["speed"],
        "heading": vehicle["heading"],
        "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    }
    
    client.publish(
        topic, 
        json.dumps(payload),
        qos=1
        )
    
    print(
        f"{vehicle_id}: "
        f"{vehicle['latitude']:.4f}, "
        f"{vehicle['longitude']:.4f}"
    )
    

def update_vehicle_position(vehicle):
    vehicle["longitude"] += 0.0002
    
    
def main():
    connect()
    
    try:
        while True:
            for vehicle_id, vehicle in vehicles.items():
                update_vehicle_position(vehicle)
                publish_vehicle_location(vehicle_id, vehicle)
            time.sleep(5)
    except KeyboardInterrupt:
        print("Stopping vehicle simulator...")
    
    finally:
        client.loop_stop()
        client.disconnect()
        
if __name__ == "__main__":
    main()