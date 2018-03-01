//
//  User.swift
//  Uplift
//
//  Created by Harold Asiimwe on 22/10/2017.
//  Copyright © 2017 Harold Asiimwe. All rights reserved.
//

import Foundation
import Firebase

struct ULUser {
    
    let uid: String
    let email: String
    
    init(authData: User) {
        uid = authData.uid
        email = authData.email!
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
}
