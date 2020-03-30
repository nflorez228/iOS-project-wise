//
//  SearchHubViewController.swift
//  BeWise
//
//  Created by Nicolas Florez on 11/9/16.
//  Copyright © 2016 BEWISE. All rights reserved.
//

import UIKit

class SearchHubViewController: UIViewController {
    var dismissAlertClosure: (() -> Void)?
    var dataLoadingDone = false {
        didSet {
            if dataLoadingDone == true {
                dismissAlertClosure?()
            }
        }
    }
    let alerta: UIAlertView = UIAlertView(title: "Loading", message: "Searching hub please wait...", delegate: nil, cancelButtonTitle: nil)
    let alerta2: UIAlertView = UIAlertView(title: "Error", message: "Hub not found", delegate: nil, cancelButtonTitle: "OK")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        alerta.cancelButtonIndex = -1
        
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 50, y: 10, width: 37, height: 37)) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alerta.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        
        dismissAlertClosure = {
            self.alerta.dismiss(withClickedButtonIndex: -1, animated: false)
            self.alerta2.show()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchHub(_ sender: Any) {
        alerta.show()
        let ip = IPChecker.getIP();
        let needle: Character = "."
        var ount=0
        var ountp=0
        var strrta=""
        for i in (ip?.characters)! {
            ount += 1
            if(i==needle)
            {
                ountp += 1
                if(ountp==3)
                {
                    let str = ip?.index((ip?.startIndex)!, offsetBy: ount)
                    strrta = (ip?.substring(to: str!))!
                }
            }
        }
        let myURLString = "http://\(strrta)"
        searchHubIP2(ip: myURLString)
        
        /*var found = false
        var count = 200
        while !found {
            
            let myURLString = "http://\(strrta)\(count)/"
            count += 1
            //let myURLString = "https://wtfismyip.com/text"
            guard let myURL = URL(string: myURLString) else {
                print("Error: \(myURLString) doesn't seem to be a valid URL")
                return
            }
            
            do {
                var myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
                myHTMLString = myHTMLString.replacingOccurrences(of: "\n", with: "")
                print("HTML : \(myHTMLString)")
                found = true
                
                //myHTMLString = "201.244.233.70"//QUITAR_________________________________________________
                
                searchHubIP2(ip: myHTMLString)
                
            } catch let error {
                print("Error: \(error)")
            }
        }*/
        //performSegue(withIdentifier: "hubFound", sender: nil)
    }
    
    func searchHubIP(ip:String)  {
        var alert: UIAlertView = UIAlertView(title: "Loading", message: "Searching hub please wait...", delegate: nil, cancelButtonTitle: nil)
        
        alert.cancelButtonIndex = -1
        
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 50, y: 10, width: 37, height: 37)) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        
        alert.show();
        
        print("http://\(ip).en.bewise.com.co")
        let myURLString = "http://\(ip).en.bewise.com.co"
        guard let myURL = URL(string: myURLString) else {
            print("Error: \(myURLString) doesn't seem to be a valid URL")
            return
        }
        
        do {
            let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
            let notfound: Bool = myHTMLString.contains("not found")
            //print("HTML : \(myHTMLString)")
            alert.dismiss(withClickedButtonIndex: -1, animated: false)
            if notfound
            {
                print("Bewisehub not found")
            }
            else
            {
                print("Bewisehub found")
                configureHubSocketIO(ip: ip)
            }
        } catch let error {
            print("Error: \(error)")
        }

        
    }
    
    
    
    func searchHubIP2(ip:String)
    {
        var alert: UIAlertView = UIAlertView(title: "Loading", message: "Searching hub please wait...", delegate: nil, cancelButtonTitle: nil)
        
        alert.cancelButtonIndex = -1
        
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 50, y: 10, width: 37, height: 37)) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        
        
        //alert.show();
        //alerta.show()
        
        //print("http://\(ip).en.bewise.com.co")
        //let myURLString:String = "http://\(ip).en.bewise.com.co"
        //let myURLString:String = "http://bewisehub"
        
        

        var found = false
        var count = 200
        while !found {
            
            let myURLString = "\(ip)\(count)/"
            count += 1
            let url: URL = URL(string:myURLString)!
            let request1: URLRequest = URLRequest(url: url)
            let queue: OperationQueue = OperationQueue()
            
            
            
            NSURLConnection.sendAsynchronousRequest(request1, queue: queue, completionHandler: {(response: URLResponse?, data: Data?, error: Error?) -> Void in
                //alerta.dismiss(withClickedButtonIndex: -1, animated: false)
                print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
                if(data == nil)
                {
                    
                    //print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
                    //let resp = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    //if (resp?.contains("not found"))!
                    //{
                    //var alert2: UIAlertView = UIAlertView(title: "Error", message: "Bewisehub not found", delegate: nil, cancelButtonTitle: "OK")
                    //alert2.show()
                    //self.dataLoadingDone = true
                    // ** This gets the main queue **
                    //alert.dismiss(withClickedButtonIndex: -1, animated: false)
                    
                    /*DispatchQueue.main.async(execute: {
                        self.dismissAlertClosure!()
                    })*/
                    //}
                }
                else
                {
                    found = true
                    self.alerta.dismiss(withClickedButtonIndex: -1, animated: false)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: {
                        self.performSegue(withIdentifier: "hubFound", sender: self)
                        //self.configureHubSocketIO(ip: ip)
                    })
                    
                    
                }
            })
        }
        self.dismissAlertClosure!()
    }
    
    
    
    func configureHubSocketIO(ip:String)
    {
        /*let socket = SocketIOClient(socketURL: URL(string: "http://\(ip).en.bewise.com.co")!, config: [.log(true), .forcePolling(true)])
         socket.on("connect"){data, ack in
         print("socket connected")
         }*/
            performSegue(withIdentifier: "hubFound", sender: nil)
        
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
