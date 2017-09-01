//
//  TabBarController.swift
//  map-search
//
//  Created by Rodrigo Velazquez on 15/03/17.
//  Copyright © 2017 Rodrigo Velazquez. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    var user:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        /*let userSignedIn = UserDefaults.standard.bool(forKey: "userSignedIn")
        print("UserSignedIn: \(userSignedIn)")
        if(!userSignedIn){
            self.performSegue(withIdentifier: "signInSegue", sender: self)
        }
        */
    }
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        
        let isPressentingbyNavigationController = presentingViewController is UINavigationController
        
        if isPressentingbyNavigationController {
            dismiss(animated: true, completion: nil)
            UserDefaults.standard.set(false, forKey: "userSignedIn")
            UserDefaults.standard.synchronize()
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
