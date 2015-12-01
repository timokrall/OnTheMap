//
//  Parse.swift
//  OnTheMap
//
//  Created by Timo Krall on 11/29/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import Foundation
import CoreLocation

class Parse {
// Instruction on parse integration available at https://docs.google.com/document/d/1E7JIiRxFR3nBiUUzkKal44l9JkSyqNWvQrNH4pDrOFU/pub?embedded=true
// Code of this class fixed after comparing with https://github.com/RP-3/OnTheMap-Submission
    
    let request = Request.sharedInstance()
    let userDataModel = userModel.sharedInstance()
    let baseURL = "https://api.parse.com/1/classes/"
    
    let reqHeaders = [
        "X-Parse-Application-Id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
        "X-Parse-REST-API-Key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    ]
    
    func parseUserData(data: [NSDictionary]) -> [UserInformation]{
        
        var result: Array<UserInformation> = []
        
        for dict in data {
            let s:UserInformation = UserInformation(dict: dict)
            result.append(s)
        }
        
        return result
        
    }
    
    func getLocations(callback: ((error: String?) -> Void)) {
        
        let url = baseURL + "UserLocation"
        
        request.GET(url, headers: reqHeaders, isUdacity: false) { (data, response, error) -> Void in
            
            // Handle connection error
            if error != nil {
                callback(error: error?.description)
                return
            }
            
            // Handle user error
            let httpResponse = response as! NSHTTPURLResponse
            if(httpResponse.statusCode > 399 && httpResponse.statusCode < 500){
                callback(error: "Invalid login credentials")
                return
            }
            
            let arrayObjs = data as! [String: AnyObject]
            let arrayDicts = (arrayObjs["results"]! as? [NSDictionary])
            self.userDataModel.setUserData(self.parseUserData(arrayDicts!))
            
            // Return session data to login view controller
            callback(error: nil)
            return
        }
        
    }
    
    func upsertUserData(locationId: String, userUpdate: [String: AnyObject], callback: ((error: String?) -> Void)) {
        
        // Check location data has loaded
        if(userDataModel.getUserData() == nil){
            callback(error: "User Data not yet loaded")
            return
        }
        
        // Check if locationId exists in locationData array
        var alreadyPosted: Bool = false
        var objectId: String? = nil
        
        let userData = userDataModel.getUserData()
        
        for user in userData! {
            if (user.uniqueKey == locationId){
                alreadyPosted = true
                objectId = user.objectId
            }
        }
        
        if(alreadyPosted == false){
            // Use Parse POST method to create a new value
            let url = baseURL + "UserLocation"
            
            request.POST(url, headers: reqHeaders, body: userUpdate, isUdacity: false) { (data, response, error) -> Void in
                
                // Handle connection error
                if error != nil {
                    callback(error: error?.description)
                    return
                }
                
                // Handle user error
                let httpResponse = response as! NSHTTPURLResponse
                if(httpResponse.statusCode > 399 && httpResponse.statusCode < 500){
                    callback(error: "Access denied")
                    return
                }
                
                // If no error is found, set callback to nil
                callback(error: nil)
                return
                
            }
            
        }else{
            // Use Parse PUT method to update an existing value
            let url = baseURL + "UserLocation/" + objectId!
            
            request.PUT(url, headers: reqHeaders, body: userUpdate, isUdacity: false) { (data, response, error) -> Void in
                
                // Handle connection error
                if error != nil {
                    callback(error: error?.description)
                    return
                }
                
                // Handle user error
                let httpResponse = response as! NSHTTPURLResponse
                if(httpResponse.statusCode > 399 && httpResponse.statusCode < 500){
                    callback(error: "Access denied")
                    return
                }
                
                // If no error is found, set callback to nil
                callback(error: nil)
                return
                
            }
            
        }
        
    }
    
    // Singleton to ensure that Parse runs only once
    class func sharedInstance() -> Parse {
        
        struct Singleton {
            static var sharedInstance = Parse()
        }
        
        return Singleton.sharedInstance
    }

}
