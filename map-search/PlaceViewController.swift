//
//  PlaceViewController.swift
//  map-search
//
//  Created by Rodrigo Velazquez on 04/09/17.
//  Copyright © 2017 Rodrigo Velazquez. All rights reserved.
//

import UIKit

class PlaceViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var alternative1Label: UILabel!
    @IBOutlet weak var alternative2Label: UILabel!
    @IBOutlet weak var denueCodeLabel: UILabel!
    @IBOutlet weak var foursquareCodeLabel: UILabel!
    @IBOutlet weak var googleCodeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingControl: RatingControl!
    
    var place:Place?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let place = place {
            nameLabel.text = place.principalName
            alternative1Label.text = place.alternativeName
            alternative2Label.text = place.alternativeName2
            denueCodeLabel.text = place.denueCode
            foursquareCodeLabel.text = place.foursquareCode
            googleCodeLabel.text = place.googleCode
            distanceLabel.text = String(place.distance) + " Km"
            ratingControl.rating = place.rating
        }
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
