//
//  MapViewController.swift
//  PigMoneyPoket
//
//  Created by Changyul Seo on 07/01/2019.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import RealmSwift

class MapViewController: UIViewController {
    @IBOutlet weak var mapView:MKMapView!
    var paymentID:String? = nil
    var payment:PaymentModel? {
        if let id = paymentID {
            return try! Realm().object(ofType: PaymentModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let pay = payment else {
            return
        }
        title = pay.isIncome ? "income".localized : "expenditure".localized
        let ann = MKPointAnnotation()
        ann.coordinate.longitude = pay.longitude
        ann.coordinate.latitude = pay.latitude
        ann.title = pay.name
        ann.subtitle = NumberFormatter.localizedString(from: NSNumber(value: pay.price), number: .currency)
        mapView.addAnnotation(ann)
        mapView.setCamera(MKMapCamera(lookingAtCenter: ann.coordinate, fromDistance: 800 , pitch: 30, heading: 0), animated: false)

    }

    
}
