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
    deinit {
        debugPrint("------ \(#file) \(#function) -----")
    }

    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var dateLabel:UILabel!
    @IBOutlet weak var priceLabel:UILabel!
    
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
        let price = NumberFormatter.localizedString(from: NSNumber(value: pay.price), number: .currency)
        ann.subtitle = price
        mapView.addAnnotation(ann)
        mapView.setCamera(MKMapCamera(lookingAtCenter: ann.coordinate, fromDistance: 800 , pitch: 30, heading: 0), animated: false)
        titleLabel.text = payment?.name
        dateLabel.text = DateFormatter.localizedString(from: pay.datetime!, dateStyle: DateFormatter.Style.long, timeStyle: DateFormatter.Style.medium)
        priceLabel.text = price
        priceLabel.textColor = pay.price < 0 ? .red : .blue
    }

    
}
