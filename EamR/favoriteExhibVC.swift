//
//  favoriteExhibVC.swift
//  EamR
//
//  Created by Apple on 18/07/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit
import AFNetworking
import SDWebImage


class favoriteExhibVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet var menuBtn: UIButton!
    @IBOutlet var exhibitionTableView: UITableView!
    var favoritesListArray = NSArray()
    var appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            self.menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: UIControlEvents.touchUpInside)
            //segmentedPager.isUserInteractionEnabled = false
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Clear rule color ------------------
        exhibitionTableView.separatorColor = UIColor.clear

        self.appDelegate.showProgress(true)
        getFavoritesList()

        // Do any additional setup after loading the view.
    }

    
    
    func getFavoritesList() {
        
        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/get_fav.php")
        
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
            self.exhibitionTableView.isHidden = false

            if (responseDictionary["status"] as! Int == 1) {
                print("EamR Success")
                
                if ((responseDictionary["exhibition_lists"] as? NSNull) != nil) {
                    let alertController = UIAlertController(title: "Sorry", message:"You have not added favorites", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(ok)
                    self.present(alertController, animated: true) { _ in }

                } else {
                    self.favoritesListArray = responseDictionary["exhibition_lists"] as! NSArray
                    self.exhibitionTableView.reloadData()
                }
            } else if (responseDictionary["status"] as! Int == 0) {
                print("EamR Failure")
                let alertController = UIAlertController(title: "Failure", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler:  {(_ action: UIAlertAction) -> Void in
                    self.exhibitionTableView.isHidden = true
                })
                alertController.addAction(ok)
                self.present(alertController, animated: true) { _ in }
            }
            
        }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
            self.appDelegate.showProgress(false)
            print("Favorite Exhibition Error: \(String(describing: error))")
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSections(in theTableView: UITableView) -> Int {
        return 1
    }
    
    // number of row in the section, I assume there is only 1 row
    func tableView(_ theTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoritesListArray.count
    }
    
    func tableView(_ theTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: exhibitionCell? = (theTableView.dequeueReusableCell(withIdentifier: "exhibitionCell") as? exhibitionCell)
        if cell == nil {
            cell = exhibitionCell(style: .default, reuseIdentifier: "exhibitionCell")
        }
        
        let dict = (self.favoritesListArray[indexPath.row] as AnyObject) as! NSDictionary
        print("Dict: \(dict)")

        
        let startDateStr : String = dict["start_date"] as! String
        let endDateStr : String = dict["end_date"] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
        let date = dateFormatter.date(from: startDateStr)
        let endDate = dateFormatter.date(from: endDateStr)
        
        dateFormatter.dateFormat = "dd-MMM-yyyy"
        let startDateF = dateFormatter.string(from: date!)
        let endDateF = dateFormatter.string(from: endDate!)
        
        let exhibDate = startDateF + " to " + endDateF
        
        cell?.nameLbl.text = dict["name"] as? String
        cell?.countryLbl.text = dict["place"] as? String
        cell?.venuLbl.text = dict["place"] as? String
        cell?.industryLbl.text = dict["industry"] as? String
        cell?.startDateLbl.text = startDateF //"01-07-2017 to 30-07-2017"  //dict["name"] as? String
        cell?.endDateLbl.text = endDateF
        cell?.descTV.text = dict["shortdes"] as? String
        cell?.newDistLbl.text = "\(dict["distance"] as! String) km"
        //cell?.activity.isHidden = false
        //cell?.activity.startAnimating()
        cell?.exbImageView.sd_setImage(with: URL(string: (dict["image"] as? String)!), placeholderImage: UIImage(named: "placeholder"))
        cell?.removeBtn.tag = indexPath.row
        cell?.removeBtn.addTarget(self, action: #selector(removeExhib(_:)), for: .touchUpInside)

        //cell?.exbImageView.image = UIImage(named:"exhibition.jpg")
        //cell?.activity.stopAnimating()
        //cell?.activity.isHidden = true
        
        
        cell?.descTV.isScrollEnabled = false
        cell?.descTV.isEditable = false
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected \(Int(indexPath.row)) row")
        
        let dict = (self.favoritesListArray[indexPath.row] as AnyObject) as! NSDictionary
        
        let data = NSKeyedArchiver.archivedData(withRootObject: dict)
        UserDefaults.standard.set(data, forKey: "exhibDetail")
        UserDefaults.standard.set(dict["sno"] as? String, forKey: "selExhibId")
        
        tableView.deselectRow(at: indexPath, animated: false)
        let infoController: exhibitionDetailsVC = storyboard?.instantiateViewController(withIdentifier: "exhibitionDetailsVC") as! exhibitionDetailsVC
        self.navigationController?.pushViewController(infoController, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    @IBAction func removeExhib(_ sender: UIButton) {
        let refreshAlert = UIAlertController(title: "Alert", message: "Do you want to remove this Exhibition from Favorite list?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            
            self.appDelegate.showProgress(true)
            let tag = sender.tag
            
            let cartDict = (self.favoritesListArray[tag] as AnyObject) as! NSDictionary
            
            let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/delete_favourite.php")
            
            let param = ["profile_id" : UserDefaults.standard.value(forKey: "ProfileID")!, "exhibitionid" : cartDict["sno"]!]
            
            print(param)
            
            let manager = AFHTTPSessionManager()
            manager.requestSerializer = AFHTTPRequestSerializer()
            manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
            let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
            
            manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
            
            manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
                self.appDelegate.showProgress(false)
                print("Delete Exhibition from Favorite Response: \(responseObject as Any)")
                let responseDictionary = (responseObject as! NSDictionary)
                
                if (responseDictionary["status"] as! Int == 1) {
                    print("EamR Success")
                    let alertController = UIAlertController(title: "Success", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                        self.appDelegate.showProgress(true)
                        self.getFavoritesList()
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}