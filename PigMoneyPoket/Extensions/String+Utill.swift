//
//  String+Utill.swift
//  PigMoneyPoket
//
//  Created by Changyul Seo on 06/01/2019.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import Foundation
extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    func makeDate(format:String)->Date? {
        let formater = DateFormatter()
        formater.dateFormat = format
        return formater.date(from: self)
    }
}
