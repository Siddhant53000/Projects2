//
//  LearningLanguageTableDelegate.swift
//  LextTalk
//
//  Created by Shane Rosse on 9/25/16.
//
//

import UIKit

class LearningLanguageTableDelegate : NSObject, UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }


    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        if arc4random() % 2 == 0 {
            cell.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        } else {
            cell.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        }
        return cell
        
    }
}
