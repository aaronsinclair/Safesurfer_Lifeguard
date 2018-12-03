//
//  LIfeguardViewController.swift
//  Lifeguard
//
//  Created by Aaron Sinclair on 8/05/18.
//  Copyright © 2018 Aaron Sinclair. All rights reserved.
//

import UIKit
import Alamofire

class LifeguardViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailOutlet: UITextField!
    
    @IBOutlet weak var passwordOutlet: UITextField!
    
    @IBAction func forgotPassword(_ sender: Any) {
        
        let parameters: [String: String] = ["ip" : "9.9.9.9"]
        
        
        let url = "http://" + lifeguardDeviceObject.deviceArray[lifeguardDeviceObject.deviceSelected] + ".local/ajax/forgotPassword.php/post"
        
        Alamofire.request(url, method: .post, parameters: parameters).response { response in
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                let alert = UIAlertController(title: "Password Recovery", message: utf8Text, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "continue", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
            
        }
        
    }
    
    @IBAction func backToDeviceList(_ sender: Any) {
         self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func loginAction(_ sender: Any) {
        
        if (emailOutlet.text?.isEmpty)! {
            let alert = UIAlertController(title: "Email address is empty", message: "Please enter your login email address", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "continue", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        if (passwordOutlet.text?.isEmpty)! {
            let alert = UIAlertController(title: "Password is empty", message: "Please enter your password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "continue", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        if  !lifeguardDeviceObject.deviceArray.indices.contains(lifeguardDeviceObject.deviceSelected) {
            
            let alert = UIAlertController(title: "Lifeguard Device Went Away", message: "We lost connection to the Lifeguard Device 😰", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "continue", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
            
        }
        
        
        
        let parameters: [String: String] = [
            "email" : emailOutlet.text!,
            "password" : passwordOutlet.text!
        ]
        
        
        let url = "http://" + lifeguardDeviceObject.deviceArray[lifeguardDeviceObject.deviceSelected] + ".local/ios/loginCheck.php/post"
        
        Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in
            print(response)
            if let json = response.result.value {
                let jsonResponse:Dictionary = json as! Dictionary<String, Any>
                if(jsonResponse["1"] as! String == "Success") {
                    print("Successfull logon")
                    
                    
                    let defaults = UserDefaults.standard
                    defaults.set(self.emailOutlet.text, forKey: "email")
                    defaults.set(self.passwordOutlet.text, forKey: "password")
                    self.performSegue(withIdentifier: "showWebView", sender: self)
                    
                    
                    
                }
                    
                else {
                    
                    self.alertCouldNotAuthenticate()
                }
                
            } else {
                self.alertCouldNotConnect()
            }
        }
        
        
    }
    
    
    func alertCouldNotConnect() {
        let alert = UIAlertController(title: "Could not connect to device", message: "Please try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "continue", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        return
        
    }
    
    func alertCouldNotAuthenticate() {
        let alert = UIAlertController(title: "Could not authenticate", message: "Please check your Email and Pasword before trying again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "continue", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        return
    }
    
    
    func textFieldShouldReturn(_ userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        return true
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        emailOutlet.keyboardType = UIKeyboardType.emailAddress
        
        
        self.emailOutlet.delegate = self
        self.passwordOutlet.delegate = self
        let defaults = UserDefaults.standard
        if let savedEmail = defaults.string(forKey: "email"), let savedPassword = defaults.string(forKey: "password")  {
            print(savedEmail)
            print(savedPassword)
            
            emailOutlet.text = savedEmail
            passwordOutlet.text = savedPassword
            
            let parameters: [String: String] = [
                "email" : savedEmail,
                "password" : savedPassword
                
            ]
            
            let url = "http://" + lifeguardDeviceObject.deviceArray[lifeguardDeviceObject.deviceSelected] + ".local/ios/loginCheck.php/post"
            
            Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in
                print(response)
                if let json = response.result.value {
                    let jsonResponse:Dictionary = json as! Dictionary<String, Any>
                    if(jsonResponse["1"] as! String == "Success") {
                        print("Successfull logon")
                        // performSegue(withIdentifier: "showWebView", sender: Any)
                        // self.performSegue(withIdentifier: "showWebView", sender: self)
                    }
                    
                }
            }
            
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
