//
//  ViewController.swift
//  BGDownloader
//
//  Created by Administrator on 9/14/16.
//  Copyright © 2016 ITP. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	
	@IBOutlet weak var tableView: UITableView!
	
	let dataURLs : [String] = [
		"https://upload.wikimedia.org/wikipedia/commons/d/d8/NASA_Mars_Rover.jpg",
		"http://img2.tvtome.com/i/u/28c79aac89f44f2dcf865ab8c03a4201.png", "http://news.brown.edu/files/article_images/MarsRover1.jpg",
		"https://loveoffriends.files.wordpress.com/2012/02/love-of-friends-117.jpg", "http://www.nasa.gov/images/content/482643main_msl20100916-full.jpg",
		"http://www.facultyfocus.com/wp-content/uploads/images/iStock_000012443270Large150921.jpg", "http://mars.nasa.gov/msl/images/msl20110602_PIA14175.jpg",
        "http://i.kinja-img.com/gawker-media/image/upload/iftylroaoeej16deefkn.jpg",
        "http://www.ymcanyc.org/i/ADULTS%20groupspinning2%20FC.jpg",
        "http://www.dogslovewagtime.com/wp-content/uploads/2015/07/Dog-Pictures.jpg",
        "http://cdn.phys.org/newman/gfx/news/hires/2015/earthandmars.png"
	]
	
	var tableData : [UIImage] = []
	
    var faceNumbers : [Int] = []
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	

    
	
	@IBAction func downloadTouched(_ sender: AnyObject) {
        let workQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        workQueue.async {
            var bTask : UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
            //    bTask=UIApplication.sharedApplication
     
            bTask=UIApplication.shared.beginBackgroundTask(expirationHandler: {
                ()-> Void in
                UIApplication.shared.endBackgroundTask(bTask)
                bTask=UIBackgroundTaskInvalid
            })
        
            
//            bTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
//                () -> Void in
//                UIApplication.sharedApplication().endBackgroundTask(backgroundTaskIdentifier)
//                backgroundTaskIdentifier  = UIBackgroundTaskInvalid
//            }

            for i in 0 ..< self.dataURLs.count{
                let imageUrl = self.dataURLs[i]
                let backgroundRemainingTime = UIApplication.shared.backgroundTimeRemaining;
                print (backgroundRemainingTime)
                if(backgroundRemainingTime < 120)
                {
                    print ("No time to download")

                    continue;
                                   }
                let image = UIImage(data: try! Data(contentsOf: URL(string: imageUrl)!))
//                self.tableData.append(image!);
                if let inputImage = image {
                    let ciImage = CIImage(cgImage: inputImage.cgImage!)
                    
                    let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
                    let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: options)!
                    
                    let faces = faceDetector.features(in: ciImage)
                    print(faces.count)
                    self.faceNumbers.append(faces.count)
                    if(faces.count == 0)
                    {
                        let context = CIContext(options: nil)
                        
                        let beginImage = CIImage(image: inputImage)
                        let filter : CIFilter! = CIFilter(name: "CIHueAdjust")
                        filter.setValue(beginImage, forKey: kCIInputImageKey)
                        filter.setValue(1.0, forKey: kCIInputAngleKey)
                        let output = filter.outputImage!
                        
                        let filter2 : CIFilter! = CIFilter(name: "CIExposureAdjust")
                        filter2.setValue(output, forKey: kCIInputImageKey)
                        filter2.setValue(1.0, forKey: kCIInputEVKey)
                        let output2 = filter2.outputImage!
                        let currentImage:UIImage = UIImage.init(ciImage: output2)
                        self.tableData.append(currentImage)
                        
                  //      self.tableData.append(inputImage)
                    }
                    else{
                        let context = CIContext(options: nil)
                        
                        let beginImage = CIImage(image: inputImage)
                        let filter2 : CIFilter! = CIFilter(name: "CIGaussianBlur")
                        filter2.setValue(beginImage, forKey: kCIInputImageKey)
                        filter2.setValue(5.0, forKey: kCIInputRadiusKey)
                        let output2 = filter2.outputImage!
                        let currentImage:UIImage = UIImage.init(ciImage: output2)
                        self.tableData.append(currentImage)
                    }
                }
                
                Thread.sleep(forTimeInterval: 0.5)
                DispatchQueue.main.sync{
                    let rowIndex = i; //your row index where you want to add cell
                    let sectionIndex = 0;//your section index
                    let iPath : IndexPath = IndexPath(row: rowIndex, section: sectionIndex)
                    self.tableView.insertRows(at: [iPath], with: UITableViewRowAnimation.left)
                }
                

            }
        }
        
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableData.count
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

		cell?.imageView?.image = tableData[indexPath.row]
		if(faceNumbers[indexPath.row] == 0)
        {
            cell?.textLabel?.text = "No Faces detected!"
        }
        else
        {
            cell?.textLabel?.text = "\(faceNumbers[indexPath.row]) face(s) detected"
        }
        

		
		return cell!
	}
	
	
	


}

