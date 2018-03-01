//
//  OfflineAnswer.swift
//  Uplift
//
//  Created by Harold Asiimwe on 23/01/2018.
//  Copyright © 2018 Harold Asiimwe. All rights reserved.
//

import Foundation
import RealmSwift

class OfflineAnswer: Object {
    @objc dynamic var questionKey: String = ""
    @objc dynamic var answer: String = ""
    
    override static func primaryKey()-> String {
        return "questionKey"
    }
}
