//
//  JoinViewController.swift
//  PigMoneyPoket
//
//  Created by Changyul Seo on 04/07/2019.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import RxSwift
import RxCocoa

class JoinViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var password2TextField: UITextField!
    @IBOutlet weak var joinBtn:UIButton!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        checkJoinBtnEnable()
        emailTextField.rx.text.orEmpty.subscribe(onNext: { (value) in
            self.emailTextField.text = value.trimmingCharacters(in: .whitespacesAndNewlines)
            self.checkJoinBtnEnable()
        }).disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty.subscribe(onNext: { (value) in
            self.checkJoinBtnEnable()
        }).disposed(by: disposeBag)
        
        password2TextField.rx.text.orEmpty.subscribe(onNext: { (value) in
            self.checkJoinBtnEnable()
        }).disposed(by: disposeBag)
        
        emailTextField.placeholder = "email".localized
        passwordTextField.placeholder = "password".localized
        password2TextField.placeholder = "password".localized
        joinBtn.setTitle("create account".localized, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseAuthHelper.shared.start()
    }
    
    private func checkJoinBtnEnable() {
        let isVaildEmail = emailTextField.text?.isValidateEmail ?? false
        let isVaildPsswd = passwordTextField.text?.isEmpty == false && passwordTextField.text == password2TextField.text
        joinBtn.isEnabled = isVaildEmail && isVaildPsswd
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        FirebaseAuthHelper.shared.end()
    }
    
    @IBAction func onTouchupJoinButton(_ sender: Any) {
        guard let email = emailTextField.text, let passwd = passwordTextField.text else {
            return
        }
        Auth.auth().createUser(withEmail: email, password: passwd) { (result, error) in
            if error == nil {
                FirebaseAuthHelper.shared.signIn(email: email, passwod: passwd, completion: { _ in
                    UIApplication.shared.keyWindow?.rootViewController = ListTableViewController.navigationController
                })
            } else {
                let ac = UIAlertController(title: nil, message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                ac.addAction(UIAlertAction(title: "confirm".localized, style: .cancel, handler: nil))
                self.present(ac, animated: true)
            }
        }
    }
}
