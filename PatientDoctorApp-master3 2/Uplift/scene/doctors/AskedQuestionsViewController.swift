//
//  QuestionsTableViewController.swift
//  Uplift
//
//  Created by Harold Asiimwe on 02/11/2017.
//  Copyright © 2017 Harold Asiimwe. All rights reserved.
//

import UIKit
import Firebase
import SwiftDate

class AskedQuestionsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var questionRef = DatabaseReference()
    
    var items: [Question] = []
    
    var patientName  = ""
    var patientEmail = ""
    var doctorEmail  = ""
    var doctorName   = ""
    var selectedQuestion: Question!
    var questionCatergory : QuestionCategory!
    var questionsToAsk = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addQuestionButton()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        questionRef = Database.database().reference(withPath: "questions")
        questionRef.keepSynced(true)
        questionRef.queryOrdered(byChild: "addedByDoctor").queryEqual(toValue: doctorEmail)
        questionRef.queryOrdered(byChild: "belongsTo").queryEqual(toValue: patientEmail).observe(.value, with: { snapshot in
            var questions: [Question] = []
            
            for item in snapshot.children {
                let question = Question(snapshot: item as! DataSnapshot)
                questions.append(question)
            }
            self.items = questions
            self.tableView.reloadData()
            if self.items.count > 0 {
                self.tableView.backgroundView = nil
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.shadowImage = #imageLiteral(resourceName: "default_color_pixel")
        navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "default_color_pixel"), for: .default)
        navigationItem.title = patientName
        
        selectedQuestion = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    func addQuestionButton() {
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addQuestion))
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func addQuestion() {
        //performSegue(withIdentifier: "enterQuestionSegue", sender: self)
        questionType()
    }
    
    private func questionType() {
        let alertController = UIAlertController(title: "Select question category", message: nil, preferredStyle: .actionSheet)
        
        let thoughtRecordButton = UIAlertAction(title: "Thought Record Sheet", style: .default, handler: { (action) -> Void in
            self.questionsToAsk = AskedQuestionsManager().getUnSelectedQuestions(questionCatergory: .thoughtRecord, questions: self.items)
            if self.questionsToAsk.count > 0 {
                self.questionCatergory = QuestionCategory.thoughtRecord
                self.performSegue(withIdentifier: "selectQuestionSegue", sender: self)
            } else {
                Shared.showAlert(title: "Thought Record", message: "The selected question category has already been asked", viewController: self)
            }
        })
        
        let  avoidanceSufferingButton = UIAlertAction(title: "Avoidance & suffering diary", style: .default, handler: { (action) -> Void in
            self.questionsToAsk = AskedQuestionsManager().getUnSelectedQuestions(questionCatergory: .avoidanceSufferingDiary, questions: self.items)
            if self.questionsToAsk.count > 0 {
                self.questionCatergory = QuestionCategory.avoidanceSufferingDiary
                self.performSegue(withIdentifier: "selectQuestionSegue", sender: self)
            } else {
                Shared.showAlert(title: "Avoidance & suffering diary", message: "The selected question category has already been asked", viewController: self)
            }
        })
        
        let  newQuestionButton = UIAlertAction(title: "New question", style: .default, handler: { (action) -> Void in
            self.performSegue(withIdentifier: "enterQuestionSegue", sender: self)
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        
        alertController.addAction(thoughtRecordButton)
        alertController.addAction(avoidanceSufferingButton)
        alertController.addAction(newQuestionButton)
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "enterQuestionSegue" {
            let enterQuestionVC = segue.destination as! EnterQuestionViewController
            enterQuestionVC.doctorEmail = self.doctorEmail
            enterQuestionVC.patientEmail = self.patientEmail
            enterQuestionVC.doctorName = self.doctorName
            if selectedQuestion != nil {
                enterQuestionVC.questionToBeEdited = selectedQuestion
            }
            //print(selectedQuestion)
        } else if segue.identifier == "showAnswerSegue" {
            let answerSegue = segue.destination as! AnsweredQuestionViewController
            answerSegue.selectedQuestion = selectedQuestion
        } else if segue.identifier == "selectQuestionSegue" {
            let selectQuestionVC = segue.destination as! SelectQuestionTableViewController
            selectQuestionVC.questionCategory = questionCatergory
            selectQuestionVC.doctorEmail = self.doctorEmail
            selectQuestionVC.patientEmail = self.patientEmail
            selectQuestionVC.doctorName = self.doctorName
            switch questionCatergory {
            case .thoughtRecord:
                selectQuestionVC.questionItems = self.questionsToAsk.flatMap({ (key, value) -> String? in
                    return key
                })
            case .avoidanceSufferingDiary:
                selectQuestionVC.questionItems = self.questionsToAsk.flatMap({ (key, value) -> String? in
                    return value
                })
            default: ()
            }
        }
    }
    

}

extension AskedQuestionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedQuestion = items[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showAnswerSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let question = self.items[indexPath.row]
            question.ref?.removeValue()
            self.items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            print("Edit action received at \(indexPath.row)")
            self.selectedQuestion = self.items[indexPath.row]
            self.performSegue(withIdentifier: "enterQuestionSegue", sender: self)
        }
        //edit.backgroundColor = UIColor.blue
        
        return [delete, edit]
    }
}

extension AskedQuestionsViewController: UITableViewDataSource { // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AskedQuestionCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].name
        let date = DateInRegion(absoluteDate: NSDate(timeIntervalSince1970: Double(items[indexPath.row].timeAdded)!) as Date)
        let (colloquial, _) = try! date.colloquialSinceNow()
        cell.detailTextLabel?.text = "Added: \(colloquial)"
        return cell
    }
}
