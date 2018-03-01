//
//  AnswerCell.swift
//  Uplift
//
//  Created by Harold Asiimwe on 18/12/2017.
//  Copyright © 2017 Harold Asiimwe. All rights reserved.
//

import UIKit

protocol EditAnswerDelegate: class {
    func didTapEditAnswerButton(indexPath: IndexPath)
}

class AnswerCell: UITableViewCell {
    
    weak var delegate: EditAnswerDelegate?
    
    var indexPath: IndexPath?
    
    @IBOutlet weak var dateAddedLabel: UILabel!
    
    @IBOutlet weak var answerTextLabel: UILabel!
    
    @IBAction func editButtonTapped(_ sender: Any) {
        if let indexPath = indexPath {
            delegate?.didTapEditAnswerButton(indexPath: indexPath)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
