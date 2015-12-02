//
//  ViewControllerMap.swift
//  OnTheMap
//
//  Created by Timo Krall on 11/29/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import UIKit
import MapKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewControllerMap: UIViewController, MKMapViewDelegate {

    // MARK: Variables
    
    let userDataModel = userModel.sharedInstance()
    let parse = Parse.sharedInstance()
    let udacity = Udacity.sharedInstance()

    // MARK: Outlets
    
    // Connection to button fixed after reading https://discussions.udacity.com/t/crashing-issues-when-running-app/26331
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        getUserData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Functions
    
    func getUserData(){
    
        parse.getLocations() { (error) -> Void in
            if (error != nil){

                dispatch_async(dispatch_get_main_queue(), {
                    
                    // Display error if user data cannot be retrieved
                    let alertController = UIAlertController(title: "Data Access Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "The user data could not be accessed", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }else{
                
                // Display user data if no error occurs
                var userPinsArray: Array<userPin> = []
                
                if let userData = self.userDataModel.getUserData(){
                    
                    for user in userData {
                        
                        // Setup user first and last name
                        let userName = user.firstName! + " " + user.lastName!
                        
                        // Setup user study location
                        let userCoord = CLLocationCoordinate2D(latitude: user.latitude!, longitude: user.longitude!)
                        
                        // Setup user URL
                        let userSubtitle = user.mediaURL!
                        
                        // Show collected user information
                        let newUserPin = userPin(title: userName, subtitle: userSubtitle, coordinate: userCoord)
                        userPinsArray.append(newUserPin)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    // Remove previous annotations
                    let annotationsToRemove = self.mapView.annotations.filter { _ in return true }
                    self.mapView.removeAnnotations( annotationsToRemove )
                    
                    // Add new annotations
                    self.mapView.addAnnotations(userPinsArray)
                })
            }
        }
    }
    
    // Function for displaying user location
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            let userAnnotation = annotation as! userPin
            pinView = MKPinAnnotationView(annotation: userAnnotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }else{
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // Function for responding to user tap
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
        }
    }
    
    // MARK: Actions
    
    @IBAction func mapLogout(sender: AnyObject) {
        
        // Logout from Facebook
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        // Logout from Udacity
        udacity.logout(){() -> Void in
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ViewControllerLogin")
            self.presentViewController(controller, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func mapRefresh(sender: AnyObject) {
        
        // Retrieve current user data if refresh button is pressed
        getUserData()

    }
    
    @IBAction func mapInput(sender: AnyObject) {
        
        // Show input view controller if input button is pressed
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ViewControllerInput")
        self.presentViewController(controller, animated: true, completion: nil)
        
    }

}
