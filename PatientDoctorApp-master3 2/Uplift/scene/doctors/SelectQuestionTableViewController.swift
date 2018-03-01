//
//  SelectQuestionTableViewController.swift
//  Uplift
//
//  Created by Harold Asiimwe on 01/12/2017.
//  Copyright © 2017 Harold Asiimwe. All rights reserved.
//

import UIKit
import Firebase

class SelectQuestionTableViewController: UITableViewController {
    
    var questionRef = DatabaseReference()
    var questionItems = [String]()
    var questionCategory: QuestionCategory!
    var patientEmail = ""
    var doctorEmail  = ""
    var doctorName   = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        questionRef = Database.database().reference(withPath: "questions")
        questionRef.keepSynced(true)
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.estimatedRowHeight = 75.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsMultipleSelection = true
        setRightBarItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setRightBarItems() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let selectallButton = UIBarButtonItem(title: "Select all", style: .plain, target: self, action: #selector(selectAllItems))
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.setRightBarButtonItems([doneButton, selectallButton], animated: false)
    }
    
    func setRightBarDeselectItems() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let deselectallButton = UIBarButtonItem(title: "Deselect all", style: .plain, target: self, action: #selector(deselectAllItems))
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.setRightBarButtonItems([doneButton, deselectallButton], animated: false)
    }
    
    @objc func done(){
        
        if let selectedIndexPathRows = tableView.indexPathsForSelectedRows {
            
            DispatchQueue.global(qos: .background).async {
                //background code
                var select = [String]()
                for row in selectedIndexPathRows {
                    select.append(self.questionItems[row.row])
                }
                if self.questionCategory == QuestionCategory.thoughtRecord {
                    let thoughtRecord = AskedQuestionsManager.QuestionStore.init(doctorEmail: self.doctorEmail, doctorName: self.doctorName, patientEmail: self.patientEmail, questionRef: self.questionRef)
                    var questionsToSave = [String:String]()
                    for selectedQtn in select {
                        for qtn in thoughtRecord.questions {
                            if qtn.value == selectedQtn {
                                questionsToSave.updateValue(qtn.value, forKey: qtn.key)
                            }
                        }
                    }
                    if questionsToSave.count > 0 {
                        thoughtRecord.addCategoryQuestions(questions: questionsToSave)
                    }
                } else if self.questionCategory == QuestionCategory.avoidanceSufferingDiary {
                    let avoidanceSuffering = AskedQuestionsManager.QuestionStore.init(doctorEmail: self.doctorEmail, doctorName: self.doctorName, patientEmail: self.patientEmail, questionRef: self.questionRef)
                    var toSaveQuestions = [String:String]()
                    for selectedQtn in select {
                        for qtn in avoidanceSuffering.avoidanceSufferingQuestions {
                            if qtn.value == selectedQtn {
                                toSaveQuestions.updateValue(qtn.value, forKey: qtn.key)
                            }
                        }
                    }
                    if toSaveQuestions.count > 0 {
                        avoidanceSuffering.addCategoryQuestions(questions: toSaveQuestions)
                    }
                }
                
                DispatchQueue.main.async {
                    //your main thread
                }
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func selectAllItems() {
        let totalRows = tableView.numberOfRows(inSection: 0)
        for row in 0..<totalRows {
            let indexPath = IndexPath(row: row, section: 0)
            _ = tableView.delegate?.tableView?(tableView, willSelectRowAt: indexPath)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
        }
        setRightBarDeselectItems()
    }
    
    @objc func deselectAllItems(){
        let totalRows = tableView.numberOfRows(inSection: 0)
        for row in 0..<totalRows {
            let indexPath = IndexPath(row: row, section: 0)
            _ = tableView.delegate?.tableView?(tableView, willDeselectRowAt: indexPath)
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.delegate?.tableView?(tableView, didDeselectRowAt: indexPath)
        }
        
        setRightBarItems()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionItems.count
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = cell.isSelected ? .checkmark : .none
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectQuestionCell", for: indexPath) as! SelectQuestionCell
        // Configure the cell...
        cell.questionLabel.text = questionItems[indexPath.row]
        cell.accessoryType = cell.isSelected ? .checkmark : .none
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
