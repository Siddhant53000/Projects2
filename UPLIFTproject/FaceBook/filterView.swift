//
//  filterView.swift
//  UPLIFT
//
//  Created by Siddhant Gupta on 5/6/17.
//  Copyright © 2017 ITP344. All rights reserved.
//

import Foundation
import UIKit
class filterView: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sepiaButton: UIButton!
    @IBOutlet weak var blurButton: UIButton!
    @IBOutlet weak var vignetteButton: UIButton!
    var newImage : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sepiaButton(_ sender: Any) {
    }
    
    @IBAction func blurButton(_ sender: Any) {
    }
    @IBAction func vignetteButton(_ sender: Any) {
    }
}
