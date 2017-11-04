//
//  purchaseHistoryVC.swift
//  EamR
//
//  Created by Apple on 24/07/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit
import AFNetworking
import SDWebImage

class purchaseHistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var purchHistTableView: UITableView!
    @IBOutlet var menuBtn: UIButton!
    var purchaseHistoryArray = NSArray()
    var appDelegate = UIApplication.shared.delegate as! AppDelegate


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            self.menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: UIControlEvents.touchUpInside)
            //segmentedPager.isUserInteractionEnabled = false
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        self.appDelegate.showProgress(true)
        getPurchasesList()

        // Do any additional setup after loading the view.
    }
    
    func getPurchasesList() {
        
        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/purchase_history.php")
        
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
            print("Purchase History Response: \(responseDictionary as Any)")
            
            if (responseDictionary["status"] as! Int == 1) {
                print("EamR Success")
                
                if ((responseDictionary["product_list"] as? NSNull) != nil) {
                    let alertController = UIAlertController(title: "Sorry", message:"You do not have purchase history", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(ok)
                    self.present(alertController, animated: true) { _ in }
                    
                } else {
                    self.purchaseHistoryArray = responseDictionary["product_list"] as! NSArray
                    
                    if (self.purchaseHistoryArray.count == 0) {
                        let alertController = UIAlertController(title: "Sorry", message:"You do not have purchase history", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(ok)
                        self.present(alertController, animated: true) { _ in }
                    } else {
                        self.purchHistTableView.reloadData()
                    }
                }
            } else if (responseDictionary["status"] as! Int == 0) {
                print("EamR Failure")
                let alertController = UIAlertController(title: "Failure", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(ok)
                self.present(alertController, animated: true) { _ in }
            }
            
        }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
            self.appDelegate.showProgress(false)
            print("Favorite Exhibition Error: \(String(describing: error))")
        })
        
        
    }

    func numberOfSections(in theTableView: UITableView) -> Int {
        return 1
    }
    
    // number of row in the section, I assume there is only 1 row
    func tableView(_ theTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.purchaseHistoryArray.count
    }
    
    func tableView(_ theTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: purchHistCell? = (theTableView.dequeueReusableCell(withIdentifier: "purchHistCell") as? purchHistCell)
        if cell == nil {
            cell = purchHistCell(style: .default, reuseIdentifier: "purchHistCell")
        }
        
        let dict = (self.purchaseHistoryArray[indexPath.row] as AnyObject) as! NSDictionary
        
        print("Dict: \(dict)")
        var price = (dict["total_price"] as? String)! + " " as String
        price += (dict["currency"] as? String)!
        
        let dateStr : String = dict["created_date"] as! String
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        let date = dateFormatter.date(from: dateStr)
        
        dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
        let newDate = dateFormatter.string(from: date!)
        
        cell?.purchProdName.text = dict["name"] as? String
        cell?.purchProdPrice.text = price
        cell?.purchDate.text = newDate  //dict["name"] as? String
        cell?.purchProdDesc.text = dict["delivery_status"] as? String
        cell?.exhibitionName.text = dict["event_name"] as? String
        cell?.exhibitorName.text = dict["exhibitor_name"] as? String
        
        if (dict["delivery_status"] as? String == "Completed") {
            cell?.purchProdDesc.textColor = UIColor(red: 64.0/255.0, green: 128.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        } else if (dict["delivery_status"] as? String == "Shipped") {
            cell?.purchProdDesc.textColor = UIColor(red: 64.0/255.0, green: 0.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        } else if (dict["delivery_status"] as? String == "Processing") {
            cell?.purchProdDesc.textColor = UIColor(red: 255.0/255.0, green: 128.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        } else if (dict["delivery_status"] as? String == "Pending") {
            cell?.purchProdDesc.textColor = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        } else {
            cell?.purchProdDesc.textColor = UIColor.white
        }

        cell?.PurchImageView.sd_setImage(with: URL(string: (dict["photo1"] as? String)!), placeholderImage: UIImage(named: "placeholder"))
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected \(Int(indexPath.row)) row")
        
        /*let dict = (self.purchaseHistoryArray[indexPath.row] as AnyObject) as! NSDictionary
        
        UserDefaults.standard.set(dict, forKey: "exhibDetail")
        
        tableView.deselectRow(at: indexPath, animated: false)
        let infoController: exhibitionDetailsVC = storyboard?.instantiateViewController(withIdentifier: "exhibitionDetailsVC") as! exhibitionDetailsVC
        self.navigationController?.pushViewController(infoController, animated: true)*/
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //self.searchBar.resignFirstResponder
        //dropDownTableView.isHidden = true
        //self.searchBar.endEditing(true)
        
        let offset: CGPoint = purchHistTableView.contentOffset
        let bounds: CGRect = purchHistTableView.bounds
        let size: CGSize = purchHistTableView.contentSize
        let inset: UIEdgeInsets = purchHistTableView.contentInset
        let y = Float(offset.y + bounds.size.height - inset.bottom)
        let h = Float(size.height)
        
        let reload_distance: Float = 10
        if y > h + reload_distance {
            
            ///isTableEnd = true
            print("Table view scrolled to end")
            
            self.getPurchasesList()
        }
        
        /*if (self.exhibitionTableView.contentOffset.y >= (self.exhibitionTableView.contentSize.height - self.exhibitionTableView.bounds.size.height))
         {
         // Don't animate
         print("Table view scrolled to end 222")
         }*/
        
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
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let UIVC: myCartVC? = storyboard.instantiateViewController(withIdentifier: "myCartVC") as? myCartVC
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionFade
        //transition.subtype = kCATransitionFromTop;
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(UIVC!, animated: false)
        
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
