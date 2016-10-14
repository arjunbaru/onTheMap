//
//  udacityConvinence.swift
//  onTheMap
//
//  Created by Arjun Baru on 03/10/16.
//  Copyright © 2016 Arjun Baru. All rights reserved.
//

import Foundation

extension udacityClient{
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void){
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            completionHandler(nil, NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
            return
        }
        completionHandler(parsedResult as AnyObject?, nil)
    }

  class func  getUserData(_ userID: String?, completionHandlerForUserID: @escaping (_ result: [String]? ,_ error: NSError?) -> Void){
    let url = udacityClient.Constants.UdacityBaseURL + udacityClient.Methods.Users + userID!
    let request = NSMutableURLRequest(url: NSURL(string: url) as! URL)
        let task = URLSession.shared.dataTask(with: request as URLRequest){(data,response,error) in
            if error != nil{
                print ("error found")
                return
            }
            print("the response \(response)")
            print("the data \(data)")
            let dataLength = data?.count
            let r = 5...Int(dataLength!)
            let newData = data?.subdata(in: Range(r))
            var parsedResult: AnyObject!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
            } catch {
                print("cannot parse")
                return
            }
    
            if let userDictionary = parsedResult["user"] as? [String:AnyObject]{
                var result = [String]()
                if let firstName = userDictionary["first_name"] as? String{
                    result.append(firstName)
                    print("this is \(firstName)")
                    if let lastName = userDictionary["last_name"] as? String{
                        result.append(lastName)
                        print("this is \(lastName)")
                        completionHandlerForUserID(result,error as NSError?)
                    }
                }
                
            }
    }
    task.resume()
}
     func deleteSession(comletionhandlerToDelete: @escaping (_ result: String?, _ error: NSError?)-> Void){
        taskToDelete(){(result,error) in
            if error != nil {
                print("error is : \(error)")
                return
            }
            if let result = result {
                if let dictionary = result["session"] as? [String:AnyObject]{
                    print("session deleted : \(dictionary)")
                    if let session = dictionary["id"] as? String{
                        comletionhandlerToDelete(session,nil)
                    }
                }
            }
        }
        
    }
    
    func validateUsernameAndPassword(_ Username: String?,_ password: String?,completionHandler: @escaping(_ result: String?,_ error: NSError?)-> Void){
        let parameter: [String:Any] = [udacityClient.JSONBodyKeys.Udacity: [udacityClient.JSONBodyKeys.Username: Username!,
                                                              udacityClient.JSONBodyKeys.Password: password!]
        ]
        
        udacityClient.sharedInstance().taskToAunthicate(parameter){(result,error) in
            guard error == nil else{
                print("error \(error)")
                completionHandler(nil,error)
                return
            }
            if let result = result?[JSONResponseKeys.Key] as? String {
                completionHandler(result, nil)
                
            }else{
                completionHandler(nil,error)

        }
    }
        

}
}
