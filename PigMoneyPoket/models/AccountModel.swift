//
//  AccountModel.swift
//  PigMoneyPoket
//
//  Created by Changyul Seo on 04/07/2019.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import Foundation
import RealmSwift

class AccountModel: Object {
    @objc dynamic var uid:String = ""
    @objc dynamic var email:String = ""
    @objc dynamic var password:String = ""
}


extension AccountModel {
    static func makeAccount(email:String, password:String, uid:String) {
        let model = AccountModel()
        model.email = email
        model.password = password
        model.uid = uid
        let realm = try! Realm()
        realm.beginWrite()
        realm.add(model)
        try! realm.commitWrite()
    }
}
