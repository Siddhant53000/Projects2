//
//  ViewController.swift
//  FaceBook
//
//  Created by Administrator on 10/3/16.
//  Copyright © 2016 ITP344. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import MobileCoreServices
import CoreLocation
//import Firebase
import FirebaseDatabase

var currLat : Double!
var currLong : Double!
var currLoc : String!
class ViewController: UIViewController, FBSDKLoginButtonDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

	@IBOutlet weak var viewFriendsButton: UIButton!
    @IBOutlet weak var CameraButton: UIButton!
    
    @IBOutlet weak var filterBtn: UIButton!
 
    @IBOutlet weak var textButton: UIButton!
 //   @IBOutlet weak var bothBtn: UIButton!
  
   
   // @IBOutlet weak var blurBtn: UIButton!
    @IBOutlet weak var vignetteBtn: UIButton!
  
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imagePicked: UIImageView!
    let picker = UIImagePickerController()
	var loginButton : FBSDKLoginButton!
    var locationManager : CLLocationManager!

    var imagesDirectoryPath:String!
    var images:[UIImage]!
    var titles:[String]!
    var ref : FIRDatabaseReference!
    var  dataModel : imageDataModel!
    var latitude : Double!
    var longitude : Double!
    var chosenImage : UIImage!
    var myCity :String!
    
    //VIEW DID LOAD
    override func viewDidLoad() {
		super.viewDidLoad()
		currLoc = String()
		loginButton = FBSDKLoginButton()
        myCity = String()
		loginButton.center = self.view.center
		self.view.addSubview(loginButton)
		
		loginButton.delegate = self
		
		print("Logged in")
        images = []
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        // Get the Document directory path
        let documentDirectorPath:String = paths[0]
        // Create a new path for the new images folder
        imagesDirectoryPath = documentDirectorPath.appending("/ImagePicker")
        var objcBool:ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: imagesDirectoryPath, isDirectory: &objcBool)
        // If the folder with the given path doesn't exist already, create it
        if isExist == false{
            do{
                try FileManager.default.createDirectory(atPath: imagesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Something went wrong while creating a new folder")
            }
        }
        dataModel = imageDataModel()
      
        
		let likeButton : FBSDKLikeButton = FBSDKLikeButton()
		likeButton.center = self.view.center
		likeButton.center.y += 50
		likeButton.objectID = "https://www.facebook.com/FacebookDevelopers"
		picker.delegate = self
        initLocationManager()
		self.view.addSubview(likeButton)
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if(FBSDKAccessToken.current() == nil){
			self.performSegue(withIdentifier: "loginSegue", sender: self)
			return
		}

		
	}
    
    //checking for location manager permissions
    func initLocationManager(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        // locationManager.requestWhenInUseAuthorization()
        
    }
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus)
    {
        
        if(status == .denied){
            locationManager.stopUpdatingLocation()
            let errorMsg = "Location servie permission denied for this app"
            // dispay error message
        }
        if(status == .authorizedWhenInUse || status == .authorizedAlways){
          //  locationManager.startUpdatingLocation()
            // other location initilaization
            
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation : CLLocation = locations.last!
        if(lastLocation.horizontalAccuracy < 0){
            return
        }
        
        // process the location information
        print("New latitude: \(lastLocation.coordinate.latitude)")
        print("New longitude: \(lastLocation.coordinate.longitude)")
        latitude = lastLocation.coordinate.latitude
        currLat = lastLocation.coordinate.latitude
        longitude = lastLocation.coordinate.longitude
        
        print("Timestamp: \(lastLocation.timestamp)")

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    
//OPENING CAMERA TO CHOOSE IMAGE
    @IBAction func cameraButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            //var imagePicker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.camera;
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func textButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            //var imagePicker = UIImagePickerController()
            var imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            //imag.mediaTypes = [kUTTypeImage];
            imag.allowsEditing = false
            if CLLocationManager.locationServicesEnabled() {
                switch(CLLocationManager.authorizationStatus()) {		case .notDetermined, .restricted, .denied:
                    print("No access")
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
                    locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    //   locationManager.distanceFilter = 100.0  //meters
                    locationManager.delegate = self
                    locationManager.distanceFilter = 100.0
                    //    locationManager.startUpdatingLocation()
                    
                    // print ("@%@", locationManager.requestLocation())
                    locationManager.requestLocation()
                    //   locationManager.stopUpdatingLocation()
                }
            }
            else {
                print("Location services are not enabled")
            }
            self.present(imag, animated: true, completion: nil)        }
    }
 
    
    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("entered")
            imagePicked.contentMode = .scaleAspectFit
            imagePicked.image = pickedImage
            chosenImage = pickedImage
            filterBtn.isHidden = false
//            blurBtn.isHidden = false
//            bothBtn.isHidden = false
            vignetteBtn.isHidden = false
            saveButton.isHidden = false
            var location = CLLocation(latitude: latitude, longitude: longitude) //changed!!!
            print(location)
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                print(location)
                
                if error != nil {
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                
                if (placemarks?.count)! > 0 {
                    let pm = placemarks?[0] as! CLPlacemark
                    print("Locality \(pm.locality)")
                    self.myCity = pm.locality
                    currLoc = self.myCity
                    print ("curr location \(currLoc)")
                }
                else {
                    print("Problem with the data received from geocoder")
                }
            })

//            CameraButton.isHidden = 
//            textButton.isHidden = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
	func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
	
		
		print("loginButton didCompleteWith \(error)")
		
	}
	
	func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
		
		self.performSegue(withIdentifier: "loginSegue", sender: self)
		
	}

    
    @IBAction func sepiaButton(_ sender: Any) {
        DispatchQueue.global().async {
            
            let inputImage : UIImage! = self.imagePicked.image
            
            let context = CIContext(options: nil)
            
            let beginImage = CIImage(image: inputImage)
            
            let filter : CIFilter! = CIFilter(name: "CISepiaTone")
            filter.setValue(beginImage, forKey: kCIInputImageKey)
            filter.setValue(0.9, forKey: kCIInputIntensityKey)
            let output = filter.outputImage!
            
            let cgimg : CGImage! = context.createCGImage(output, from: output.extent)
            
            let processedImage = UIImage(cgImage:cgimg)
            DispatchQueue.main.async {
                self.imagePicked.image = processedImage
                
            }
            
        }
    }
   
//    @IBAction func blurBtn(_ sender: Any) {
//    
//        DispatchQueue.global().async {
//
//        let inputImage : UIImage! =  self.imagePicked.image
//        
//            let context = CIContext(options: nil)
//            
//            let beginImage = CIImage(image: inputImage)
//            let filter2 : CIFilter! = CIFilter(name: "CIGaussianBlur")
//            filter2.setValue(beginImage, forKey: kCIInputImageKey)
//            filter2.setValue(5.0, forKey: kCIInputRadiusKey)
//            let output2 = filter2.outputImage!
//            let currentImage:UIImage = UIImage.init(ciImage: output2)
//        DispatchQueue.main.async {
//            self.imagePicked.image = currentImage
//            
//            }
//        }
//
//
//    }
//    @IBAction func bothBtn(_ sender: Any) {
//    }
//    
//
//    @IBAction func sepiaAndBlur(_ sender: Any) {
//        DispatchQueue.global().async {
//            
//            let inputImage : UIImage! =  self.imagePicked.image
//            
//            let context = CIContext(options: nil)
//            
//            let beginImage = CIImage(image: inputImage)
//            
//            let filter : CIFilter! = CIFilter(name: "CISepiaTone")
//            filter.setValue(beginImage, forKey: kCIInputImageKey)
//            filter.setValue(0.9, forKey: kCIInputIntensityKey)
//            let output = filter.outputImage!
//            
//            //			let filter2 : CIFilter! = CIFilter(name: "CIGaussianBlur")
//            //			filter2.setValue(output, forKey: kCIInputImageKey)
//            //			filter2.setValue(1.0, forKey: kCIInputRadiusKey)
//            //			let output2 = filter2.outputImage!
//            
//            let filter2 : CIFilter! = CIFilter(name: "CIZoomBlur")
//            filter2.setValue(output, forKey: kCIInputImageKey)
//            filter2.setValue(5.0, forKey: "inputAmount")
//            let output2 = filter2.outputImage!
//            
//            
//            let cgimg : CGImage! = context.createCGImage(output2, from: output2.extent)
//            
//            let processedImage = UIImage(cgImage:cgimg)
//            DispatchQueue.main.async {
//                self.imagePicked.image = processedImage
//                
//            }
//            
//        }
//        
//    }

    @IBAction func VignetteBtn(_ sender: Any) {
        DispatchQueue.global().async {
            
            let inputImage : UIImage! = self.imagePicked.image
        
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
            self.imagePicked.image = currentImage
        //self.tableData.append(currentImage)
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
     //   var myCity : String! = ""
     
        print ("Mycity \(myCity))")
        let imageName = dataModel.uploadData(latitue: latitude, longitude: longitude, city: myCity)
        let myImage = imagePicked.image
        
        dataModel.uploadPhotoFB(photo: chosenImage, name: imageName)
        //upload(latitue: 10.0, longitude: 10.0, title: "Test")
    }

	@IBAction func shareOnFBTouched(_ sender: AnyObject) {
		
		let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
		content.contentURL = URL(string: "http://www.google.com")
		FBSDKShareDialog.show(from: self, with: content, delegate: nil)
		
	}

    
    
    
}

