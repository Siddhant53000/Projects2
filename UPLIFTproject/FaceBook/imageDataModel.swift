//
//  imageDataModel.swift
//  UPLIFT
//
//  Created by Siddhant Gupta on 5/8/17.
//  Copyright © 2017 ITP344. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

class imageDataModel : NSObject
{
   // static var instance : imageDataModel!
   // let baseURL = "http://uplift.site.swiftengine.net/locations.ssp"
    var ref : FIRDatabaseReference!
    
    var conditional : Int!
    
    //UPLOADING THE FILE DATA TO FIREBASE
    
    func uploadData (latitue : Double, longitude : Double, city: String) -> String
    {
        let infoDict : [String : String] = [
           // "title" : title,
            "lat" : String(latitue),
            "long" : String(longitude),
            "city" : city
            
        ]
        let ref = FIRDatabase.database().reference(withPath : "locations")

        let key = ref.childByAutoId().key
        ref.child(key).setValue(infoDict)
        return key
    }
    //UPLOADING THE PHOTO TO FIREBASE
    func uploadPhotoFB(photo: UIImage, name: String)
    {
        
        let storageREF = FIRStorage.storage().reference()
        let fileName  = "\(name).jpg"
        let imagesREF = "images/\(fileName)"
        var data = NSData()
        data = UIImageJPEGRepresentation(photo, 0.8)! as NSData
        storageREF.child(imagesREF).put(data as Data, metadata: nil){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            else{
                print ("Upload Successful!")
            }
        }

}
}
//    func uploadPhoto(_ photo: UIImage, params: [String: String], name : String){
//        
//        
//        print ("entered upload")
//    
//        var r  = URLRequest(url: URL(string: "http://uplift.site.swiftengine.net/uploader.ssp")!)
//        r.httpMethod = "POST"
//        let boundary = "Boundary-\(UUID().uuidString)"
//        r.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        print ("reached 1")
//        r.httpBody = createBody(parameters: params,
//                                boundary: boundary,
//                                data: UIImageJPEGRepresentation(photo, 0.7)!,
//                                mimeType: "image/jpg",
//                                filename: "hi.jpg")
//        print ("reached2")
//        let task = URLSession.shared.dataTask(with: r) {
//            (responseData, urlResponse, error) in
//            
//            
//            let alertController = UIAlertController(
//                title: "Done",
//                message: "Uploaded!",
//                preferredStyle: UIAlertControllerStyle.alert
//            )
//            let confirmAction = UIAlertAction(
//            title: "OK", style: UIAlertActionStyle.default) { (action) in
//                // ...
//            }
//            alertController.addAction(confirmAction)
//         //   self.present(alertController, animated: true, completion: nil)
//            
//        }
//        print ("reached 3")
//        task.resume()
//        print ("reached 4")
//        
//    }
//    
//    func createBody(parameters: [String: String],
//                    boundary: String,
//                    data: Data,
//                    mimeType: String,
//                    filename: String) -> Data {
//        var body = Data()
//        
//        let boundaryPrefix = "--\(boundary)\r\n"
//        
//        for (key, value) in parameters {
//            body.appendString(boundaryPrefix)
//            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
//            body.appendString("\(value)\r\n")
//        }
//        
//        body.appendString(boundaryPrefix)
//        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
//        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
//        body.append(data)
//        body.appendString("\r\n")
//        body.appendString("--".appending(boundary.appending("--")))
//        
//        return body as Data
//    }
//    
//    
//}
//extension Data {
//    mutating func appendString(_ string: String) {
//        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
//        self.append(data!)
//    }


//extension Data {
//    mutating func appendString(_ string: String) {
//        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
//        self.append(data!)
//    }
//}

//    static let sharedInstance = imageDataModel()
//    func uploadPost(latitue : Float, longitude : Float, title : String , callback:@escaping (_ data : AnyObject?, _ error: AnyObject?)->()) -> Void{
//        
//        let infoDict : [String : String] = [
//            "title" : title,
//            "lat" : String(latitue),
//            "long" : String(longitude)
//        ]
//        let toUpload : [String : AnyObject] = [
//            "location" : infoDict as AnyObject
//        ]
//        let postData = convertDictionaryToJsonData(toUpload)
//        //  let dataString = convertDataToString(myData!)
//        
//        var request = URLRequest(url: URL(string: "\(baseURL)")!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30.0)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let session = urlSession() //URLSession.shared
//        
//        let task = session.uploadTask(with: request as URLRequest,
//                                      from: postData, completionHandler: {
//                                        (data, response, error) -> Void in
//                                        
//                                        if let data = data{
//                                            
//                                            let dict =  self.convertJsonDataToDictionary(data)
//                                            callback(dict as AnyObject?, nil)
//                                            
//                                        }else{
//                                            
//                                            callback(nil, nil)
//                                            
//                                            
//                                        }
//                                        
//        })
//        task.resume()
//        
//        
//    }
//    func convertJsonDataToDictionary(_ inputData : Data) -> Array<[String:AnyObject]>? {
//        guard inputData.count > 1 else{ return nil }  // avoid processing empty responses
//        
//        do {
//            return try JSONSerialization.jsonObject(with: inputData, options: []) as? Array<Dictionary<String, AnyObject>>
//        }catch let error as NSError{
//            print(error)
//            
//        }
//        return nil
//    }
//    func convertDictionaryToJsonData(_ inputDict : Dictionary<String, AnyObject>) -> Data?{
//        
//        do{
//            return try JSONSerialization.data(withJSONObject: inputDict, options:JSONSerialization.WritingOptions.prettyPrinted)
//            
//        }catch let error as NSError{
//            print(error)
//            
//        }
//        
//        return nil
//    }
//    
//    func convertDataToString(_ inputData : Data) -> NSString?{
//        
//        let returnString = String(data: inputData, encoding: String.Encoding.utf8)
//        //print(returnString)
//        return returnString as NSString?
//        
//    }



