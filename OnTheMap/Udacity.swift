//
//  Udacity.swift
//  OnTheMap
//
//  Created by Timo Krall on 11/29/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import UIKit
import AVFoundation

class Udacity: NSObject {
// Instruction on udacity login api available at https://docs.google.com/document/d/1MECZgeASBDYrbBg7RlRu9zBBLGd3_kfzsN-0FtURqn0/pub?embedded=true
// Code of this class fixed after comparing with https://github.com/RP-3/OnTheMap-Submission
    
    override init() {
        urlsession = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: Variables
    
    var urlsession : NSURLSession
    var sessionID: AnyObject?  = nil
    var userID: AnyObject? = nil
    var uniqueKey: String = ""
    var errorMsg: String = ""
    let request = Request.sharedInstance()
    let baseURL = "https://www.udacity.com/api/"
    
    var session: [String: String?] = [
        "key": nil,
        "sessionId": nil,
        "expiration": nil,
        "facebookAccessToken": nil
    ]
    
    var user: [String: String?] = [
        "firstName": nil,
        "lastName": nil
    ]
    
    
    // MARK: Functions
    
    // Login via credentials
    
    func loginCredentials(username: String, password: String, callback: ((data: [String: String?]?, error: String?) -> Void)) {
        
        let url = baseURL + "session"
        
        let reqBody = [
            "udacity" : [
                "username": username,
                "password": password
            ]
        ]
        
        request.POST(url, headers: nil, body: reqBody, isUdacity:true) { (data, response, error) -> Void in
            
            // Handle connection error
            if error != nil {
                callback(data: nil, error: error?.description)
                return
            }
            
            // Handle user error
            let httpResponse = response as! NSHTTPURLResponse
            if(httpResponse.statusCode > 399 && httpResponse.statusCode < 500){
                callback(data: nil, error: "Invalid login credentials")
                return
            }
            
            // No errors
            // Set up Udacity client session
            let account = data!["account"] as! NSDictionary
            self.session["key"] = account["key"]! as? String
            
            let dataSession = data!["session"] as! NSDictionary
            self.session["sessionId"] = dataSession["id"] as? String
            self.session["expiration"] = dataSession["expiration"] as? String
            
            self._getUserData((account["key"]! as? String)!)
            
            // Return session data to login view controller
            callback(data: self.session, error: nil)
            return
        }
        
    }
    
    // Retrieve User's Personal Data using the sessionID
    // Code found at https://github.com/mechdon/OnTheMap
    func getUserData() -> [String: String?] {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(self.uniqueKey)")!)
        let task = urlsession.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                return
            }
            
            self.parseJSONWithCompletionHandler(data!, completionHandler: { (result, error) in
                if error != nil {
                    return
                } else {
                    if let userData = result["user"] as? NSDictionary {
                        let firstName = userData["first_name"] as! String
                        let lastName = userData["last_name"] as! String
                        NSUserDefaults.standardUserDefaults().setObject(firstName, forKey: "firstName")
                        NSUserDefaults.standardUserDefaults().setObject(lastName, forKey: "lastName")
                    }
                }
            })
        }
        task.resume()
        return self.user
    }
    
    func _getUserData(userId: String){
        let url = baseURL + "users/" + userId
        
        request.GET(url, headers: nil, isUdacity: true) { (data, response, error) -> Void in
            
            // Handle connection error
            if error != nil {
                return
            }
            
            // Handle user error
            let httpResponse = response as! NSHTTPURLResponse
            if(httpResponse.statusCode > 399 && httpResponse.statusCode < 500){
                return
            }
            
            // Save public student info
            let firstName = data!["user"]!!["first_name"] as! String
            let lastName = data!["user"]!!["last_name"] as! String
            
            self.user["firstName"] = firstName
            self.user["lastName"] = lastName
            
            
        }
    }

    
    func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        var parsingError: NSError? = nil
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    // Function used by input view controller
    func getSession()->[String:String?]{
        return self.session
    }
    
    func logout(callback: (() -> Void)) {
        session["key"] = nil
        session["sessionId"] = nil
        session["expiration"] = nil
        callback()
    }
    
    // Singleton to ensure that Udacity runs only once
    class func sharedInstance() -> Udacity {
        
        struct Singleton {
            static var sharedInstance = Udacity()
        }
        
        return Singleton.sharedInstance
        
    }

}