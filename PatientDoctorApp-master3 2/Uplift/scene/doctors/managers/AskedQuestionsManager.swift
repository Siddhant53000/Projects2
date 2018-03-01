//
//  AskedQuestionsManager.swift
//  Uplift
//
//  Created by Harold Asiimwe on 21/11/2017.
//  Copyright © 2017 Harold Asiimwe. All rights reserved.
//

import Foundation
import Firebase

enum QuestionCategory: String {
    case thoughtRecord, avoidanceSufferingDiary
}

class AskedQuestionsManager {
    
    struct QuestionStore {
        
        var doctorEmail = ""
        var doctorName = ""
        var patientEmail = ""
        var questionRef = DatabaseReference()
        
        let questions = [
            "Situation / Trigger": "What happened? Where? When? Who with? How?",
            "Feelings Emotions – (Rate 0 – 100%) Body sensations" :
            "What emotion did I feel at that time? What else? How intense was it? What did I notice in my body? Where did I feel it?",
            "Unhelpful Thoughts / Images" :
            "What went through my mind? What disturbed me? What did those thoughts/images/memories mean to me, or say about me or the situation? What am I responding to? What ‘button’ is this pressing for me? What would be the worst thing about that, or that could happen?",
            "Facts that support the unhelpful thought" : "What are the facts? What facts do I have that the unhelpful thought/s are totally true?",
            "Facts that provide evidence against the unhelpful thought" :
            "What facts do I have that the unhelpful thought/s are NOT totally true? Is it possible that this is opinion, rather than fact? What have others said about this?",
            "Alternative, more realistic and balanced perspective" :
            "STOPP! Take a breath…. What would someone else say about this situation? What’s the bigger picture? Is there another way of seeing it? What advice would I give someone else? Is my reaction in proportion to the actual event? Is this really as important as it seems?",
            "Outcome Re-rate emotion" : "What am I feeling now? (0-100%) What could I do differently? What would be more effective? Do what works! Act wisely. What will be most helpful for me or the situation? What will the consequences be?"
        ]
        
        let avoidanceSufferingQuestions = [
            "Painful Thoughts/ Feelings/ Sensations/ Memories that showed up today" :
            "Painful Thoughts/ Feelings/ Sensations/ Memories that showed up today",
            "What I did to escape, avoid, get rid of them, or distract myself from them":
            "What I did to escape, avoid, get rid of them, or distract myself from them",
            "What that cost me in terms of health, vitality, relationship issues, getting stuck, increasing pain, wasted time/money/energy etc.":
            "What that cost me in terms of health, vitality, relationship issues, getting stuck, increasing pain, wasted time/money/energy etc."
        ]
        
        func addQuestions(questionCategory: QuestionCategory) {
            switch questionCategory {
            case .thoughtRecord:
                //Add thought record questions
                saveQuestionsToFireBase(questions: questions)
            default:
                saveQuestionsToFireBase(questions: avoidanceSufferingQuestions)
            }
        }
        
        func addCategoryQuestions(questions:[String:String]) {
            saveQuestionsToFireBase(questions: questions)
        }
        
        private func saveQuestionsToFireBase(questions: [String:String]) {
            for question in questions {
                let nsdateAdded = NSDate().timeIntervalSince1970
                let question = Question(name: question.key, addedByDoctor: doctorEmail, doctorName: doctorName, questionText: question.value, belongsTo: patientEmail, timeAdded: "\(nsdateAdded)", active: true)
                let questionItemRef = self.questionRef.child("\(Date().ticks)")
                questionItemRef.setValue(question.toAnyObject())
            }
        }
    }
    
    func questionAlreadyAsked(questionCatergory: QuestionCategory, questions:[Question]) -> Bool {
        switch questionCatergory {
        case .thoughtRecord:
            let thoughtRecord = QuestionStore()
            for question in questions {
                for qtn in thoughtRecord.questions {
                    if question.name == qtn.key && question.questionText == qtn.value {
                        return true
                    }
                }
            }
        default:
            let avoidanceSufferingQtns = QuestionStore()
            for question in questions {
                for qtn in avoidanceSufferingQtns.avoidanceSufferingQuestions {
                    if question.name == qtn.key && question.questionText == qtn.value {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func getUnSelectedQuestions(questionCatergory: QuestionCategory, questions:[Question]) -> [String : String] {
        switch questionCatergory {
            case .thoughtRecord:
                let thoughtRecord = QuestionStore()
                var thoughtRecordQuestions = thoughtRecord.questions
                for question in questions {
                    for qtn in thoughtRecordQuestions {
                        if question.name == qtn.key {
                            thoughtRecordQuestions.removeValue(forKey: qtn.key)
                        }
                    }
                }
                return thoughtRecordQuestions
            case .avoidanceSufferingDiary:
                let avoidance = QuestionStore()
                var avoidanceQuestions = avoidance.avoidanceSufferingQuestions
                for question in questions {
                    for qtn in avoidanceQuestions {
                        if qtn.key == question.name {
                            avoidanceQuestions.removeValue(forKey: qtn.key)
                        }
                    }
                }
                return avoidanceQuestions
        }
    }
}
