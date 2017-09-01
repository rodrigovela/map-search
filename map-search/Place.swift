//
//  Place.swift
//  map-search
//
//  Created by Rodrigo Velazquez on 28/08/17.
//  Copyright © 2017 Rodrigo Velazquez. All rights reserved.
//

import UIKit
import CoreLocation
class Place {
    
    // MARK: Properties
    
    var principalName: String
    var alternativeName: String
    var alternativeName2: String
    var latitude: Double
    var longitude: Double
    var rating: Int
    var googleCode: String
    var denueCode: String
    var foursquareCode: String
    var distance: Double = 0.0
    
    
    // MARK: Initialization
    
    init?(principal: String, alternative1: String, alternative2: String, latitude: Double, longitude: Double, rating: Int, denueCode: String, foursquareCode: String, googleCode: String, distance: Double) {
        
        guard !principal.isEmpty else {
            return nil
        }
        
        guard (rating >= 1) && (rating <= 3) else {
            return nil
        }
        
        self.principalName = principal
        self.alternativeName = alternative1
        self.alternativeName2 = alternative2
        self.latitude = latitude
        self.longitude = longitude
        self.rating = rating
        self.denueCode = denueCode
        self.googleCode = googleCode
        self.foursquareCode = foursquareCode
        self.distance = distance
    }
}
