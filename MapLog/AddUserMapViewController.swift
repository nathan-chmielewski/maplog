//
//  AddUserMapViewController.swift
//  MapLog
//
//  Created by Nathan Chmielewski on 3/4/20.
//  Copyright © 2020 Nathan Chmielewski. All rights reserved.
//

import UIKit

class AddUserMapViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
     
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var descriptionTextField: UITextField!
    @IBOutlet var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet var textFields: [UITextField]!
    
        
    var userMap: UserMap?

    let mapCategories = [MapCategory.breakfast.rawValue,
                      MapCategory.lunch.rawValue,
                      MapCategory.dinner.rawValue,
                      MapCategory.bars.rawValue,
                      MapCategory.nightlife.rawValue,
                      MapCategory.cafés.rawValue,
                      MapCategory.dessert.rawValue]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // If userMap was instantiated, load into view
        if let userMap = userMap {
            nameTextField?.text = userMap.name
            descriptionTextField?.text = userMap.description
        }
        
        // Update save bar button enabled status
        UpdateSaveBarButtonState()
    }

    
    // Enable 'Save' bar button only when all text fields are not empty
    func UpdateSaveBarButtonState() {
        let nameText = nameTextField.text ?? ""
        let descriptionText = descriptionTextField.text ?? ""
        saveBarButton.isEnabled = !nameText.isEmpty && !descriptionText.isEmpty
    }
    

    // Update 'Save' button status on every text change
    @IBAction func textEditingChanged(_ sender: UITextField) {
        UpdateSaveBarButtonState()
    }
    
    @IBAction func editEnded(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func backgroundTapped(_ sender: UIControl) {
        for tf in textFields {
            tf.resignFirstResponder()
        }
    }
    
        
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mapCategories.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mapCategories[row]
    }

        
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Check that Save button was tapped
        guard segue.identifier == "saveUnwind" else { return }
        // place text from view into userMap property to be added to userMapTVC
        let nameText = nameTextField.text ?? ""
        let descriptionText = descriptionTextField.text ?? ""
        let categorySelected = mapCategories[picker.selectedRow(inComponent: 0)]
        
         var mapCategory : MapCategory = MapCategory(rawValue: categorySelected)!
        
         switch categorySelected {
         case "Breakfast":
             mapCategory = .breakfast
             break
         case "Lunch":
             mapCategory = .lunch
             break
         case "Dinner":
             mapCategory = .dinner
             break
         case "Nightlife":
             mapCategory = .nightlife
             break
         case "Bars":
             mapCategory = .bars
             break
         case "Cafés":
             mapCategory = .cafés
             break
         case "Dessert":
             mapCategory = .dessert
             break
         default:
             break
         }
        
        userMap = UserMap(places: [], name: nameText, description: descriptionText, mapCategory: mapCategory)
    }

}
