//
//  LogInController.swift
//  map-search
//
//  Created by Rodrigo Velazquez on 15/03/17.
//  Copyright © 2017 Rodrigo Velazquez. All rights reserved.
//

import UIKit

class LogInController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func textFieldDoneEditing(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func tapBackground(_ sender: UIControl){
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    @IBAction func signInButton(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        //Check Empty fields
        
        if(email.isEmpty || password.isEmpty){
            displayAlertMessage("Missing empty fields")
            return
        }
        
        requestToServer(email, password: password)
    }
    func requestToServer(_ email:String, password:String) {
        
        let url = NSURL(string:"http://148.204.66.28/server/userLogin.php")
        let request = NSMutableURLRequest(url: url! as URL)
        
        request.httpMethod = "POST"
        
        let postString = "email=\(email)&password=\(password)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                if let parseJSON = json {
                    
                    let resultValue = parseJSON["status"] as! String!
                    print("result : \(resultValue)")
                    
                    var userValue = parseJSON["user"] as! String!
                    print("UserValue: \(userValue)")
                    
                    if(resultValue! == "Success") {
                        
                        print("entra")
                        //Login is Succesfull
                        UserDefaults.standard.set(true, forKey: "userSignedIn")
                        UserDefaults.standard.set(userValue!, forKey: "userID")
                        UserDefaults.standard.synchronize()
                        //
                        DispatchQueue.main.async{
                            
                            func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
                                let sigVista = segue.destination as! TabBarController
                                sigVista.user = userValue!
                            }
                            self.performSegue(withIdentifier: "tabBarSegue", sender: self)
                        }
                    }
                }
            }
            catch _{
                print(error)
                
            }
            
            
        }
        task.resume()
    }
    func displayAlertMessage(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
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
