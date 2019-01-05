//
//  SingleTone.swift
//  PigMoneyPoket
//
//  Created by Changyul Seo on 05/01/2019.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import Foundation
import CoreLocation

class KLocationManager : NSObject {
    static let shared = KLocationManager()
    let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestAlwaysAuthorization()
    }
    
}

extension KLocationManager: CLLocationManagerDelegate {
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        debugPrint(#function)
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        debugPrint(#function)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint(#function)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        debugPrint(#function)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        debugPrint(#function)

    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        debugPrint(#function)

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        debugPrint(#function)

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        debugPrint(#function)

    }

    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        debugPrint(#function)

    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        debugPrint(#function)

    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        debugPrint(#function)

    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        debugPrint(#function)

    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        debugPrint(#function)

    }

    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        debugPrint(#function)

    }
}
