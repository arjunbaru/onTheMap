//
//  reachability.swift
//  onTheMap
//
//  Created by Arjun Baru on 13/10/16.
//  Copyright © 2016 Arjun Baru. All rights reserved.
//


import Foundation

public class Reachability {
    
    class func isConnectedToNetwork(completionHandlerForNetwork: @escaping(_ result: Bool)->Void){
        
        var Status:Bool = false
        let url = NSURL(string: "https://google.com/")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "HEAD"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        let session = URLSession.shared
        
        session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            print("data \(data)")
            print("response \(response)")
            print("error \(error)")
            
            if let httpResponse = response as? HTTPURLResponse {
                print("httpResponse.statusCode \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    Status = true
                    print("hey \(Status)")
                    completionHandlerForNetwork(true)
                    return
                }
                    
                
                
            }
           completionHandlerForNetwork(false)
        }).resume()
        
        
    }
}
