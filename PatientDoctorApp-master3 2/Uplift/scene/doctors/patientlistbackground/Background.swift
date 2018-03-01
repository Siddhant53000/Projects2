//
//  Background.swift
//  Uplift
//
//  Created by Harold Asiimwe on 22/10/2017.
//  Copyright © 2017 Harold Asiimwe. All rights reserved.
//

import UIKit

protocol BackgroundAddPatientsProtocol: class {
    func addPatientsButtonTapped()
}

class Background: UIView {

    @IBOutlet var contentView: UIView!
    
    weak var delegate: BackgroundAddPatientsProtocol?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBAction func addPatientsButtonTapped(_ sender: Any) {
        delegate?.addPatientsButtonTapped()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("Background", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
