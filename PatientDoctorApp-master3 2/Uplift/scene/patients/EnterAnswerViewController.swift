//
//  EnterAnswerViewController.swift
//  Uplift
//
//  Created by Harold Asiimwe on 07/11/2017.
//  Copyright © 2017 Harold Asiimwe. All rights reserved.
//

import UIKit
import GrowingTextView
import Firebase

class EnterAnswerViewController: UIViewController, GrowingTextViewDelegate {
    
    var answerRef = DatabaseReference()
    var question: Question!
    var answerToBeEdited: Answer!
    
    @IBOutlet weak var enterAnswerTextView: GrowingTextView!
    
    
    @IBAction func saveAnswerButtonTapped(_ sender: Any) {
        if enterAnswerTextView.isFirstResponder {
            enterAnswerTextView.resignFirstResponder()
        }
        if enterAnswerTextView.text.isEmpty {
            Shared.showAlert(title: "Enter Answer", message: "No answer text was entered", viewController: self)
            return
        }
        
        if answerToBeEdited != nil {
            saveAnswerEdit(text: enterAnswerTextView.text)
        } else {
            saveAnswer(text: enterAnswerTextView.text)
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        answerRef = Database.database().reference(withPath: "answers")
        answerRef.keepSynced(true)
        self.hideKeyboardWhenTappedAround()
        
        if answerToBeEdited != nil {
            enterAnswerTextView.text = answerToBeEdited.name
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.view.endEditing(true)
    }
    
    func saveAnswer(text: String) {
        let nsdateAdded = NSDate().timeIntervalSince1970
        let answer = Answer(name: text, addedBy: Auth.auth().currentUser!.email!, belongsToQuestion: question.key, active: true, timeAdded: "\(nsdateAdded)")
        let answerItemRef = self.answerRef.child("\(Date().ticks)")
        answerItemRef.setValue(answer.toAnyObject())
    }
    
    func saveAnswerEdit(text:String) {
        if let answer = answerToBeEdited {
            answer.ref?.updateChildValues(["name": text], withCompletionBlock: { (error, reference) in
                if error != nil {
                    Shared.showAlert(title: "Error", message: (error?.localizedDescription)!, viewController: self)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            })
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
