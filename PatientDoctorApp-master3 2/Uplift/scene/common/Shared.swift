//
//  Shared.swift
//  Uplift
//
//  Created by Harold Asiimwe on 13/10/2017.
//  Copyright © 2017 Harold Asiimwe. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Firebase

struct Shared {
    
    static func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    static func showAlert(title:String, message:String, viewController:UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Ok button a alert"), style: .default) { (action) in
        }
        
        alertController.addAction(OKAction)
        viewController.present(alertController, animated: true) {
        }
    }
    
    static func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    static func logout(viewController: UIViewController){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let storyboard = UIStoryboard(name: "Accounts", bundle: nil)
            let doctorsTabBarController = storyboard.instantiateViewController(withIdentifier: "AccountsNavigationController")
            viewController.navigationController?.present(doctorsTabBarController, animated: false, completion: nil)
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "IS_PATIENT")
            defaults.synchronize()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            //cString = cString.substring(to: cString.index(cString.startIndex, offsetBy: 1))
            cString = String(cString[cString.index(cString.startIndex, offsetBy: 1)...])
        }
        
        if (cString.count != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue:  CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func retrieveOfflineAnswer(questionKey: String) -> String {
        do {
            let realm = try Realm()
            let offlineAnswer =  realm.object(ofType: OfflineAnswer.self, forPrimaryKey: questionKey)
            if let offlineAnswer = offlineAnswer {
                return offlineAnswer.answer
            }
        } catch let error {
            print(error)
        }
        return String()
    }
    
    static func saveAnswer(text: String, questionKey: String, answerRef: DatabaseReference) {
        let nsdateAdded = NSDate().timeIntervalSince1970
        let answer = Answer(name: text, addedBy: Auth.auth().currentUser!.email!, belongsToQuestion: questionKey, active: true, timeAdded: "\(nsdateAdded)")
        let answerItemRef = answerRef.child("\(Date().ticks)")
        answerItemRef.setValue(answer.toAnyObject())
    }
}

