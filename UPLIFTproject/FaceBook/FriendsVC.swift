//
//  FriendsVC.swift
//  FaceBook
//
//  Created by Administrator on 10/5/16.
//  Copyright © 2016 ITP344. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
class FriendsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

   
    @IBOutlet weak var tableView: UITableView!
    var friendsList:[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()

		if(FBSDKAccessToken.current().hasGranted("user_friends")){
            let graphRequest = FBSDKGraphRequest(graphPath: "/me/taggable_friends?limit=1000000" , parameters: nil)
            
            // perform graph request
            graphRequest?.start(completionHandler: {
                (connection, result, error) -> Void in
                print(result!)
                if (error == nil){
                    // cast result data as a dictrionary
                    let resultDict = result as! [String:Any]
                    // get the "data" value from the dictionary and case as an array of dictionaries
                    let friends = resultDict["data"] as! [[String:Any]]
                    // itterate through each item
                    var counter = 0
                    for friend in friends {
                        let name = friend["name"]
                        self.friendsList.append(name as! String)
                        print (name!)
                        let rowIndex = counter; //your row index where you want to add cell
                        counter += 1
                        let sectionIndex = 0;//your section index
                        let iPath : IndexPath = IndexPath(row: rowIndex, section: sectionIndex)
                        self.tableView.insertRows(at: [iPath], with: UITableViewRowAnimation.left)
                  //      friendsTableView.add
                    }
                }
            })
            
            
            
        }else{
			print("user_freinds access not granted")
			
		}
		
		
	
	}
	@IBAction func closeButtonTouched(_ sender: AnyObject) {
		
		self.dismiss(animated: true, completion: nil)
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     //   return 1
        return friendsList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    
    let cellId = "cellId1"
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if(cell == nil){
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellId)
        }
        
      //  cell?.imageView?.image = tableData[indexPath.row]
        cell?.textLabel?.text = friendsList[indexPath.row]
        
        
        return cell!
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
