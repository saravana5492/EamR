//
//  newReviewVC.swift
//  EamR
//
//  Created by Apple on 20/07/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

import UIKit
import AFNetworking
import FloatRatingView


class newReviewVC: UIViewController, FloatRatingViewDelegate, UITextViewDelegate {

    @IBOutlet var reviewTitleView: UIView!
    @IBOutlet var reviewTitleTextField: UITextField!
    @IBOutlet var reviewTextView: UIView!
    @IBOutlet var reviewTextField: UITextView!
    @IBOutlet var starRating: FloatRatingView!
    @IBOutlet var addReviewBtn: UIButton!
    var placeholderLabel : UILabel!
    @IBOutlet var bottomBarView: UIView!
    @IBOutlet var viewBtmSpace: NSLayoutConstraint!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var reviewTitleStr: String!
    var reviewTextStr: String!
    var reviewRatingStr: String!
    var reviewFor: String!
    var reviewForDict : NSDictionary!
    var reviewUserId: String!
    var url: NSURL!
    var param: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        
        reviewTitleView.layer.borderWidth = 1
        reviewTitleView.layer.cornerRadius = 3
        reviewTitleView.layer.borderColor = UIColor(red: 254.0/255.0, green: 62.0/255.0, blue: 47.0/255.0, alpha: 1.0).cgColor
        reviewTextView.layer.borderWidth = 1
        reviewTextView.layer.cornerRadius = 3
        reviewTextView.layer.borderColor = UIColor(red: 254.0/255.0, green: 62.0/255.0, blue: 47.0/255.0, alpha: 1.0).cgColor
        addReviewBtn.layer.cornerRadius = 3
        
        //reviewTextField.delegate = self
        //reviewTextField.text = "Write your review.."
        //reviewTextField.textColor = UIColor.lightGray
        
        reviewTextField.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Write your review.."
        placeholderLabel.font = UIFont.systemFont(ofSize: (reviewTextField.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        reviewTextField.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (reviewTextField.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !reviewTextField.text.isEmpty
        
        bottomBarView.isHidden = true
        //viewBtmSpace.constant = 0
        
        starRating.emptyImage = UIImage(named: "not_selected_star")
        starRating.fullImage = UIImage(named: "selected_star")
        // Optional params
        starRating.delegate = self
        starRating.contentMode = UIViewContentMode.scaleAspectFit
        starRating.maxRating = 5
        starRating.minRating = 1
        starRating.editable = true
        starRating.halfRatings = false
        starRating.floatRatings = true

        reviewUserId = UserDefaults.standard.value(forKey: "ProfileID") as! String
        
        self.reviewFor = UserDefaults.standard.value(forKey: "reviewFor") as! String
        
        if self.reviewFor == "exhibition" {
            //reviewForDict = UserDefaults.standard.value(forKey: "exhibDetail") as! NSDictionary
            let data = UserDefaults.standard.value(forKey: "exhibDetail")
            reviewForDict = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! NSDictionary
        } else if self.reviewFor == "exhibitor" {
            let data = UserDefaults.standard.value(forKey: "exhibitorDetail")
            reviewForDict = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! NSDictionary
        } else if self.reviewFor == "product" {
            let data = UserDefaults.standard.value(forKey: "productDetail")
            reviewForDict = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! NSDictionary
        }
        
        reviewRatingStr = ""
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if UserDefaults.standard.bool(forKey: "loggedIn") == true {
            bottomBarView.isHidden = false
            //viewBtmSpace.constant = 52
        }
        else {
            bottomBarView.isHidden = true
            //viewBtmSpace.constant = 0
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    // MARK: FloatRatingViewDelegate
    
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating:Float) {
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        reviewRatingStr = String(rating)
    }


    @IBAction func addReviewAction(_ sender: Any) {

        reviewTitleStr = reviewTitleTextField.text!
        reviewTextStr = reviewTextField.text!
        
        if reviewTitleStr == "" {
            let alertController = UIAlertController(title: "Failure", message:"Please give a title for your review", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(ok)
            self.present(alertController, animated: true) { _ in }

        } else if (reviewTextStr == "" || reviewTextStr == "Write your review..") {
            let alertController = UIAlertController(title: "Failure", message:"Please give your review", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(ok)
            self.present(alertController, animated: true) { _ in }
            
        } else {
            
            self.appDelegate.showProgress(true)

            if self.reviewFor == "exhibition" {
                url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/add_exhibition_review.php")! as NSURL
                
                if reviewRatingStr == "" {
                    reviewRatingStr = "1";
                }
                
                param = ["profile_id" : reviewUserId, "exhibition_id" : reviewForDict["sno"]!, "review_name" : reviewTitleStr, "reviewdesc" : reviewTextStr, "review_rating" : reviewRatingStr]
                
            } else if self.reviewFor == "exhibitor" {
                url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/add_exhibitor_review.php")! as NSURL

                if reviewRatingStr == "" {
                    reviewRatingStr = "1";
                }

                param = ["profile_id" : reviewUserId, "exhibitor_id" : reviewForDict["sno"]!, "review_name" : reviewTitleStr, "reviewdesc" : reviewTextStr, "review_rating" : reviewRatingStr]
                
            } else if self.reviewFor == "product" {
                url = URL(string: "http://perfectrdp.us/eamr.life/exhibition_webservice/add_product_review.php")! as NSURL

                if reviewRatingStr == "" {
                    reviewRatingStr = "1";
                }

                param = ["profile_id" : reviewUserId, "product_id" : reviewForDict["sno"]!, "review_name" : reviewTitleStr, "reviewdesc" : reviewTextStr, "review_rating" : reviewRatingStr]
                
            }
            
            print(param)
            
            let manager = AFHTTPSessionManager()
            manager.requestSerializer = AFHTTPRequestSerializer()
            manager.responseSerializer = AFJSONResponseSerializer(readingOptions: JSONSerialization.ReadingOptions.allowFragments)
            let acceptableContent : NSSet = NSSet(objects: "application/json", "text/html", "text/plain")
            
            manager.responseSerializer.acceptableContentTypes = acceptableContent as? Set<String>
            
            manager.post((url!.absoluteString)!, parameters: param, progress: nil, success: {(operation: URLSessionTask, responseObject: Any) -> Void in
                self.appDelegate.showProgress(false)
                print("Login/Registration User Response: \(responseObject as Any)")
                let responseDictionary = (responseObject as! NSDictionary)
                
                if (responseDictionary["status"] as! Int == 1) {
                    print("EamR Success")
                    let alertController = UIAlertController(title: "Success", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                        self.navigationController?.popViewController(animated: true)
                    })
                    alertController.addAction(ok)
                    self.present(alertController, animated: true) { _ in }
                    
                } else if (responseDictionary["status"] as! Int == 0) {
                    print("EamR Failure")
                    let alertController = UIAlertController(title: "Failure", message:responseDictionary["msg"] as? String, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(ok)
                    self.present(alertController, animated: true) { _ in }
                }
                
            }, failure: { (operation: URLSessionTask?, error: Error?) -> Void in
                self.appDelegate.showProgress(false)
                print("Login/Registration User Error: \(String(describing: error))")
            })
        }
    }
    
    /*func textViewDidBeginEditing(_ textView: UITextView) {
        if reviewTextField.textColor == UIColor.lightGray {
            reviewTextField.text = nil
            reviewTextField.textColor = UIColor.black
        }
    }*/
    
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func chatAction(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let UIVC: chatListVC? = storyboard.instantiateViewController(withIdentifier: "chatListVC") as? chatListVC
        let transition = CATransition()
        transition.duration = 0
        transition.type = kCATransitionFade
        //transition.subtype = kCATransitionFromTop;
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(UIVC!, animated: false)
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        
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
    
    @IBAction func myCartAction(_ sender: UIButton) {
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
