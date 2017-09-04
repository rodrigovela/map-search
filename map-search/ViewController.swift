//
//  ViewController.swift
//  map-search
//
//  Created by Rodrigo Velazquez on 16/02/17.
//  Copyright © 2017 Rodrigo Velazquez. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: Properties 
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var keywordSwitch: UISwitch!
    
    var places = [Place]()
    
    var location = true
    var urlGeoserver = ""
    var categorySelected = 1
    var catTag = "cine"
    var user:String = ""
    
    let managerLocation = CLLocationManager()
    var flagToSearch = Bool()
    
    let categories = ["Cine","Comida rápida","Gasolineras","Bancos","Estaciones Metro","Tiendas de Conveniencia"]
    let categoriesTag = ["cine","comida%20rapida","gasolineras","bancos","estaciones%20metro","tiendas%20de%20conveniencia"]
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        /*let tabBarController = segue.destination as! UITabBarController
        let navigationController = tabBarController.viewControllers![1] as! UINavigationController
        let mapViewController = navigationController.topViewController as! MapViewController
        
        mapViewController.places = places*/
        
        guard let placeDetailViewController = segue.destination as? PlaceViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        guard  let selectedPlaceCell = sender as? PlaceTableViewCell else {
            fatalError("unexpected sender: \(sender.debugDescription)")
        }
        
        guard let indexPath = tableView.indexPath(for: selectedPlaceCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }
        
        let selectedPlace = places[indexPath.row]
        placeDetailViewController.place = selectedPlace
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        configLocationManager()
        navigationItem.title = "Search"
        categoryPickerView.dataSource = self
        categoryPickerView.delegate = self
        searchText.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isHidden = true
        
        
        if let myString = UserDefaults.standard.value(forKey: "userID") as? String {
            print("USER id: \(myString)")
        }
    }
    
    private func configLocationManager()
    {
        self.managerLocation.delegate = self
        self.managerLocation.desiredAccuracy = kCLLocationAccuracyBest

        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if (authorizationStatus == CLAuthorizationStatus.notDetermined) {
            managerLocation.requestWhenInUseAuthorization()
        }
        else if(authorizationStatus == CLAuthorizationStatus.denied){
            managerLocation.requestWhenInUseAuthorization()
        }
        else {
            managerLocation.startUpdatingLocation()
        }
    }

    
    // MARK: UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "PlaceTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)as? PlaceTableViewCell  else {
            fatalError("The dequeued cell is not an instance of PlaceTableViewCell.")
        }
        //let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        
        cell.cellTitle.text = places[indexPath.row].principalName
        
        var textDetail = ""
        
        if places[indexPath.row].denueCode != "" {
            textDetail.append("D")
        }
        if places[indexPath.row].foursquareCode != "" {
            textDetail.append("F")
        }
        if places[indexPath.row].googleCode != "" {
            textDetail.append("G")
        }
        //cell.detailTextLabel?.text = "(\(items2[indexPath.row]["lat"]),\(items2[indexPath.row]["lon"]))"
        cell.cellDetail.text = textDetail
        //cell.detailTextLabel?.text = items2[indexPath.row]["nombre"]
        cell.distanceLabel.text = String(places[indexPath.row].distance)
        cell.ratingControl.rating = places[indexPath.row].rating
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)")
    }
    
    // MARK: Actions
    
    @IBAction func go(_ sender: Any) {
        
        flagToSearch = false
        let query = searchText.text!
        
        
        places = []
        
        let lat = managerLocation.location?.coordinate.latitude
        let lon = managerLocation.location?.coordinate.longitude
        
        if(keywordSwitch.isOn){
        urlGeoserver = "http://148.204.66.28:8080/geoserver/opengeo/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=opengeo:locales&cql_filter=strToLowerCase(nom_principal)%20LIKE%20%27%25\(query.replacingOccurrences(of: " ", with: "%20"))%25%27%20AND%20INTERSECTS(the_geom,%20BUFFER(POINT(\(lon!)%20\(lat!)),0.03))%20AND%20categoria%20LIKE%20%27\(catTag)%27&maxFeatures=100&outputFormat=application%2Fjson"
        }
        else{
            urlGeoserver = "http://148.204.66.28:8080/geoserver/opengeo/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=opengeo:locales&cql_filter=INTERSECTS(the_geom,%20BUFFER(POINT(\(lon!)%20\(lat!)),0.03))%20AND%20categoria%20LIKE%20%27\(catTag)%27&maxFeatures=100&outputFormat=application%2Fjson"
        }
        search(urls: urlGeoserver)
    }
    
    @IBAction func backgroundTap(_ sender: UIControl){
        searchText.resignFirstResponder()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    /*@IBAction func textFieldDoneEditing(_ sender: UITextField) {
        sender.resignFirstResponder()
        /*
        let query = searchText.text!
        print("\(query)")
        self.flagToSearch = false
        items2 = []
        
        let lat = managerLocation.location?.coordinate.latitude
        let lon = managerLocation.location?.coordinate.longitude
        
        self.urlGeoserver = "http://148.204.66.28:8080/geoserver/opengeo/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=opengeo:locales&cql_filter=strToLowerCase(nom_principal)%20LIKE%20%27%25\(query.replacingOccurrences(of: " ", with: "%20"))%25%27%20AND%20INTERSECTS(the_geom,%20BUFFER(POINT(\(lon!)%20\(lat!)),0.03))&maxFeatures=100&outputFormat=application%2Fjson"
        search(urls: self.urlGeoserver)
        
        //integrate(query)
        
        //search(urls: urlGeoserver)
        */
    }*/

    
    
    /*@IBAction func signOutButton(_ sender: Any) {
        
        UserDefaults.standard.set(false, forKey: "userSignedIn")
        UserDefaults.standard.synchronize()
        
        //performSegue(withIdentifier: "signInSegue", sender: self)
        //self.dismiss(animated: false, completion: nil)
        self.dismiss(animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "login")
        self.present(vc, animated: true, completion: nil)
        
    }*/
    // MARK: Private Methods
    
    private func search(urls: String) -> Void
    {
        //self.items2 = []
        //self.tableView.reloadData()
        
        let url = NSURL(string: urls)
        if url != nil{
        let sesion = URLSession.shared
        let bloque = { (datos:Data?, resp: URLResponse?, error: Error?) -> Void in
                let text = NSString(data: datos! as Data, encoding: String.Encoding.utf8.rawValue)
                print(error.debugDescription)
                print(text!)
                
                if error == nil {
                    DispatchQueue.main.async{
                        
                        do{
                            let userLocation = CLLocation(latitude: (self.managerLocation.location?.coordinate.latitude)!, longitude: (self.managerLocation.location?.coordinate.longitude)!)
                            let json = try JSONSerialization.jsonObject(with: datos!, options: JSONSerialization.ReadingOptions.mutableLeaves)
                            let query = json as! NSDictionary
                            let geoserverList : [NSDictionary] = query["features"] as! NSArray as! Array
                            for point in geoserverList{
                                
                                let properties = point["properties"] as! NSDictionary
                                let nameG = properties["nom_principal"] as! NSString as String
                                let score = properties["score"] as! Int
                                let nameA1 = properties["nom_alt1"] as! NSString as String
                                let nameA2 = properties["nom_alt2"] as! NSString as String
                                let cod_f = properties["cod_foursquare"] as! NSString as String
                                let cod_d = properties["cod_denue"] as! NSString as String
                                let cod_g = properties["cod_google"] as! NSString as String
                                let geometry = point["geometry"] as! NSDictionary
                                let coordinates = geometry["coordinates"] as! NSArray
                                let lngG = coordinates[0] as! Double
                                let latG = coordinates[1] as! Double
                                let location = CLLocation(latitude: latG, longitude: lngG)
                                let distance = (userLocation.distance(from: location) * 100).rounded() / 100
                        
                                let place: Place? = Place(principal: nameG, alternative1: nameA1, alternative2: nameA2, latitude: latG, longitude: lngG, rating: score, denueCode: cod_d, foursquareCode: cod_f, googleCode: cod_g, distance: distance)
                                self.places.append(place!)
                            }
                            self.places.sort(by: {(Place,Place2) -> Bool
                            in
                                if Place.distance < Place2.distance {
                                    return true
                                } else {
                                    return false
                                }
                            }
                            )
                            self.tableView.reloadData()
                            self.tableView.isHidden = false
                            
                            
                            
                                                    }
                        catch _ {
                            fatalError("HTTP request fails")
                        }
                        
                        if self.places.count <= 5 && !self.flagToSearch {
                    
                            self.integrate()
                            self.flagToSearch = true
                            
                        }
                    }
                }
            }
            let dt = sesion.dataTask(with: url! as URL, completionHandler: bloque)
            dt.resume()
            print(places.count)
        }
    }
    
    private func integrate(){
        
        let lat = managerLocation.location?.coordinate.latitude
        let lon = managerLocation.location?.coordinate.longitude
        
        let url = NSURL(string: "http://148.204.66.28/server/python.php")
        let request = NSMutableURLRequest(url: url! as URL)
        
        request.httpMethod = "POST"
        
        let postString = "category=\(categorySelected)&lat=\(lat!)&lon=\(lon!)"
        print(postString)
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if let messageError = error {
                print("Error register:\(messageError)")
                return
            }
            
            do {
                
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as? NSDictionary
                
                if let parseJSON = json {
                    
                    print(parseJSON)
                    let resultValue = parseJSON["status"] as!  String!
                    let messageValue = parseJSON["message"] as! String!
                    
                    DispatchQueue.main.async{
                        if resultValue=="success" {
                            print("true")
                        }
                        self.search(urls: self.urlGeoserver)
                    }
                    print("message : \(messageValue!)")
                }
                
            }
            catch _ {
                print("Error : \(error ?? "Break" as! Error)")
            }
        }
        task.resume()
    }
    
    
    
    // MARK: UIPickerViewDelegate 
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categorySelected = row + 1
        catTag = categoriesTag[row]
        return
    }

}

