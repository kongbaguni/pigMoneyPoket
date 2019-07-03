//
//  OldPaymentsByLocationInfoViewController.swift
//  PigMoneyPoket
//
//  Created by Changyul Seo on 08/01/2019.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import UIKit
import RealmSwift
import RxCocoa
import RxSwift

protocol OldPaymentsByLocationInfoViewControllerDelegate : class {
    func didSelectPayment(id:String)
}

class OldPaymentsByLocationInfoViewController: UITableViewController {
    deinit {
        debugPrint("------ \(#file) \(#function) -----")
    }
    @IBOutlet weak var searchBar: UISearchBar!
    
    var isIncome:Bool = false
    weak var delegate:OldPaymentsByLocationInfoViewControllerDelegate? = nil

    private var _pays:Results<PaymentModel>? = nil
    var pays:Results<PaymentModel>? {
        set {
            _pays = newValue
        }
        get {
            if var pays = _pays {
                if let search = searchBar.text {
                    if search.isEmpty == false {
                        pays = pays.filter("name contains[C] %@", search)
                    }
                }
                return pays
            }
            return nil
        }
    }
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isIncome {
            title = "income list".localized
        }
        else {
            title = "expenditure list".localized
        }
        
        searchBar.rx.text
            .orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
                self?.tableViewLayoutFix()
            })
            .disposed(by: disposeBag)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableViewLayoutFix()
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pays?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListTableViewCell
        cell.loadData(data: pays![indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popViewController(animated: true)
        delegate?.didSelectPayment(id: pays![indexPath.row].id)
    }
    
    private func tableViewLayoutFix() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(500)) {
            self.tableView.contentSize.height = CGFloat((self.pays?.count ?? 0) * 100)
        }
    }
    
}

