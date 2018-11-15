//
//  ViewController.swift
//  MemeMe
//
//  Created by Faisal Albellaihi on 13/11/2018.
//  Copyright © 2018 FAISAL Albellaihi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate{
    @IBOutlet weak var ImagePicker: UIImageView!
    
    @IBOutlet weak var NavBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var CameraButton: UIBarButtonItem!
    @IBOutlet weak var Share: UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    
    // #MARK: TopText textfield
    @IBOutlet weak var TopTxt: UITextField!
    // #MARK: Bottomtext textfield
    @IBOutlet weak var BottomTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PreparProperties()
        
      
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeTokeyBoardNotification()
        
    }
    // #MARK: VIEW WILL DISAPEAR
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeTokeyBoardNotification() // unsubscribe from notification
        
    }
    
    // #MARK: END EDITING TEXT?
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        TopTxt.endEditing(true)
        BottomTxt.endEditing(true)
       
       
    }
    
    // #MARK: TEXT FIELD SHOULR RETURN
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        TopTxt.resignFirstResponder()
        BottomTxt.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "Top" {
            textField.text = ""
        }
        else if textField.text == "Bottom" {
            textField.text=""
        }
        
    }
    
    struct Meme {
        
        var topText:String!
        var bottomText:String!
        var originalImage: UIImage!
        var memedImage:UIImage!
    }
    
    func grayColor() -> UIColor {
        
        return UIColor.gray
    }
    func blackColor() ->UIColor {
        return UIColor.black
    }
    
    func PreparProperties(){
     
        self.TopTxt.delegate = self
        self.BottomTxt.delegate = self
        TopTxt.isEnabled = false;
        TopTxt.text = ""
        BottomTxt.text = ""
        BottomTxt.isEnabled = false;
        Share.isEnabled = false
       ImagePicker.image = nil
        view.backgroundColor = grayColor()
        
        
    }
    
    //#MARK: TEXT FIELD STYLE
    func TextFieldStyle(text: UITextField, string: String)->UITextField{
        
        
        let memeTextAttributes:[String: Any] = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue:-3.0 ]
        
        text.textAlignment = .center
        text.borderStyle = .none
        text.defaultTextAttributes = memeTextAttributes
        text.text = string
        text.isEnabled = true
        
        return text
    }
 
    @IBAction func ShareImage(_ sender: Any) {
        let memedImage = generateMemedImage()
        let ActivityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        ActivityViewController.completionWithItemsHandler =  { activity, success, items, error in
            
            if success {
                self.save(memedImage: memedImage)
                self.dismiss(animated: true, completion: nil)
                
            }
            
            
        }
        present(ActivityViewController, animated: true,completion:nil)
        
    }
    // cancel the operation
    @IBAction func Cancel(_ sender: Any) {
        let CancelAC = UIAlertController(title: NSLocalizedString("Cancel Editing" , comment: "Cancel editing the image?" ), message: NSLocalizedString("Changes will be unsaved", comment: "You clicked on cancel if you click on OK all changes will be unsaved"), preferredStyle: .alert) // Localized Alert Controller
        let CancelConfirm = UIAlertAction(title:  NSLocalizedString("OK", comment: "Cancel editing"), style: .default) { (action) in
            
            self.PreparProperties()
        } // Lozalized Alert Action
        
        
         let CancelActionNO = UIAlertAction(title:  NSLocalizedString("Continue Editing", comment:" Goback to editor " ), style: .default) { (action) in}
        CancelAC.addAction(CancelConfirm)
        CancelAC.addAction(CancelActionNO)
        
        self.present(CancelAC, animated: true){} // show the Alert
    }
    
    // #MARK: ALBUM IMAGE PICKER
    @IBAction func PickAnImageFromAlbum(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    // #MARK CAMERA BUTTON ACTION
    @IBAction func CameraButton(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        present(pickerController, animated: true, completion: nil)
    }
    
    // #MARK: IMAGE PICKER CONTROLLER
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            ImagePicker.image = image
            TopTxt = TextFieldStyle(text: TopTxt, string: "Top") // set the top text and its string
            BottomTxt = TextFieldStyle(text: BottomTxt, string: "Bottom") // set the bottom string
            Share.isEnabled = true // disable the share button until the image has been uploaded
            view.backgroundColor = blackColor() // set background color to black to make the image look much better
        }
        dismiss(animated: true, completion: nil)
    }
    // #MARK: DID USER CANCELED IMAGE?
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
 
       
    }
    //#MARK KEYBOARD WILL SHOW
    @objc func keyboardWillShow(_ notification : Notification){
        view.frame.origin.y = -getKeyboardHight(notification)
    }
   
    // #MARK: KEYBOARD WILL HIDE
    @objc func keyboardWillHide(_ notification : Notification) {
    
        view.frame.origin.y = 0
    }
    
    
    ///#MARK: KEYBOARD HIGHT
    func getKeyboardHight(_ notification:Notification)->CGFloat {
        let usrInfo = notification.userInfo
        let keyboardSize = usrInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // size of the keyboard rect
        return keyboardSize.cgRectValue.height
    }
  
    
    
    // #MARK: SUBSCRIBE TO KEYBOARD NOTIFICATIONS
    func subscribeTokeyBoardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    // #MARK: UNSBSCRIBE TO KEYBOARD NOTIFICATION
    func unsubscribeTokeyBoardNotification() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
         NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    /// #MARK: Save the image
    func save(memedImage:UIImage) {
        // Create the meme
        let meme = Meme(topText: TopTxt.text!, bottomText: BottomTxt.text!, originalImage: ImagePicker.image!, memedImage: memedImage)
    }
    
    
    //#MARK: Generate the image and hide buttons and tool bar
    func generateMemedImage() -> UIImage {
        
        // Render view to an image
        self.toolBar.isHidden = true
       // self.Share.isHidden  = true
        //self.CancelButton.isHidden = true
        self.NavBar.isHidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        self.toolBar.isHidden = false
       // self.Share.isHidden  = false
        //self.CancelButton.isHidden = false
        self.NavBar.isHidden = false
        return memedImage
    }

}


