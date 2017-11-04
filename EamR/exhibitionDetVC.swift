//
//  exhibitionVC.swift
//  EamR
//
//  Created by Apple on 14/07/17.
//  Copyright © 2017 smitiv. All rights reserved.
//
/*
import UIKit
import MXSegmentedPager

class exhibitionDetVC: UIViewController, MXSegmentedPagerDelegate {

    @IBOutlet var navExhibNameLbl: UILabel!
    @IBOutlet var menuBtn: UIButton!
    @IBOutlet var homeBtn: UIButton!
    @IBOutlet var contView: UIView!

    var segmentedPager: MXSegmentedPager!
    var data = [AnyHashable: Any]()
    var sectionNames = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            self.menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: UIControlEvents.touchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //self.navigationController?.setNavigationBarHidden(true, animated: false)

        segmentedPager.segmentedControl.selectionIndicatorLocation = .down
        segmentedPager.segmentedControl.backgroundColor = .white
        segmentedPager.segmentedControl.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 254 / 255.0, green: 62 / 255.0, blue: 47 / 255.0, alpha: 1.0)]
        segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 254 / 255.0, green: 62 / 255.0, blue: 47 / 255.0, alpha: 1.0)]
        segmentedPager.segmentedControl.selectionStyle = .fullWidthStripe
        segmentedPager.segmentedControl.selectionIndicatorColor = .orange

        
        // Do any additional setup after loading the view.
    }

    
    func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        return ["Booths", "Info", "Reviews"][index]
    }
    
    func segmentedPager(_ segmentedPager: MXSegmentedPager, didScrollWith parallaxHeader: MXParallaxHeader) {
        print("progress \(parallaxHeader.progress)")
    }
    
    @IBAction func homeBtnAction(_ sender: UIButton) {
    }
    
    @IBAction func backAction(_ sender: UIButton) {
    }
    
    @IBAction func chatAction(_ sender: UIButton) {
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
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

}*/
