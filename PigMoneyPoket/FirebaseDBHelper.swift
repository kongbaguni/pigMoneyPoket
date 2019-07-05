//
//  FirebaseDBHelper.swift
//  PigMoneyPoket
//
//  Created by Changyul Seo on 05/07/2019.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import RealmSwift
import SwiftyJSON

class FirebaseDBHelper {
    static let shared = FirebaseDBHelper()
    let ref:DatabaseReference!
    
    init() {
        ref = Database.database().reference()
    }

    var uid:String {
        return Auth.auth().currentUser!.uid
    }
    
    /** 저장하기*/
    func save(model:PaymentModel) {
        let value:[String:Any] = [
            "name" : model.name,
            "isIncome": model.isIncome,
            "price" : model.price,
            "latitude" : model.coordinate2D.latitude,
            "longitude" : model.coordinate2D.longitude,
            "createdDateTime" : model.createdDateTime?.timeIntervalSince1970 ?? Date().timeIntervalSince1970,
            "updatedDateTime" : model.updatedDatetime?.timeIntervalSince1970 ?? Date().timeIntervalSince1970,
            "tags" : model.tag
        ]
        self.ref.child("pays/\(uid)/\(model.id)").setValue(value)
    }
    
    func delete(payid:String) {
        self.ref.child("pays/\(uid)/\(payid)").setValue(nil)        
    }
    
    func loadData(complete:@escaping()->Void) {
        if try! Realm().objects(PaymentModel.self).count > 0 {
            return
        }
        ref.child("pays/\(uid)").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else {
                return
            }
            
            let json = JSON(parseJSON: value.jsonString)
            var newModels:[Object] = []
            for dic in json.dictionaryValue {
                let id = dic.key
                let model = PaymentModel()
                model.id = id
                model.name = json[id]["name"].stringValue
                model.createdDateTime = Date(timeIntervalSince1970: TimeInterval(json[id]["createDateTime"].doubleValue))
                model.updatedDatetime = Date(timeIntervalSince1970: TimeInterval(json[id]["updateDateTime"].doubleValue))
                model.price = json[id]["price"].intValue
                model.latitude = json[id]["latitude"].doubleValue
                model.longitude = json[id]["longitude"].doubleValue
                model.tag = json[id]["tags"].stringValue
                newModels.append(model)
            }
            
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(newModels, update: .modified)
            try! realm.commitWrite()
            DispatchQueue.main.async {
                complete()
            }
        }
    }
    
    
}
