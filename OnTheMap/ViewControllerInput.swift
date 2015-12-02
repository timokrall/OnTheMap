//
//  ViewControllerInput.swift
//  OnTheMap
//
//  Created by Timo Krall on 11/29/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import WebKit
import CoreLocation

class ViewControllerInput: UIViewController, MKMapViewDelegate, WKNavigationDelegate, UITextFieldDelegate {
// Class fixed after looking up https://github.com/RP-3/OnTheMap-Submission
    
    // MARK: Variables
    
    let studentDataModel = studentModel.sharedInstance()
    let parse = Parse.sharedInstance()
    let udacity = Udacity.sharedInstance()
    let geoCoder = CLGeocoder()
    
    var reqBody: [String: AnyObject] = [
        "firstName": "",
        "lastName": "",
        "mapString": "",
        "mediaURL": "",
        "uniqueKey": "",
        "latitude": "",
        "longitude": ""
    ]
    
    var webView: WKWebView!
    
    // MARK: Outlets

    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonFind: UIButton!
    @IBOutlet weak var textFieldEnterLocation: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelOne: UILabel!
    @IBOutlet weak var labelTwo: UILabel!
    @IBOutlet weak var labelThree: UILabel!
    @IBOutlet weak var containerTop: UIView!
    @IBOutlet weak var containerMiddle: UIView!
    @IBOutlet weak var containerBottom: UIView!
    
    // MARK: Functions
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        
        textFieldEnterLocation.text = webView.URL?.absoluteURL.absoluteString
        
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        
        // Setup alert controller for URL errors
        let alertController = UIAlertController(title: "URL Error", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Please enter a valid URL.", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
        
        // Change button text
        buttonFind.setTitle("Visit URL", forState: UIControlState.Normal)
        
    }

    // MARK: Actions
    
    @IBAction func inputCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        // Change button text when editing begins
        // Change to different button text depending on whether location or website is requested
        if(buttonFind.titleLabel?.text == "Confirm Location"){
            buttonFind.setTitle("Find on Map", forState: UIControlState.Normal)
        }else if(buttonFind.titleLabel?.text == "Confirm URL"){
            buttonFind.setTitle("Visit URL", forState: UIControlState.Normal)
        }
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // Change button text when characters are changed
        if(buttonFind.titleLabel?.text == "Confirm URL"){
            buttonFind.setTitle("Visit URL", forState: UIControlState.Normal)
            
        }
        
        return true
        
    }

    @IBAction func inputFind(sender: AnyObject) {
        
        textFieldEnterLocation.resignFirstResponder()
        
        // If student is asked to confirm URL and button is pressed, submit student data to parse
        if(buttonFind.titleLabel?.text == "Confirm URL"){

            let userId = reqBody["uniqueKey"] as! String
            reqBody["mediaURL"] = textFieldEnterLocation.text
            
            parse.upsertStudentData(userId, studentUpdate: reqBody){ (error) -> Void in
                
                let msg = error == nil ? "Update Successful." : "Error updating data."
                
                dispatch_async(dispatch_get_main_queue(), {
                    let alertController = UIAlertController(title: msg, message: "", preferredStyle: UIAlertControllerStyle.Alert)
                    let action = UIAlertAction(title: "Back", style: UIAlertActionStyle.Default){(UIAlertAction) -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    alertController.addAction(action)
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
                
            }
        }
            
            
        // If the student is asked to visit the URL and the button is pressed, visit the URL and ask student to confirm URL
        else if(buttonFind.titleLabel?.text == "Visit URL"){
            
            let url = NSURL(string: textFieldEnterLocation.text!)!
            webView.loadRequest(NSURLRequest(URL: url))
            
            buttonFind.setTitle("Confirm URL", forState: UIControlState.Normal)
            
        }
            
        // If the student is asked to confirm the entered location and the button is pressed...
        else if(buttonFind.titleLabel?.text == "Confirm Location"){
            
            // ...change button text
            buttonFind.setTitle("Confirm URL", forState: UIControlState.Normal)
            
            // ...add location information to reqBody
            reqBody["latitude"] = mapView.region.center.latitude
            reqBody["longitude"] = mapView.region.center.longitude
            reqBody["mapString"] = textFieldEnterLocation.text
            
            // ...add website information to reqBody
            if reqBody["mediaURL"] as! String != "" {
                textFieldEnterLocation.text = reqBody["mediaURL"] as? String
            }else{
                textFieldEnterLocation.text = "https://www.google.com"
            }
            
            // ...switch to web view
            mapView.removeFromSuperview()
            webView = WKWebView(frame: containerBottom.frame)
            webView.center = CGPointMake(containerBottom.frame.width/2, containerBottom.frame.height/2)
            webView.navigationDelegate = self
            
            containerBottom.addSubview(webView)
            
            let url = NSURL(string: textFieldEnterLocation.text!)!
            webView.loadRequest(NSURLRequest(URL: url))
            webView.allowsBackForwardNavigationGestures = true
            
            labelOne.text = "What is"
            labelTwo.text = "your"
            labelThree.text = "website?"
            
        // If the student is asked to find his or her location on the map and the button is pressed, ask student to confirm the location or display an error message
        }else{

            textFieldEnterLocation.resignFirstResponder()
            
            if let inputText = textFieldEnterLocation.text {
                
                geoCoder.geocodeAddressString(inputText, completionHandler: { (placemark: [CLPlacemark]?, error: NSError?) -> Void in
                    
                    if let returnedLocation = placemark {
                        
                        self.buttonFind.setTitle("Confirm Location", forState: UIControlState.Normal)
                        
                        let pmCircularRegion = returnedLocation[0].region as! CLCircularRegion
                        let region = MKCoordinateRegionMakeWithDistance(pmCircularRegion.center, pmCircularRegion.radius, pmCircularRegion.radius)
                        
                        self.mapView.setRegion(region, animated: true)
                        
                    }else{
                        dispatch_async(dispatch_get_main_queue(), {
                            let alertController = UIAlertController(title: "Location Error", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                            alertController.addAction(UIAlertAction(title: "Could not find this location on the map.", style: UIAlertActionStyle.Default,handler: nil))
                            self.presentViewController(alertController, animated: true, completion: nil)
                        })
                    }
                })
            }
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup reqBody
        let studentId = udacity.getSession()["key"]!
        
        reqBody["uniqueKey"] = studentId
        reqBody["firstName"] = udacity.getUserData()["firstName"]!
        reqBody["lastName"] = udacity.getUserData()["lastName"]!
        
        if let userParseData = studentDataModel.getStudentInfo(studentId!) {
            reqBody["mapString"] = userParseData.mapString!
            reqBody["mediaURL"] = userParseData.mediaURL!
        }
        
        textFieldEnterLocation.placeholder = reqBody["mapString"] as? String
        textFieldEnterLocation.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
