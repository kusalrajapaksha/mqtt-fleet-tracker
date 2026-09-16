import json
import math
import time
import random
from datetime import datetime, timezone

import paho.mqtt.client as mqtt
from paho.mqtt.enums import CallbackAPIVersion
import requests

BROKER_HOST = "localhost"
BROKER_PORT = 1883
MQTT_CLIENT_ID = "vehicle-simulator"
ROUTE_API_URL = "https://router.project-osrm.org/route/v1/driving/"

ROUTES = {
    "VH-001": {
        "start": (18.0686, 59.3293),
        "end": (18.0900, 59.3400),
    },
    "VH-002": {
        "start": (18.0650, 59.3305),
        "end": (18.0450, 59.3200),
    },
    "VH-003": {
        "start": (18.0700, 59.3270),
        "end": (18.0800, 59.3150),
    },
}

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


def get_route(start, end):
    url = (
        f"{ROUTE_API_URL}"
        f"{start[0]},{start[1]};{end[0]},{end[1]}"
        "?overview=full&geometries=geojson"
    )

    response = requests.get(url, timeout=15)
    response.raise_for_status()

    data = response.json()

    if data["code"] != "Ok":
        raise RuntimeError("Could not find a route")

    return data["routes"][0]["geometry"]["coordinates"]


def initialize_vehicles():
    initialized_vehicles = {}

    for vehicle_id, vehicle in vehicles.items():
        route = ROUTES[vehicle_id]
        initialized_vehicle = vehicle.copy()
        initialized_vehicle["route"] = get_route(
            route["start"],
            route["end"]
        )
        initialized_vehicle["route_index"] = 0
        initialized_vehicles[vehicle_id] = initialized_vehicle

    return initialized_vehicles


def create_mqtt_client():
    return mqtt.Client(
        CallbackAPIVersion.VERSION2,
        client_id=MQTT_CLIENT_ID
    )


def connect(client):
    print("Connecting to MQTT broker...")

    client.connect(
        BROKER_HOST,
        BROKER_PORT,
        keepalive=60
    )

    client.loop_start()

    print("Connected to MQTT broker.")


def publish_vehicle_location(client, vehicle_id, vehicle):
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


def calculate_heading(
    latitude1,
    longitude1,
    latitude2,
    longitude2
):
    lat1 = math.radians(latitude1)
    lat2 = math.radians(latitude2)

    difference_longitude = math.radians(
        longitude2 - longitude1
    )

    x = math.sin(difference_longitude) * math.cos(lat2)

    y = (
        math.cos(lat1) * math.sin(lat2)
        - math.sin(lat1)
        * math.cos(lat2)
        * math.cos(difference_longitude)
    )

    heading = math.degrees(math.atan2(x, y))

    return (heading + 360) % 360


def update_vehicle_position(vehicle):
    route = vehicle["route"]
    index = vehicle["route_index"]

    if index >= len(route) - 1:
        vehicle["route_index"] = 0
        index = 0

    longitude, latitude = route[index]
    vehicle["latitude"] = latitude
    vehicle["longitude"] = longitude

    next_longitude, next_latitude = route[index + 1]

    vehicle["heading"] = calculate_heading(
        latitude1=latitude,
        longitude1=longitude,
        latitude2=next_latitude,
        longitude2=next_longitude
    )

    # Slightly change speed
    vehicle["speed"] += random.uniform(-2.0, 2.0)

    # Keep speed within a realistic range
    vehicle["speed"] = max(
        0.0,
        min(vehicle["speed"], 90.0)
    )

    vehicle["route_index"] += 1


def run_simulation(client, initialized_vehicles):
    try:
        while True:
            for vehicle_id, vehicle in initialized_vehicles.items():
                update_vehicle_position(vehicle)
                publish_vehicle_location(client, vehicle_id, vehicle)
            time.sleep(1)
    except KeyboardInterrupt:
        print("Stopping vehicle simulator...")

    finally:
        client.loop_stop()
        client.disconnect()


def main():
    initialized_vehicles = initialize_vehicles()
    client = create_mqtt_client()
    connect(client)
    run_simulation(client, initialized_vehicles)


if __name__ == "__main__":
    main()