//
//  GBLocationManager.swift
//  GB
//
//  Created by Gentian Barileva on 17.9.20.
//  Copyright © 2020 Gentian Barileva. All rights reserved.
//

import Foundation
import CoreLocation

protocol GBLocationManagerDelegate: AnyObject {
    func didUpdateLocation(location: CLLocation?)
    func didFailWith(error: Error)
    func authorizationStatusChanged(status: CLAuthorizationStatus)
}

extension GBLocationManagerDelegate {
    func didUpdateLocation(location: CLLocation?) {}
    func didFailWith(error: Error) {}
    func authorizationStatusChanged(status: CLAuthorizationStatus) {}
}

final class GBLocationManager: NSObject, CLLocationManagerDelegate {
    typealias LocationClosure = (_ success: Bool, _ location: CLLocation?) -> Void

    // MARK: - GBLocationManager Singleton
    static let shared = GBLocationManager()

    // MARK: - Public variables
    private(set) var currentLocation: CLLocation?
    private(set) var currentLocatioCoordinate: CLLocationCoordinate2D?
    var authorizationStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()

    var isAuthorized: Bool {
        switch authorizationStatus {
        case .notDetermined,
                .restricted,
                .denied:
            return false
        case .authorizedAlways,
                .authorizedWhenInUse:
            return true
        @unknown default:
            return false
        }
    }

    weak var delegate: GBLocationManagerDelegate?

    // MARK: - Private variables
    private let locationManager: CLLocationManager = {
        $0.desiredAccuracy = kCLLocationAccuracyBest
        $0.distanceFilter = 0
        return $0
    }(CLLocationManager())
    private var timer: Timer?

    // MARK: - init
    private override init() {
        super.init()
        locationManager.delegate = self
        currentLocation = locationManager.location
    }

    // MARK: - deinit
    deinit {
        locationManager.delegate = nil
        delegate = nil
        timer?.invalidate()
    }

    // MARK: - Public Methods

    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationServices(shouldUpdate: Bool) {
        shouldUpdate ? locationManager.startUpdatingLocation() : locationManager.stopUpdatingLocation()
    }

    func requestLocationUpdate(completion: @escaping LocationClosure) {
        locationManager.startUpdatingLocation()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            let hasLocation = (self.currentLocation != nil)

            if !hasLocation {
                return
            }
            self.locationServices(shouldUpdate: !hasLocation)
            completion(hasLocation, self.currentLocation)
            timer.invalidate()
        }
    }

    func requestLocation() {
        locationManager.requestLocation()
    }

    /// This method requests for authorization when status is notDetermined. If it's declined then it posts a notification. If authorized then it does a locationRequest.
    func checkAuthorization() {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            requestLocation()
        } else {
            print("Location IS NO AUTHORIZED with status: \(authorizationStatus.rawValue)")
        }

        postDelegateauthorizationStatusChanged()
    }

    // MARK: - CLLocationManagerDelegate Stubs
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        checkAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }

        currentLocation = location
        currentLocatioCoordinate = location.coordinate
        postDelegateUpdateWith(location: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        postDelegateUpdateWith(error: error)
    }

    // MARK: - Internal Methods
    private func postDelegateUpdateWith(location: CLLocation) {
        guard let delegate = self.delegate else { return }

        delegate.didUpdateLocation(location: location)
    }

    private func postDelegateUpdateWith(error: Error) {
        guard let delegate = self.delegate else { return }

        delegate.didFailWith(error: error)
    }

    private func postDelegateauthorizationStatusChanged() {
        guard let delegate = self.delegate else { return }

        delegate.authorizationStatusChanged(status: authorizationStatus)
    }
}
