//
//  SoketIOConfigureHubViewController.swift
//  BeWise
//
//  Created by Nicolas Florez on 11/10/16.
//  Copyright © 2016 BEWISE. All rights reserved.
//

import UIKit
import SocketIO

class SoketIOConfigureHubViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    var dismissAlertClosure: (() -> Void)?
    var dataLoadingDone = false {
        didSet {
            if dataLoadingDone == true {
                dismissAlertClosure?()
            }
        }
    }
    let alerta: UIAlertView = UIAlertView(title: "Loading", message: "Verifing avialability of your hub name", delegate: nil, cancelButtonTitle: nil)
    let alerta2 = "Authenticating on the hub"
    let alerta3 = "Sending Settings to the hub"
    let alerta4 = "Configuring the hub. Please wait"
    let alerta2m: UIAlertView = UIAlertView(title: "Error", message: "Hub name not available", delegate: nil, cancelButtonTitle: "OK")
    
    @IBOutlet weak var typeOfHomePickerView: UIPickerView!
    @IBOutlet weak var hubName: UITextField!
    
    var pikerDataSource = ["House", "Office"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.typeOfHomePickerView.dataSource = self
        self.typeOfHomePickerView.delegate = self
        self.hubName.delegate = self
        
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
            //self.alerta2.show()
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pikerDataSource.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pikerDataSource[row]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == hubName)
        {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func configureHub(_ sender: Any) {
        var nametxt:String = hubName.text!
        var valid:Bool = true
        
        let pat = "/(\\w+)(\\W+)/i"
        
        //let regex = NSRegularExpression(pattern: pat, options: [])
        
        
        
        if(nametxt.isEmpty || nametxt.characters.count<5)
        {
            print("error")
            valid=false
        }
        
        if valid
        {
            alerta.show()
            searchHubNameAvailable(name: nametxt)
        }
        
    }
    
    func searchHubNameAvailable(name:String)  {
        print("http://\(name).en.bewise.com.co")
        let myURLString:String = "http://\(name).en.bewise.com.co"
        let url: URL = URL(string:myURLString)!
        let request1: URLRequest = URLRequest(url: url)
        let queue: OperationQueue = OperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request1, queue: queue, completionHandler: {(response: URLResponse?, data: Data?, error: Error?) -> Void in
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
            let resp = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            if (resp?.contains("unavailable at the moment"))!
            {
                print("available")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: {
                    self.alerta.message = self.alerta2
                    //self.alerta.show()
                    //self.configureHubSocketIO(ip: self.getIP(), name:name)
                    self.configureHubSocketIONoIP(name:name)
                })
            }
            else
            {
                self.alerta.dismiss(withClickedButtonIndex: -1, animated: false)
                
                print("not available")
                DispatchQueue.main.async(execute: {
                    self.alerta2m.show()
                })
            }
        })
    }
    
    func configureHubSocketIONoIP(name:String)
    {
        
        let socket = SocketIOClient(socketURL: URL(string: "http://bewisehub")!, config: [.log(true), .forcePolling(true)])
        socket.on("connect"){data, ack in
        print("connected!!!!!!!!!!!!!!!!!!!!!!!!")
            
            let jsonobj: [String: String] = [
                "username":"bewise",
                "password":"bewise"
            ]
            let valid = JSONSerialization.isValidJSONObject(jsonobj)
            socket.emit("authentication", jsonobj)
        }
        socket.on("error"){data, ack in
         print("ha ocurrido un error")
            socket.disconnect()
            //TODO informar que no ha sido posible establecer una conexion o que ocurrio un error.
        }
        socket.on("authenticated"){data, ack in
            socket.emit("authenticated")
        }
        socket.on("PROCESS"){data, ack in
            if let cur = data[0] as? String{
                
                if cur == "authenticatedOK"
                {
                    self.alerta.message = self.alerta3
                    
                    print("llego authenticatedOK")
                    
                    let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                    
                    if let documents = directories.first {
                        
                        if let urlDocuments = NSURL(string: documents) {
                            let urlDictionary = urlDocuments.appendingPathComponent("user.plist")
                            let loadedDictionary = NSDictionary(contentsOfFile: urlDictionary!.path)
                            if let dictionary = loadedDictionary {
                                print(dictionary)
                                let data: NSArray = dictionary.value(forKey: "data") as! NSArray
                                print(data)
                                print(data[0])//nombre
                                print(data[1])//email
                                print(data[2])//pass
                                print(data[3])//NotiID
                                let jsonobj2: [String:String] = [
                                    "nombre":name,
                                    "login":"bewise",
                                    "login2":data[1] as! String,
                                    "pass":"bewise",
                                    "pass2":data[2] as! String,
                                    "rid":data[3] as! String
                                ]
                                socket.emit("CAMBIARNOMBRE",jsonobj2)
                            }
                        }
                    }
                    
                    
                }
                else if cur ==  "cambiarnombreOK"
                {
                    self.alerta.message = self.alerta4
                    print("llego cambiarnombreOK")
                    socket.disconnect()
                    self.keepSearchingHubName(name: name, type: self.pikerDataSource[self.typeOfHomePickerView.selectedRow(inComponent: 0)], urli:"http://\(name).en.bewise.com.co", urle:"http://\(name)")
                    
                }
                
            }
            
            
            
        }
        socket.connect()
        //socket.emit("authentication",jsonobj)
        //performSegue(withIdentifier: "hubFound", sender: nil)
    }
    
    func configureHubSocketIO(ip:String, name:String)
    {
        print("http://\(ip).en.bewise.com.co")
        
        let socket = SocketIOClient(socketURL: URL(string: "http://\(ip).en.bewise.com.co")!, config: [.log(true), .forcePolling(true)])
        socket.on("connect"){data, ack in
            print("connected!!!!!!!!!!!!!!!!!!!!!!!!")
            
            let jsonobj: [String: String] = [
                "username":"bewise",
                "password":"bewise"
            ]
            let valid = JSONSerialization.isValidJSONObject(jsonobj)
            socket.emit("authentication", jsonobj)
        }
        socket.on("error"){data, ack in
            print("ha ocurrido un error")
            socket.disconnect()
            
            //TODO enviar alerta que se ha perdido la conexion.
        }
        socket.on("authenticated"){data, ack in
            socket.emit("authenticated")
        }
        socket.on("PROCESS"){data, ack in
            if let cur = data[0] as? String{
                
                if cur == "authenticatedOK"
                {
                    self.alerta.message = self.alerta3
                    
                    print("llego authenticatedOK")
                    
                    let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                    
                    if let documents = directories.first {
                        
                        if let urlDocuments = NSURL(string: documents) {
                            let urlDictionary = urlDocuments.appendingPathComponent("user.plist")
                            let loadedDictionary = NSDictionary(contentsOfFile: urlDictionary!.path)
                            if let dictionary = loadedDictionary {
                                print(dictionary)
                                let data: NSArray = dictionary.value(forKey: "data") as! NSArray
                                print(data)
                                print(data[0])//nombre
                                print(data[1])//email
                                print(data[2])//pass
                                print(data[3])//NotiID
                                let jsonobj2: [String:String] = [
                                    "nombre":name,
                                    "login":"bewise",
                                    "login2":data[1] as! String,
                                    "pass":"bewise",
                                    "pass2":data[2] as! String,
                                    "rid":data[3] as! String
                                ]
                                socket.emit("CAMBIARNOMBRE",jsonobj2)
                            }
                        }
                    }
                    
                    
                }
                else if cur ==  "cambiarnombreOK"
                {
                    self.alerta.message = self.alerta4
                    print("llego cambiarnombreOK")
                    socket.disconnect()
                    self.keepSearchingHubName(name: name, type: self.pikerDataSource[self.typeOfHomePickerView.selectedRow(inComponent: 0)], urli:"http://\(name).en.bewise.com.co", urle:"http://\(name)")
                    
                }
                
            }
            
            
            
        }
        socket.connect()
        //socket.emit("authentication",jsonobj)
        //performSegue(withIdentifier: "hubFound", sender: nil)
    }
    
    
    func getIP() -> String {
        
            let myURLString = "https://wtfismyip.com/text"
            var myHTMLString = ""
         let myURL = URL(string: myURLString)
        do {
                myHTMLString = try String(contentsOf: myURL!, encoding: .ascii)
                myHTMLString = myHTMLString.replacingOccurrences(of: "\n", with: "")
                print("HTML : \(myHTMLString)")
            
                
            } catch let error {
                print("Error: \(error)")
            }
            //performSegue(withIdentifier: "hubFound", sender: nil)
        //myHTMLString = "201.244.233.70"
        return myHTMLString

    }
    
    func keepSearchingHubName(name:String, type:String, urli:String, urle:String)  {
        print("http://\(name).en.bewise.com.co")
        let myURLString:String = "http://\(name).en.bewise.com.co"
        let url: URL = URL(string:myURLString)!
        let request1: URLRequest = URLRequest(url: url)
        let queue: OperationQueue = OperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request1, queue: queue, completionHandler: {(response: URLResponse?, data: Data?, error: Error?) -> Void in
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
            let resp = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            if (resp?.contains("not found"))!
            {
                self.keepSearchingHubName(name: name, type:type, urli:urli, urle:urle)
            }
            else
            {
                self.alerta.dismiss(withClickedButtonIndex: -1, animated: true)
                self.addPlaceToDatabase(name:name, type:type, urli:urli, urle: urle)
            }
        })
    }

    func addPlaceToDatabase(name:String, type:String, urli:String, urle:String) {
        let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        if let documents = directories.first {
            if let urlDocuments = NSURL(string: documents) {
                let urlDictionary = urlDocuments.appendingPathComponent("places.plist")
                
                // Write Array to Disk
                let data = [name, type, urli, urle] as NSArray
                let dictionary = ["data" : data, "index" : 1] as NSDictionary
                
                dictionary.write(toFile: urlDictionary!.path, atomically: true)
                
                // Load from Disk
                
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: {
            self.performSegue(withIdentifier: "cambiarNombreOK", sender: nil)

        })
        
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
