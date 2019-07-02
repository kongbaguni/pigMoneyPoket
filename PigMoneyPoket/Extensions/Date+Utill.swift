//
//  Date+Utill.swift
//  PigMoneyPoket
//
//  Created by Changyul Seo on 01/07/2019.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import Foundation
extension Date {
    /** String 으로 변환*/
    func makeString(format:String)->String? {
        let formater = DateFormatter()
        formater.dateFormat = format
        return formater.string(from: self)
    }
    
    /** 자정 시각의 Date 를 구함*/
    var midnight:Date {
        let format = "yyyy-MM-dd"
        return self.makeString(format: format)?.makeDate(format: format) ?? Date()
    }
}
