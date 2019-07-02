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
    deinit {
        debugPrint("------ \(#file) \(#function) -----")
    }

    static var viewController:ListTableViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "listController") as! ListTableViewController
    }
    
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var footerView: UIView!
    
    var tag:String? = nil
    
    var datas:Results<PaymentModel> {
        var list = try! Realm().objects(PaymentModel.self)
        if let tag = self.tag {
            
            list = list.filter("tag contains[C] %@", ",\(tag),")
        }
        var date:Date = Date().midnight
        if let d = calendarView?.selectedDate {
            date = d
        }
        list = list.filter("datetime > %@ && datetime < %@",date, Date(timeInterval: 86400
            , since: date))
        return list
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "income, expenditure".localized
        if let t = tag {
            tableView.tableHeaderView?.isHidden = true
            tableView.tableFooterView?.isHidden = true
            for view in [tableView.tableHeaderView, tableView.tableFooterView] {
                view?.frame.size.height = 0
            }
            title = t
        }
        calendarView.dataSource = self
        calendarView.delegate = self
        setFooterViewShow()
        calendarView.select(Date())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        calendarView.reloadData()
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
        if datas.count > 0 {
            return 2
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return datas.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListTableViewCell
            let data = datas[indexPath.row]
            cell.loadData(data: data)
            cell.tagListView.delegate = self
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "sum", for: indexPath)
            cell.textLabel?.text = "sum".localized
            let sum:Int = datas.sum(ofProperty: "price")
            
            cell.detailTextLabel?.text = NumberFormatter.localizedString(from: NSNumber(value: sum), number: NumberFormatter.Style.currency)
            cell.detailTextLabel?.textColor = sum < 0 ? .red : .blue
            return cell
        }
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
                    self.calendarView.reloadData()
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [indexPath], with: .left)
                    self.tableView.endUpdates()
                }))
                vc.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
                self.present(vc, animated: true, completion: nil)
            }),
            UITableViewRowAction(style: .normal, title: "edit".localized, handler: { (action, indexPath) in
                let data = self.datas[indexPath.row]
                self.performSegue(withIdentifier: "edit", sender: data.id)
            })
        ]
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let data = datas[indexPath.row]
            self.performSegue(withIdentifier: "showMap", sender: data.id)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    private func setFooterViewShow() {
        footerView.isHidden = false
        if let d = calendarView.selectedDate {
            if d.timeIntervalSince1970 != Date().midnight.timeIntervalSince1970 {
                footerView.isHidden = true
            }
        }
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
        setFooterViewShow()
    }
}
