//
//  lifeguardWebView.swift
//  Lifeguard
//
//  Created by Aaron Sinclair on 8/05/18.
//  Copyright © 2018 Aaron Sinclair. All rights reserved.
//

import UIKit
import WebKit

class lifeguardWebView: UIViewController,  WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    /* func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
     <#code#>
     } */
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            print("JavaScript is sending a message \(message.body)")
            // self.dismiss(animated: true, completion: {});
            //self.navigationController?.popToRootViewController(animated: true);
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        //present(alertController, animated: true, completion: nil)
        
        
        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = self.view
        }
        
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    var webviewTimer = Timer()
    @IBOutlet weak var webview: WKWebView!
    
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
        
        webConfiguration.userContentController = contentController
        
        webview = WKWebView(frame: .zero, configuration: webConfiguration)
        webview.uiDelegate = self
        webview.navigationDelegate = self
        view = webview
        
        /*
         URLCache.shared.removeAllCachedResponses()
         URLCache.shared.diskCapacity = 0
         URLCache.shared.memoryCapacity = 0
         */
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear( animated )
        webviewTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(lifeguardWebView.lifeguardConected), userInfo: nil, repeats: true)
        
        /*
         let url:URL = URL(string: "http://" + lifeguardDeviceObject.deviceArray[lifeguardDeviceObject.deviceSelected] + "/ios/loginCheck.php/post")!
         var urlRequest:URLRequest = URLRequest(url: url)
         urlRequest.httpMethod = "POST"
         webview.load(urlRequest)
         */
        
        //let url = NSURL (string: "https://www.google.com")
        
        let url:URL = URL(string: "http://" + lifeguardDeviceObject.deviceArray[lifeguardDeviceObject.deviceSelected] + ".local/login.php")!
        //let url:URL = URL(string: "http://" + lifeguardDeviceObject.deviceArray[lifeguardDeviceObject.deviceSelected] + ".local/test.html")!
        
        
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        
        
        let request = NSMutableURLRequest(url: url, cachePolicy:NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let defaults = UserDefaults.standard
        let post: String = "email=" + defaults.string(forKey: "email")! + "&password=" + defaults.string(forKey: "password")!
        let postData: NSData = post.data(using: String.Encoding.ascii, allowLossyConversion: true)! as NSData
        
        request.httpBody = postData as Data
        
        /*
         let config = WKWebViewConfiguration()
         //adds a new messageHandler to the javascript called `newJsMethod`
         //and sets the delegate for the callback to this ViewController.
         config.userContentController.add(self as WKScriptMessageHandler, name: "callbackHandler")
         
         webview.uiDelegate = self as? WKUIDelegate
         webview.navigationDelegate = self as? WKNavigationDelegate
         webview = WKWebView(frame: .zero, configuration: config)
         
         */
        webview.load(request as URLRequest)
        
        
        //let value = webview.evaluateJavaScript(<#T##javaScriptString: String##String#>, completionHandler: <#T##((Any?, Error?) -> Void)?##((Any?, Error?) -> Void)?##(Any?, Error?) -> Void#>)
        
        /*
         webview.evaluateJavaScript("alertIOS()") { (result, error) in
         if error != nil {
         if result != nil {
         print(result!)
         } else {
         print("no js response")
         }
         }
         }
         */
        
        
        
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
