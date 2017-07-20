//
//  FilterViewController.swift
//  LextTalk
//
//  Created by Shane Rosse on 9/25/16.
//
//

import UIKit

public class FilterViewController: UIViewController {

    @IBOutlet weak var recentlyActiveView: UIView!
    @IBOutlet weak var feelingLuckyView: UIView!

    @IBOutlet weak var speakingLanguageView: UIView!
    @IBOutlet weak var learningLanguageView: UIView!

    @IBOutlet weak var recentlyActiveSwitch: UISwitch!
    @IBOutlet weak var multilingualSwitch: UISwitch!
    @IBOutlet weak var speakingLanguageSwitch: UISwitch!
    @IBOutlet weak var learningLanguageSwitch: UISwitch!

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var matchMeButton: UIButton!
    
    public var delegate: MapViewController?
    
    override public func viewDidLoad() {
        super.viewDidLoad()

    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func configureWithFilter( _ filter: MapFilter) {
        recentlyActiveSwitch.isOn = filter.onlyRecentlyActive
        multilingualSwitch.isOn = filter.onlyMultilingual
        speakingLanguageSwitch.isOn = filter.onlySpeakingWhatImLearning
        learningLanguageSwitch.isOn = filter.onlyLearningWhatImSpeaking
    }
    
    @IBAction func backButtonTouch(_ sender: AnyObject) {
        dismiss(animated: true) { 
            print("Filter View Controller dismissed")
        }
    }
    
    @IBAction func matchMeButtonTouch(_ sender: AnyObject) {
//        delegate?.filterCompleted(gatherResults())
        dismiss(animated: true) {
            self.delegate?.matchMe()
        }
    }
    
    @IBAction func filterButtonTouch(_ sender: AnyObject) {
        delegate?.filterCompleted(gatherResults())
        dismiss(animated: true) { 
            //
        }
    }
    @IBAction func resetButtonTouch(_ sender: AnyObject) {
        recentlyActiveSwitch.isOn = false
        multilingualSwitch.isOn = false
        speakingLanguageSwitch.isOn = false
        learningLanguageSwitch.isOn = false
    }
    func gatherResults() -> [Bool] {
        return [recentlyActiveSwitch.isOn, multilingualSwitch.isOn, learningLanguageSwitch.isOn, speakingLanguageSwitch.isOn]
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
