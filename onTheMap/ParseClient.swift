//
//  ParseClient.swift
//  onTheMap
//
//  Created by Arjun Baru on 04/10/16.
//  Copyright © 2016 Arjun Baru. All rights reserved.
//

import Foundation
import UIKit
class parseClient: NSObject{
    var appDelegate : AppDelegate!

    
    static func getStudentData(completionHandler: @escaping (_ result: [String:AnyObject]?, _ error: NSError?)-> Void){
        let parameter :[String:AnyObject] = [parseClient.Methods.limit: parseClient.Methods.number as AnyObject ]
        let method = parseClient.sharedInstance().URLFromParameters(parameters: parameter)
        print("URL is \(method)")
        let request = NSMutableURLRequest(url: method as URL)
        request.addValue(parseClient.Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(parseClient.Constants.ParseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                completionHandler(nil,error as NSError?)
                return
            }
            parseClient.parseJSONWithCompletionHandler(data!){(result,error) in
                if error == nil {
                    completionHandler(result,nil)
                }else{
                    print("parsing Failed")
                    completionHandler(nil,error)
                }
            }
        }
        task.resume()
    }
    
    static func getaStudentData(completionHandler: @escaping(_ result: [[String:AnyObject]]?,_ error: NSError?) ->Void){
        let parameter: [String:AnyObject] = [parseClient.Methods.support :  "{\"\(parseClient.JSONBodyKeys.UniqueKey)\":\"\(udacityClient.sharedInstance().sessionID!)\"}" as AnyObject]
        
        let urlString = (parseClient.sharedInstance().URLFromParameters(parameters: parameter as [String : AnyObject]))
       // print(urlString)
       
        let url:NSURL = urlString
        let request = NSMutableURLRequest(url: url as URL)
        request.addValue(parseClient.Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(parseClient.Constants.ParseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest ) { data, response, error in
            if error != nil{
                print("error while getting student info")
                return
            }
            guard let data = data else{
                print("data not found")
                return
            }
            parseJSONWithCompletionHandler(data){(newData,error) in
                if error != nil{
                    print("error found after parsing")
                }
               guard let dictionary = newData?["results"] as? [[String:AnyObject]] else{
                    print("cannot form into dictionary ")
                    return
                }
               // print("dictionary \(dictionary)")
                completionHandler(dictionary as [[String:AnyObject]],nil)
            }
        }
        task.resume()
    }
    
    func taskForPut(_ objectId: String?,_ jsonBody: [String:Any]?, completionHandler: @escaping (_ result: [String: AnyObject]?, _ error: NSError?) -> Void){
        let urlString = Constants.ParseBaseSecureURL+parseClient.Methods.StudentLocation + "/" + objectId!
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "PUT"
        request.addValue(parseClient.Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(parseClient.Constants.ParseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do{
            request.httpBody = try! JSONSerialization.data(withJSONObject: jsonBody!)
        }
      
        let task = URLSession.shared.dataTask(with: request as URLRequest){(data,response,error) in
            if error != nil{
                print("error found while putting")
                completionHandler(nil,error as NSError?)
                return
            }
            if let data = data {
                parseClient.parseJSONWithCompletionHandler(data){(result,error) in
                    
                    
                    completionHandler(result! as [String:AnyObject],nil)
                }
            }
        }
        task.resume()
    }
    
    
    
    
    func taskForPost(_ method: String,_ jsonBody: [String:Any]?, completionHandler: @escaping (_ result: [String:AnyObject]?, _ _error: NSError? )-> Void){
        print("what is there in json  \(jsonBody?["latitude"])")
    
        let urlString = Constants.ParseBaseSecureURL + parseClient.Methods.StudentLocation + "/"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue(Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do{
            request.httpBody = try! JSONSerialization.data(withJSONObject: jsonBody!)
        }
        
        let task = URLSession.shared.dataTask(with: request as URLRequest){(data,response,error) in
            if error != nil{
                print("error")
            }
            guard let data = data else{
                print("unable to POST get data")
                return
            }
            print(NSString(data: data, encoding: String.Encoding.utf8.rawValue))
            var parsedResult: AnyObject!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
            } catch {
                let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
                completionHandler(nil, NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
                return
            }

            
            guard let parsedResutl = parsedResult as? [String:AnyObject] else{
                print("cannot parse")
                return
            }
             print("parsed Result for POST \(parsedResutl)")
               completionHandler(parsedResutl,nil)
        }
        task.resume()
    }
    
    
    
    class func sharedInstance() -> parseClient {
        
        struct Singleton {
            static var sharedInstance = parseClient()
        }
        return Singleton.sharedInstance
    }

    }
    


