//
//  Patient.swift
//  Uplift
//
//  Created by Harold Asiimwe on 22/10/2017.
//  Copyright © 2017 Harold Asiimwe. All rights reserved.
//

import Foundation
import Firebase

struct Patient {
    let key: String
    let name: String
    let email: String
    let password: String
    let addedByDoctor: String
    let ref: DatabaseReference?
    let active:Bool
    
    init(name: String, email: String, password: String, addedByDoctor: String, active: Bool, key: String = "") {
        self.key = key
        self.name = name
        self.email = email
        self.password = password
        self.addedByDoctor = addedByDoctor
        self.active = active
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        email = snapshotValue["email"] as! String
        password = snapshotValue["password"] as! String
        addedByDoctor = snapshotValue["addedByDoctor"] as! String
        active = snapshotValue["active"] as! Bool
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "name" :name,
            "email":email,
            "password": password,
            "addedByDoctor": addedByDoctor,
            "active":active
        ]
    }
}
