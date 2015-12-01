//
//  userPin.swift
//  OnTheMap
//
//  Created by Timo Krall on 11/30/15.
//  Copyright © 2015 Timo Krall. All rights reserved.
//

import Foundation
import MapKit

class userPin: NSObject, MKAnnotation {
// Class added after looking up https://github.com/RP-3/OnTheMap-Submission
    
    // MARK: Variables
    
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    // MARK: Pin
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D){
    
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        super.init()
        
    
    }
    
}
