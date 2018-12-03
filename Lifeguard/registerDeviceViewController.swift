//
//  registerDeviceViewController.swift
//  bonjourtest
//
//  Created by Aaron Sinclair on 7/05/18.
//  Copyright © 2018 Aaron Sinclair. All rights reserved.
//

import UIKit
import WebKit

class registerDeviceViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    @IBOutlet weak var registerWebView: WKWebView!
    //@IBOutlet weak var registerWebView: WKWebView!
    var webviewTimer = Timer()
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            print("JavaScript is sending a message \(message.body)")
            // self.dismiss(animated: true, completion: {});
            //self.navigationController?.popToRootViewController(animated: true);
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        
        if (message.name == "deviceRegistered") {
            print("JavaScript is sending a message \(message.body)")
            
            let jsonText:String = message.body as! String
            if let jsonData = jsonText.data(using: String.Encoding.utf8) {
                let decoder = JSONDecoder()
                
                
                let response = try? decoder.decode(Dictionary<String,String>.self, from: jsonData)
                print(response!["email"]!)
                print(response!["password"]!)
                
                let defaults = UserDefaults.standard
                defaults.set(response!["email"], forKey: "email")
                defaults.set(response!["password"], forKey: "password")
                
                
            }
            
            /*
             if let dataFromString = (message.body as AnyObject).data() {
             let json = JSON(data: dataFromString)
             if let status = json["status"].string {
             print("status: \(status)")
             }
             }
             */
            
            
            // let json = JSON(data: message.body)
            //let decoder = JSONDecoder()
            //let response = try decoder.decode(Dictionary<String,String>, from: json)
            //let jsonResponse: InputStream = message.body as! InputStream;
            //let json = try? JSONSerialization.jsonObject(with: jsonResponse)
            //print(json)
        }
        
    }
    
    @objc func lifeguardConected() {
        if  !lifeguardDeviceObject.deviceArray.indices.contains(lifeguardDeviceObject.deviceSelected) {
            
            let alert = UIAlertController(title: "Lifeguard Device Went Away", message: "We lost connection to the Lifeguard Device 😰", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "continue", style: .cancel, handler: { action in
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                
            }))
            self.present(alert, animated: true)
            
            return
            
        }
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        // Inject JavaScript which sending message to App
        //let js: String = "document.getElementById('note').innerHTML = 'script from swift'; window.webkit.messageHandlers.callbackHandler.postMessage('Hello from JavaScript');"
        //let userScript = WKUserScript(source: js, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false)
        //contentController.removeAllUserScripts()
        //contentController.addUserScript(userScript)
        // Add ScriptMessageHandler
        contentController.add(
            self,
            name: "callbackHandler"
        )
        
        contentController.add(
            self,
            name: "deviceRegistered"
        )
        
        webConfiguration.userContentController = contentController
        
        registerWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        registerWebView.uiDelegate = self
        registerWebView.navigationDelegate = self
        view = registerWebView
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear( animated )
        webviewTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(registerDeviceViewController.lifeguardConected), userInfo: nil, repeats: true)
        
        let url:URL = URL(string: "http://" + lifeguardDeviceObject.deviceArray[lifeguardDeviceObject.deviceSelected] + ".local/registerDevice_www.php")!
        let request = NSMutableURLRequest(url: url)
        //request.httpMethod = "POST"
        //request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        //let defaults = UserDefaults.standard
        //let post: String = "email=" + defaults.string(forKey: "email")! + "&password=" + defaults.string(forKey: "password")!
        //let postData: NSData = post.data(using: String.Encoding.ascii, allowLossyConversion: true)! as NSData
        //request.httpBody = postData as Data
        
        registerWebView.load(request as URLRequest)
        
        
        
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
