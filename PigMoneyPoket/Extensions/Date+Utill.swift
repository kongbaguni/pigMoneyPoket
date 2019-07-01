//
//  Date+Utill.swift
//  PigMoneyPoket
//
//  Created by Changyul Seo on 01/07/2019.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import Foundation
extension Date {
    func makeString(format:String)->String? {
        let formater = DateFormatter()
        formater.dateFormat = format
        return formater.string(from: self)
    }
    
    var midnight:Date {
        let format = "yyyy-MM-dd"
        return self.makeString(format: format)?.makeDate(format: format) ?? Date()
    }
}
