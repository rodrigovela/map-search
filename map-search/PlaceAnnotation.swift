//
//  PlaceAnnotation.swift
//  map-search
//
//  Created by Rodrigo Velazquez on 04/09/17.
//  Copyright © 2017 Rodrigo Velazquez. All rights reserved.
//
import MapKit
import UIKit

class PlaceAnnotation:NSObject, MKAnnotation {

    var title: String?
    var category: String
    var rating: Int
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, category: String, rating: Int, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.category = category
        self.rating = rating
        self.coordinate = coordinate
        
        super.init()
    }
    
    
    var subtitle: String? {
        return category
    }
    
    func pinColor() -> UIColor?  {
        switch rating {
        case 3:
            return UIColor.red
        case 2: 
            return UIColor.brown
        default:
            return UIColor.orange
        }
        
    }
    // MARK: Car Indications
    func mapItem() ->MKMapItem {
        // Create a PlaceMark for Maps App
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        // Create a PlaceMark -> MapItem
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        // Return MapItem
        return mapItem
    }

}
