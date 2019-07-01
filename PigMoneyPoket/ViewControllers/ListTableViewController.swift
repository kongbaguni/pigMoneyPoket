//
//  ListTableViewController.swift
//  PigMoneyPoket
//
//  Created by Changyul Seo on 05/01/2019.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift
import TagListView
import FSCalendar
import MapKit

class ListTableViewController: UITableViewController {
    static var viewController:ListTableViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "listController") as! ListTableViewController
    }
    
    @IBOutlet weak var calendarView: FSCalendar!

    var tag:String? = nil
    
    var datas:Results<PaymentModel> {
        var list = try! Realm().objects(PaymentModel.self)
        if let tag = self.tag {
            
            list = list.filter("tag contains[C] %@", ",\(tag),")
        }
        if let date = calendarView.selectedDate {
            list = list.filter("datetime > %@ && datetime < %@",date, Date(timeInterval: 86400
                , since: date))
        }
        return list
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "income, expenditure".localized
        if let t = tag {
            tableView.tableHeaderView = UIView()
            tableView.tableFooterView = UIView()
            title = t
        }
        calendarView.dataSource = self
        calendarView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }
        switch id {
        case "income":
            if let vc = segue.destination as? MakePaymentViewController {
                vc.data.isIncome = true
            }
            
        case "expenditure":
            if let vc = segue.destination as? MakePaymentViewController {
                vc.data.isIncome = false
            }
            
        case "edit":
            if let vc = segue.destination as? MakePaymentViewController ,
                let id = sender as? String{
                vc.paymentID = id
            }

        case "showMap":
            if let vc = segue.destination as? MapViewController,
                let id = sender as? String {
                vc.paymentID = id
            }
        default:
            break
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListTableViewCell
        let data = datas[indexPath.row]
        cell.loadData(data: data)
        cell.tagListView.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .destructive, title: "delete".localized, handler: { (action, indexPath) in
                let vc = UIAlertController(title: nil, message: "delete?".localized, preferredStyle: .alert)
                vc.addAction(UIAlertAction(title: "confirm".localized, style: .default, handler: { (action) in
                    let data = self.datas[indexPath.row]
                    let realm = try! Realm()
                    realm.beginWrite()
                    realm.delete(data)
                    try! realm.commitWrite()
                    self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                }))
                vc.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
                self.present(vc, animated: true, completion: nil)
            }),
            UITableViewRowAction(style: .default, title: "edit".localized, handler: { (action, indexPath) in
                let data = self.datas[indexPath.row]
                self.performSegue(withIdentifier: "edit", sender: data.id)
            })
        ]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = datas[indexPath.row]
        self.performSegue(withIdentifier: "showMap", sender: data.id)
    }
    
}

extension ListTableViewController: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        if self.tag == title {
            return
        }
        if self.tag != nil {
            navigationController?.popViewController(animated: true)
        }
        let vc = ListTableViewController.viewController
        vc.tag = title
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ListTableViewController : FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let list = try! Realm().objects(PaymentModel.self)
        return list.filter("datetime > %@ && datetime < %@",date, Date(timeInterval: 86400
, since: date)).count
    }
}

extension ListTableViewController : FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.tableView.reloadData()
    }
}
