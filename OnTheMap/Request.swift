//
//  Request.swift
//  OnTheMap
//
//  Created by Timo Krall on 11/29/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import Foundation
import UIKit

class Request: NSObject {
// Instruction on integrating Parse API available at https://docs.google.com/document/d/1E7JIiRxFR3nBiUUzkKal44l9JkSyqNWvQrNH4pDrOFU/pub?embedded=true
// Class fixed after looking up https://github.com/RP-3/OnTheMap-Submission
    
    // MARK: Variables
    
    var session: NSURLSession
    var sessionID : String? = nil
    var userID : Int? = nil
    
    // MARK: Initialize session
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: Functions
    
    // Parse API GET method
    func GET(url: String, headers: [String: String]?, isUdacity: BooleanLiteralType, callback: ((data: AnyObject?, response: NSURLResponse?, error: NSError?) -> Void)?) {
        let request = makeRequest(url, method: "GET", body: nil, headers: headers)
        let task = session.dataTaskWithRequest(request) {downloadData, downloadResponse, downloadError in
            self.parseJSONWithCompletionHandler(downloadData, response: downloadResponse, error: downloadError, isUdacity: isUdacity, completionHandler: callback!)
        }
        task.resume()
    }
    
    // Parse API POST method
    func POST(url: String, headers: [String: String]?, body: [String : AnyObject], isUdacity: BooleanLiteralType, callback: ((data: AnyObject?, response: NSURLResponse?, error: NSError?) -> Void)?) {
        let request = makeRequest(url, method: "POST", body: body, headers: headers)
        let task = session.dataTaskWithRequest(request) {downloadData, downloadResponse, downloadError in
            self.parseJSONWithCompletionHandler(downloadData, response: downloadResponse, error: downloadError, isUdacity: isUdacity, completionHandler: callback!)
        }
        task.resume()
    }
    
    // Parse API PUT method
    func PUT(url: String, headers: [String: String]?, body: [String : AnyObject], isUdacity: BooleanLiteralType, callback: ((data: AnyObject?, response: NSURLResponse?, error: NSError?) -> Void)?) {
        let request = makeRequest(url, method: "PUT", body: body, headers: headers)
        let task = session.dataTaskWithRequest(request) {downloadData, downloadResponse, downloadError in
            self.parseJSONWithCompletionHandler(downloadData, response: downloadResponse, error: downloadError, isUdacity: isUdacity, completionHandler: callback!)
        }
        task.resume()
    }
    
    func parseUdacityData(data:NSData) ->NSData{
        return data.subdataWithRange(NSMakeRange(5, data.length - 5))
    }
    
    func makeRequest(url:String, method: String, body: [String : AnyObject]?, headers: [String: String]?) -> NSMutableURLRequest {
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let headerDictionary = headers {
            for (header, value) in headerDictionary {
                request.addValue(value, forHTTPHeaderField: header)
            }
        }
        
        if let requestBodyDictionary = body {
            
            let serealisedBody: NSData?
            do {
                serealisedBody = try NSJSONSerialization.dataWithJSONObject(requestBodyDictionary, options: [])
            } catch let error as NSError {
                print(error)
                serealisedBody = nil
            }
            request.HTTPBody = serealisedBody
            
        }
        
        return request
        
    }
    
    func parseJSONWithCompletionHandler(data: NSData?, response: NSURLResponse?, error: NSError?, isUdacity: BooleanLiteralType, completionHandler: (data: AnyObject?, result: NSURLResponse?, error: NSError?) -> Void) {
        
        if(error != nil){
            
            // Handle connection error
            print("Error in connection case.")
            completionHandler(data: nil, result: nil, error: error!)
            return
            
        }
        
        var preparsedData = data
        let parsedResult: AnyObject?
        
        if(isUdacity){
            preparsedData = parseUdacityData(preparsedData!)
        }
        
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(preparsedData!, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            
            // Handle parsing error
            print("Error in parsing case.")
            completionHandler(data: nil, result: nil, error: error)
            return
            
        }
        
        completionHandler(data: parsedResult, result: response!, error: nil)
        
    }
    
    // Singleton to ensure that request runs only once
    class func sharedInstance() -> Request {
        
        struct Singleton {
            static var sharedInstance = Request()
        }
        
        return Singleton.sharedInstance
    }
    
}
