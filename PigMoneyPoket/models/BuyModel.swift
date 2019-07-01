//
//  BuyModel.swift
//  PigMoneyPoket
//
//  Created by Changyul Seo on 05/01/2019.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import RealmSwift
import CoreLocation

class PaymentModel: Object {
    @objc dynamic var id = UUID().uuidString
    /** 이름 */
    @objc dynamic var name = ""
    /** 가격 */
    @objc dynamic var price = 0
    /** 태그 콤마로 구분하는 스트링값 저장*/
    @objc dynamic var tag:String = ""
    /** 위치정보 */
    @objc dynamic var latitude:Double = 0
    /** 위치정보 */
    @objc dynamic var longitude:Double = 0
    /** 날자*/
    @objc dynamic var datetime:Date? = nil
    /** 수입내역인가?*/
    @objc dynamic var isIncome:Bool = false
    
    var coordinate2D:CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var tags:[String] {
        return tag.components(separatedBy: ",")
    }
    
    func loadData(_ data:MakePaymentViewController.Data) {
        guard let name = data.name ,
            let price = data.price,
            let coordinate = data.coordinate else {
                return
        }
        self.name = name
        if data.isIncome {
            self.price = price
        } else {
            self.price = -abs(price)
        }
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.datetime = Date()
        self.isIncome = data.isIncome
        self.tag = "," + data.tagString + ","
    }
    
    override static func ignoredProperties() -> [String] {
        return ["coordinate2D","tags"]
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
