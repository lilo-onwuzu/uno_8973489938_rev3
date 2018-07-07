//
//  CreateViewController.swift
//
//  Created by mac on 10/27/16.
//  Copyright © 2016 iponwuzu. All rights reserved.
//


import UIKit
import ImagePicker

class CreateViewController: CommonSourceController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImagePickerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var objectCount: UITextField!
    @IBOutlet weak var addTitleButton: UIButton!
    @IBOutlet weak var addCountButton: UIButton!
    @IBOutlet weak var addRateButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var cyclePicker: UIPickerView!
    @IBOutlet weak var rateStepper: UIStepper!
    @IBOutlet weak var rateField: UITextField!
    @IBOutlet weak var detailsField: UITextField!
    @IBOutlet weak var libButton: UILabel!
    @IBOutlet weak var camButton: UILabel!
    @IBOutlet weak var photoScroll: UICollectionView!
    
    // text field limit for title text
    let text_field_limit = 64
    // new createObject object is initialized with vc
    var createObject: PFObject = PFObject(className: "Listing")
    // set initial value to flat because UIPickerView delegate's method didSelectRow is only called when there is a change from the initial value
    var cycleValue = "Weekly"
    // create an array of all the items in the picker
    var cycle = ["Weekly", "Monthly", "Annually"]
    let imagePicker = UIImagePickerController()
    let ImagePicker = ImagePickerController()
    let user = PFUser.current()!
    var activityIndicator = UIActivityIndicatorView()
    var objectImages: [UIImage] = []
    var inEditMode = false
    
    enum State {
        case title, count, rate, photos, details, edit
    }
    
    func isActive(state: State) -> Bool {
        switch state {
            case .title:
                return !titleField.isHidden
            case .count:
                return !objectCount.isHidden
            case .rate:
                return !rateField.isHidden
            case .photos:
                return !photoScroll.isHidden
            case .details:
                return !detailsField.isHidden
            case .edit:
                return inEditMode
        }
    }
    
    func step(textField: UITextField, _ sender: UIStepper) {
        var enterRate = Int(textField.text!)
        if enterRate != nil {
            enterRate? += Int(sender.value)
            textField.text = String(enterRate!)
        } else {
            textField.text = "1"
        }
        sender.value = 0
    }
    
    func hideAll() {
        let subviews = self.view.subviews
        for view in subviews {
            if (view.tag != 5) {
                view.isHidden = true
            }
        }
    }
    
    func showAddTitle() {
        if (inEditMode) {
            homeButton.setTitle("<", for: .normal)
            homeButton.setImage(nil, for: .normal)
        } else {
            homeButton.setTitle("", for: .normal)
            let home = UIImage(named: "homeImg.png")!
            homeButton.setImage(home, for: .normal)
        }
        hideAll()
        titleField.isHidden = false
        addTitleButton.isHidden = false
    }
    
    func showAddCount() {
        hideAll()
        rateStepper.isHidden = false
        objectCount.isHidden = false
        addCountButton.isHidden = false
    }
    
    func showAddRate() {
        hideAll()
        rateField.isHidden = false
        cyclePicker.isHidden = false
        rateStepper.isHidden = false
        addRateButton.isHidden = false
    }

    func showAddPhotos() {
        hideAll()
        photoScroll.isHidden = false
        uploadButton.isHidden = false
        libButton.isHidden = false
        camButton.isHidden = false
        if isActive(state: .edit) {
            let images = createObject.object(forKey: "images") as! [PFFile]
            if images.count > 0 {
                for image in images {
                    image.getDataInBackground { (data, error) in
                        if let data = data {
                            let imageData = NSData(data: data)
                            let uiImage = UIImage(data: imageData as Data)!
                            if !self.isDup(newImage: uiImage) {
                                self.objectImages.append(uiImage)
                                self.photoScroll.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func showAddDetails() {
        hideAll()
        detailsField.isHidden = false
        doneButton.isHidden = false
    }
    
    func addTitle() {
        homeButton.setImage(nil, for: .normal)
        homeButton.setTitle("<", for: .normal)
        if titleField.text != "" && titleField.text != "First, describe your place in 1-3 words" {
            // PFUser.current() must exist here because the login screen comes before this
            let userId = (user.objectId)!
            // .setValue() sets value of a type while .add() create an array type column and adds to it
            createObject.setValue(self.titleField.text!, forKey: "title")
            createObject.setValue(userId, forKey: "requesterId")
            // set empty array for users who have accepted the job on job creation
            createObject.setValue([], forKey: "userAccepted")
            // set empty string for user who has been selected for the job on job creation
            createObject.setValue("", forKey: "selectedUser")
            showAddCount()
        } else {
            super.alertWithSingleOption(title: "Invalid Entry", message: "Please add a job title")
        }
        self.view.endEditing(true)
    }
    
    func addCount() {
        let count = Int(objectCount.text!)
        if count != nil && count! > 0 {
            createObject.setValue(count, forKey: "objectCount")
            showAddRate()
        } else {
            super.alertWithSingleOption(title: "Invalid Entry", message: "Please enter a valid number of roommates")
        }
        self.view.endEditing(true)
    }
    
    func addRate() {
        createObject.setValue(self.cycleValue, forKey: "cycle")
        // confirm that rate has a valid number
        let rate = Int(rateField.text!)
        if rate !=  nil && rate! > 0 {
            createObject.setValue(rate, forKey: "rate")
            showAddPhotos()
        } else {
            super.alertWithSingleOption(title: "Invalid Entry", message: "Please enter a valid rate")
        }
        self.view.endEditing(true)
    }
    
    func addPhotos() {
        var images : [PFFile] = []
        for image in objectImages {
            images.append(convertToPF(image: image))
        }
        createObject["images"] = images
        showAddDetails()
    }
    
    func addDetails() {
        if detailsField.text != "" && detailsField.text != "Tell us more..." {
            createObject.setValue(self.detailsField.text! , forKey: "details")
            activityIndicator = super.showActivity()
            // finally save PFObject. saveInBackground is an asychronous call that does not wait to execute before continuing so save it with block if you need data that is returned from the async call
            createObject.saveInBackground(block: { (success, error) in
                super.restore(activityIndicator: self.activityIndicator)
                if success {
                    // wait till object is saved in async call before confirming
                    self.performSegue(withIdentifier: "toListings", sender: self)
                } else {
                    super.alertWithSingleOption(title: "Network Error", message: "Please try again later")
                }
            })
        } else {
            super.alertWithSingleOption(title: "Invalid Entry", message: "Please enter valid details")
        }
        self.view.endEditing(true)
    }
    
    func convertToPF(image: UIImage) -> PFFile {
        let imageData = UIImageJPEGRepresentation(image, 0.5)!
        let imageFile = PFFile(data: imageData)!
        return imageFile
    }
    
    func setEditMode() {
        titleField.clearsOnBeginEditing = false
        objectCount.clearsOnBeginEditing = false
        rateField.clearsOnBeginEditing = false
        detailsField.clearsOnBeginEditing = false
    }
    
    func populateFields() {
        let title = createObject.object(forKey: "title") as! String
        titleField.text = title
        let rate = createObject.object(forKey: "rate") as! Int
        rateField.text = String(rate)
        let cycleValue = createObject.object(forKey: "cycle") as! String
        let cycleIndex = cycle.index(of: cycleValue)!
        cyclePicker.selectRow(cycleIndex, inComponent: 0, animated: false)
        let count = createObject.object(forKey: "objectCount") as! Int
        objectCount.text = String(count)
        let details = createObject.object(forKey: "details") as? String
        detailsField.text = details
    }
    
    
    func deletePhoto(indexPath: IndexPath) {
        objectImages.remove(at: indexPath.row)
        photoScroll.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleField.delegate = self
        self.rateField.delegate = self
        self.detailsField.delegate = self
        self.objectCount.delegate = self
        imagePicker.delegate = self
        ImagePicker.delegate = self
        ImagePicker.imageLimit = 5
        addTitleButton.layer.masksToBounds = true
        addTitleButton.layer.cornerRadius = 10
        addCountButton.layer.masksToBounds = true
        addCountButton.layer.cornerRadius = 10
        addRateButton.layer.masksToBounds = true
        addRateButton.layer.cornerRadius = 10
        uploadButton.layer.masksToBounds = true
        uploadButton.layer.cornerRadius = 10
        doneButton.layer.masksToBounds = true
        doneButton.layer.cornerRadius = 10
        self.cyclePicker.delegate = self
        self.cyclePicker.dataSource = self
        cyclePicker.layer.masksToBounds = true
        cyclePicker.layer.cornerRadius = 10
        libButton.layer.masksToBounds = true
        libButton.layer.cornerRadius = 7
        camButton.layer.masksToBounds = true
        camButton.layer.cornerRadius = 7
        super.getLocation(object: createObject)
        showAddTitle()
        if (isActive(state: .edit)) {
            setEditMode()
            populateFields()
        }
    }
    
    @IBAction func addTitle(_ sender: UIButton) {
        addTitle()
    }
    
    @IBAction func addCount(_ sender: Any) {
        addCount()
    }
    
    @IBAction func addRate(_ sender: UIButton) {
        addRate()
    }
    
    @IBAction func addDetails(_ sender: UIButton) {
        addDetails()
    }
    
    @IBAction func uploadPhotos(_ sender: UIButton) {
        addPhotos()
    }
    
    @IBAction func home(_ sender: UIButton) {
        if (isActive(state: .edit) && isActive(state: .title)) {
            dismiss(animated: true, completion: nil)
            return
        }
        if (isActive(state: .count)) {
            showAddTitle()
            return
        }
        if (isActive(state: .rate)) {
            showAddCount()
            return
        }
        if (isActive(state: .photos)) {
            showAddRate()
            return
        }
        if (isActive(state: .details)) {
            showAddPhotos()
            return
        }
        super.showMenu(mainView: self.view)
    }
    
    // called on touch up inside. checks to see if rateField has a value that can be converted into a Double
    @IBAction func step(_ sender: UIStepper) {
        if isActive(state: .count) {
            step(textField: objectCount, sender)
        } else if isActive(state: .rate) {
            step(textField: rateField, sender)
        }
    }
    
    @IBAction func getPhotoLib(_ sender: Any) {
        self.present(ImagePicker, animated: true, completion: nil)
    }
    
    @IBAction func getPhotoCam(_ sender: Any) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // tap anywhere to escape keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // hit return to escape keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // textfield delegate so characters greater than the text field limit cannot be entered
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return (textField.text?.utf16.count ?? 0) + string.utf16.count - range.length <= text_field_limit
    }

    // UIPickerViewDelegate method: number of sections laid side by side in picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewDelegate method: return an attributed form of each value in cycle array into each row in picker
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as? UILabel
        if label == nil {
            label = UILabel()
        }
        let cycleRow = cycle[row]
        let title = NSAttributedString(string: cycleRow, attributes: [NSAttributedStringKey.font : UIFont.init(name: "Pompiere-Regular", size: 28.0)!, NSAttributedStringKey.foregroundColor : UIColor.white])
        label?.attributedText = title
        label?.textAlignment = .center
        return label!
    }
    
    // UIPickerViewDelegate method: number of items in picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cycle.count
    }
    
    // UIPickerViewDelegate method: get selected row value. Save selected cycle in variable "cycleValue"
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        cycleValue = cycle[row]
    }
    
    // protocol for UIImagePickerDelegate (camera only)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if !isDup(newImage: image) {
                objectImages.append(image)
                photoScroll.reloadData()
            }
        }
        // dismiss imagePicker controller
        self.dismiss(animated: true, completion: nil)
    }
    
    // protocol for custom module ImagePickerDelegate (photolibrary only)
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {

    }

    func isDup(newImage: UIImage) -> Bool {
        var dup = false
        if objectImages.contains(where: { UIImagePNGRepresentation($0) == UIImagePNGRepresentation(newImage) }) {
            dup = true
        }
        return dup
    }
    
    // protocol for custom module ImagePickerDelegate (photolibrary only)
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        for image in images {
            if !isDup(newImage: image) {
                objectImages.append(image)
                photoScroll.reloadData()
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // protocol for custom module ImagePickerDelegate (library only)
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objectImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = objectImages[indexPath.row]
        cell.myCollectionView = photoScroll
        cell.viewController = self
        return cell
    }
    
}
