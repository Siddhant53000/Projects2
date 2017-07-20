//
//  MapFilter.swift
//  LextTalk
//
//  Created by Shane Rosse on 10/2/16.
//
//

import Foundation

public class MapFilter: NSObject {
    
    var onlyRecentlyActive: Bool = false
    var onlyMultilingual: Bool = false
    var onlySpeakingWhatImLearning: Bool = false
    var onlyLearningWhatImSpeaking: Bool = false
    
    public func initWithResults(_ results: NSArray) {
        // result recent, multilingual, speaking, learning
        
        onlyRecentlyActive = results[0] as! Bool
        onlyMultilingual = results[1] as! Bool
        onlySpeakingWhatImLearning = results[2] as! Bool
        onlyLearningWhatImSpeaking = results[3] as! Bool
    }
    
    func checkUserSpeakingWhatImLearning(user: LTUser) -> Bool {
        if let shared = LTDataSource.shared() {
            if let localUser = shared.localUser {
                var success = false
                if let speakingLanguage = localUser.activeLearningLan {
                    for speakingLanguages in user.speakingLanguages {
                        if (speakingLanguages as! String) == speakingLanguage {
                            success = true
                        }
                    }
                }
                if !success {
                    return false
                }
            }
        }
        return true
    }
    
    func checkUserLearningWhatImSpeaking(user: LTUser) -> Bool {
        if let shared = LTDataSource.shared() {
            if let localUser = shared.localUser {
                var success = false
                if let learningLanguage = localUser.activeSpeakingLan {
                    for learningLanguages in user.learningLanguages {
                        if (learningLanguages as! String) == learningLanguage {
                            success = true
                        }
                    }
                }
                if !success {
                    return false
                }
            }
        }
        return true
    }
    
    func checkUserActivity(user: LTUser, activeSince: Int) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        if let date = dateFormatter.date(from: user.lastUpdate) {
            let inactiveInterval = Date().timeIntervalSince(date)
            let inactiveDays = inactiveInterval/60/60/24
            if Int(inactiveDays) > activeSince {
                return false
            }
        }
        return true
    }
    
    func checkMultilingual(user: LTUser) -> Bool {
        if user.speakingLanguages.count > 1 {
            return true
        }
        return false
    }
    
    public func checkUser(user: LTUser) -> Bool {
        
        if onlySpeakingWhatImLearning {
            if !checkUserSpeakingWhatImLearning(user: user) {
                return false
            }
        }
        
        if onlyLearningWhatImSpeaking {
            if !checkUserLearningWhatImSpeaking(user: user) {
                return false
            }
        }
        
        if onlyRecentlyActive {
            if !checkUserActivity(user: user, activeSince: 7) {
                return false
            }
        }
        
        if onlyMultilingual {
            if !checkMultilingual(user: user) {
                return false
            }
        }
        
        return true
    }
}
