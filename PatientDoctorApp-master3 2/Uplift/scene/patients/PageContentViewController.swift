//
//  PageContentViewController.swift
//  Uplift
//
//  Created by Harold Asiimwe on 01/01/2018.
//  Copyright © 2018 Harold Asiimwe. All rights reserved.
//

import UIKit
import RealmSwift
import GrowingTextView


class PageContentViewController: UIViewController {
    
    @IBOutlet weak var questionHeading: UILabel!
    @IBOutlet weak var answerInputTextView: GrowingTextView!
    
    var pageIndex: Int?
    var questionText : String!
    var answerText : String!
    var questionKey: String!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.questionHeading.text = self.questionText
        self.answerInputTextView.placeHolder = self.answerText.isEmpty ? "Enter your answer here" : self.answerText
        self.questionHeading.alpha = 0.1
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.questionHeading.alpha = 1.0
        })
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.answerInputTextView.text = Shared.retrieveOfflineAnswer(questionKey: self.questionKey).isEmpty ? "" : Shared.retrieveOfflineAnswer(questionKey: self.questionKey)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        /// Save any input that has been entered by the user locally here
        do {
            let realm = try Realm()
            let answerToBeSaved = OfflineAnswer()
            answerToBeSaved.questionKey = self.questionKey
            answerToBeSaved.answer = self.answerInputTextView.text
            
            try! realm.write {
                realm.add(answerToBeSaved, update: true)
            }
            
        } catch let error {
            print(error)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
