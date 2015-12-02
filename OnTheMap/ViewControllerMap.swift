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
    
    let studentDataModel = studentModel.sharedInstance()
    let parse = Parse.sharedInstance()
    let udacity = Udacity.sharedInstance()

    // MARK: Outlets
    
    // Connection to button fixed after reading https://discussions.udacity.com/t/crashing-issues-when-running-app/26331
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        getStudentData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Functions
    
    func getStudentData(){
    
        parse.getLocations() { (error) -> Void in
            if (error != nil){

                dispatch_async(dispatch_get_main_queue(), {
                    
                    // Display error if student data cannot be retrieved
                    let alertController = UIAlertController(title: "Data Access Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "The student data could not be accessed", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }else{
                
                // Display student data if no error occurs
                var studentPinsArray: Array<studentPin> = []
                
                if let studentData = self.studentDataModel.getStudentData(){
                    
                    for student in studentData {
                        
                        // Setup student first and last name
                        let studentName = student.firstName! + " " + student.lastName!
                        
                        // Setup student study location
                        let studentCoord = CLLocationCoordinate2D(latitude: student.latitude!, longitude: student.longitude!)
                        
                        // Setup student URL
                        let studentSubtitle = student.mediaURL!
                        
                        // Show collected student information
                        let newStudentPin = studentPin(title: studentName, subtitle: studentSubtitle, coordinate: studentCoord)
                        studentPinsArray.append(newStudentPin)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    // Remove previous annotations
                    let annotationsToRemove = self.mapView.annotations.filter { _ in return true }
                    self.mapView.removeAnnotations( annotationsToRemove )
                    
                    // Add new annotations
                    self.mapView.addAnnotations(studentPinsArray)
                })
            }
        }
    }
    
    // Function for displaying student location
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            let studentAnnotation = annotation as! studentPin
            pinView = MKPinAnnotationView(annotation: studentAnnotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }else{
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // Function for responding to student tap
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
        }
    }
    
    // MARK: Actions
    
    @IBAction func mapLogout(sender: AnyObject) {
        
        // Logout from Facebook
        // Retrieved the code for logging out from Facebook from http://stackoverflow.com/questions/29374235/facebook-sdk-4-0-ios-swift-log-a-user-out-programatically
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        // Logout from Udacity
        udacity.logout(){() -> Void in
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ViewControllerLogin")
            self.presentViewController(controller, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func mapRefresh(sender: AnyObject) {
        
        // Retrieve current student data if refresh button is pressed
        getStudentData()

    }
    
    @IBAction func mapInput(sender: AnyObject) {
        
        // Show input view controller if input button is pressed
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ViewControllerInput")
        self.presentViewController(controller, animated: true, completion: nil)
        
    }

}
