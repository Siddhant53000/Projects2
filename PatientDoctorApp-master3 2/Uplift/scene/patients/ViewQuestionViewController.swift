//
//  ViewQuestionViewController.swift
//  Uplift
//
//  Created by Harold Asiimwe on 06/11/2017.
//  Copyright © 2017 Harold Asiimwe. All rights reserved.
//

import UIKit

class ViewQuestionViewController: UIViewController {
    
    var selectedQuestion: Question!
    var questionText = ""
    
    @IBOutlet weak var questionAskedLabel: UILabel!
    
    @IBAction func proceedToEnterAnswer(_ sender: Any) {
        performSegue(withIdentifier: "enterQuestionAnswerSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if selectedQuestion != nil {
            questionAskedLabel.text = selectedQuestion.questionText.isEmpty ? selectedQuestion.name : selectedQuestion.questionText
        } else {
            questionAskedLabel.text = "Unable to set question details"
        }
        //questionAskedLabel.text = questionText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "enterQuestionAnswerSegue" {
            let enterAnswerVC = segue.destination as! EnterAnswerViewController
            enterAnswerVC.question = selectedQuestion
        }
    }
    

}
