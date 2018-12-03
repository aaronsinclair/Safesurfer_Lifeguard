//
//  ViewController.swift
//  Lifeguard
//
//  Created by Aaron Sinclair on 7/05/18.
//  Copyright © 2018 Aaron Sinclair. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NetServiceBrowserDelegate, NetServiceDelegate {
    var nsb : NetServiceBrowser!
    var services = [NetService]()
    var timer = Timer()

    @IBOutlet weak var tableView: UITableView!
    
    
    @objc func checkForDevice() {
        print("listening for services...")
        self.services.removeAll()
        self.nsb = NetServiceBrowser()
        self.nsb.delegate = self
        self.nsb.searchForServices(ofType:"_sslifeguard._tcp", inDomain: "")
        tableView.reloadData()
        print("Lenght of array \(lifeguardDeviceObject.deviceArray.count)")
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("listening for services...")
        self.services.removeAll()
        self.nsb = NetServiceBrowser()
        self.nsb.delegate = self
        self.nsb.searchForServices(ofType:"_sslifeguard._tcp", inDomain: "")
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ViewController.checkForDevice), userInfo: nil, repeats: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear( animated )
       // tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.layer.cornerRadius = 5
        tableView.clipsToBounds = true
        tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func updateInterface () {
        for service in self.services {
            if service.port == -1 {
                print("service \(service.name) of type \(service.type)" +
                    " not yet resolved")
                service.delegate = self
                service.resolve(withTimeout:10)
            } else {
                print("service \(service.name) of type \(service.type)," +
                    "port \(service.port), addresses \(service.addresses as Any)")
                lifeguardDeviceObject.addDevice(newDevice: service.name)
                tableView.reloadData()
            }
        }
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        self.updateInterface()
    }
    
    func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didFind aNetService: NetService, moreComing: Bool) {
        print("adding a service")
        self.services.append(aNetService)
        if !moreComing {
            self.updateInterface()
        }
    }
    
    func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didRemove aNetService: NetService, moreComing: Bool) {
        if let ix = self.services.index(of:aNetService) {
            self.services.remove(at:ix)
            print("removing a service")
            if !moreComing {
                self.updateInterface()
            }
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if lifeguardDeviceObject.deviceArray.count == 0 {
            return 1
        } else {
            return lifeguardDeviceObject.deviceArray.count
        }
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if lifeguardDeviceObject.deviceArray.count == 0 {
            cell.textLabel?.text = "Searching for Lifeguard Device"
            cell.textLabel?.textColor = UIColor.white
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
            cell.textLabel?.textAlignment = .center
            return cell
        } else {
        
            cell.textLabel?.text = lifeguardDeviceObject.deviceArray[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
            cell.textLabel?.textAlignment = .center
            return cell
        }
    }
    
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if lifeguardDeviceObject.deviceArray.count > 0 {
            print("Selected \(lifeguardDeviceObject.deviceArray[indexPath.row])")
            lifeguardDeviceObject.deviceSelected = indexPath.row
            
            
            
            
            let parameters: [String: String] = [
                "deviceRegistered" : "check"
            ]
            
            
            let url = "http://" + lifeguardDeviceObject.deviceArray[lifeguardDeviceObject.deviceSelected] + ".local/ios/deviceIsRegistered.php/post"
            
            Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in
                print(response)
                if let json = response.result.value {
                    let jsonResponse:Dictionary = json as! Dictionary<String, Any>
                    if(jsonResponse["1"] as! String == "Registered") {
                        print("Device Registered, continue")
                        
                        //self.performSegue(withIdentifier: "showWebView", sender: self)
                        self.performSegue(withIdentifier: "sequeToLifeguardVC", sender: self)
                        
                        
                    }
                        
                    else {
                        print("Device Not Registered")
                        self.performSegue(withIdentifier: "registerDeviceSeque", sender: self)
                        //self.alertCouldNotAuthenticate()
                    }
                    
                } else {
                    self.alertCouldNotConnect()
                }
            }
            
            
            
            
            //test
        }
    }
   
    
    
    func alertCouldNotConnect() {
        let alert = UIAlertController(title: "Could not connect to device", message: "Please try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "continue", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        return
        
    }


}

