//
//  RegisterViewController.swift
//  Uplift
//
//  Created by Harold Asiimwe on 13/10/2017.
//  Copyright © 2017 Harold Asiimwe. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: LoadingButton!
    
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        passwordTextField.resignFirstResponder()
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            Shared.showAlert(title: "Register", message: "Please enter all the fields", viewController: self)
            return
        }
        
        if !Shared.isValidEmail(testStr: emailTextField.text!) {
            Shared.showAlert(title: "Register", message: "Please enter a valid email address", viewController: self)
            return
        }
        
        if passwordTextField.text!.count < 6{
            Shared.showAlert(title: "Register", message: "Password field should at least have 6 characters", viewController: self)
            return
        }
        
        //Make firebase call to register user here
        registerButton.showLoading()
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            self.registerButton.hideLoading()
            if let error = error {
                Shared.showAlert(title: "Register", message: "Unable to complete registration process. Try again", viewController: self)
                print(error.localizedDescription)
            } else {
                if let _ = user {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let doctorsTabBarController = storyboard.instantiateViewController(withIdentifier: "DoctorsTabBarController")
                    self.navigationController?.present(doctorsTabBarController, animated: false, completion: nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationItem.title = "Register"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
