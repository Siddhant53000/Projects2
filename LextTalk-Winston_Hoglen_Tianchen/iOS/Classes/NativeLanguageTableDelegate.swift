//
//  NativeLanguageTableDelegate.swift
//  LextTalk
//
//  Created by Shane Rosse on 9/25/16.
//
//

import UIKit

class NativeLanguageTableDelegate : NSObject, UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        if arc4random() % 2 == 0 {
            cell.backgroundColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        } else {
            cell.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        }
        return cell
    }
}
