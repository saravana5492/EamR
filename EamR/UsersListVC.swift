//
//  UsersListVC.swift
//  EamR
//
//  Created by Apple on 25/09/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit
import AFNetworking
import SDWebImage


class UsersListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var userListTableView: UITableView!
    var userListArray = NSArray()
    var selectedExbChat = NSDictionary()
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var navHead: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Selected Chat dictionary ***
        let data = UserDefaults.standard.value(forKey: "selectedExbChat")
        self.selectedExbChat = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! NSDictionary
        
        navHead.text = self.selectedExbChat["exbh_name"] as? String
        
        self.userListTableView.separatorColor = UIColor.clear
        
        getUsersList()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getUsersList()
        
        // No need for semicolon
    }
    
    
    
    func getUsersList() {
        self.appDelegate.showProgress(true)
        let url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/get_chat_group_users.php")
        
        let param = ["profile_id" : UserDefaults.standard.value(forKey: "ProfileID")!, "exhibitor_id" : self.selectedExbChat["exhibitor_id"]!]
        
        print(param)
        
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
        let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
        
        manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
        
        manager.post((url!.absoluteString), parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
            self.appDelegate.showProgress(false)
            //self.userListTableView.isHidden = false
            let responseDictionary = (responseObject as! NSDictionary)
            print(responseDictionary as Any)
            
            if (responseDictionary["status"] as! Int == 1) {
                print("EamR Success")
                self.userListArray = (responseDictionary["user_list"] as AnyObject) as! NSArray
                
                if self.userListArray.count == 0 {
                    self.userListTableView.isHidden = true
                } else {
                    self.userListTableView.reloadData()
                }
                
            } else {
                print("EamR Failure")
                let alertController = UIAlertController(title: "Sorry", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler:  {(_ action: UIAlertAction) -> Void in
                })
                alertController.addAction(ok)
                self.present(alertController, animated: true) { _ in }
            }
            
        }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
            self.appDelegate.showProgress(false)
            print("Error: \(String(describing: error))")
        })
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: userListCell? = (tableView.dequeueReusableCell(withIdentifier: "userListCell", for: indexPath) as? userListCell)
        
        let dict = (self.userListArray[indexPath.row] as AnyObject) as! NSDictionary
        
        print("Dict: \(dict)")
        
        
        cell?.userImgView.sd_setImage(with: URL(string: (dict["user_image"] as? String)!), placeholderImage: UIImage(named: "profilePlaceholder"))
        cell?.userName?.text = dict["user_name"] as? String

        cell?.userListBackView?.layer.cornerRadius = 31.5
        cell?.userImgView?.layer.masksToBounds = true
        cell?.userImgView?.layoutIfNeeded()
        cell?.userImgView?.layer.cornerRadius = 29.5
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 79.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let dict = (self.userListArray[indexPath.row] as AnyObject) as! NSDictionary
      
        let userProfile: String = dict["profile_id"] as! String!
        
        if (userProfile == UserDefaults.standard.value(forKey: "ProfileID") as! String) {
            
        } else {
            
            UserDefaults.standard.setValue("userList", forKey: "pChatFrom")
            
            let data = NSKeyedArchiver.archivedData(withRootObject: dict)
            UserDefaults.standard.set(data, forKey: "selectedUser")
            
            let infoController: privateChatVC? = storyboard?.instantiateViewController(withIdentifier: "privateChatVC") as? privateChatVC
            navigationController?.pushViewController(infoController!, animated: true)
        }
        
        
    }

    
    @IBAction func backAction(_ sender: Any) {

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
