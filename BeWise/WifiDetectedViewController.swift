//
//  WifiDetectedViewController.swift
//  BeWise
//
//  Created by Nicolas Florez on 11/9/16.
//  Copyright © 2016 BEWISE. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration.CaptiveNetwork

class WifiDetectedViewController: UIViewController {

    @IBOutlet weak var wifiDetectedText: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        wifiDetectedText.text = "We have detected a wifi network called: \"\(fethSSIDInfo())\" \n If it is the same network of the router you have connected your bewisehub you can continue.\n If not please connect to the same network in your phone."
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
