//
//  MainViewController.swift
//  BeWise
//
//  Created by Nicolas Florez on 11/4/16.
//  Copyright © 2016 BEWISE. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {

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

    override func viewDidAppear(_ animated: Bool) {
        
        let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        if let documents = directories.first {
            
            if let urlDocuments = NSURL(string: documents) {
                let urlDictionary = urlDocuments.appendingPathComponent("places.plist")
                let loadedDictionary = NSDictionary(contentsOfFile: urlDictionary!.path)
                if let dictionary = loadedDictionary {
                    print(dictionary)
                    performSegue(withIdentifier: "ready", sender: nil)
                }
                else
                {
                    
                    let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                    
                    if let documents = directories.first {
                        
                        if let urlDocuments = NSURL(string: documents) {
                            let urlDictionary = urlDocuments.appendingPathComponent("user.plist")
                            let loadedDictionary = NSDictionary(contentsOfFile: urlDictionary!.path)
                            if let dictionary = loadedDictionary {
                                print(dictionary)
                                performSegue(withIdentifier: "logged", sender: nil)
                            }
                            else
                            {
                                
                                self.performSegue(withIdentifier: "push", sender: self)
                            }
                        }
                    }
                }
            }
        }
    }
}
