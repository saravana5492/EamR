//
//  addNewWishList.swift
//  EamR
//
//  Created by Apple on 05/10/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit
import AFNetworking

class addNewWishList: UIViewController {

    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    //@IBOutlet weak var newProductView: UIView!
    @IBOutlet weak var newProductName: UITextField!
    @IBOutlet weak var minPrice: UITextField!
    @IBOutlet weak var maxPrice: UITextField!
    @IBOutlet weak var addWishList: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        addWishList.layer.cornerRadius = 3.0
        
        
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(disKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }

    func disKeyboard() {
        
        self.newProductName.resignFirstResponder()
        self.minPrice.resignFirstResponder()
        self.maxPrice.resignFirstResponder()
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    @IBAction func addNewWishListAction(_ sender: Any) {
        
        if (newProductName.text == "") {
            
            let alertController = UIAlertController(title: "Failure", message:"Enter wishlist product name", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler:   {(_ action: UIAlertAction) -> Void in
                
            })
            
            alertController.addAction(ok)
            self.present(alertController, animated: true) { _ in }
            
        } else if (minPrice.text == "") {
            
            let alertController = UIAlertController(title: "Failure", message:"Enter minimum price of the product", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler:   {(_ action: UIAlertAction) -> Void in
                
            })
            
            alertController.addAction(ok)
            self.present(alertController, animated: true) { _ in }
            
        } else if (maxPrice.text == "") {
            
            let alertController = UIAlertController(title: "Failure", message:"Enter maximum price of the product", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler:   {(_ action: UIAlertAction) -> Void in
                
            })
            
            alertController.addAction(ok)
            self.present(alertController, animated: true) { _ in }
            
        } else {
            self.appDelegate.showProgress(true)
            let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/add_wishlist_new.php")
            
            let param: [String: Any] = ["profile_id" : UserDefaults.standard.value(forKey: "ProfileID") as! String, "keyword": newProductName.text!, "min": minPrice.text!, "max": maxPrice.text!]
            
            print(param, (url!.absoluteString))
            
            let manager = AFHTTPSessionManager()
            manager.requestSerializer = AFHTTPRequestSerializer()
            manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
            let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
            
            manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
            
            manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
                self.appDelegate.showProgress(false)
                let responseDictionary = (responseObject as! NSDictionary)
                print("Add wishlist Response: \(responseDictionary as Any)")
                
                //self.wishListTableView.isHidden = false
                
                if (responseDictionary["status"] as! Int == 1) {
                    print("EamR Success")
                    
                    let alertController = UIAlertController(title: "Success", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler:   {(_ action: UIAlertAction) -> Void in
                        
                        self.newProductName.text = ""
                        self.minPrice.text = ""
                        self.maxPrice.text = ""
                        
                        self.view.endEditing(true)
                        self.navigationController?.popViewController(animated: true)
                        
                    })
                    
                    alertController.addAction(ok)
                    self.present(alertController, animated: true) { _ in }
                    
                } else if (responseDictionary["status"] as! Int == 0) {
                    print("EamR Failure")
                    let alertController = UIAlertController(title: "Failure", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler:   {(_ action: UIAlertAction) -> Void in
                        //self.wishListTableView.isHidden = true
                        //self.addNewProduct.tag = 0
                        //self.newProductView.isHidden = true
                    })
                    
                    alertController.addAction(ok)
                    self.present(alertController, animated: true) { _ in }
                }
                
            }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
                self.appDelegate.showProgress(false)
                print("Favorite Exhibition Error: \(String(describing: error))")
            })
        }
        
    }

    
    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        print("Touched Outside")
        
        self.view.endEditing(true)
        
        self.newProductName.resignFirstResponder()
        self.minPrice.resignFirstResponder()
        self.maxPrice.resignFirstResponder()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)

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

}

