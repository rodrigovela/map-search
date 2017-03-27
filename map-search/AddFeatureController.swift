//
//  AddFeatureController.swift
//  map-search
//
//  Created by Rodrigo Velazquez on 16/03/17.
//  Copyright © 2017 Rodrigo Velazquez. All rights reserved.
//

import UIKit
import CoreLocation

class AddFeatureController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var featureTextField: UITextField!
    @IBOutlet weak var latitudLabel: UILabel!
    @IBOutlet weak var longitudLabel: UILabel!
    
    @IBOutlet weak var categoryPickerView: UIPickerView!
    
    var user:String? = nil
    let category = ["Restaurant","Cine","Comida"]
    let managerLocation = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configLocationManager()
        self.featureTextField.delegate = self
        self.categoryPickerView.delegate = self
        self.categoryPickerView.dataSource = self
        
        user = UserDefaults.standard.value(forKey: "userID") as! String?
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
 
    
    @IBAction func textFieldDoneEditing(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func addButton(_ sender: Any) {
        
        let featureName = featureTextField.text!
        if featureName.isEmpty {
            displayAlertMessage("Empty name")
            return
        }
    }
    
    @IBAction func tapBackground(_ sender: UIControl) {
        self.featureTextField.resignFirstResponder()
    }
    
    //PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return category.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return category[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        return
    }
    
    //Alert
    
    func displayAlertMessage(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }

    //LocationManager
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            managerLocation.startUpdatingLocation()
        }
        else {
            print("No")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0] as CLLocation
        
        latitudLabel.text = String(userLocation.coordinate.latitude)
        longitudLabel.text = String(userLocation.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        displayAlertMessage(error.localizedDescription)
    }
    
    func upload() {
        
        let url = NSURL(string:"")
        let request = NSMutableURLRequest(url: url! as URL)
        
        request.httpMethod = "POST"
        let postString = "name=&category=&lat=&lon=user&"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            data, response, error in
            
            if error != nil {
                print("error: \(error)")
                return
            }
            
            do {
                
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as? NSDictionary
                
                
                if let parseJSON = json {
                    
                    let resultValue = parseJSON["status"] as! String!
                    
                    var messageToDisplay = parseJSON["status"] as! String!
                    
                    DispatchQueue.main.async {
                        self.displayAlertMessage(messageToDisplay!)
                    }
                }
                
                
            }
            catch _{
                print(error)
            }
            
        }
        task.resume()
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