//
//  PageContentTableViewController.swift
//  Uplift
//
//  Created by Harold Asiimwe on 01/01/2018.
//  Copyright © 2018 Harold Asiimwe. All rights reserved.
//

import UIKit
import RealmSwift

class PageContentTableViewController: UIViewController {
    
    var items: [Question] = []

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.estimatedRowHeight = 270.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        /// Save any entered answers locally
        saveEnteredAnswers()
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        saveEnteredAnswers()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func saveEnteredAnswers() {
        do {
            let realm = try Realm()
            
            try! realm.write {
                
                for section in 0...self.tableView.numberOfSections - 1 {
                    for row in 0...self.tableView.numberOfRows(inSection: section) - 1 {
                        if let cell = self.tableView.cellForRow(at: NSIndexPath(row: row, section: section) as IndexPath) as? EnterAnswerViewCell {
                            
                            let key = items[section].key
                            let answer = cell.enterAnswerTextView.text!
                            
                            let answerToBeSaved = OfflineAnswer()
                            answerToBeSaved.questionKey = key
                            answerToBeSaved.answer = answer
                            
                            realm.add(answerToBeSaved, update: true)
                            //print("Section: \(section)  Row: \(row)")
                            
                        }
                        
                    }
                }
            }
            
        } catch let error {
            print(error)
        }
    }

}

extension PageContentTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EnterAnswerCell", for: indexPath) as! EnterAnswerViewCell
        cell.enterAnswerTextView.placeHolder = items[indexPath.section].questionText.isEmpty ? "Enter your answer here" : items[indexPath.section].questionText
        cell.enterAnswerTextView.text = Shared.retrieveOfflineAnswer(questionKey: items[indexPath.section].key).isEmpty
            ? "" : Shared.retrieveOfflineAnswer(questionKey: items[indexPath.section].key)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return items[section].name
    }
}

extension PageContentTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 262.0
    }
}
