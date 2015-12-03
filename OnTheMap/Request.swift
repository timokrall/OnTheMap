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
// Class changed and introduced makeRequest simplification to create methods after looking up https://github.com/RP-3/OnTheMap-Submission
    
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
    
    // Simplified GET method created using makeRequest method
    func GET(url: String, headers: [String: String]?, isUdacity: BooleanLiteralType, callback: ((data: AnyObject?, response: NSURLResponse?, error: NSError?) -> Void)?) {
        let request = makeRequest(url, method: "GET", body: nil, headers: headers)
        let task = session.dataTaskWithRequest(request) {downloadData, downloadResponse, downloadError in
            self.parseJSONWithCompletionHandler(downloadData, response: downloadResponse, error: downloadError, isUdacity: isUdacity, completionHandler: callback!)
        }
        task.resume()
    }
    
    // Simplified POST method created using makeRequest method
    func POST(url: String, headers: [String: String]?, body: [String : AnyObject], isUdacity: BooleanLiteralType, callback: ((data: AnyObject?, response: NSURLResponse?, error: NSError?) -> Void)?) {
        let request = makeRequest(url, method: "POST", body: body, headers: headers)
        let task = session.dataTaskWithRequest(request) {downloadData, downloadResponse, downloadError in
            self.parseJSONWithCompletionHandler(downloadData, response: downloadResponse, error: downloadError, isUdacity: isUdacity, completionHandler: callback!)
        }
        task.resume()
    }
    
    // TODO: POST method for Facebook session
    func facebookPOST(url: String, headers: [String: String]?, body: [String : AnyObject], isUdacity: BooleanLiteralType, callback: ((data: AnyObject?, response: NSURLResponse?, error: NSError?) -> Void)?) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"DADFMS4SN9e8BAD6vMs6yWuEcrJlMZChFB0ZB0PCLZBY8FPFYxIPy1WOr402QurYWm7hj1ZCoeoXhAk2tekZBIddkYLAtwQ7PuTPGSERwH1DfZC5XSef3TQy1pyuAPBp5JJ364uFuGw6EDaxPZBIZBLg192U8vL7mZAzYUSJsZA8NxcqQgZCKdK4ZBA2l2ZA6Y1ZBWHifSM0slybL9xJm3ZBbTXSBZCMItjnZBH25irLhIvbxj01QmlKKP3iOnl8Ey;\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                // Handle error...
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    
    }
    
    // Simplified PUT method created using makeRequest method
    func PUT(url: String, headers: [String: String]?, body: [String : AnyObject], isUdacity: BooleanLiteralType, callback: ((data: AnyObject?, response: NSURLResponse?, error: NSError?) -> Void)?) {
        let request = makeRequest(url, method: "PUT", body: body, headers: headers)
        let task = session.dataTaskWithRequest(request) {downloadData, downloadResponse, downloadError in
            self.parseJSONWithCompletionHandler(downloadData, response: downloadResponse, error: downloadError, isUdacity: isUdacity, completionHandler: callback!)
        }
        task.resume()
    }
    
    // Simplified DELETE method created using makeRequest method
    func DELETE(url: String, headers: [String: String]?, body: [String : AnyObject], isUdacity: BooleanLiteralType, callback: ((data: AnyObject?, response: NSURLResponse?, error: NSError?) -> Void)?) {
        let request = makeRequest(url, method: "DELETE", body: body, headers: headers)
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
