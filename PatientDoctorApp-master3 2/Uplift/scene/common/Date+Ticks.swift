//
//  Date+Ticks.swift
//  Uplift
//
//  Created by Harold Asiimwe on 05/11/2017.
//  Copyright © 2017 Harold Asiimwe. All rights reserved.
//

import Foundation

extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}
