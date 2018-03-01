//
//  Answer.swift
//  Uplift
//
//  Created by Harold Asiimwe on 22/10/2017.
//  Copyright © 2017 Harold Asiimwe. All rights reserved.
//

import Foundation
import Firebase

struct Answer {
    let key: String
    let name: String
    let addedBy: String
    let belongsToQuestion: String
    let ref: DatabaseReference?
    let active:Bool
    let timeAdded: String
    
    init(name: String, addedBy: String, belongsToQuestion: String, active: Bool, key: String = "", timeAdded: String = "") {
        self.key = key
        self.name = name
        self.addedBy = addedBy
        self.belongsToQuestion = belongsToQuestion
        self.timeAdded = timeAdded
        self.active = active
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        addedBy = snapshotValue["addedBy"] as! String
        belongsToQuestion = snapshotValue["belongsToQuestion"] as! String
        active = snapshotValue["active"] as! Bool
        timeAdded = (snapshotValue["timeAdded"] as? String) ?? ""
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "name" :name,
            "addedBy": addedBy,
            "belongsToQuestion": belongsToQuestion,
            "timeAdded": timeAdded,
            "active":active
        ]
    }
}
