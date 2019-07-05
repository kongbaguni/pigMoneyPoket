//
//  NSDictionary+Utill.swift
//  PigMoneyPoket
//
//  Created by Changyul Seo on 05/07/2019.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import Foundation
extension NSDictionary {
    var jsonString:String {
        let jsonData = try! JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        return jsonString
    }    
}
