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
    let studentDataModel = studentModel.sharedInstance()
    let baseURL = "https://api.parse.com/1/classes/"
    
    let reqHeaders = [
        "X-Parse-Application-Id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
        "X-Parse-REST-API-Key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    ]
    
    func parseStudentData(data: [NSDictionary]) -> [StudentInformation]{
        
        var result: Array<StudentInformation> = []
        
        for dict in data {
            let s:StudentInformation = StudentInformation(dict: dict)
            result.append(s)
        }
        
        return result
        
    }
    
    func getStudentLocations(callback: ((error: String?) -> Void)) {
        
        let url = baseURL + "StudentLocation"
        
        request.GET(url, headers: reqHeaders, isUdacity: false) { (data, response, error) -> Void in
            
            // Handle connection error
            if error != nil {
                callback(error: error?.description)
                return
            }
            
            // Handle student error
            let httpResponse = response as! NSHTTPURLResponse
            if(httpResponse.statusCode > 399 && httpResponse.statusCode < 500){
                callback(error: "Invalid login credentials")
                return
            }
            
            let arrayObjs = data as! [String: AnyObject]
            let arrayDicts = (arrayObjs["results"]! as? [NSDictionary])
            self.studentDataModel.setStudentData(self.parseStudentData(arrayDicts!))
            
            // Return session data to login view controller
            callback(error: nil)
            return
        }
        
    }
    
    func upsertStudentData(studentId: String, studentUpdate: [String: AnyObject], callback: ((error: String?) -> Void)) {
        
        // Check location data has loaded
        if(studentDataModel.getStudentData() == nil){
            callback(error: "Student Data not yet loaded")
            return
        }
        
        // Check if studentId exists in locationData array
        var alreadyPosted: Bool = false
        var objectId: String? = nil
        
        let studentData = studentDataModel.getStudentData()
        
        for student in studentData! {
            if (student.uniqueKey == studentId){
                alreadyPosted = true
                objectId = student.objectId
            }
        }
        
        if(alreadyPosted == false){
            // Use Parse POST method to create a new value
            let url = baseURL + "StudentLocation"
            
            request.POST(url, headers: reqHeaders, body: studentUpdate, isUdacity: false) { (data, response, error) -> Void in
                
                // Handle connection error
                if error != nil {
                    callback(error: error?.description)
                    return
                }
                
                // Handle student error
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
            let url = baseURL + "StudentLocation/" + objectId!
            
            request.PUT(url, headers: reqHeaders, body: studentUpdate, isUdacity: false) { (data, response, error) -> Void in
                
                // Handle connection error
                if error != nil {
                    callback(error: error?.description)
                    return
                }
                
                // Handle student error
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
