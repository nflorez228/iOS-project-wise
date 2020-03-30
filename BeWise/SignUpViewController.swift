//
//  SignUpViewController.swift
//  BeWise
//
//  Created by Nicolas Florez on 11/5/16.
//  Copyright © 2016 BEWISE. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var repasswd: UITextField!
    @IBOutlet weak var creatAccBut: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(SignUpViewController.dissmissKeyboard))
        
        view.addGestureRecognizer(tap)
        name.delegate=self
        email.delegate=self
        password.delegate=self
        repasswd.delegate=self
    }
    
    func dissmissKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == name)
        {
            email.select(nil)
        }
        else if(textField == email)
        {
            password.select(nil)
        }
        else if(textField == password)
        {
            repasswd.select(nil)
        }
        else
        {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func but(_ sender: AnyObject) {
        print("hola")
        var nametxt:String = name.text!
        let emailtxt:String = email.text!
        var passwordtxt:String = password.text!
        let repasswdtxt:String = repasswd.text!
        print(nametxt)
        print(emailtxt)
        print(passwordtxt)
        print(repasswdtxt)
        
        var valid:Bool = true
        
        var error=""
        
        if(nametxt.isEmpty || nametxt.characters.count<3)
        {
            print("error")
            error.append("Name must be at least 3 characters\n")
            valid=false
        }
        if(emailtxt.isEmpty || !isValidEmail(testStr: emailtxt))
        {
            print("errorMail")
            error.append("Email is not a valid email address\n")
            valid=false
        }
        if(passwordtxt.isEmpty || passwordtxt.characters.count<4 || passwordtxt.characters.count>15)
        {
            print("errorpass")
            error.append("Password must be between 4 and 15 characters\n")
            valid=false
        }
        if(repasswdtxt.isEmpty || repasswdtxt != passwordtxt)
        {
            print("errorrepass")
            error.append("Passwords doesn't match")
            valid=false
        }
        
        
        if(valid)
        {
            let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            
            if let documents = directories.first {
                if let urlDocuments = NSURL(string: documents) {
                    let urlDictionary = urlDocuments.appendingPathComponent("user.plist")
                    
                    // Write Array to Disk
                    let data = [nametxt, emailtxt, passwordtxt, "NOTIDIOS"] as NSArray
                    let dictionary = ["data" : data, "index" : 1, "logged" : true] as NSDictionary
                    
                    dictionary.write(toFile: urlDictionary!.path, atomically: true)
                    
                    // Load from Disk
                    
                }
            }
            
            if let documents = directories.first {
                
                if let urlDocuments = NSURL(string: documents) {
                    let urlDictionary = urlDocuments.appendingPathComponent("user.plist")
                    let loadedDictionary = NSDictionary(contentsOfFile: urlDictionary!.path)
                    if let dictionary = loadedDictionary {
                        print(dictionary)
                        performSegue(withIdentifier: "ChooseHub", sender: nil)
                    }
                }
            }
        }
        else
        {
            let alert = UIAlertView()
            alert.title = "Error"
            alert.message = error
            alert.addButton(withTitle: "OK")
            alert.show()
        }
    }

    func isValidEmail(testStr:String) -> Bool {
    // print("validate calendar: \(testStr)")
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
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
