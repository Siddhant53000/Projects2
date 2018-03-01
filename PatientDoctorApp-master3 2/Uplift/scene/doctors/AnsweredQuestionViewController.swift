//
//  AnsweredQuestionViewController.swift
//  Uplift
//
//  Created by Harold Asiimwe on 06/11/2017.
//  Copyright © 2017 Harold Asiimwe. All rights reserved.
//

import UIKit
import Firebase
import SwiftDate

class AnsweredQuestionViewController: UIViewController {
    
    var answerRef = DatabaseReference()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var questionLabel: UILabel!
    var patientEmail = ""
    var selectedQuestion: Question!
    var answers: [Answer] = []
    var selectedAnswerToEdit: Answer?
    var shouldAddNewAnswerButton = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.barTintColor = Shared.hexStringToUIColor(hex: "3796FC")
        navigationItem.title = "Answers"
        addAnswerBarButton()
        
        questionLabel.text = selectedQuestion.name
        answerRef = Database.database().reference(withPath: "answers")
        answerRef.keepSynced(true)
        answerRef.queryOrdered(byChild: "addedBy").queryEqual(toValue: patientEmail)
        answerRef.queryOrdered(byChild: "belongsToQuestion").queryEqual(toValue: selectedQuestion.key).observe(.value, with: { snapshot in
            
            var answers: [Answer] = []
            for item in snapshot.children {
                let answer = Answer(snapshot: item as! DataSnapshot)
                answers.append(answer)
            }
            if !answers.isEmpty {
                self.answers = answers.reversed()
                self.tableView.backgroundView = nil
                self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                self.tableView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.shadowImage = #imageLiteral(resourceName: "default_color_pixel")
        navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "default_color_pixel"), for: .default)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }
    
    func addAnswerBarButton() {
        if shouldAddNewAnswerButton {
            let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAnswer))
            navigationItem.rightBarButtonItem = rightBarButton
        }
    }
    
    @objc func addAnswer() {
        selectedAnswerToEdit = nil //set this to nil since the new question
        performSegue(withIdentifier: "showEditAnswerSegue", sender: self)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showEditAnswerSegue" {
            let enterAnswerVC = segue.destination as! EnterAnswerViewController
            enterAnswerVC.answerToBeEdited = selectedAnswerToEdit
            enterAnswerVC.question = selectedQuestion
        }
    }
    
}

extension AnsweredQuestionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

extension AnsweredQuestionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.answers.count == 0 {
            let message = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
            message.text = "No answers found"
            message.textAlignment = NSTextAlignment.center
            message.sizeToFit()
            //set tableview background
            self.tableView.backgroundView = message
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            
            return 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath) as! AnswerCell
        cell.delegate = self
        cell.indexPath = indexPath
        let answer = answers[indexPath.row]
        cell.answerTextLabel.text = answer.name
        if !answer.timeAdded.isEmpty {
            //let us = Region(tz: TimeZoneName.americaLosAngeles, cal: CalendarName.gregorian, loc: LocaleName.englishUnitedStates)
            let date = DateInRegion(absoluteDate: NSDate(timeIntervalSince1970: Double(answer.timeAdded)!) as Date)
            cell.dateAddedLabel.text = "Added: \(date.string(dateStyle: .medium, timeStyle: .short))"
        } else {
            cell.dateAddedLabel.text = "Added: --"
        }
        return cell
    }
}

extension AnsweredQuestionViewController: EditAnswerDelegate {
    func didTapEditAnswerButton(indexPath: IndexPath) {
        selectedAnswerToEdit = answers[indexPath.row]
        performSegue(withIdentifier: "showEditAnswerSegue", sender: self)
    }
}
