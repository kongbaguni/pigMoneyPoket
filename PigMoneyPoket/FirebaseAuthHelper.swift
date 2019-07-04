//
//  FirebaseAuthHelper.swift
//  PigMoneyPoket
//
//  Created by Changyul Seo on 04/07/2019.
//  Copyright © 2019 Changyul Seo. All rights reserved.
//

import Foundation
import FirebaseAuth
class FirebaseAuthHelper {
    static let shared = FirebaseAuthHelper()
    
    var handle:AuthStateDidChangeListenerHandle? = nil
    func start() {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            print(user?.email ?? "없음")
        }
    }
    
    func end() {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    func signIn(email:String, passwod:String, completion:@escaping (_ uid:String?)->Void) {
        Auth.auth().signIn(withEmail: email, password: passwod) { (result, error) in
            completion(result?.user.uid)
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
