//
//  ContentView-ViewModel.swift
//  Bucklist
//
//  Created by Aaron Brown on 10/11/23.
//

import LocalAuthentication
import MapKit
import SwiftUI

extension ContentView {
    @MainActor class ViewModel: ObservableObject {
        @Published var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25)
        ))
        @Published var currentPosition = CLLocationCoordinate2D(latitude: 50, longitude: 0)
        @Published private(set) var locations: [Location]
        
        @Published var selectedPlace: Location?
        @Published var isUnlocked: Bool = false
        
        let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedPath")
        
        init() {
            // Loading Data from savePath in Documents Directory
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
            }
        }
        
        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                // Options: .completeFileProtection enables encrytion with requires athenication.
                try data.write(to: savePath, options: [.atomic, .completeFileProtection])
            } catch {
                print("Unable to save data")
            }
        }
        
        func addLocation() {
            let newLocation = Location(id: UUID(), name: "New Location", description: "", latitude:  currentPosition.latitude, longitude:  currentPosition.longitude)
            locations.append(newLocation)
            save()
        }
        func updateLocation(location: Location) {
            guard let selectedPlace = selectedPlace else { return }
            if let index = locations.firstIndex(of: selectedPlace) {
                locations[index] = location
                save()
            }
        }
        func authenticate () {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Please authenticate yourself to unlock your places."
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    if success {
                        Task { @MainActor in
                            // You can also do this:
//                            await MainActor.run {  self.isUnlocked = true }
                            self.isUnlocked = true
                        }
                    } else {
                        // there was a problem
                    }
                }
            } else {
                // no biometrics
            }
        }
    }
}
