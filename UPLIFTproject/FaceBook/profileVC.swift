//
//  profileVC.swift
//  UPLIFT
//
//  Created by Siddhant Gupta on 4/23/17.
//  Copyright © 2017 Siddhant Gupta. All rights reserved.
//

import Foundation
import UIKit
class profileVC: UIViewController {
    public var myImage : UIImage!
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = myImage
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
