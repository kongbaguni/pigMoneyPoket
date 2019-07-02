//
//  OldPaymentsByLocationInfoViewController.swift
//  PigMoneyPoket
//
//  Created by Changyul Seo on 08/01/2019.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift

protocol OldPaymentsByLocationInfoViewControllerDelegate : class {
    func didSelectPayment(id:String)
}

class OldPaymentsByLocationInfoViewController: UITableViewController {
    deinit {
        debugPrint("------ \(#file) \(#function) -----")
    }

    var isIncome:Bool = false
    weak var delegate:OldPaymentsByLocationInfoViewControllerDelegate? = nil
    var paymentIds:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isIncome {
            title = "income list".localized
        }
        else {
            title = "expenditure list".localized
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentIds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListTableViewCell
        if let data = try! Realm().object(ofType: PaymentModel.self, forPrimaryKey: paymentIds[indexPath.row]) {
            cell.loadData(data: data)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popViewController(animated: true)
        delegate?.didSelectPayment(id: paymentIds[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

