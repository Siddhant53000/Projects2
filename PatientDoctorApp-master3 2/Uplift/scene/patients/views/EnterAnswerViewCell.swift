//
//  EnterAnswerViewCell.swift
//  Uplift
//
//  Created by Harold Asiimwe on 03/01/2018.
//  Copyright © 2018 Harold Asiimwe. All rights reserved.
//

import UIKit
import GrowingTextView

class EnterAnswerViewCell: UITableViewCell {
    
    @IBOutlet weak var enterAnswerTextView: GrowingTextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension EnterAnswerViewCell: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.contentView.layoutIfNeeded()
        }
    }
}
