//
//  parseConstant.swift
//  onTheMap
//
//  Created by Arjun Baru on 04/10/16.
//  Copyright © 2016 Arjun Baru. All rights reserved.
//

import Foundation

extension parseClient{
    struct Constants {
        static let ParseApplicationID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseAPIKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ParseBaseSecureURL: String = "https://parse.udacity.com/parse/classes/"
        static let ApiScheme = "https"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse/classes/StudentLocation"

    }
    
    //Mark -- Methods
    struct Methods {
        static let StudentLocation = "StudentLocation"
        static let support = "where"
        static let limit = "limit"
        static let number = "100"
    }

    
    struct StudentResponseKeys {
        static let Results = "results"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
    }
    struct JSONBodyKeys {
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
}
}
