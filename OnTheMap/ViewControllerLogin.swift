//
//  ViewController.swift
//  OnTheMap
//
//  Created by Timo Krall on 11/28/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import UIKit

class ViewControllerLogin: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var buttonSignInFacebook: UIButton!
    @IBOutlet weak var buttonSignInUdacity: UIButton!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var labelLoginInformation: UILabel!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Actions
    
    @IBAction func loginActionUdacity(sender: AnyObject) {
    }

    
    @IBAction func loginActionFacebook(sender: AnyObject) {
    }
    
    // MARK: Functions
    
    
    
}