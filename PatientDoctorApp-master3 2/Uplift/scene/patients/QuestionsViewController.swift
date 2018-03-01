//
//  QuestionsViewController.swift
//  Uplift
//
//  Created by Harold Asiimwe on 31/10/2017.
//  Copyright © 2017 Harold Asiimwe. All rights reserved.
//

import UIKit
import Firebase
import SwiftDate
import UserNotifications

class QuestionsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var questionRef = DatabaseReference()
    
    var items: [Question] = []
    
    var selectedQuestion: Question!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Configure User Notification Center
        UNUserNotificationCenter.current().delegate = self
        
        questionRef = Database.database().reference(withPath: "questions")
        questionRef.keepSynced(true)
        questionRef.queryOrdered(byChild: "belongsTo").queryEqual(toValue: Auth.auth().currentUser!.email!).observe(.value, with: { snapshot in
            var questions: [Question] = []
            
            for item in snapshot.children {
                let question = Question(snapshot: item as! DataSnapshot)
                questions.append(question)
            }
            self.items = questions
            self.tableView.reloadData()
            if self.items.count > 0 {
                self.tableView.backgroundView = nil
                self.setUpLocalNotifications()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Notifications
    private func setUpLocalNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                // Request auth
                self.requestAuthorization(completionHandler: { (success) in
                    guard success else { return }
                    
                    // Schedule local notification
                    self.scheduleLocalNotification()
                })
            case .authorized:
                // Schedule local notification
                self.scheduleLocalNotification()
            case .denied:
                print("Application Not Allowed to Display Notifications")
            }
        }
    }
    
    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        // Request Authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            
            completionHandler(success)
        }
    }
    
    private func scheduleLocalNotification() {
        // Create Notification Content
        let notificationContent = UNMutableNotificationContent()
        
        // Configure Notification Content
        notificationContent.title = "Reminder"
        notificationContent.subtitle = "Have you answered all your questions?"
        notificationContent.body = "A reminder to provide answers to your doctors' questions."
        
        // Add Trigger
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)
        
        let calendar = NSCalendar(identifier: .gregorian)!
        var dateFire = Date()
        
        var fireComponents = calendar.components( [NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year, NSCalendar.Unit.hour, NSCalendar.Unit.minute], from: dateFire)
        
        if (fireComponents.hour! >= 9) {
            dateFire = dateFire.addingTimeInterval(86400)  // Use tomorrow's date
            
           fireComponents = calendar.components( [NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year, NSCalendar.Unit.hour, NSCalendar.Unit.minute], from: dateFire);
        }
        
        let _  = UNCalendarNotificationTrigger(dateMatching: fireComponents, repeats: true)
        
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "uplift_local_notification", content: notificationContent, trigger: notificationTrigger)
        
        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showQuestionAskedSegue" {
            let viewQuestionVC = segue.destination as! ViewQuestionViewController
            viewQuestionVC.selectedQuestion = selectedQuestion
        } else if segue.identifier == "showAnswersSegue" {
            let answerSegue = segue.destination as! AnsweredQuestionViewController
            answerSegue.selectedQuestion = selectedQuestion
            answerSegue.shouldAddNewAnswerButton = true
        }
    }
    

}

extension QuestionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedQuestion = items[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showAnswersSegue", sender: self)
    }
}

extension QuestionsViewController: UITableViewDataSource { // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientQuestionCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].name
        let date = DateInRegion(absoluteDate: NSDate(timeIntervalSince1970: Double(items[indexPath.row].timeAdded)!) as Date)
        let (colloquial, _) = try! date.colloquialSinceNow()
        cell.detailTextLabel?.text = "Asked: \(colloquial)"
        return cell
    }
}

extension QuestionsViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
