//
//  FirebaseAuthHelper.swift
//  PigMoneyPoket
//
//  Created by Changyul Seo on 04/07/2019.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit

class FirebaseAuthHelper {
    static let shared = FirebaseAuthHelper()
    
    var handle:AuthStateDidChangeListenerHandle? = nil
    func start() {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            print(user?.email ?? "없음")
        }
    }
    
    func end() {
        if let h = handle {
            Auth.auth().removeStateDidChangeListener(h)
        }
    }
    
    func signIn(email:String, passwod:String, completion:@escaping ()->Void) {
        Auth.auth().signIn(withEmail: email, password: passwod) { (result, error) in
            if let err = error {
                let ac = UIAlertController(title: nil, message: err.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                ac.addAction(UIAlertAction(title: "confirm".localized, style: .cancel, handler: nil))
                UIApplication.shared.keyWindow?.rootViewController?.present(ac, animated: true, completion: nil)
                return
            }
            completion()
        }
    }
    
    func createUser(email:String, passwd:String, compleion:@escaping(_ error:Error?)->Void) {
        Auth.auth().createUser(withEmail: email, password: passwd) { (result, error) in
            if error != nil {
                self.signIn(email: email, passwod: passwd, completion: {
                    compleion(error)
                })
                return
            }
            compleion(error)
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        }
        catch {
            
        }
    }
}
