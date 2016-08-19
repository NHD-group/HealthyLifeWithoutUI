//
//  uploadVideoViewController.swift
//  HealthyLife
//
//  Created by admin on 8/16/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//


import UIKit
import Firebase
import MobileCoreServices
import AVFoundation
import MBProgressHUD

class uploadVideoViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var nameVideoTextField: UITextField!
    @IBOutlet weak var libImagesButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var desTextField: UITextField!
    @IBOutlet weak var resultImage: UIImageView!
    
    @IBAction func chooseImageAction(sender: AnyObject) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String , kUTTypeMovie as String]
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    var videoUrl: NSURL?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        if videoUrl != nil {
            resultImage.thumbnailForVideoAtURL(videoUrl!)
        }
        title = "Upload Video"
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
            // we selected a video
            self.videoUrl = videoUrl
            resultImage.thumbnailForVideoAtURL(videoUrl)
        }
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            resultImage.image = image
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func onCamera(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .Camera
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func uploadAction(sender: AnyObject) {
        
        let name = nameVideoTextField.text
        if name?.characters.count == 0 {
            Helper.showAlert("Warning", message: "Please enter the title of video", inViewController: self)
            return
        }
        guard let videoUrl = videoUrl else {
            Helper.showAlert("Warning", message: "Please select an photo/video!", inViewController: self)
            return
        }
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)

        let key = DataService.dataService.userRef.child("yourVideo").childByAutoId().key

        let uploadTask = FIRStorage.storage().reference().child("videos").child(key).putFile(videoUrl, metadata: nil, completion: { (metadata, error) in
            if error  != nil {
                
                Helper.showAlert("Error", message: error?.localizedDescription, inViewController: self)
            } else {
                if let videoUrl = metadata?.downloadURL()?.absoluteString {
                    
                    
                    let videoInfo: [String: AnyObject] = ["videoUrl": videoUrl, "name": self.nameVideoTextField.text!, "description": self.desTextField.text!]
                    
                    DataService.dataService.userRef.child("yourVideo").child(key).setValue(videoInfo)
                }
                
            }
        })
        
        uploadTask.observeStatus(.Success, handler: { (snapshot) in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.onBack()
        })
        
    }
}


