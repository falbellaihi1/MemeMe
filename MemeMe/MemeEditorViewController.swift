//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Faisal Albellaihi on 13/11/2018.
//  Copyright © 2018 FAISAL Albellaihi. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate{
    
    // #MARK: IBOutlets 
    @IBOutlet weak var ImagePicker: UIImageView!
    @IBOutlet weak var NavBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var CameraButton: UIBarButtonItem!
    @IBOutlet weak var ShareButton: UIBarButtonItem!
    @IBOutlet weak var CancelButton: UIButton!
    @IBOutlet weak var TopTxt: UITextField!
    @IBOutlet weak var BottomTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareProperties() // prepare properties when view load
        
      
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeTokeyBoardNotification()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeTokeyBoardNotification() // unsubscribe from notification
        
    }
    
   
    
    // #MARK: TEXT FIELD SHOULR RETURN
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        TopTxt.resignFirstResponder()
        BottomTxt.resignFirstResponder()
        
        return true
    }
    //Hide status bar to turn on/off
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    //#MARK: Color functions
    func whiteColor() ->UIColor{
        return UIColor.white
    }
    func grayColor() -> UIColor {
        
        return UIColor.gray
    }
    func blackColor() ->UIColor {
        return UIColor.black
    }
    
    func clearText(text:UITextField) {
        return text.text = ""
    }
    // prepare buttons and view for the load
    func prepareProperties(){
       ShareButton.isEnabled = false
       ImagePicker.image = nil
        clearText(text: TopTxt)
        clearText(text: BottomTxt)
        view.backgroundColor = whiteColor()
        if (!UIImagePickerController.isSourceTypeAvailable(.camera)){
            CameraButton.isEnabled = false
        }
        
        
    }
    
    //#MARK: TEXT FIELD STYLE
    func TextFieldStyle(text: UITextField, string: String)->UITextField{
        text.delegate = self
        let memeTextAttributes:[String: Any] = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
            NSAttributedStringKey.font.rawValue: UIFont(name: "impact", size: 45)!,
            NSAttributedStringKey.strokeWidth.rawValue:-4.0 ]
        text.defaultTextAttributes = memeTextAttributes
        text.textAlignment = .center
        text.borderStyle = .none
        text.text = string
        text.isEnabled = true
        
        return text
    }
 
    // #MARK: Button Actions
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
            
            self.prepareProperties()
        } // Lozalized Alert Action
        
        
         let CancelActionNO = UIAlertAction(title:  NSLocalizedString("Continue Editing", comment:" Goback to editor " ), style: .default) { (action) in}
        CancelAC.addAction(CancelConfirm)
        CancelAC.addAction(CancelActionNO)
        
        self.present(CancelAC, animated: true){} // show the Alert
    }
    
    @IBAction func PickAnImageFromAlbum(_ sender: Any) {
        pickImage(sourceType: .photoLibrary)
    }
    
    @IBAction func CameraButton(_ sender: Any) {
       
        pickImage(sourceType: .camera)
    }
    
    
    // Picker controller for images by source type
    func pickImage(sourceType: UIImagePickerControllerSourceType) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        present(pickerController, animated: true, completion: nil)
        
        
    }
    
    // #MARK: IMAGE PICKER CONTROLLER
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            ImagePicker.image = image
            TopTxt = TextFieldStyle(text: TopTxt, string: "TOP") // set the top text and its string
            BottomTxt = TextFieldStyle(text: BottomTxt, string: "BOTTOM") // set the bottom string
            ShareButton.isEnabled = true // disable the share button until the image has been uploaded
            view.backgroundColor = blackColor() // set background color to black to make the image look much better
        }
        dismiss(animated: true, completion: nil)
    }
    // #MARK: DID USER CANCELED IMAGE?
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
 
    }
    
    //# MARK : Keyboard controls
    @objc func keyboardWillShow(_ notification : Notification){
        if (!TopTxt.isEditing){
            view.frame.origin.y = -getKeyboardHight(notification)
        }
    }
   
    @objc func keyboardWillHide(_ notification : Notification) {
    
        view.frame.origin.y = 0
    }
    
    func getKeyboardHight(_ notification:Notification)->CGFloat {
        let usrInfo = notification.userInfo
        let keyboardSize = usrInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
  
    
    
    // #MARK: Keyboard notifications
    func subscribeTokeyBoardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeTokeyBoardNotification() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
         NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    /// #MARK: Image controls
    func save(memedImage:UIImage) {
        // Create the meme
        _ = Meme(topText: TopTxt.text!, bottomText: BottomTxt.text!, originalImage: ImagePicker.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        self.toolBar.isHidden = true
        self.NavBar.isHidden = true
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.toolBar.isHidden = false
        self.NavBar.isHidden = false
        return memedImage
    }

}


