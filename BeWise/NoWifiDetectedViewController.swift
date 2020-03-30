//
//  NoWifiDetectedViewController.swift
//  BeWise
//
//  Created by Nicolas Florez on 11/9/16.
//  Copyright © 2016 BEWISE. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration.CaptiveNetwork

class NoWifiDetectedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    func fethSSIDInfo() -> String {
        var currentSSID = ""
        if let interfaces = CNCopySupportedInterfaces(){
            for i in 0..<CFArrayGetCount(interfaces){
                let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interfaces, i)
                let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
                let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString)
                if unsafeInterfaceData != nil{
                    let interfaceData = unsafeInterfaceData! as NSDictionary
                    currentSSID = interfaceData["SSID"] as! String
                }
            }
        }
        return currentSSID
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if fethSSIDInfo() != ""
        {
            self.performSegue(withIdentifier: "wifiDetected", sender: self)
        }
    }

}
