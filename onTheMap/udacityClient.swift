//
//  ContainsMethods.swift
//  onTheMap
//
//  Created by Arjun Baru on 02/10/16.
//  Copyright © 2016 Arjun Baru. All rights reserved.
//

import Foundation
import UIKit

class udacityClient: NSObject{
    
    var session = URLSession.shared
    var sessionID: String? = nil
    var UserID :String? = nil
    
    
    
    func taskToAunthicate(_ jsonBody: [String:Any]?, completionHandler: @escaping (_ result: [String:AnyObject]?, _ error: NSError?)-> Void){
        
        let url = udacityClient.Constants.UdacityBaseURL + Methods.Session
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      
        do{
            request.httpBody = try! JSONSerialization.data(withJSONObject: jsonBody!)
        }
        
        let task = udacityClient.sharedInstance().session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                print(error)
              completionHandler(nil,error as NSError?)
                return
            }
            guard let data = data else{
                print("data not found")
                completionHandler(nil,error as NSError?)
                return
            }
            
            let dataLength = data.count
            let r = 5...Int(dataLength)
            let newData = data.subdata(in: Range(r))
            
            print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue))
           guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode<=299 else {
            if let response = response as? HTTPURLResponse {
                let userInfo = [NSLocalizedDescriptionKey: "Your Request returned an invalid respons! Status code: \(response.statusCode)!"]
                completionHandler(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            } else if let response = response {
                let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response! Response: \(response)!"]
                completionHandler(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            } else {
                let userInfo = [NSLocalizedDescriptionKey: "Your request returned an invalid response!"]
                completionHandler(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
               return
            }

            udacityClient.parseJSONWithCompletionHandler(newData){(result2,error) in
               
                guard  error == nil else {
                    print("parsed result returned nothing")
                    return
                   
                }
                if let statusCode = result2?["status"] as? String {
                    print(statusCode)
                }
                
                if let dictionary = result2![JSONResponseKeys.Account] as? [String : AnyObject] {
                    completionHandler(dictionary,nil)
                
                }else{
                    completionHandler(nil,error)
                }
            }
        }
        task.resume()
    }
     func taskToDelete(completionhandlerToDelete: @escaping (_ result: AnyObject?, _ error: NSError?)-> Void){
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://www.udacity.com/api/session")! as URL)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            guard error == nil else{
                print("error found ")
                return
            }
            guard let data = data else{
                print("data empty")
                return
            }
            let dataLength = data.count
            let r = 5...Int(dataLength)
            let newData = data.subdata(in: Range(r))
            udacityClient.parseJSONWithCompletionHandler(newData){ (result,error) in
                if error != nil {
                    print("parse failed")
                    return
                }
                completionhandlerToDelete(result,nil)
                
            }
        }
        task.resume()
    }
    
    class func sharedInstance() -> udacityClient{
        
        struct Singleton {
            static var sharedInstance = udacityClient()
        }
        return Singleton.sharedInstance
    }
}

