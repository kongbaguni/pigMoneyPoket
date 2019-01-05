//
//  MakeBuyViewController.swift
//  PigMoneyPoket
//
//  Created by Changyul Seo on 05/01/2019.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift
import MapKit
import TagListView
import CoreLocation

class MakeBuyViewController: UITableViewController {
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var nameCell:UITableViewCell!
    @IBOutlet weak var tagListView:TagListView!
    @IBOutlet weak var priceCell:UITableViewCell!
    @IBOutlet weak var tagCell: UITableViewCell!
    var locationUpdateCount = 0
    
    let locationManager = CLLocationManager()

    class Data {
        var name:String? = nil
        var tags:Set<String> = []
        var price:Int? = nil
        var tagString:String {
            var result = ""
            for tag in tags {
                if result.isEmpty == false {
                    result.append(",")
                }
                result.append(tag)
            }
            return result
        }
    }
    
    var data = Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        title = "지출"
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        updateLabel()
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        switch cell {
        case nameCell:
            let vc = UIAlertController(title: "이름입력", message: "이름을 입력하세요", preferredStyle: .alert)
            vc.addTextField { (textField) in
                textField.placeholder = "이름"
                textField.text = self.data.name
                textField.clearButtonMode = .whileEditing
            }
            vc.addAction(UIAlertAction(title: "확인", style: .cancel) { _ in
                self.data.name = vc.textFields?.first?.text
                tableView.deselectRow(at: indexPath, animated: true)
                self.updateLabel()
            })
            present(vc, animated: true, completion: nil)
            
        case priceCell:
            let vc = UIAlertController(title: "가격입력", message: "가격을 입력하세요", preferredStyle: .alert)
            vc.addTextField { (textField) in
                textField.placeholder = "0"
                if let p = self.data.price {
                    textField.text = "\(p)"
                }
                textField.clearButtonMode = .whileEditing
                textField.keyboardType = .numberPad
            }
            vc.addAction(UIAlertAction(title: "확인", style: .cancel) { _ in
                if let t = vc.textFields?.first?.text {
                    self.data.price = NSString(string: t).integerValue
                }
                tableView.deselectRow(at: indexPath, animated: true)
                self.updateLabel()
            })
            present(vc, animated: true, completion: nil)
            
        case tagCell:
            let vc = UIAlertController(title: "태그편집", message: "태그 편집.", preferredStyle: .alert)
            vc.addTextField { (textField) in
                textField.placeholder = "태그"
                textField.clearButtonMode = .whileEditing
                textField.text = self.data.tagString
            }
            
            vc.addAction(UIAlertAction(title: "확인", style: .cancel) { _ in
                if let t = vc.textFields?.first?.text {
                    for str in t.components(separatedBy: ",") {
                        self.data.tags.insert(str.trimmingCharacters(in: CharacterSet(charactersIn: " ")))
                    }
                }
                tableView.deselectRow(at: indexPath, animated: true)
                self.updateLabel()
            })
            present(vc, animated: true, completion: nil)

        default:
            break
        }
    }
    
    func updateLabel() {
        nameCell.textLabel?.text = "이름"
        priceCell.textLabel?.text = "가격"
        if let name = data.name {
            if name.isEmpty == false {
                nameCell.textLabel?.text = name
            }
        }
        
        if let price = data.price {
            priceCell.textLabel?.text = "\(price)"
        }
        tagListView.removeAllTags()
        for tag in data.tags {
            tagListView.addTag(tag)
        }
    }
}

extension MakeBuyViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.first?.coordinate {
            let value = CLLocationDistance(Int(Date().timeIntervalSince1970) % 300)
            mapView.setCamera(MKMapCamera(lookingAtCenter: coordinate, fromDistance: 200 + value, pitch: 30, heading: 0), animated: locationUpdateCount > 0)
            locationUpdateCount += 1
        }
    }
    
}
