//
//  AnswerCarouselViewController.swift
//  Uplift
//
//  Created by Harold Asiimwe on 01/01/2018.
//  Copyright © 2018 Harold Asiimwe. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

class AnswerCarouselViewController: UIViewController {
    
    var questionRef = DatabaseReference()
    
    var items: [Question] = [Question]()
    
    var pageViewController : UIPageViewController!
    
    var pageContentViewController : UIViewController?
    
    var count = 0
    
    var changeButtonToSubmit = false
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var doubleButtonContainer: UIView!
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        changePage(direction: .forward)
    }
    @IBAction func previousButtonTapped(_ sender: Any) {
        changePage(direction: .reverse)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        questionRef = Database.database().reference(withPath: "questions")
        questionRef.keepSynced(true)
        questionRef.queryOrdered(byChild: "belongsTo").queryEqual(toValue: Auth.auth().currentUser!.email!).observe(.value, with: { snapshot in
            var questions: [Question] = []
            
            for item in snapshot.children {
                let question = Question(snapshot: item as! DataSnapshot)
                questions.append(question)
            }
            self.items = questions
            if self.items.count > 0 {
                self.reset()
            }
        })
        
        reset()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reset() {
        /* Getting the page View controller */
        pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        
        pageContentViewController = self.viewControllerAtIndex(index: 0)
        if let pageContentViewController = pageContentViewController {
            self.pageViewController.setViewControllers([pageContentViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
            
            /* We are substracting 150 because we have the prev & next buttons whose height is 90*/
            self.pageViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - (UIDevice.isIphoneX ? 200 : 150))
            self.addChildViewController(pageViewController)
            self.view.addSubview(pageViewController.view)
            self.pageViewController.didMove(toParentViewController: self)
        }
    }
    
    func viewControllerAtIndex(index : Int) -> UIViewController? {
        if((self.items.count <= 0) || (index >= self.items.count)) {
            return nil
        }
        
        let pageContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageContentViewController") as! PageContentViewController
    
        pageContentViewController.questionKey = self.items[index].key
        pageContentViewController.questionText = self.items[index].name
        pageContentViewController.answerText = self.items[index].questionText
        pageContentViewController.pageIndex = index
        return pageContentViewController
    }
    
    func changePage(direction: UIPageViewControllerNavigationDirection){
        var isLastViewControllerDisplayed = false
        if ((pageViewController.viewControllers?.first as? PageContentTableViewController) != nil) {
            if direction == .forward {
                confirmSubmissionOfAnswers()
                return
            }
            isLastViewControllerDisplayed = true
            pageViewController.setViewControllers([viewControllerAtIndex(index: (items.count-1))!], direction: direction, animated: true, completion: nil)
            reinstateNextButton()
        }
        
        guard var viewControllerIndex = (pageViewController.viewControllers?.first as! PageContentViewController).pageIndex else {
            return
        }
        if direction == .forward {
            viewControllerIndex = viewControllerIndex + 1
        } else if !isLastViewControllerDisplayed {
            viewControllerIndex = viewControllerIndex - 1
        }
        
        if viewControllerIndex == 0 {
            doubleButtonContainer.isHidden = true
        } else {
            setUpPrevNextButtons()
        }
        
        if let pageContentVC = viewControllerAtIndex(index: viewControllerIndex) {
            pageViewController.setViewControllers([pageContentVC], direction: direction, animated: true, completion: nil)
            reinstateNextButton()
        } else if viewControllerIndex >= items.count {
            pageViewController.setViewControllers([pageContentInTableView()!], direction: .forward, animated: true, completion: nil)
            changeNextButtonToSubmit()
        }
        
    }
    
    private func setUpPrevNextButtons() {
        doubleButtonContainer.backgroundColor = UIColor.white
        doubleButtonContainer.isHidden = false
    }
    
    private func changeNextButtonToSubmit() {
        nextButton.setTitle("SUBMIT", for: .normal)
        nextButton.backgroundColor = Shared.hexStringToUIColor(hex: "4CAF50")
    }
    
    private func reinstateNextButton() {
        nextButton.setTitle("NEXT", for: .normal)
        nextButton.backgroundColor = Shared.hexStringToUIColor(hex: "3093FF")
    }
    
    private func pageContentInTableView()  -> UIViewController? {
        let pageContentTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageContentTableViewController") as! PageContentTableViewController
        pageContentTableViewController.items = self.items
        return pageContentTableViewController
    }
    
    private func confirmSubmissionOfAnswers() {
        let alert = UIAlertController(title: "Submit Answers",
                                      message: "Are you sure you want to submit your answers?",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Submit", style: .default) { action in
            print("Submit items")
            // disable paging here and loop through all saved answers and submit them for storage\
            
            
            let answerRef = Database.database().reference(withPath: "answers")
            answerRef.keepSynced(true)
            
            do {
                let realm = try Realm()
                let offlineAnswers =  realm.objects(OfflineAnswer.self)
                if offlineAnswers.count > 0 {
                    for answer in offlineAnswers {
                        Shared.saveAnswer(text: answer.answer, questionKey: answer.questionKey, answerRef: answerRef)
                    }
                }
            } catch let error {
                print(error)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
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


extension AnswerCarouselViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var isLastViewControllerDisplayed = false
        
        if ((self.pageViewController.viewControllers?.first as? PageContentTableViewController) != nil) {
            self.pageViewController.setViewControllers([viewControllerAtIndex(index: (items.count-1))!], direction: .forward, animated: true, completion: nil)
            isLastViewControllerDisplayed = true
        }
        
        if ((viewController as? PageContentTableViewController) != nil) {
            return viewControllerAtIndex(index: items.count - 1)
        }
        
        guard let viewControllerIndex = (viewController as! PageContentViewController).pageIndex else {
            return nil
        }
        
        if viewControllerIndex == 0 {
            doubleButtonContainer.isHidden = true
        }
        
        let previousIndex = isLastViewControllerDisplayed ? viewControllerIndex : viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard items.count > previousIndex else {
            return nil
        }
        
        return viewControllerAtIndex(index: previousIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if ((pageViewController.viewControllers?.first as? PageContentTableViewController) != nil) {
            return nil
        }
        
        if ((viewController as? PageContentTableViewController) != nil) {
            return nil
        }
        
        guard let viewControllerIndex = (viewController as! PageContentViewController).pageIndex else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        let orderedViewControllersCount = items.count
        
        guard orderedViewControllersCount != nextIndex else {
            return pageContentInTableView()
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        setUpPrevNextButtons()
        
        return viewControllerAtIndex(index: nextIndex)
    }
    
    
}

extension AnswerCarouselViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if previousViewControllers.first! is PageContentTableViewController {
            reinstateNextButton()
            changeButtonToSubmit = false
        } else if changeButtonToSubmit && finished && completed {
            changeNextButtonToSubmit()
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if pendingViewControllers.first! is PageContentTableViewController {
            changeButtonToSubmit = true
        } else {
            changeButtonToSubmit = false
        }
        
    }
}



