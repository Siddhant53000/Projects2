//
//  Question.swift
//  Uplift
//
//  Created by Harold Asiimwe on 22/10/2017.
//  Copyright © 2017 Harold Asiimwe. All rights reserved.
//

import Foundation
import Firebase

struct Question {
    let key: String
    let name: String
    let questionText: String
    let addedByDoctor: String
    let doctorName: String
    let belongsTo: String
    let ref: DatabaseReference?
    let active:Bool
    let timeAdded: String
    
    init(name: String, addedByDoctor: String, doctorName: String, questionText: String = "", belongsTo: String, timeAdded:String, active: Bool, key: String = "") {
        self.key = key
        self.name = name
        self.questionText = questionText
        self.addedByDoctor = addedByDoctor
        self.belongsTo = belongsTo
        self.timeAdded = timeAdded
        self.active = active
        self.doctorName = doctorName
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        questionText = (snapshotValue["questionText"] as? String) ?? ""
        addedByDoctor = snapshotValue["addedByDoctor"] as! String
        doctorName = (snapshotValue["doctorName"] as? String) ?? ""
        belongsTo = snapshotValue["belongsTo"] as! String
        active = snapshotValue["active"] as! Bool
        timeAdded = snapshotValue["timeAdded"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "name" :name,
            "questionText" : questionText,
            "addedByDoctor": addedByDoctor,
            "doctorName": doctorName,
            "belongsTo": belongsTo,
            "timeAdded": timeAdded,
            "active":active
        ]
    }
    
}
