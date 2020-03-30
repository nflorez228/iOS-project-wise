//
//  WebViewViewController.swift
//  BeWise
//
//  Created by Nicolas Florez on 11/12/16.
//  Copyright © 2016 BEWISE. All rights reserved.
//

import UIKit
import SocketIO

class WebViewViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webV: UIWebView!
    var url = ""
    var cun = ""
    
    let alerta: UIAlertView = UIAlertView(title: "Authenticating", message: "", delegate: nil, cancelButtonTitle: nil)
    let alerta2: UIAlertView = UIAlertView(title: "Loading", message: "", delegate: nil, cancelButtonTitle: nil)
    
    let progress: UIProgressView = UIProgressView(frame: CGRect(x: 50, y:10, width: 37, height: 37))
    override func viewDidLoad() {
        webV.delegate = self
        super.viewDidLoad()
        alerta.cancelButtonIndex = -1
        alerta2.cancelButtonIndex = -1
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 50, y: 10, width: 37, height: 37)) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alerta.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        alerta.show()
        
        
        alerta2.setValue(progress, forKey: "accessoryView")
        //alerta2.show()
        
        print(url)
        loadweb()
                // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func webViewDidStartLoad(_ webView: UIWebView) {
        print("start")
        self.progress.progress = 0.1
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("stop")
        self.progress.progress = 1
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3), execute: {
            self.alerta2.dismiss(withClickedButtonIndex: -1, animated: true)
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

    
    func loadweb()  {
        let socket = SocketIOClient(socketURL: URL(string: url)!, config: [.log(true), .forcePolling(true)])
        
        
        var jsonobj2: [String: String] = [
            "username":"bewise",
            "password":"bewise"
        ]
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
                    jsonobj2 = [
                        "username":data[1] as! String,
                        "password":data[2] as! String
                    ]
                }
            }
        }
        
        socket.on("connect"){data, ack in
            print("connected!!!!!!!!!!!!!!!!!!!!!!!!")
            
            socket.emit("authentication", jsonobj2)
        }
        socket.on("error"){data, ack in
            print("ha ocurrido un error")
            socket.disconnect()
            
            //TODO enviar alerta de que no ha sido posible conectarse.
            
        }
        socket.on("authenticated"){data, ack in
            socket.emit("authenticated")
        }
        /*socket.on("PROCESS"){data, ack in
            if let cur = data[0] as? String{
                
                if cur == "authenticatedOK"
                {
                    let image: UIImage = UIImage(named: "c.jpg")!
                    let imagedata = UIImagePNGRepresentation(image)
                    let strbase64:String = (imagedata?.base64EncodedString())!
                    //print(strbase64)
                    let jsonobj: [String: String] = [
                        "width":"\(image.size.width)",
                        "height":"\(image.size.height)",
                        "source":strbase64
                    ]
                    socket.emit("SETIMG", jsonobj)
                }
            }
        }*/
        socket.on("SETCUN"){data, ack in
            if let cur = data[0] as? String{
                self.alerta.dismiss(withClickedButtonIndex: -1, animated: true)
                socket.disconnect()
                self.cun = cur
                let urltemp = self.url
                print(urltemp + "/mobile.html?cun=" + cur)
                //let toUrl = URL(string: self.url + "/mobile.html?cun=" + cur)
                let urlttemp2 = urltemp + "/mobile.html?cun=" + cur
                
                let req = URLRequest(url: URL(string: urlttemp2)!)
                self.webV.loadRequest(req)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2 , execute: {
                    self.alerta2.show()
                })
            }
        }
        socket.connect()
        
    }
}
