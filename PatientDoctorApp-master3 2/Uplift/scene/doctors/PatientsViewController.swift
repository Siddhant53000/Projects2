//
//  PatientsViewController.swift
//  Uplift
//
//  Created by Harold Asiimwe on 13/10/2017.
//  Copyright © 2017 Harold Asiimwe. All rights reserved.
//

import UIKit
import Firebase

class PatientsViewController: UIViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var items: [Patient] = []
    
    let prefs:UserDefaults = UserDefaults.standard
    var patientRef = DatabaseReference()
    var currentUser: ULUser!
    
    var selectedCellIndexPath: IndexPath!
    
    @IBAction func segmentValueChanged(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex {
        case 1:
            getInactivePatients()
        default:
            getActivePatients()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = FirebaseApp.app(name: "CreatingPatientsApp") {
        } else {
           FirebaseApp.configure(name: "CreatingPatientsApp", options: FirebaseApp.app()!.options)
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.currentUser = ULUser(authData: user)
        }
        
        patientRef = Database.database().reference(withPath: "patients")
        patientRef.keepSynced(true)
        getActivePatients()
    }
    
    func getActivePatients() {
        patientRef.queryOrdered(byChild: "addedByDoctor").queryEqual(toValue: Auth.auth().currentUser!.email!).observe(.value, with: { snapshot in
            var patients: [Patient] = []
            
            for item in snapshot.children {
                let patient = Patient(snapshot: item as! DataSnapshot)
                if patient.active {
                    patients.append(patient)
                }
            }
            
            self.items = patients
            self.tableView.reloadData()
            if self.items.count > 0 {
                self.tableView.backgroundView = nil
            } else {
                let background = Background()
                background.delegate = self
                self.tableView.backgroundView = background
            }
        })
    }
    
    func getInactivePatients() {
        patientRef.queryOrdered(byChild: "addedByDoctor").queryEqual(toValue: Auth.auth().currentUser!.email!).observe(.value, with: { snapshot in
            var patients: [Patient] = []
            
            for item in snapshot.children {
                let patient = Patient(snapshot: item as! DataSnapshot)
                if !patient.active {
                    patients.append(patient)
                }
            }
            
            self.items = patients
            self.tableView.reloadData()
            if self.items.count > 0 {
                self.tableView.backgroundView = nil
            } else {
                let background = Background()
                background.delegate = self
                self.tableView.backgroundView = background
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.shadowImage = #imageLiteral(resourceName: "default_color_pixel")
        navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "default_color_pixel"), for: .default)
        if items.count == 0 {
            let background = Background()
            background.delegate = self
            self.tableView.backgroundView = background
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func addPatientNavBarButtonTapped(_ sender: Any) {
        addPatient()
    }
    
    func addPatient() {
        let alert = UIAlertController(title: "Add Patient",
                                      message: "",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let nameField = alert.textFields![0]
            let emailField = alert.textFields![1]
            let passwordField = alert.textFields![2]
            
            guard let nameText = nameField.text, let emailText = emailField.text, let passwordText = passwordField.text else { return }
            
            if !nameText.isEmpty, !emailText.isEmpty, !passwordText.isEmpty {
                
                if Shared.isValidEmail(testStr: emailText) {
                    
                    if let secondaryApp = FirebaseApp.app(name: "CreatingPatientsApp") {
                        let secondaryAppAuth = Auth.auth(app: secondaryApp)
                        secondaryAppAuth.createUser(withEmail: emailText, password: passwordText) { (user, error) in
                            if let error = error {
                                Shared.showAlert(title: "Add Patient", message: "Unable to complete patient creation process.\n \(error.localizedDescription)", viewController: self)
                                print(error.localizedDescription)
                            } else {
                                if let _ = user {
                                    //Save the patient to another table
                                    let patient = Patient(name: nameText, email: emailText, password: passwordText, addedByDoctor: self.currentUser.email, active: true)
                                    let patientItemRef = self.patientRef.child(nameText.lowercased())
                                    patientItemRef.setValue(patient.toAnyObject())
                                    do {
                                        try secondaryAppAuth.signOut()
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                        }
                    }
                    //First add the patient as a firebase user
                } else {
                    Shared.showAlert(title: "Add Patient", message: "An invald email was entered. Please try again", viewController: self)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter patient name"
        }
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter patient email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter patient password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "askedQuestionsSegue" {
            if let selectedCellIndexPath = selectedCellIndexPath {
                let askedQuestionsController = segue.destination as! AskedQuestionsViewController
                askedQuestionsController.patientName = items[selectedCellIndexPath.row].name
                askedQuestionsController.patientEmail = items[selectedCellIndexPath.row].email
                askedQuestionsController.doctorEmail = currentUser.email
                askedQuestionsController.doctorName = currentUser.email
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if selectedCellIndexPath == nil {
            return false
        }
        return true
    }
}

extension PatientsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell", for: indexPath)
        let patient = items[indexPath.row]
        cell.textLabel?.text = patient.name
        cell.detailTextLabel?.text = patient.email
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let patient = items[indexPath.row]
        if patient.active {
            let archive = UITableViewRowAction(style: .destructive, title: "Archive") { (action, indexPath) in
                patient.ref?.updateChildValues(["active": false], withCompletionBlock: { (error, ref) in
                    if error != nil {
                        Shared.showAlert(title: "Error", message: (error?.localizedDescription)!, viewController: self)
                    }
                })
            }
            return [archive]
        } else {
            let unarchive = UITableViewRowAction(style: .normal, title: "Unarchive") { (action, indexPath) in
                patient.ref?.updateChildValues(["active": true], withCompletionBlock: { (error, ref) in
                    if error != nil {
                        Shared.showAlert(title: "Error", message: (error?.localizedDescription)!, viewController: self)
                    }
                })
            }
            unarchive.backgroundColor = UIColor.darkGray
            return [unarchive]
        }
    }
}

extension PatientsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCellIndexPath = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "askedQuestionsSegue", sender: self)
    }
}

extension PatientsViewController: BackgroundAddPatientsProtocol {
    func addPatientsButtonTapped() {
        print("Patients to be added!!")
        addPatient()
    }
}

