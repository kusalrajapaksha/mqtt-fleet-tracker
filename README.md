# 🚚 MQTT Fleet Tracker

A real-time fleet tracking system built with **SwiftUI, MapKit, MQTT, Python, and Docker**.

The project simulates multiple vehicles moving along real road routes and displays their live locations, movement history, connection status, and travelled distance in an iOS application.

This project demonstrates real-time communication, location-based visualization, reactive UI architecture, and backend infrastructure setup.

---

## 📱 Project Preview

<img width="300" height="654" alt="fleet_map" src="https://github.com/user-attachments/assets/5fd28c88-0513-4808-a579-3f5b8f3dc0df" />
<img width="300" height="654" alt="vehicle_details" src="https://github.com/user-attachments/assets/08b03aae-e011-4b40-9c9b-05735bdb6892" />

---

## ✨ Features

### iOS Application

* Real-time vehicle location updates
* Interactive MapKit map
* Multiple vehicle markers
* Road-based route visualization
* Selected vehicle route highlighting
* Vehicle search
* Vehicle details view
* Vehicle online/offline status
* Vehicle movement history
* Distance travelled calculation
* Automatic MQTT reconnection
* SwiftUI reactive interface
* MVVM-style architecture

### Vehicle Simulator

* Simulates multiple vehicles
* Publishes vehicle locations using MQTT
* Uses real road routes from OSRM
* Calculates vehicle heading
* Simulates dynamic vehicle speed
* Publishes location updates continuously
* Supports multiple vehicle IDs

### Infrastructure

* Dockerized Mosquitto MQTT broker
* MQTT TCP connection
* MQTT WebSocket connection
* Simple local development setup

---

## 🏗️ Architecture

```text
┌──────────────────────┐
│   Python Simulator   │
│                      │
│  - Vehicle movement  │
│  - Route simulation  │
│  - Location updates  │
└──────────┬───────────┘
           │
           │ MQTT
           ▼
┌──────────────────────┐
│   Mosquitto Broker   │
│       Docker         │
└──────────┬───────────┘
           │
           │ fleet/+/location
           ▼
┌──────────────────────┐
│      iOS App         │
│                      │
│  MQTTManager         │
│        ↓             │
│  FleetViewModel      │
│        ↓             │
│  SwiftUI + MapKit    │
└──────────────────────┘
```

---

## 🧰 Technologies

### iOS

* Swift
* SwiftUI
* MapKit
* CoreLocation
* Observation framework
* CocoaMQTT
* Swift Concurrency
* MVVM architecture

### Simulator

* Python
* Paho MQTT
* Requests
* OSRM Routing API

### Infrastructure

* Docker
* Docker Compose
* Eclipse Mosquitto
* MQTT
* MQTT over WebSockets

---

## 📂 Project Structure

```text
mqtt-fleet-tracker/
│
├── README.md
├── LICENSE
├── .gitignore
│
├── iOS/
│   └── MQTTFleetTracker/
│       ├── MQTTFleetTracker.xcodeproj
│       └── MQTTFleetTracker/
│           ├── Models/
│           ├── Networking/
│           ├── ViewModels/
│           ├── Views/
│           └── MQTTFleetTrackerApp.swift
│
├── simulator/
│   ├── simulator.py
│   ├── requirements.txt
│   └── README.md
│
└── infrastructure/
    └── mosquitto/
        ├── docker-compose.yml
        └── mosquitto.conf
```

---

## 🔌 MQTT Topic

Each vehicle publishes its location to a topic using the following format:

```text
fleet/{vehicleId}/location
```

Example:

```text
fleet/vehicle-001/location
```

### Location Payload

```json
{
  "vehicleId": "vehicle-001",
  "latitude": 59.3293,
  "longitude": 18.0686,
  "speed": 42.5,
  "heading": 180.0,
  "timestamp": "2026-09-16T12:00:00Z"
}
```

The iOS application subscribes to:

```text
fleet/+/location
```

This allows the application to receive location updates from all vehicles.

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/kusalrajapaksha/mqtt-fleet-tracker
git clone 
cd mqtt-fleet-tracker
```

---

### 2. Start the MQTT Broker

Make sure Docker Desktop is installed and running.

Navigate to the Mosquitto infrastructure directory:

```bash
cd infrastructure/mosquitto
```

Start the broker:

```bash
docker compose up -d
```

Check the running containers:

```bash
docker ps
```

The broker exposes:

```text
MQTT:        localhost:1883
WebSockets:  localhost:9001
```

---

### 3. Set Up the Python Simulator

Navigate to the simulator directory:

```bash
cd ../../simulator
```

Create a virtual environment:

```bash
python3 -m venv .venv
```

Activate the virtual environment:

#### macOS/Linux

```bash
source .venv/bin/activate
```

#### Windows

```bash
.venv\Scripts\activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Start the simulator:

```bash
python simulator.py
```

The simulator will:

1. Download road routes.
2. Create simulated vehicles.
3. Move vehicles along the routes.
4. Publish location updates through MQTT.

---

### 4. Run the iOS Application

1. Open the Xcode project.
2. Resolve Swift Package dependencies.
3. Select an iOS Simulator or physical device.
4. Build and run the application.
5. Confirm that the MQTT broker and simulator are running.

The application should begin receiving live vehicle updates.

---

## 🗺️ Map Features

The application displays:

* Current vehicle positions
* Vehicle movement direction
* Individual vehicle routes
* Selected vehicle route
* Vehicle movement history
* Vehicle connection status
* Distance travelled

Vehicle routes are drawn using the received location history.

---

## 🧠 Technical Highlights

### Real-Time MQTT Communication

The application uses MQTT subscriptions to receive vehicle location updates without continuously polling an HTTP endpoint.

### Reactive SwiftUI Interface

The UI updates automatically when new vehicle locations arrive.

### Vehicle History

The application stores recent location updates for each vehicle and limits the history size to avoid unnecessary memory usage.

### Offline Detection

A vehicle is considered offline when no location update has been received within the configured timeout period.

### Automatic Reconnection

The MQTT manager attempts to reconnect when the broker connection is interrupted.

### Road-Based Simulation

The Python simulator uses OSRM route data to move vehicles along realistic road paths instead of using random coordinates.

---

## 🔐 Security Note

This project currently uses a local development MQTT broker with anonymous access enabled.

The following configuration is intended only for local development:

```text
allow_anonymous true
```

For production usage, the broker should use:

* Username and password authentication
* TLS encryption
* Access control lists
* Restricted network access
* Secure MQTT credentials
* Environment variables for secrets

---

## 🛠️ Future Improvements

Possible future enhancements include:

* User authentication
* Secure MQTT connection using TLS
* MQTT username and password authentication
* Vehicle filtering by status
* Geofencing
* Speed limit alerts
* Vehicle clustering
* Persistent location storage
* Backend REST API
* Historical route playback
* Trip and mileage reports
* Vehicle battery status
* Push notifications
* Admin dashboard
* Cloud deployment
* Automated tests
* CI/CD pipeline

---

## 🎯 Purpose of This Project

This project was created as a portfolio project to demonstrate practical experience with:

* iOS development
* SwiftUI
* Real-time data communication
* MQTT messaging
* MapKit
* Python scripting
* Docker infrastructure
* Reactive application architecture
* Location-based applications

---

## 👨‍💻 Author

**Kusal Rajapaksha**

Senior iOS Engineer
Stockholm, Sweden

* GitHub: [Kusal Rajapaksha](https://github.com/kusalrajapaksha)
* LinkedIn: [Kusal Rajapaksha](https://www.linkedin.com/in/kusal-rajapaksha-948740170/)

---

## 📄 License

This project is licensed under the MIT License.

See the [LICENSE](LICENSE) file for details.
