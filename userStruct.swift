//
//  userStruct.swift
//  OnTheMap
//
//  Created by Timo Krall on 11/30/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import Foundation

struct UserInformation {
// Struct fixed after looking up https://github.com/RP-3/OnTheMap-Submission
    
    // MARK: Variables
    
    var createdAt: NSDate?
    var firstName: String?
    var lastName: String?
    var latitude: Double?
    var longitude: Double?
    var mapString: String?
    var mediaURL: String?
    var objectId: String?
    var uniqueKey: String?
    var updatedAt: NSDate?
    
    // MARK: Dictionary
    
    init (dict: NSDictionary) {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let createdDateString = (dict["createdAt"] as AnyObject? as? String?)!
        let updatedDateString = (dict["updatedAt"] as AnyObject? as? String?)!
        
        createdAt = formatter.dateFromString(createdDateString!)
        updatedAt = formatter.dateFromString(updatedDateString!)
        firstName = (dict["firstName"] as AnyObject? as? String?)!
        lastName = (dict["lastName"] as AnyObject? as? String?)!
        latitude = (dict["latitude"]  as AnyObject? as? Double?)!
        longitude = (dict["longitude"]  as AnyObject? as? Double?)!
        mapString = (dict["mapString"] as AnyObject? as? String?)!
        mediaURL = (dict["mediaURL"] as AnyObject? as? String?)!
        objectId = (dict["objectId"] as AnyObject? as? String?)!
        uniqueKey = (dict["uniqueKey"]  as AnyObject? as? String?)!
        
    }
    
}