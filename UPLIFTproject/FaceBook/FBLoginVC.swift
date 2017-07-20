//
//  FBLoginVC.swift
//  FaceBook
//
//  Created by Administrator on 10/5/16.
//  Copyright © 2016 ITP344. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class FBLoginVC: UIViewController, FBSDKLoginButtonDelegate{
	
	var loginButton : FBSDKLoginButton!

	@IBOutlet weak var errorMessageLabel: UILabel!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		loginButton = FBSDKLoginButton()
		loginButton.center = self.view.center
		self.view.addSubview(loginButton)
		loginButton.readPermissions = ["public_profile", "email", "user_friends"]
		loginButton.delegate = self
		
    }

	func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
		
		if (error != nil) {
			errorMessageLabel.text = "\(error)"
			
		} else if(result.token != nil) {
			self.dismiss(animated: true, completion: nil)
			
		} else {
			errorMessageLabel.text = "Unknown error occured"
		}
		
		
		
		print("loginButton didCompleteWith \(error)")
		
	}
	
	func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
		
		
	}


}
