//
//  feedVC.swift
//  UPLIFT
//
//  Created by Siddhant Gupta on 4/23/17.
//  Copyright © 2017 Siddhant Gupta. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage
var ref : FIRDatabaseReference!
var postsDict : Dictionary<String, AnyObject>!
var keysArray : Array<String>!
var cityArray : Array<String>!
class feedVC: UIViewController, UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var imageArray : [UIImage]!
    var rangeImageArray : [UIImage]!
    var flag : Int!
   // var storageRef : FIRDatabaseReference!
    @IBOutlet weak var rangeBtn: UIButton!
    
    @IBOutlet weak var reloadButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        flag = 0
        // Do any additional setup after loading the view, typically from a nib.
            keysArray = Array()
            postsDict = Dictionary()
            imageArray = Array()
            rangeImageArray = Array()
        cityArray = Array()
        
        
    }
    //INITIAL SETUP
    override func viewDidAppear(_ animated: Bool) {
        flag = 0
        if ( keysArray == nil)
        {
            keysArray = Array()
        }
        if(postsDict == nil)
        {
            postsDict = Dictionary()
            
        }
        if (imageArray == nil)
        {
            imageArray = Array()
        }
        if (rangeImageArray == nil)
        {
            rangeImageArray = Array()
        }
        if(cityArray == nil)
        {
            cityArray = Array()
        }
        ref = FIRDatabase.database().reference(withPath : "locations")
        
        ref.observe(.value, with: { snapshot in
            if let snapshots  = snapshot.children.allObjects as? [FIRDataSnapshot]{
                var counter = 0
                for snap in snapshots{
                    if let postDict = snap.value as? Dictionary <String, AnyObject>{
                        let key = snap.key
                        print ("key \(key)")
                        if (counter < keysArray.count){
                            keysArray[counter] = (key)
                        }
                        else{
                            keysArray.append(key)
                        }
                        counter += 1
                        var city : String!
                       city = postDict["city"] as! String
                        print ("city \(city)")
                        cityArray.append(city as! String)
                        print ("City array \(cityArray.count)")
                        postsDict["\(key)"] = postDict as AnyObject
                        //print (postDict["title"])
                    }
                }
            }
            print(snapshot.value)
        })

        reloadTableData()
   
        
    }
    ///READING THE IMAGES BY CALLING THE READ IMAGES FUNCTION
    func reloadTableData()
    {
        let workQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        workQueue.async {
            var bTask : UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
            //    bTask=UIApplication.sharedApplication
            
            bTask=UIApplication.shared.beginBackgroundTask(expirationHandler: {
                ()-> Void in
                UIApplication.shared.endBackgroundTask(bTask)
                bTask=UIBackgroundTaskInvalid
            })

       // var i = self.imageArray.count - 1
            var i = 0
           
            if ( self.imageArray.count == keysArray.count && self.imageArray.count != 0)
            {
                return
            }
            if ( self.imageArray.count != 0 && keysArray.count > self.imageArray.count)
            {
                i = self.imageArray.count
            }
        for k in postsDict{
            if ( self.imageArray.count != 0 && keysArray.count > self.imageArray.count)
            {
                if (i < self.imageArray.count){
                    i += 1
                    continue
                }
            }
            if ( i >= keysArray.count )
            {
                break
            }
            let backgroundRemainingTime = UIApplication.shared.backgroundTimeRemaining;
            print (backgroundRemainingTime)
            if(backgroundRemainingTime < 120)
            {
                print ("No time to download")
                
                continue;
            }
            self.viewImage(position: i)
            i += 1
            }
        }
         print ("Finished Appeding")
       // self.tableView.reloadData()
    }
    //RELOADING THE TABLE VIA THE BUTTON
    @IBAction func realodButton(_ sender: Any) {
        flag = 0
      
        self.tableView.reloadData()
    }
    
    
    @IBAction func rangeBtn(_ sender: Any) {
        
        flag = 1
        var p : Int!
        p = 0
        for img in imageArray{
            if (cityArray[p] == currLoc)
            {
                rangeImageArray.append(img)
            }
            p =  p + 1
        }
        self.tableView.reloadData()
    }
    
    
    
    
    //GETTING THE IMAGE FROM FIREBASE
    func viewImage(position : Int)
    {
                let key = keysArray[position]
            print ("keytoprint \(key)")
                let imageName = "images/\(key).jpg"
                let imageURL = FIRStorage.storage().reference().child(imageName)
        
                imageURL.downloadURL(completion: { (url, error) in
        
                    if error != nil {
                        print(error?.localizedDescription)
                        return
                    }
        
                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
        
                        if error != nil {
                            print(error)
                            return
                        }
        
                        guard let imageData = UIImage(data: data!) else { return }
        
                        //DispatchQueue.main.async {
                            print ("entered")
                            //self.imageView.image = imageData
                            print ("appending")
                            self.imageArray.append(imageData)
                        //}
                        
                    }).resume()
                    
                })
       

    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (flag == 0){
            
        if let posts = postsDict {
            return posts.count
            
            }
        }
        else if (flag == 1)
        {
            if let posts = postsDict{
                return rangeImageArray.count
            }
        }
        return 0
    }
    
    //SETTING THE CELL FOR THE TABLE VIEW
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MyTestCell")
        print ("index \(indexPath.row)")
        
        print ("imagecount \(imageArray.count)")
        //viewImage(position: indexPath.row)
      //  sleep(100)
       
        
        if ( flag == 0){
        var imagetoPut : UIImage = imageArray[indexPath.row]
        
     //   cell.imageView?.image = imageWithImage(image: imagetoPut, scaledToSize: CGSize(width: 2000, height: 2000))
//        let key = keysArray[indexPath.row]
//        let record = postsDict["key"]
       cell.imageView?.image = imagetoPut
        cell.textLabel?.text = cityArray[indexPath.row]
            return cell
        }
        else{
            var imagetoPut : UIImage = rangeImageArray[indexPath.row]
            cell.imageView?.image = imagetoPut
            return cell
        }
    }
    
    
    func imageWithImage(image:UIImage,scaledToSize newSize:CGSize)->UIImage{
        
        UIGraphicsBeginImageContext( newSize )
        image.draw(in: CGRect(x: 0,y: 0,width: newSize.width,height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!.withRenderingMode(.alwaysTemplate)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print ("entered reload")
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "profileVC") as! profileVC
        destination.myImage = imageArray[indexPath.row]
        
        navigationController?.pushViewController(destination, animated: true)
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
//    {
//        
//        print ("entered reload")
//        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        let destination = storyboard.instantiateViewController(withIdentifier: "profileVC") as! profileVC
//        navigationController?.pushViewController(destination, animated: true)
//       // performSegue(withIdentifier: "segueToNextViewController", sender: self)
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    
}
