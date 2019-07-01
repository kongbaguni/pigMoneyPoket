//
//  MakePaymentViewController.swift
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

class MakePaymentViewController: UITableViewController {
    @IBOutlet weak var footerView: UIView!
    var locationUpdateCount = 0
    var paymentID:String? = nil
    var payment:PaymentModel? {
        if let id = paymentID {
            return try! Realm().object(ofType: PaymentModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    var paymentsByLocation:Results<PaymentModel>? {
        guard let coordinate = data.coordinate else {
            return nil
        }
        
        let la = coordinate.latitude // 위도
        let lo = coordinate.longitude // 경도
        let d1:CLLocationDegrees = 1/114.6 * 0.1
        let d2:CLLocationDegrees = 1/88 * 0.1
        var list = try! Realm().objects(PaymentModel.self)
        list = list.filter("isIncome = %@",self.data.isIncome)
        list = list.filter("latitude < %@ && latitude > %@ && longitude < %@ && longitude > %@", la + d1, la - d1, lo + d2, lo - d2)
        return list
    }
    
    @IBOutlet weak var mapView:MKMapView!
    @IBOutlet weak var nameCell:UITableViewCell!
    @IBOutlet weak var tagListView:TagListView!
    @IBOutlet weak var priceCell:UITableViewCell!
    @IBOutlet weak var tagCell: UITableViewCell!
    
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var listBtn:UIBarButtonItem!
    
    let locationManager = CLLocationManager()

    class Data {
        /** 수입인가?*/
        var isIncome = false
        /** 이름*/
        var name:String? = nil
        /** 태그*/
        var tags:Set<String> = []
        /** 가격*/
        var price:Int? = nil
        /** 테그 콤마로 구분된 스트링값*/
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
        /** 위치정보*/
        var coordinate:CLLocationCoordinate2D? = nil
    }
    
    var data = Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagLabel.text = "tag".localized
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if let model = payment {
            loadData(model: model)
        } else {
            if data.isIncome {
                title = "income".localized
                listBtn.title = "income list".localized
            } else {
                title = "expenditure".localized
                listBtn.title = "expenditure list".localized
            }
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
        updateLabel()
        checkBtn()
        priceCell.textLabel?.textColor = self.data.isIncome ? .blue : .red
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.onTouchupDoneBtn(_:)))
        addOldPayments()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }
        switch id {
        case "showOldPayments":
            if let vc = segue.destination as? OldPaymentsByLocationInfoViewController {
                vc.delegate = self
                if let list = paymentsByLocation {
                    for pay in list {
                        vc.paymentIds.append(pay.id)
                    }
                }
            }
        default:
            break
        }
    }
    
    func checkBtn() {
        tableView.tableFooterView?.isHidden = false
        if paymentsByLocation?.count == 0 || paymentsByLocation == nil {
            tableView.tableFooterView?.isHidden = true
        }
    }
    
    func addOldPayments() {
        guard let list = paymentsByLocation else {
            return
        }
        for pay in list {
            let ann = MKPointAnnotation()
            ann.coordinate = pay.coordinate2D
            ann.title = pay.name
            ann.subtitle = NumberFormatter.localizedString(from: NSNumber(value: pay.price), number: .currency)
            print(pay.coordinate2D)
            mapView.addAnnotation(ann)
        }
    }
    
    func loadData(model:PaymentModel, isFixLocation:Bool = true) {
        data.coordinate = CLLocationCoordinate2D(latitude: model.latitude, longitude: model.longitude)
        data.isIncome = model.isIncome
        data.name = model.name
        for tag in model.tags {
            if tag.isEmpty == false {
                data.tags.insert(tag)
            }
        }
        data.price = model.price
        if model.isIncome {
            title = "income".localized
        } else {
            title = "expenditure".localized
        }
        if isFixLocation {
            let ann = MKPointAnnotation()
            ann.coordinate.latitude = model.latitude
            ann.coordinate.longitude = model.longitude
            mapView.addAnnotation(ann)
            mapView.setCamera(MKMapCamera(lookingAtCenter: ann.coordinate, fromDistance: 200, pitch: 30, heading: 0), animated: locationUpdateCount > 0)
            mapView.showsUserLocation = false
        }

    }
    private func inputRun(cell:UITableViewCell?) {
        switch cell {
        case nameCell:
            let vc = UIAlertController(title: "이름입력", message: "이름을 입력하세요", preferredStyle: .alert)
            vc.addTextField { (textField) in
                textField.placeholder = "이름"
                textField.text = self.data.name
                textField.clearButtonMode = .whileEditing
            }
            vc.addAction(UIAlertAction(title: "confirm".localized, style: .cancel) { _ in
                self.data.name = vc.textFields?.first?.text
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
            vc.addAction(UIAlertAction(title: "confirm".localized, style: .cancel) { _ in
                if let t = vc.textFields?.first?.text {
                    let price = abs(NSString(string: t).integerValue)
                    if self.data.isIncome {
                        self.data.price = price
                    } else {
                        self.data.price = -price
                    }
                }
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
            vc.addAction(UIAlertAction(title: "confirm".localized, style: .cancel) { _ in
                self.data.tags.removeAll()
                if let t = vc.textFields?.first?.text {
                    for str in t.components(separatedBy: ",") {
                        let tt = str.trimmingCharacters(in: CharacterSet(charactersIn: " "))
                        if tt.isEmpty == false {
                            self.data.tags.insert(tt)
                        }
                    }
                }
                self.updateLabel()
            })
            present(vc, animated: true, completion: nil)
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        inputRun(cell: cell)
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
            priceCell.textLabel?.text = NumberFormatter.localizedString(from: NSNumber(value: price), number: NumberFormatter.Style.currency)
        }
        tagListView.removeAllTags()
        for tag in data.tags {
            tagListView.addTag(tag)
        }
    }
    
    @objc func onTouchupDoneBtn(_ sender:UIBarButtonItem) {
        if data.name == nil {
            self.inputRun(cell: self.nameCell)
            return
        }
        if data.price == nil {
            self.inputRun(cell: self.priceCell)
            return
        }
        
        let realm = try! Realm()
        if let model = self.payment {
            realm.beginWrite()
            model.loadData(data)
            try! realm.commitWrite()
        } else {
            let model = PaymentModel()
            model.loadData(data)
            realm.beginWrite()
            realm.add(model)
            try! realm.commitWrite()
        }
        navigationController?.popViewController(animated: true)

    }
}

extension MakePaymentViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.first?.coordinate {
            mapView.setCamera(MKMapCamera(lookingAtCenter: coordinate, fromDistance: 200 , pitch: 30, heading: 0), animated: locationUpdateCount > 0)
            data.coordinate = coordinate
            locationUpdateCount += 1
            checkBtn()
        }
    }
    
}


extension MakePaymentViewController : OldPaymentsByLocationInfoViewControllerDelegate {
    func didSelectPayment(id: String) {
        guard let payment = try! Realm().object(ofType: PaymentModel.self, forPrimaryKey: id) else {
            return
        }
        
        loadData(model: payment, isFixLocation: false)
        updateLabel()
    }
}
