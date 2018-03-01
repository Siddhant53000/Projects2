//
//  SignInViewController.swift
//  Uplift
//
//  Created by Harold Asiimwe on 13/10/2017.
//  Copyright © 2017 Harold Asiimwe. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signinButton: LoadingButton!
    
    var patientRef = DatabaseReference()
    
    @IBAction func signButtonTapped(_ sender: Any) {
        patientRef = Database.database().reference(withPath: "patients")
        patientRef.keepSynced(true)
        
        passwordTextField.resignFirstResponder()
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            Shared.showAlert(title: "Signin", message: "Please enter all the fields", viewController: self)
            return
        }
        
        if !Shared.isValidEmail(testStr: emailTextField.text!) {
            Shared.showAlert(title: "Signin", message: "Please enter a valid email address", viewController: self)
            return
        }
        
        if passwordTextField.text!.count < 6 {
            Shared.showAlert(title: "Signin", message: "Passwords should at least have 6 characters", viewController: self)
            return
        }
        
        //Make firebase call to sign in user here
        signinButton.showLoading()
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            self.signinButton.hideLoading()
            if let error = error {
                Shared.showAlert(title: "Signin", message: "There is no user record matching the input details.", viewController: self)
                print(error.localizedDescription)
            } else {
                //check if user is patient or doctor
                print(self.emailTextField.text!)
                let query = self.patientRef.queryOrdered(byChild: "email").queryEqual(toValue: self.emailTextField.text!)
                query.keepSynced(true)
                self.patientRef.queryOrdered(byChild: "email").queryEqual(toValue: self.emailTextField.text!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snapshot = snapshot.value as? NSDictionary { // If email found under patients, redirect to patients storyboard
                        print(snapshot)
                        let defaults = UserDefaults.standard
                        defaults.set(true, forKey: "IS_PATIENT")
                        defaults.synchronize()
                        let storyboard = UIStoryboard(name: "Patients", bundle: nil)
                        let patientsTabBarController = storyboard.instantiateViewController(withIdentifier: "PatientsTabBarController")
                        self.navigationController?.present(patientsTabBarController, animated: false, completion: nil)
                        
                    } else { // User is doctor, redirect to doctor storyboard
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let doctorsTabBarController = storyboard.instantiateViewController(withIdentifier: "DoctorsTabBarController")
                        self.navigationController?.present(doctorsTabBarController, animated: false, completion: nil)
                    }
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        self.navigationController?.navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SignInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        if textField == emailTextField {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
}
