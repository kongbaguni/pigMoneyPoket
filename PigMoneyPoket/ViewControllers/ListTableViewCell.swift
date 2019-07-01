//
//  ListTableViewCell.swift
//  PigMoneyPoket
//
//  Created by Changyul Seo on 05/01/2019.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import UIKit
import MapKit
import TagListView

class ListTableViewCell: UITableViewCell {
    deinit {
        debugPrint("------ \(#file) \(#function) -----")
    }

    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var tagListView:TagListView!
    @IBOutlet weak var priceLabel:UILabel!
    @IBOutlet weak var dateLabel:UILabel!
    @IBOutlet weak var mapView:MKMapView!
    
    func loadData(data:PaymentModel) {
        nameLabel.text = data.name
        
        priceLabel.text = NumberFormatter.localizedString(from: NSNumber(value: data.price), number: NumberFormatter.Style.currency)
        priceLabel.textColor = data.price < 0 ? .red : .blue
        let ann = MKPointAnnotation()
        ann.coordinate.latitude = data.latitude
        ann.coordinate.longitude = data.longitude
        mapView.isUserInteractionEnabled = false
        mapView.addAnnotation(ann)
        mapView.setCamera(MKMapCamera(lookingAtCenter: ann.coordinate, fromDistance: 400 , pitch: 30, heading: 0), animated: false)
        
        tagListView.removeAllTags()
        for tag in data.tags {
            if tag.isEmpty == false {
                tagListView.addTag(tag)
            }
        }
        
        if let date = data.datetime {
            let str = DateFormatter.localizedString(from: date, dateStyle: .full, timeStyle: DateFormatter.Style.medium)
            dateLabel.text = str
        }
    }
}
