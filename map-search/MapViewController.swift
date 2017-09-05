//
//  MapViewController.swift
//  map-search
//
//  Created by Rodrigo Velazquez on 16/02/17.
//  Copyright © 2017 Rodrigo Velazquez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AddressBook

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    // MARK: Properties
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var centerMyLocationButton: UIButton!
    let locationManager = CLLocationManager()
    var places = [Place]()

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
       
        configMap()
        configLocationManager()
        centerUserLocation()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Retrieve data from other view
        let search:ViewController = self.tabBarController?.viewControllers![0] as! ViewController
        places = search.places
        
        // Add annotation
        //addAnnotations()
    }
    

    // MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
        
        if status == .authorizedWhenInUse{
            map.showsUserLocation = true
            locationManager.startUpdatingLocation()
            print("yes")
        }
        else{
            map.showsUserLocation = false
            print("no")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "ERROR", message: error.localizedDescription, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default, handler: {
            action in
        })
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    }
    
    // MARK: MapViewDelegate
    
    // Add Annotations 
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        addAnnotations()
    }
    
    //
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Determine the selected location
        let location = view.annotation as! PlaceAnnotation
        // Options for maps
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        // Return mapItem with base in placemark for pass to "Maps App"
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
    // Custom Annotations
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? PlaceAnnotation {
            let identifier = "pin"
            let pin = UIImage(named: "point")
            var annotationView: MKPinAnnotationView
            if let dequeueView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeueView.annotation = annotation
                annotationView = dequeueView
            }
            else {
                
                let ratingControl = RatingControl()
                ratingControl.itemSize = CGSize(width: 20, height: 20)
                ratingControl.isUserInteractionEnabled = false
                ratingControl.rating = annotation.rating
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView.canShowCallout = true
                annotationView.calloutOffset = CGPoint(x: -5, y: 5)
                
                annotationView.rightCalloutAccessoryView = UIButton.init(type: .detailDisclosure) as? UIView
                //annotationView.leftCalloutAccessoryView = ratingControl as? UIView
                //annotationView.leftCalloutAccessoryView = UIImageView(image: pin)
                //annotationView.detailCalloutAccessoryView = ratingControl
                
                annotationView.pinTintColor = annotation.pinColor()
            }
            return annotationView
        }
        
            return nil
        
        
    }
    
    // MARK: IBActions
    
    
    @IBAction func showUserLocation(_ sender: UIButton) {
        centerUserLocation()
    }
    
    // MARK: Private Methods
    
    private func configMap(){
        map.delegate = self
        map.mapType = MKMapType.standard
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.showsUserLocation = true
    }
    
    private func configLocationManager()
    {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if (authorizationStatus == CLAuthorizationStatus.notDetermined) {
            locationManager.requestWhenInUseAuthorization()
        }else if(authorizationStatus == CLAuthorizationStatus.denied){
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    private func configAnnotation(location: CLLocationCoordinate2D, title: String, subtitle: String) -> MKPointAnnotation {
        
        let customAnnotation: MKPointAnnotation = MKPointAnnotation()
        
        customAnnotation.coordinate = location
        customAnnotation.title = title
        customAnnotation.subtitle = subtitle
        
        return customAnnotation
        
    }
    
    private func centerUserLocation() {
        let regionRadius: CLLocationDistance = 4000
        let userLocation = CLLocation(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, regionRadius, regionRadius)
        map.setRegion(region, animated: true)
    }
    
    
    
   
    
    private func addAnnotations () {
        
        map.removeAnnotations(map.annotations)
        if !places.isEmpty {
            for row in places{
                
                var marker = CLLocationCoordinate2D()
                marker.latitude = Double(row.latitude)
                marker.longitude = Double(row.longitude)
                
                //let point = configAnnotation(location: marker, title: row.principalName, subtitle: String(row.rating))
                let alternative: String
                
                if row.alternativeName != "" {
                    alternative = row.alternativeName
                }else {
                    alternative = row.alternativeName2
                }
                
                let pointPin = PlaceAnnotation(title: row.principalName, category: alternative, rating: row.rating, coordinate: marker)
                /*
                let pin = MKPointAnnotation()
                pin.title = row.principalName
                pin.subtitle = "\(row.latitude) & \(row.longitude)"
                //pin.subtitle = "(\(userlocation.coordinate.latitude),\(userlocation.coordinate.longitude))"
                pin.coordinate = marker
                
                //let customPinAnnotation = MKPinAnnotationView(annotation: point, reuseIdentifier: "pin")
                //map.addAnnotation(customPinAnnotation.annotation!)*/
                map.addAnnotation(pointPin)
            }

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
