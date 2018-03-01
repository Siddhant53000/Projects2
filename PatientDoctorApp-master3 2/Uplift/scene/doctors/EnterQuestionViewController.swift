//
//  EnterQuestionViewController.swift
//  Uplift
//
//  Created by Harold Asiimwe on 02/11/2017.
//  Copyright © 2017 Harold Asiimwe. All rights reserved.
//

import UIKit
import Firebase
import GrowingTextView

class EnterQuestionViewController: UIViewController, UITextViewDelegate, GrowingTextViewDelegate {
    
    var questionRef = DatabaseReference()
    var patientEmail = ""
    var doctorEmail  = ""
    var doctorName   = ""
    var questionToBeEdited: Question!
    var isAbilityToAddCustomPlaceHolderForNewQtnEnabled = false
    var tempEnteredQuestionText = ""
    
    @IBOutlet weak var enteredQuestion: GrowingTextView!
    
    @IBAction func saveEnteredQuestion(_ sender: Any) {
        if enteredQuestion.isFirstResponder {
            enteredQuestion.resignFirstResponder()
        }
        if enteredQuestion.text.isEmpty {
            Shared.showAlert(title: "Enter Question", message: "No question text was entered", viewController: self)
            return
        }
        
        if questionToBeEdited != nil {
            saveQuestionEdit(text: enteredQuestion.text)
        } else if !tempEnteredQuestionText.isEmpty {
            saveQuestion(text: tempEnteredQuestionText, questionText: enteredQuestion.text)
            navigationController?.popViewController(animated: true)
        } else {
            saveQuestion(text: enteredQuestion.text)
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            //scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        // Do any additional setup after loading the view.
        questionRef = Database.database().reference(withPath: "questions")
        questionRef.keepSynced(true)
        
        self.hideKeyboardWhenTappedAround()
        
        if questionToBeEdited != nil {
            enteredQuestion.text = questionToBeEdited.questionText.isEmpty ? questionToBeEdited.name : questionToBeEdited.questionText
            isAbilityToAddCustomPlaceHolderForNewQtnEnabled = false
        } else { //we are entering a new question so add ability to enter a custom place holder after a question has been entered into the text view
            isAbilityToAddCustomPlaceHolderForNewQtnEnabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.view.endEditing(true)
        //saveEnteredQuestion(textView)
        if !enteredQuestion.text.isEmpty && isAbilityToAddCustomPlaceHolderForNewQtnEnabled {
            // save the question text first and then switch the textview to enable entering placeholder text
            tempEnteredQuestionText = enteredQuestion.text
            showRightBarButton()
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func saveQuestion(text: String, questionText: String = "") {
        let nsdateAdded = NSDate().timeIntervalSince1970
        let question = Question(name: text, addedByDoctor: doctorEmail, doctorName: doctorName,
                                questionText: (questionText.isEmpty ? text : questionText), belongsTo: patientEmail, timeAdded: "\(nsdateAdded)", active: true)
        let questionItemRef = self.questionRef.child("\(Date().ticks)")
        questionItemRef.setValue(question.toAnyObject())
    }
    
    func saveQuestionEdit(text: String) {
        if let question = questionToBeEdited {
            question.ref?.updateChildValues(["questionText": text], withCompletionBlock: { (error, reference) in
                if error != nil {
                    Shared.showAlert(title: "Error", message: (error?.localizedDescription)!, viewController: self)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
    }
    
    func showRightBarButton() {
        let rightBarButton = UIBarButtonItem(title: "Add placeholder", style: .plain, target: self, action: #selector(startEnteringPlaceHolder))
        navigationItem.rightBarButtonItem = rightBarButton
    }

    @objc func startEnteringPlaceHolder() {
        // change the textview place holder text to change place holder.
        enteredQuestion.text = ""
        enteredQuestion.placeHolder = "Enter placeholder answer for the previous question entered."
        navigationItem.rightBarButtonItem = nil
        isAbilityToAddCustomPlaceHolderForNewQtnEnabled = false
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
