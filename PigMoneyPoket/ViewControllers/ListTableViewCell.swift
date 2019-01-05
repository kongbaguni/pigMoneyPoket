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
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var tagListView:TagListView!
    @IBOutlet weak var priceLabel:UILabel!
    @IBOutlet weak var dateLabel:UILabel!
    @IBOutlet weak var mapView:MKMapView!
}
