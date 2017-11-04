//
//  wishListVC.swift
//  EamR
//
//  Created by Apple on 18/07/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit
import AFNetworking
import SDWebImage


class wishListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var menuBtn: UIButton!
    var wishListArray = NSArray()
    var filteredArray = NSArray()
    var productsArray = NSArray()
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var searchBar: UISearchBar!

    var isSearch: Bool = false
    var searchStr: String!
    var userName : String!
    var userEmail: String!
    
    
    @IBOutlet weak var wishListTableView: UITableView!
    @IBOutlet weak var addNewProduct: UIButton!
    @IBOutlet weak var newProductView: UIView!
    @IBOutlet weak var newProductName: UITextField!
    @IBOutlet weak var minPrice: UITextField!
    @IBOutlet weak var maxPrice: UITextField!
    @IBOutlet weak var addWishList: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            self.menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: UIControlEvents.touchUpInside)
            //segmentedPager.isUserInteractionEnabled = false
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        newProductView.isHidden = true
        
        
        //newProductView.layer.masksToBounds = false
        //newProductView.layer.shadowColor = UIColor.black.cgColor
        //newProductView.layer.shadowOpacity = 0.5
        //newProductView.layer.shadowOffset = CGSize(width: -1, height: 1)
        //newProductView.layer.shadowRadius = 1.0
        //newProductView.layer.shouldRasterize = true
        
        //newProductView.layer.shadowPath = UIBezierPath(rect: self.newProductView.bounds).cgPath
        //newProductView.layer.shouldRasterize = true
        
        addWishList.layer.cornerRadius = 3.0
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = UIColor.white
        searchBar.layer.borderColor = UIColor.lightGray.cgColor
        searchBar.layer.borderWidth = 1.0
        searchBar.layer.cornerRadius = 5.0
        
        //self.appDelegate.showProgress(true)
        getWishList()

        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        searchBar.resignFirstResponder()
        getWishList()
    }
    
    
    @IBAction func showNewAddWLView(_ sender: UIButton) {
        
        let infoController: addNewWishList? = storyboard?.instantiateViewController(withIdentifier: "addNewWishList") as? addNewWishList
        navigationController?.pushViewController(infoController!, animated: true)
        
    }
    
    @IBAction func addNewWishListAction(_ sender: Any) {
        
        if (newProductName.text == "" || minPrice.text == "" || maxPrice.text == "") {
            
            let alertController = UIAlertController(title: "Failure", message:"Fill All Fields", preferredStyle: .alert)
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
                        self.addNewProduct.tag = 0
                        self.newProductName.text = ""
                        self.minPrice.text = ""
                        self.maxPrice.text = ""
                        self.newProductView.isHidden = true
                        self.getWishList()
                    })
                    
                    alertController.addAction(ok)
                    self.present(alertController, animated: true) { _ in }
                    
                } else if (responseDictionary["status"] as! Int == 0) {
                    print("EamR Failure")
                    let alertController = UIAlertController(title: "Failure", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler:   {(_ action: UIAlertAction) -> Void in
                        //self.wishListTableView.isHidden = true
                        self.addNewProduct.tag = 0
                        self.newProductView.isHidden = true
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
    
    
    func getWishList() {
        
        self.appDelegate.showProgress(true)
       let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/getwishlist.php")
        
        let param: [String: Any] = ["profile_id" : UserDefaults.standard.value(forKey: "ProfileID") as! String]
        
        print(param, (url!.absoluteString))
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
        let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
        
        manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
        
        manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
            self.appDelegate.showProgress(false)
            let responseDictionary = (responseObject as! NSDictionary)
            print("Favorite Exhibition Response: \(responseDictionary as Any)")
            
            self.wishListTableView.isHidden = false
            
            if (responseDictionary["status"] as! Int == 1) {
                print("EamR Success")
                
                if ((responseDictionary["categorylistvalues"] as? NSNull) != nil) {
                    let alertController = UIAlertController(title: "Sorry", message:"You do not have wishlist", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(ok)
                    self.present(alertController, animated: true) { _ in }
                    
                } else {
                    self.wishListArray = responseDictionary["categorylistvalues"] as! NSArray
                    self.filteredArray = self.wishListArray
                    self.wishListTableView.reloadData()
                }
            } else if (responseDictionary["status"] as! Int == 0) {
                print("EamR Failure")
                let alertController = UIAlertController(title: "Failure", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler:   {(_ action: UIAlertAction) -> Void in
                    self.wishListTableView.isHidden = true
                })

                alertController.addAction(ok)
                self.present(alertController, animated: true) { _ in }
            }
            
        }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
            self.appDelegate.showProgress(false)
            print("Favorite Exhibition Error: \(String(describing: error))")
        })
    }
    

    
    @IBAction func removeWishList(_ sender: UIButton) {
        let refreshAlert = UIAlertController(title: "Alert", message: "Do you want to remove this Product from Wishlist?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            
            self.appDelegate.showProgress(true)
            let tag = sender.tag
            
            let cartDict = (self.filteredArray[tag] as AnyObject) as! NSDictionary
            
            let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/delete_wishlist_new.php")
            
            let param = ["sno" : cartDict["sno"]!]
            
            print(param)
            
            let manager = AFHTTPSessionManager()
            manager.requestSerializer = AFHTTPRequestSerializer()
            manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
            let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
            
            manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
            
            manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
                self.appDelegate.showProgress(false)
                print("Delete WIshList Response: \(responseObject as Any)")
                let responseDictionary = (responseObject as! NSDictionary)
                
                if (responseDictionary["status"] as! Int == 1) {
                    print("EamR Success")
                    let alertController = UIAlertController(title: "Success", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                        self.appDelegate.showProgress(true)
                        self.getWishList()
                    })
                    alertController.addAction(ok)
                    self.present(alertController, animated: true) { _ in }
                    
                } else if (responseDictionary["status"] as! Int == 0) {
                    print("EamR Failure")
                    let alertController = UIAlertController(title: "Failure", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler:  {(_ action: UIAlertAction) -> Void in
                    })
                    alertController.addAction(ok)
                    self.present(alertController, animated: true) { _ in }
                }
                
            }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
                self.appDelegate.showProgress(false)
                print("Delete Exhibition from Favorite Error: \(String(describing: error))")
            })
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }

    
    // MARK: - UITableViewDataSource
    // number of section(s), now I assume there is only 1 section
    func numberOfSections(in theTableView: UITableView) -> Int {
        return 1
    }
    
    // number of row in the section, I assume there is only 1 row
    func tableView(_ theTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredArray.count
    }
    
    func tableView(_ theTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: wishListProdCell? = (theTableView.dequeueReusableCell(withIdentifier: "wishCell") as? wishListProdCell)
        if cell == nil {
            cell = wishListProdCell(style: .default, reuseIdentifier: "wishCell")
        }
        
        let dict = (self.filteredArray[indexPath.row] as AnyObject) as! NSDictionary
        
        print("Dict: \(dict)")
        
        let minStr: String = dict["min"] as! String
        let maxStr: String = dict["max"] as! String
        
        cell?.productName.text = dict["productname"] as? String
        cell?.priceRange.text = "Price Range: \(minStr)$" + " - \(maxStr)$"

        cell?.removeBtn.tag = indexPath.row
        cell?.removeBtn.addTarget(self, action: #selector(removeWishList(_:)), for: .touchUpInside)
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected \(Int(indexPath.row)) row")
        
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.characters.count ) == 0 {
            self.filteredArray = self.wishListArray
        }
        else {
            let searchPredicate = NSPredicate(format: "productname CONTAINS[C] %@", searchText)
            self.filteredArray = (self.wishListArray as NSArray).filtered(using: searchPredicate) as NSArray
            print("Searched Array: \(self.filteredArray)")
        }
        wishListTableView.reloadData()
    }
    

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder
        self.view.endEditing(true)
        addNewProduct.tag = 0
        newProductView.isHidden = true
    }
    
    func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.searchBar.resignFirstResponder
        self.searchBar.endEditing(true)
    }
    
     func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        print("Cancel button clicked")
        
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.filteredArray = self.wishListArray
        wishListTableView.reloadData()
    }

     
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        self.view.endEditing(true)
        addNewProduct.tag = 0
        newProductView.isHidden = true
    }

 
    
    @IBAction func homeAction(_ sender: Any) {
        

        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let UIVC: homePageVC? = storyboard.instantiateViewController(withIdentifier: "homePageVC") as? homePageVC
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionFade
        //transition.subtype = kCATransitionFromTop;
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(UIVC!, animated: false)
    }
    
    @IBAction func chatAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let UIVC: chatListVC? = storyboard.instantiateViewController(withIdentifier: "chatListVC") as? chatListVC
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionFade
        //transition.subtype = kCATransitionFromTop;
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(UIVC!, animated: false)
    }
    
    @IBAction func shareAction(_ sender: Any) {
        
        UIPasteboard.general.string = "www.perfectrdp.us/eamr.life"
        
        let shareTitle: String = "Its very useful app. I am using it, download use it!!"
        let itemsToShare: [Any] = [shareTitle]
        let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.postToTwitter]
        //if iPhone
        if UI_USER_INTERFACE_IDIOM() == .phone {
            present(activityVC, animated: true, completion: { _ in })
        }
        else {
            // Change Rect to position Popover
            activityVC.modalPresentationStyle = .popover
            activityVC.popoverPresentationController?.sourceView = view
            activityVC.popoverPresentationController?.sourceRect = view.frame
            present(activityVC, animated: true, completion: { _ in })
        }
    }
    
    @IBAction func cartAction(_ sender: Any) {
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
