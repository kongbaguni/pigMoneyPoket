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

class FirebaseDBHelper {
    static let shared = FirebaseDBHelper()
    let ref:DatabaseReference!
    
    init() {
        ref = Database.database().reference()        
    }

    /** 저장하기*/
    func save(model:PaymentModel) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let value:[String:Any] = [
            "name" : model.name,
            "isIncome": model.isIncome,
            "price" : model.price,
            "latitude" : model.coordinate2D.latitude,
            "longitude" : model.coordinate2D.longitude,
            "dateTime" : model.datetime?.timeIntervalSince1970 ?? Date().timeIntervalSince1970,
            "tags" : model.tag
        ]
        self.ref.child("pays/\(uid)/\(model.id)").setValue(value)
    }
}
