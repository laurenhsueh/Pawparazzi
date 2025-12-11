//
//  LocationManager.swift
//  Pawparazzi
//
//  Created by Lauren Hsueh on 12/1/25.
//
import SwiftUI
import CoreLocation
// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var city: String = ""
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus
    
    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        if isAuthorized {
            manager.startUpdatingLocation()
        } else if authorizationStatus == .notDetermined {
            requestPermission()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if isAuthorized {
            manager.startUpdatingLocation()
        } else {
            coordinate = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        coordinate = loc.coordinate
        CLGeocoder().reverseGeocodeLocation(loc) { [weak self] placemarks, _ in
            guard let self = self else { return }
            if let city = placemarks?.first?.locality {
                DispatchQueue.main.async {
                    self.city = city
                    self.manager.stopUpdatingLocation()
                }
            }
        }
    }
}
