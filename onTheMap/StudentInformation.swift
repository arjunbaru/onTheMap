//
//  StudentInformation.swift
//  onTheMap
//
//  Created by Arjun Baru on 04/10/16.
//  Copyright © 2016 Arjun Baru. All rights reserved.
//

import Foundation
import MapKit
struct StudentInformation {
    
    //MARK: -- Properties
    var firstName: String
    var lastName: String
    var latitude: Double?
    var longitude: CLLocationDegrees?
    var mapString: String?
    var mediaURL: String?
    var objectID: String
    var uniqueKey: String?
    var createdAt: Date
    var updatedAt: Date
    static var studentData = [StudentInformation]()
    
    
     init(dictionary: [String : AnyObject]){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        self.firstName = (dictionary[parseClient.StudentResponseKeys.FirstName] as! String)
        self.lastName = dictionary[parseClient.StudentResponseKeys.LastName] as! String
        self.latitude = dictionary["latitude"] as? Double
        self.longitude = dictionary[parseClient.StudentResponseKeys.Longitude] as? CLLocationDegrees
        self.objectID = dictionary[parseClient.StudentResponseKeys.ObjectID] as! String
        self.mapString = dictionary[parseClient.StudentResponseKeys.MapString] as? String
        self.uniqueKey = (dictionary[parseClient.StudentResponseKeys.UniqueKey] as! String)
        self.mediaURL = dictionary[parseClient.StudentResponseKeys.MediaURL] as? String
        self.createdAt = dateFormatter.date(from: dictionary[parseClient.StudentResponseKeys.CreatedAt] as! String)!
        self.updatedAt = dateFormatter.date(from: dictionary[parseClient.StudentResponseKeys.UpdatedAt] as! String)!
        
}
}
