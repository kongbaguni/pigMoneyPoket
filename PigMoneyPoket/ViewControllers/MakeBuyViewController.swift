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
import CoreLocation
import RxSwift
import RxCocoa
import FirebaseDatabase
import FirebaseAuth

class MakePaymentViewController: UITableViewController {
    deinit {
        debugPrint("------ \(#file) \(#function) -----")
    }
    
    @IBOutlet weak var footerView: UIView!
    var locationUpdateCount = 0
    var paymentID:String? = nil
    var payment:PaymentModel? {
        if let id = paymentID {
            return try! Realm().object(ofType: PaymentModel.self, forPrimaryKey: id)
        }
        return nil
    }
    var ref:DatabaseReference!
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
        list = list.sorted(byKeyPath: "datetime")
        return list
    }
    
    @IBOutlet weak var mapView:MKMapView!
    
    @IBOutlet weak var listBtn:UIBarButtonItem!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var tagLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    let disposeBag = DisposeBag()
    
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
        ref = Database.database().reference()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if let model = payment {
            loadData(model: model)
            if model.isIncome {
                title = "income".localized
                listBtn.title = "income list".localized
            } else {
                title = "expenditure".localized
                listBtn.title = "expenditure list".localized
            }

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
        checkBtn()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.onTouchupDoneBtn(_:)))
        
        nameTextField.rx.text.orEmpty.subscribe(onNext: { value in
            self.data.name = value
        }).disposed(by: disposeBag)
        
        priceTextField.rx.text.orEmpty.subscribe(onNext: { value in
            self.data.price = NSString(string: value).integerValue
        }).disposed(by: disposeBag)
        
        tagTextField.rx.text.orEmpty.subscribe(onNext: { (value) in
            self.data.tags.removeAll()
            for tag in value.components(separatedBy: ",") {
                if tag.isEmpty == false {
                    self.data.tags.insert(tag)
                }
            }
        }).disposed(by: disposeBag)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
                vc.pays = paymentsByLocation
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
        tagTextField.text = data.tagString
        nameTextField.text = data.name
        priceTextField.text = "\(abs(data.price ?? 0))"
        priceTextField.textColor = model.isIncome ? .blue : .red
    }
    
    @objc func onTouchupDoneBtn(_ sender:UIBarButtonItem) {
        guard let name = data.name, let price = data.price, let coordinate = data.coordinate, let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let realm = try! Realm()
        var uuid = ""
        if let model = self.payment {
            realm.beginWrite()
            model.loadData(data)
            try! realm.commitWrite()
            uuid = model.id
        } else {
            let model = PaymentModel()
            model.loadData(data)
            realm.beginWrite()
            realm.add(model)
            try! realm.commitWrite()
            uuid = model.id
        }
        
        //Firebase db 에 쓰기
        let value:[String:Any] = [
            "name" : name,
            "isIncome": data.isIncome,
            "price" : price,
            "latitude" : coordinate.latitude,
            "longitude" : coordinate.longitude,
            "dateTime" : Date().timeIntervalSince1970,
            "tags" : data.tagString
        ]
        
        self.ref.child("pays/\(uid)/\(uuid)").setValue(value)
        
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
    }
}
