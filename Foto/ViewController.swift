//
//  ViewController.swift
//  Foto
//
//  Created by Isabelle Xu on 11/11/18.
//  Copyright © 2018 WashU. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func photoFromCameraBtn(_ sender: Any) {
        //This condition is used for check availability of camera
        
        if  UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true;
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Alert", message: "You don't have a camera for this device", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func photoFromGalleryBtn(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true;
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imgView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}

