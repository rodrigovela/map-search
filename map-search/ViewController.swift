//
//  ViewController.swift
//  map-search
//
//  Created by Rodrigo Velazquez on 16/02/17.
//  Copyright © 2017 Rodrigo Velazquez. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchText: UITextField!
    
    var user:String = ""
    var items2: [Dictionary<String, String>] = []
    var items: [String] = ["Hello","Yes","No"]
    let managerLocation = CLLocationManager()
    var flagToSearch = false
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let barViewControllers = segue.destination as! UITabBarController
        let nav = barViewControllers.viewControllers![1] as! UINavigationController
        let map = nav.topViewController as! MapViewController
        
        map.items2 = self.items2
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchText.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isHidden = true
        configLocationManager()
        
        if let myString = UserDefaults.standard.value(forKey: "userID") as? String {
            print("USER id: \(myString)")
        }
    }
    
    func configLocationManager()
    {
        self.managerLocation.delegate = self
        self.managerLocation.desiredAccuracy = kCLLocationAccuracyBest
        //self.managerLocation.requestAlwaysAuthorization()
        //self.managerLocation.requestWhenInUseAuthorization()
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if (authorizationStatus == CLAuthorizationStatus.notDetermined) {
            managerLocation.requestWhenInUseAuthorization()
        } else {
            managerLocation.startUpdatingLocation()
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items2.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "PlaceTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)as? PlaceTableViewCell  else {
            fatalError("The dequeued cell is not an instance of PlaceTableViewCell.")
        }
        //let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        
        cell.cellTitle.text = items2[indexPath.row]["nombre"]
        
        var textDetail = ""
        
        if items2[indexPath.row]["cod_d"] != "" {
            textDetail.append("D")
        }
        if items2[indexPath.row]["cod_f"] != "" {
            textDetail.append("F")
        }
        if items2[indexPath.row]["cod_w"] != "" {
            textDetail.append("W")
        }
        //cell.detailTextLabel?.text = "(\(items2[indexPath.row]["lat"]),\(items2[indexPath.row]["lon"]))"
        cell.cellDetail.text = textDetail
        //cell.detailTextLabel?.text = items2[indexPath.row]["nombre"]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)")
    }
    
    
    @IBAction func textFieldDoneEditing(_ sender: UITextField) {
        sender.resignFirstResponder()
        let query = searchText.text!
        print("\(query)")
        
        items2 = []
        
        let lat = managerLocation.location?.coordinate.latitude
        let lon = managerLocation.location?.coordinate.longitude
        
        let urlGeoserver = "http://148.204.66.28:8080/geoserver/opengeo/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=opengeo:locales&cql_filter=strToLowerCase(nom_principal)%20LIKE%20%27%25\(query)%25%27%20AND%20INTERSECTS(the_geom,%20BUFFER(POINT(\(lon!)%20\(lat!)),0.03))&maxFeatures=100&outputFormat=application%2Fjson"
        
        print("Coordenadas: \(lat!),\(lon!)")
        print(String(lat!))
        
        integrate(query)
        
        //search(urls: urlGeoserver)
        
    }

    @IBAction func backgroundTap(_ sender: UIControl){
        searchText.resignFirstResponder()
    }
    
    func search(urls: String) -> Void
    {
        
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
                            let json = try JSONSerialization.jsonObject(with: datos!, options: JSONSerialization.ReadingOptions.mutableLeaves)
                            let query = json as! NSDictionary
                            let geoserverList : [NSDictionary] = query["features"] as! NSArray as! Array
                            for place in geoserverList{
                                let infoG = place
                                let properties = infoG["properties"] as! NSDictionary
                                let nameG = properties["nom_principal"] as! NSString as String
                                let rate = properties["score"] as! Int
                                let nameA1 = properties["nom_alt1"] as! NSString as String
                                let nameA2 = properties["nom_alt2"] as! NSString as String
                                let cod_f = properties["cod_foursquare"] as! NSString as String
                                let cod_d = properties["cod_denue"] as! NSString as String
                                let cod_w = properties["cod_wikimapia"] as! NSString as String
                                let geometry = infoG["geometry"] as! NSDictionary
                                let coordinates = geometry["coordinates"] as! NSArray
                                let lngG = coordinates[0] as! Double
                                let latG = coordinates[1] as! Double
                                
                                let nuevo = ["nombre":nameG,"score":String(rate), "lat":String(latG),"lon":String(lngG),"nom_alt1":nameA1,"nom_alt2":nameA2,"cod_f":cod_f,"cod_d":cod_d,"cod_w":cod_w]
                                self.items2.append(nuevo)
                            }
                            
                            print(self.items2.count)
                            self.tableView.reloadData()
                            self.tableView.isHidden = false
                            
                            
                                                    }
                        catch _ {
                            print("No")}
                    }
                }
            }
            let dt = sesion.dataTask(with: url! as URL, completionHandler: bloque)
            dt.resume()
            print(items2.count)
        }
    }
    
    func integrate(_ query: String){
        
        let lat = managerLocation.location?.coordinate.latitude
        let lon = managerLocation.location?.coordinate.longitude
        
        let url = NSURL(string: "http://148.204.66.28/server/python.php")
        let request = NSMutableURLRequest(url: url! as URL)
        
        request.httpMethod = "POST"
        
        let postString = "query=\(query)&lat=\(lat!)&lon=\(lon!)"
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("Error: \(error)")
            }
            
            do {
                
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as? NSDictionary
                
                if let parseJSON = json {
                    
                    let resultValue = parseJSON["status"] as!  String!
                    let messageValue = parseJSON["message"] as! String!
                    
                    DispatchQueue.main.async{
                        if resultValue=="success" {
                            self.flagToSearch = true
                            print("true")
                        }
                         let urlGeoserver = "http://148.204.66.28:8080/geoserver/opengeo/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=opengeo:locales&cql_filter=strToLowerCase(nom_principal)%20LIKE%20%27%25\(query.replacingOccurrences(of: " ", with: "%20"))%25%27%20AND%20INTERSECTS(the_geom,%20BUFFER(POINT(\(lon!)%20\(lat!)),0.03))&maxFeatures=100&outputFormat=application%2Fjson"
                        self.search(urls: urlGeoserver)
                    }
                    print("message : \(messageValue)")
                }
                
            }
            catch _ {
                print("Error :\(error)")
            }
        }
        task.resume()
    }
    
    @IBAction func signOutButton(_ sender: Any) {
        
        UserDefaults.standard.set(false, forKey: "userSignedIn")
        UserDefaults.standard.synchronize()
        
        //performSegue(withIdentifier: "signInSegue", sender: self)
        //self.dismiss(animated: false, completion: nil)
        self.dismiss(animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "login") 
        self.present(vc, animated: true, completion: nil)
        
    }

}

