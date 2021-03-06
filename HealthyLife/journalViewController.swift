//
//  journalViewController.swift
//  HealthyLife
//
//  Created by admin on 7/27/16.
//  Copyright © 2016 NguyenBui. All rights reserved.
//

import UIKit
import Firebase
import TabPageViewController

class journalViewController: BaseViewController {
    
    @IBOutlet weak var avaImage: UIImageView!
    
    @IBOutlet weak var weightChangeLabel: UILabel!
    
    @IBOutlet weak var planButton: UIButton!
    
    @IBOutlet weak var addIcon: UIBarButtonItem!
    
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var heightOfTopView: NSLayoutConstraint!
    
    @IBOutlet weak var trackingButton: NHDCustomSubmitButton!
    
    @IBOutlet weak var uploadButton: NHDCustomSubmitButton!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var heightLabel: UILabel!
    
    @IBOutlet weak var followerCountLabel: UILabel!
    
    @IBOutlet weak var settingButton: UIButton!
    
    @IBOutlet weak var topView: UIView!
    
    let tc = BaseTabPageViewController()
    var vc1 = displayFoodViewController()
    var vc2 = displayResultViewController()
    var vc3 = ChartViewController()
    var constantHeightOfTopView: CGFloat = 130
    
    var currentUserID = DataService.currentUserID
    var currentUserName = DataService.currentUserName
    var userSetting: UserSetting?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUser()
        
        setupProfile()
        initTabPageView()
    }
    
    func loadUser() {
        
        avaImage.layer.cornerRadius = 20
        avaImage.clipsToBounds = true
        addIcon.title = "Add Food"
        
        if currentUserID != DataService.currentUserID {
            settingButton.hidden = true
            planButton.hidden = true
            trackingButton.hidden = true
            uploadButton.hidden = true
            constantHeightOfTopView = 100
            addIcon.title = ""
        }
        heightOfTopView.constant = constantHeightOfTopView
    }
    
    func setupProfile() {
        //MARK: set up profile
        
        let ref = DataService.BaseRef
        
        ref.child("users/\(currentUserID)/username").observeEventType(.Value, withBlock: { snapshot in
            self.name.text = snapshot.value as? String
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setValue(snapshot.value as? String, forKey: "currentUserName")
        })
        
        ref.child("users/\(currentUserID)/user_setting").observeEventType(.Value, withBlock: { snapshot in
            if let postDictionary = snapshot.value as? NSDictionary {
                
                self.userSetting = UserSetting(dictionary: postDictionary)

                ref.child("users").child(self.currentUserID).child("results_journal").observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot!) in
                    
                    let currentWeight = snapshot.value!["CurrentWeight"] as! String
                    let startingWeight = self.userSetting!.weightChanged ?? "0"                    
                    
                    let weightChanged = Double(currentWeight)! - Double(startingWeight)!
                    
                    if weightChanged > 0 {
                        self.weightChangeLabel.text = "gain: \(abs(weightChanged)) kg"
                    } else {
                        self.weightChangeLabel.text = "lose: \(abs(weightChanged)) kg"
                    }
                }
                
                self.heightLabel.text = Helper.parseHeightToMetre(self.userSetting?.height)

                var followerCount = 0
                if let count = postDictionary["followerCount"] as? Int {
                    followerCount = count
                }
                self.followerCountLabel.text = "\(followerCount) followers"
                
            } else {
                
                self.avaImage.image = UIImage(named: "defaults")
            }
            
        })
        
        ref.child("users").child(currentUserID).child("followerCount").observeEventType(.Value, withBlock: { snapshot in
            
            if let count = snapshot.value as? Int {
                self.followerCountLabel.text = "\(count) followers"
            }
            
        })
        
        ref.child("users/\(currentUserID)/photoURL").observeEventType(.Value, withBlock: { snapshot in
            if let photoURL = snapshot.value as? String {
                self.avaImage.kf_setImageWithURL(NSURL(string: photoURL))
            }
        })
    }
    
    func initTabPageView() {
        
        vc2 = displayResultViewController(nibName: String(displayResultViewController), bundle: nil)
 
        vc1.currentUserID = currentUserID
        vc2.currentUserID = currentUserID
        
        tc.tabItems = [(vc1, "Food"), (vc2, "Result"), (vc3, "Graph")]
        tc.actionDelegate = self
        
        var option = TabPageOption()
        option.currentColor = Configuration.Colors.primary
        option.tabWidth = view.frame.width / CGFloat(tc.tabItems.count)
        tc.option = option
        
        containView.addSubview(tc.view)
        tc.view.snp_makeConstraints { (make) in
            make.edges.equalTo(containView.snp_edges)
        }
        
        vc1.delegate = self
        vc2.delegate = self
    }
    
    @IBAction func onAddButtonPressed(sender: UIBarButtonItem) {
        if let index = tc.currentIndex {
            if index == 0 {
                let vc = uploadFoodViewController(nibName: String(uploadFoodViewController), bundle: nil)
                navigationController?.pushViewController(vc, animated: true)
            } else if index == 1 {
                let vc = uploadResultViewController(nibName: String(uploadFoodViewController), bundle: nil)
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}

extension journalViewController: BaseTabPageViewControllerDelegate {
    
    func pageViewControllerWasSelected(index: Int) {
        switch index {
        case 0:
            addIcon.title = (currentUserID == DataService.currentUserID ? "Add Food" : "")
            vc1.collectionView.reloadData()
            break
        case 1:
            addIcon.title = (currentUserID == DataService.currentUserID ? "Add Result" : "")
//            vc2.tableView.reloadData()
        case 2:
            addIcon.title = ""
            vc3.delegate = self
            vc3.results = vc2.results.reverse()
            vc3.foods = vc1.foods
            vc3.tableView.reloadData()
            
            break
        default:
            break
        }
    }
}

extension journalViewController: BaseScroolViewDelegate {
    
    func pageViewControllerIsMoving(isUp: Bool) {
        
        if isUp {
            if topView.tag != 1 {
                topView.tag = 1
                topView.alpha = 0
                view.layoutIfNeeded()
                UIView.animateWithDuration(Configuration.animationDuration, animations: {
                    self.heightOfTopView.constant = self.constantHeightOfTopView
                    self.view.layoutIfNeeded()
                    self.topView.alpha = 1
                })
                //                displayLogoutButton()
            }
        } else if topView.tag != 2 {
            topView.tag = 2
            view.layoutIfNeeded()
            topView.alpha = 1
            UIView.animateWithDuration(Configuration.animationDuration, animations: {
                self.heightOfTopView.constant = 0;
                self.view.layoutIfNeeded()
                self.topView.alpha = 0
            })
            //            displaySettingButton()
        }
    }
    
    
    func displaySettingButton() {
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setBackgroundImage(UIImage(named: "icn_down"), forState: UIControlState.Normal)
        button.tintColor = UIColor.whiteColor()
        button.addTarget(self, action: #selector(self.showUserPanel), forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    func showUserPanel() {
        
        pageViewControllerIsMoving(true)
    }
    
    @IBAction func onSettingTapped(sender: AnyObject) {
        let vc = SettingViewController(nibName: String(SettingViewController), bundle: nil)
        let navVC = BaseNavigationController(rootViewController: vc)
        vc.userSetting = userSetting
        presentViewController(navVC, animated: true, completion: nil)
    }

}
