//
//  editViewController.swift
//  HealthyLife
//
//  Created by admin on 8/29/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class editViewController: BaseViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var videoUrl = NSURL()
    var currentUid = (FIRAuth.auth()?.currentUser?.uid)!
    var trailerRef = FIRDatabaseReference()
    
    @IBOutlet weak var desTextField: UITextField!
    
    @IBOutlet weak var chooseVideoButton: UIButton!
    
    @IBAction func editDesAction(sender: AnyObject) {
        if desTextField.text !=  "" {
        trailerRef.child("description").setValue(desTextField.text!)
        }

    }
    
    
    @IBAction func chooseVideoAction(sender: AnyObject) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String , kUTTypeMovie as String]
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
            // we selected a video
            
            self.videoUrl = videoUrl
            thumbNailImage.thumbnailForVideoAtURL(videoUrl)
            chooseVideoButton.hidden = true
            thumbNailImage.hidden = false
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }

    
    @IBAction func editTrailer(sender: AnyObject) {
        showLoading()
        
       
        
        let uploadTask = FIRStorage.storage().reference().child("videosTrailer").child(currentUid).putFile(videoUrl, metadata: nil, completion: { (metadata, error) in
            if error  != nil {
                
                Helper.showAlert("Error", message: error?.localizedDescription, inViewController: self)
                return
            } else {
                var thumbNail = self.thumbNailImage.image
                thumbNail = thumbNail!.resizeImage(CGSize(width: 500.0, height: 500.0))
                
                let imageData: NSData = UIImagePNGRepresentation(thumbNail!)!
                
                
                
                
                // Create a reference to the file you want to upload
                
                let riversRef = FIRStorage.storage().reference().child("images").child("trailer").child(self.currentUid)
                
                // Upload the file to the path ""images/\(key)"
                riversRef.putData(imageData, metadata: nil) { metadata, error in
                    if (error != nil) {
                        // Uh-oh, an error occurred!
                        Helper.showAlert("Error", message: error?.localizedDescription, inViewController: self)
                    } else {
                        // Metadata contains file metadata such as size, content-type, and download URL.
                        if let downloadURL = metadata?.downloadURL()?.absoluteString {
                            self.trailerRef.child("thumbnail").setValue(downloadURL)
                            
                        }
                        
                        self.hideLoading()
                        self.onBack()
                        
                        
                    }
                }
                
                if let videoUrl = metadata?.downloadURL()?.absoluteString {
                    
                    
                    
                    
                    
                    self.trailerRef.child("videoUrl").setValue(videoUrl)
                }
                
            }
        })
        
    }
    
    @IBOutlet weak var thumbNailImage: UIImageView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         trailerRef = FIRDatabase.database().reference().child("videosTrailer").child(currentUid)

        chooseVideoButton.hidden = false
        
        thumbNailImage.hidden = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}