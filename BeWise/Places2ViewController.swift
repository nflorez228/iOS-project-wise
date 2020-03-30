//
//  Places2ViewController.swift
//  BeWise
//
//  Created by Nicolas Florez on 6/21/17.
//  Copyright © 2017 BEWISE. All rights reserved.
//

import UIKit

class Places2ViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var ollv: UICollectionViewCell!
    
    let reuseIdentifier = "cell"
    var items:[String] = []
    var urls:[String] = []
    var urlsi:[String] = []
    var imgs:[String] = []
    
    var resultURL="";
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        if let documents = directories.first {
            
            if let urlDocuments = NSURL(string: documents) {
                let urlDictionary = urlDocuments.appendingPathComponent("places.plist")
                let loadedDictionary = NSDictionary(contentsOfFile: urlDictionary!.path)
                if let dictionary = loadedDictionary {
                    print(dictionary)
                    let data: NSArray = dictionary.value(forKey: "data") as! NSArray
                    print(data)
                    print(data[0])
                    print(data[1])
                    print(data[2])
                    items.append(data[0] as! String)
                    urls.append(data[2] as! String)
                    urlsi.append(data[3] as! String)
                    imgs.append("a.jpg")
                }
            }
        }
        
        
        
        if(items.count==1)
        {
            resultURL = urls[0]
            performSegue(withIdentifier: "toWebView", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! Place2CollectionViewCell
        cell.houseTitle.text = "holaaa"
        //cell.title.text = self.items[indexPath.item]
        //cell.image.image =  UIImage(named: self.imgs[indexPath.item])
        /*cell.layer.borderColor = UIColor.black.cgColor
         cell.layer.borderWidth = 1
         cell.layer.cornerRadius = 8*/
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //TODO Revisar si esta en wifi de la casa para poder entrar por http://nombre o http://bewisehub
        
        resultURL = urls[indexPath.item]
        //resultURL = urlsi[indexPath.item]
        performSegue(withIdentifier: "toWebView", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toWebView")
        {
            let detailsVC = segue.destination as! WebViewViewController
            detailsVC.url = self.resultURL
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    /*extension UIImageView{
     func blurImage(){
     let blurEffe = UIBlurEffect(style: UIBlurEffectStyle.light)
     let blurEffeView = UIVisualEffect(coder: blurEffe)
     blurEffeView.frame = self.bounds
     
     blurEffeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
     self.addSubview(blurEffeView)
     }
     }*/
    
}
