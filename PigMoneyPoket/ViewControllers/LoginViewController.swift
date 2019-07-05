//
//  LoginViewController.swift
//  PigMoneyPoket
//
//  Created by Changyul Seo on 04/07/2019.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import RealmSwift
import FirebaseAuth

class LoginViewController : UIViewController {
    static var navigationController : UINavigationController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login") as! UINavigationController
    }
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField:UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    
    let disposeBag = DisposeBag()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseAuthHelper.shared.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FirebaseAuthHelper.shared.end()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.placeholder = "email".localized
        passwordTextField.placeholder = "password".localized
        joinButton.setTitle("create account".localized, for: .normal)
        loginButton.setTitle("login".localized, for: .normal)
        if Auth.auth().currentUser != nil {
            UIApplication.shared.keyWindow?.rootViewController = ListTableViewController.navigationController
            return
        }
        
        self.loginButton.isEnabled  = false
        emailTextField.rx.text.orEmpty.subscribe(onNext: { (value) in
            print(value)
            let newValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
            self.loginButton.isEnabled = newValue.isValidateEmail && self.passwordTextField.text?.isEmpty == false
            self.emailTextField.text = newValue
        }).disposed(by: disposeBag)
        emailTextField.becomeFirstResponder()
        
        passwordTextField.rx.text.orEmpty.subscribe(onNext: { (password) in
            self.loginButton.isEnabled = self.emailTextField.text?.isValidateEmail == true && password.isEmpty == false
        }).disposed(by: disposeBag)
    }
    
    @IBAction func onTouchupLoginBtn(_ sender: UIButton) {
        guard let email = emailTextField.text, let passwd = passwordTextField.text else {
            return
        }
        FirebaseAuthHelper.shared.signIn(email: email, passwod: passwd) { _ in
            UIApplication.shared.keyWindow?.rootViewController = ListTableViewController.navigationController
        }
    }
    
}
