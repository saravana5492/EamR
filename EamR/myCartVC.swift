//
//  myCartVC.swift
//  EamR
//
//  Created by Apple on 21/07/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit
import AFNetworking
import SDWebImage


class myCartVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var menuBtn: UIButton!
    @IBOutlet var cartProdListTV: UITableView!
    var cartListArray = NSArray()
    @IBOutlet var placeOrderBtn: UIButton!
    @IBOutlet var totalPriceLbl: UILabel!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var totalPrice: Float!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            self.menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: UIControlEvents.touchUpInside)
            //segmentedPager.isUserInteractionEnabled = false
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        placeOrderBtn.layer.cornerRadius = 3.0
        
        self.appDelegate.showProgress(true)
        getCartList()

        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getCartList()
    }
    
    func getCartList() {
        
        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/view_cart.php")
        
        let param = ["profile_id" : UserDefaults.standard.value(forKey: "ProfileID")!]
        
        print(param)
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
        let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
        
        manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
        
        manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
            self.appDelegate.showProgress(false)
            let responseDictionary = (responseObject as! NSDictionary)
            print(responseDictionary as Any)
            
            self.cartProdListTV.isHidden = false
            
            if (responseDictionary["status"] as! Int == 1) {
                print("EamR Success")
                self.cartListArray = (responseDictionary["product_list"] as AnyObject) as! NSArray
                self.cartProdListTV.reloadData()
                
                let price = responseDictionary["place_order_price"]!
                //let currency = responseDictionary["currency"]!
                self.totalPriceLbl.text =  "\(price)" + " USD"
                
                self.totalPrice = responseDictionary["place_order_price"]! as! Float
                
            } else {
                print("EamR Failure")
                let alertController = UIAlertController(title: "Sorry", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler:  {(_ action: UIAlertAction) -> Void in
                    self.cartProdListTV.isHidden = true
                    
                    //let currency = responseDictionary["currency"]!
                    
                    self.totalPriceLbl.text = "0.0 USD"
                })
                alertController.addAction(ok)
                self.present(alertController, animated: true) { _ in }
            }
            
        }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
            self.appDelegate.showProgress(false)
            print("Error: \(String(describing: error))")
        })
        
        
    }
    
    // MARK: - UITableViewDataSource
    // number of section(s), now I assume there is only 1 section
    func numberOfSections(in theTableView: UITableView) -> Int {
        return 1
    }
    
    // number of row in the section, I assume there is only 1 row
    func tableView(_ theTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cartListArray.count
    }
    
    func tableView(_ theTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: myCartCell? = (theTableView.dequeueReusableCell(withIdentifier: "cartCell") as? myCartCell)
        if cell == nil {
            cell = myCartCell(style: .default, reuseIdentifier: "cartCell")
        }
        
        let dict = (self.cartListArray[indexPath.row] as AnyObject) as! NSDictionary
        
        print("Dict: \(dict)")
        
        
        cell?.prodName.text = dict["name"] as? String
        var price = (dict["total_price"] as? String)! + " " as String
        price += (dict["currency"] as? String)!
        cell?.prodPrice.text = price
        cell?.prodQtyLbl.text = dict["product_qty"] as? String
        cell?.prodDesc.text = dict["explanation"] as? String
        cell?.prodImage.sd_setImage(with: URL(string: (dict["photo1"] as? String)!), placeholderImage: UIImage(named: "placeholder"))
        
        cell?.deleteProdBtn.tag = indexPath.row
        cell?.deleteProdBtn.addTarget(self, action: #selector(deleteProdCart(_:)), for: .touchUpInside)

        
        cell?.outerView.layer.borderColor = UIColor.lightGray.cgColor
        cell?.outerView.layer.borderWidth = 1.0
        //cell?.outerView.layer.cornerRadius = 5.0
        
        //cell?.outerView.layer.masksToBounds = false
        //cell?.outerView.layer.shadowColor = UIColor.black.cgColor
        //cell?.outerView.layer.shadowOpacity = 0.5
        //cell?.outerView.layer.shadowOffset = CGSize(width: -1, height: 1)
        //cell?.outerView.layer.shadowRadius = 4
        
        //cell?.outerView.layer.shadowPath = UIBezierPath(rect: (cell?.outerView.bounds)!).cgPath
        //cell?.outerView.layer.shouldRasterize = true
        
        //cell?.outerView.layer.rasterizationScale = UIScreen.main.scale
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected \(Int(indexPath.row)) row")
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    @IBAction func deleteProdCart(_ sender: UIButton) {

        let refreshAlert = UIAlertController(title: "Alert", message: "Do you want to remove this product from your cart?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            
            self.appDelegate.showProgress(true)
            let tag = sender.tag
            
            let cartDict = (self.cartListArray[tag] as AnyObject) as! NSDictionary
            
            let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/delete_cart.php")
            
            let param = ["profile_id" : UserDefaults.standard.value(forKey: "ProfileID")!, "product_id" : cartDict["productid"]!]
            
            print(param)
            
            let manager = AFHTTPSessionManager()
            manager.requestSerializer = AFHTTPRequestSerializer()
            manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
            let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
            
            manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
            
            manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
                self.appDelegate.showProgress(false)
                print("Delete product Response: \(responseObject as Any)")
                let responseDictionary = (responseObject as! NSDictionary)
                
                if (responseDictionary["status"] as! Int == 1) {
                    print("EamR Success")
                    let alertController = UIAlertController(title: "Success", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                        self.appDelegate.showProgress(true)
                        self.getCartList()
                    })
                    alertController.addAction(ok)
                    self.present(alertController, animated: true) { _ in }
                    
                } else if (responseDictionary["status"] as! Int == 0) {
                    print("EamR Failure")
                    let alertController = UIAlertController(title: "Failure", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler:  {(_ action: UIAlertAction) -> Void in
                        self.cartProdListTV.isHidden = true
                        self.totalPriceLbl.text = "0.0 USD"
                    })
                    alertController.addAction(ok)
                    self.present(alertController, animated: true) { _ in }
                }
                
            }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
                self.appDelegate.showProgress(false)
                print("Delete product Error: \(String(describing: error))")
            })
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func placeOrderAction(_ sender: Any) {
        
        if self.cartListArray.count != 0 {
            
            UserDefaults.standard.set(self.totalPrice, forKey:"payTotal")
            
            let infoController: placeOrderVC? = storyboard?.instantiateViewController(withIdentifier: "placeOrderVC") as? placeOrderVC
            navigationController?.pushViewController(infoController!, animated: true)
        }
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
    
    @IBAction func myCartAction(_ sender: Any) {
        
        
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
