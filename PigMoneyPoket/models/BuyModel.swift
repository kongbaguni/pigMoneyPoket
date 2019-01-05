//
//  BuyModel.swift
//  PigMoneyPoket
//
//  Created by Changyul Seo on 05/01/2019.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import RealmSwift
import CoreLocation

class BuyModel: Object {
    @objc dynamic var name = ""
    @objc dynamic var price = 0
    @objc dynamic var latitude:Double = 0
    @objc dynamic var longitude:Double = 0
    @objc dynamic var datetime:Date? = nil
    
    var coordinate2D:CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
