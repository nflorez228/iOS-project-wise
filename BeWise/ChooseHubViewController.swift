//
//  ChooseHubViewController.swift
//  BeWise
//
//  Created by Nicolas Florez on 11/5/16.
//  Copyright © 2016 BEWISE. All rights reserved.
//

import UIKit
import SocketIO

class ChooseHubViewController: UIViewController, UIAlertViewDelegate{

    @IBOutlet weak var getAccessBut: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func getAccessButClick(_ sender: AnyObject) {
        firstAlert(name: "")
    }
    func firstAlert(name: String)
    {
        let alertController = UIAlertController(title: "Search your hub", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Search", style: .default, handler: {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            
            print("firstName \(firstTextField.text)")
            
            if ((firstTextField.text?.isEmpty)! || (firstTextField.text?.characters.count)! < 5)
            {
                self.firstAlert(name: firstTextField.text!)
                let alert = UIAlertView()
                alert.title = "Error"
                alert.message = "The name must be at least 5 characters"
                alert.addButton(withTitle: "OK")
                alert.show()
            }
            else
            {
                //self.secondAlert(name: firstTextField.text!, email: "", passwd: "")
                self.view.endEditing(true)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                
                
                self.searchHubNameAvailable(name: firstTextField.text!)
                })
            }
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Name of the hub"
            textField.text = name
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func secondAlert(name: String, email: String, passwd: String) {
        let alertController = UIAlertController(title: "Log in", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Sign in", style: .default, handler: {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            
            let secondTextField = alertController.textFields![1] as UITextField
            
            print("firstName \(firstTextField.text)")
            
            var valid:Bool = true
            var error = ""
            if (firstTextField.text!.isEmpty || !self.isValidEmail(testStr: firstTextField.text!))
            {
                valid = false
                error.append("Email must be a valid email address\n")
            }
            if((secondTextField.text?.isEmpty)! || (secondTextField.text?.characters.count)! < 4 || (secondTextField.text?.characters.count)! > 15)
            {
                error.append("Password must be between 4 and 15 alphanumeric characters")
            }
            
            if(valid)
            {
                self.configureHubSocketIO(name: name, email: firstTextField.text!, passwd: secondTextField.text!)
            }
            else
            {
                self.secondAlert(name: name, email: firstTextField.text!, passwd: secondTextField.text!)
                let alert = UIAlertView()
                alert.title = "Error"
                alert.message = error
                alert.addButton(withTitle: "OK")
                alert.show()
            }
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Email"
            textField.keyboardType = UIKeyboardType.emailAddress
            textField.text = email
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
            textField.text = passwd
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func searchHubNameAvailable(name:String)  {
        //var alert: UIAlertView = UIAlertView(title: "Loading", message: "Searching hub please wait...", delegate: nil, cancelButtonTitle: "Cancel");
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
        print("http://\(name).en.bewise.com.co")
        let myURLString:String = "http://\(name).en.bewise.com.co"
        let url: URL = URL(string:myURLString)!
        let request1: URLRequest = URLRequest(url: url)
        let queue: OperationQueue = OperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request1, queue: queue, completionHandler: {(response: URLResponse?, data: Data?, error: Error?) -> Void in
            
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
            let resp = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            if (!(resp?.contains("unavailable at the moment"))!)
            {
                alert.dismiss(withClickedButtonIndex: -1, animated: false)
                print("not found")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                    self.showErrorAlert()
                })
                //self.showErrorAlert()
                
            }
            else
            {
                alert.dismiss(withClickedButtonIndex: -1, animated: true)
                self.secondAlert(name: name, email: "", passwd: "")
                
            }
        })
    }

    func showErrorAlert(){
        
        var alert2: UIAlertView = UIAlertView(title: "Alert", message: "The hub was not found please verifiy", delegate: nil, cancelButtonTitle: "OK");
        alert2.show()
        
        view.endEditing(true)
    }
    
    func configureHubSocketIO(name: String, email: String, passwd: String){
        
        var alert: UIAlertView = UIAlertView(title: "Loading", message: "Authenticating on the hub", delegate: nil, cancelButtonTitle: nil)
        
        alert.cancelButtonIndex = -1
        
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 50, y: 10, width: 37, height: 37)) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        
        alert.show();

        
        
        let socket = SocketIOClient(socketURL: URL(string: "http://\(name).en.bewise.com.co")!, config: [.log(true), .forcePolling(true)])
        socket.on("connect"){data, ack in
            print("connected!!!!!!!!!!!!!!!!!!!!!!!!")
            
            let jsonobj: [String: String] = [
                "username":"\(email)",
                "password":"\(passwd)"
            ]
            let valid = JSONSerialization.isValidJSONObject(jsonobj)
            socket.emit("authentication", jsonobj)
        }
        socket.on("error"){data, ack in
            print("ha ocurrido un error")
        }
        socket.on("authenticated"){data, ack in
            socket.emit("authenticated")
        }
        socket.on("PROCESS"){data, ack in
            if let cur = data[0] as? String{
                
                if cur == "authenticatedOK"
                {
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
                                print(data[1])//email
                                print(data[2])//pass
                                print(data[3])//NotiID
                                let jsonobj2: [String:String] = [
                                    "login":data[1] as! String,
                                    "pass":data[2] as! String,
                                    "rid":data[3] as! String
                                ]
                                socket.emit("AGREGARLOGIN",jsonobj2)
                                alert.message = "Adding your credentials to hub"
                            }
                        }
                    }
                }
                else if cur == "agregarLoginOK"
                {
                    print("llego agregarLoginOk")
                    socket.disconnect()
                    self.addPlaceToDatabase(name: name, type: "House", urli: "http://\(name).en.bewise.com.co")
                    alert.dismiss(withClickedButtonIndex: -1, animated: true)
                }
            }
        }
        socket.connect()
    }
    
    
    func addPlaceToDatabase(name:String, type:String, urli:String) {
        let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        if let documents = directories.first {
            if let urlDocuments = NSURL(string: documents) {
                let urlDictionary = urlDocuments.appendingPathComponent("places.plist")
                
                // Write Array to Disk
                let data = [name, type, urli] as NSArray
                let dictionary = ["data" : data, "index" : 1] as NSDictionary
                
                dictionary.write(toFile: urlDictionary!.path, atomically: true)
                
                // Load from Disk
                
            }
        }
        self.performSegue(withIdentifier: "doneExisting", sender: nil)
        
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
