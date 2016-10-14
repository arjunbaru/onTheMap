//
//  ParseConvinence.swift
//  onTheMap
//
//  Created by Arjun Baru on 04/10/16.
//  Copyright © 2016 Arjun Baru. All rights reserved.
//

import Foundation
extension parseClient{
    
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: (_ result: [String:AnyObject]?, _ error: NSError?) -> Void){
    
        var parsedResult: AnyObject!
    do {
        parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
    } catch {
        let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
        completionHandler(nil, NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        return
    }
      // print(parsedResult)
        guard let revised = parsedResult as? [String:AnyObject] else{
            print("parsing failer")
            return
        }
       
        print(revised)
        
    completionHandler(revised, nil)
}
    func putStudentLocation(_ objectId: String,_ jsonBody: [String:Any]?, completionHandler: @escaping (_ result: String?,_ network: Bool, _ error: NSError?) -> Void) {
        
            
       taskForPut(objectId,jsonBody){(result,error) in
        print("resulttttt \(result)")
        if error != nil{
            print("data unsufficent for json")
            completionHandler(nil,true,error)
            return
            
        }
        guard let result = result!["updatedAt"] as? String else{
         completionHandler(nil,false,nil)
            return
        }
        
            completionHandler(result,true,nil)
        
                    
       }
    }
    
    func postStudentLocation(_ jsonBody: [String:Any]?, completionHandlerForPostStudentLocation: @escaping (_ result: AnyObject? ,_ network: Bool, _ error: NSError? ) -> Void ) {
        let method = Methods.StudentLocation
        taskForPost(method,jsonBody){(result,error) in
            print(".....\(result)")
            if error != nil{
                print("error found")
                completionHandlerForPostStudentLocation(nil,true,error)
                return
            }
            guard let result = result?[StudentResponseKeys.ObjectID] as? String else{
                completionHandlerForPostStudentLocation(nil,false,nil)
                return
                }
         completionHandlerForPostStudentLocation(result as AnyObject?,true,nil)
            
        }
    }

    func codeForStudentData(completionHandler: @escaping(_ result: [[String:AnyObject]]?,_ network: Bool,_ error: NSError? )-> Void){
        parseClient.getStudentData(){(result,error) in
            print("\(error)..... \(result)")
            if error == nil {
                guard let resultrecieved = result![parseClient.StudentResponseKeys.Results] as? [[String: AnyObject]] else{
                    print("cannot form into results")
                    completionHandler(nil,false,nil)
                    return
                }
                completionHandler(resultrecieved,true,nil)
                
            }else{
                completionHandler(nil,true,error)
            }
    }
    }
    
    func URLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = parseClient.Constants.ApiScheme
        components.host =  parseClient.Constants.ApiHost
        components.path =  parseClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]() as [URLQueryItem]?
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: ((value) as! String))
            components.queryItems!.append(queryItem as URLQueryItem)
        }
        
        return components.url! as NSURL
    }
    
}
