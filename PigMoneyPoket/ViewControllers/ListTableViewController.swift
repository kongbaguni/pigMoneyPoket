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
class ListTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.onTouchupAddBtn(_:)))
        title = "list"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }
    }
    
    @objc func onTouchupAddBtn(_ sender:UIBarButtonItem) {
        self.performSegue(withIdentifier: "makePayment", sender: nil)
//        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        vc.addAction(UIAlertAction(title: "+", style: .default, handler: { (action) in
//            self.performSegue(withIdentifier: "makePayment", sender: nil)
//        }))
//        vc.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
//        present(vc, animated: true, completion: nil)
    }
    
}
