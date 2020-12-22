//
//  UserMapsTableViewController.swift
//  MapLog
//
//  Created by Nathan Chmielewski on 3/4/20.
//  Copyright © 2020 Nathan Chmielewski. All rights reserved.
//

import UIKit


var userMaps: [UserMap] = [
    UserMap(places: [], name: "Breakfast & Brunch", description: "Morning and weekend meetups", mapCategory: .breakfast),
    UserMap(places: [], name: "Walkable Lunch", description: "Places to grab a quick bite", mapCategory: .lunch),
    UserMap(places: [], name: "Dinner Dates", description: "Restaurants for date nights", mapCategory: .dinner),
    UserMap(places: [], name: "Happy Hour Bars", description: "Bars for happy hour after work", mapCategory: .bars),
    UserMap(places: [], name: "Cocktails & Late Night", description: "Cocktail bars for special occasions", mapCategory: .nightlife),
    UserMap(places: [], name: "Classic Cafés", description: "Where to get the perfect cappuccino", mapCategory: .cafés),
    UserMap(places: [], name: "Dessert Shops", description: "Places to grab a treat", mapCategory: .dessert)]

class UserMapsTableViewController: UITableViewController, UIAdaptivePresentationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // the width of the table view cells will stay within readable margins
        self.tableView.cellLayoutMarginsFollowReadableWidth = true
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return userMaps.count
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get UserMap object at row
        let userMap = userMaps[indexPath.row]

        // Get cell and force downcast to UserMapTableViewCell to update
        let cell = tableView.dequeueReusableCell(withIdentifier: userMap.mapCategory.rawValue, for: indexPath)
        
//        cell.update(with: userMap)
        
        // Configure the cell with UserMap model
        cell.textLabel?.text = userMap.name
        cell.detailTextLabel?.text = userMap.description
        
        cell.showsReorderControl = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    
    // implement the tableView(_:, moveRowAt fromIndexPath:, to:) method. When called, you should remove the data within userMaps at fromIndexPath.row and add it back at to.row
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let movedUserMap = userMaps.remove(at: sourceIndexPath.row)
        userMaps.insert(movedUserMap, at: destinationIndexPath.row)
        tableView.reloadData()
        
    }
    
    // delete row with delete button in EditingMode
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // remove from userMaps data model array
            userMaps.remove(at: indexPath.row)
            // remove appropriate cell
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    // Code func @IBAction for a bar button item Edit to enable/disable editing mode
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        let tableViewEditingMode = tableView.isEditing
        tableView.setEditing(!tableViewEditingMode, animated: true)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Dismiss Editing Mode
        tableView.setEditing(false, animated: true)
        
        // Get the new view controller using segue.destination.

        /*
        if segue.identifier == "EditUserMap" {
            // Get index of row tapped
            let indexPath = tableView.indexPathForSelectedRow!
            // Get userMap
            let userMap = userMaps[indexPath.row]
            // Get nav controller that AddEditUserMapsTVC is in
            let navController = segue.destination as! UINavigationController
            // Get AddEditUserMapsTVC
            let addUserMapViewController = navController.topViewController as! AddUserMapViewController
            // Set userMap in the VC
            addUserMapViewController.userMap = userMap
            // Set this VC as presentation delegate to be able to deselect selected row when AddEditTVC is dismissed with swipedown gesture
            segue.destination.presentationController?.delegate = self
        }
        */
        
        if segue.identifier == "ShowPlaces" {

            // Get nav controller that PlacesTVC is in
            let placesTableViewController = segue.destination as! PlacesTableViewController
            
            // Set view title
            // Set places[MKMapItem] in PlacesTVC
            // First get selected cell -- the row is not selected when the accessory button is tapped
            if let cell = sender as? UITableViewCell {
                if let indexPath = self.tableView.indexPath(for: cell) {
                    placesTableViewController.title = userMaps[indexPath.row].name
                    placesTableViewController.userMap = userMaps[indexPath.row]
                    placesTableViewController.row = indexPath.row
                }
            }
        }
        
        
        // Pass the selected object to the new view controller.

    }
    
    
    // Deselect selected row when AddEditTVC is dismissed with swipedown gesture
    func presentationControllerDidDismiss(
        _ presentationController: UIPresentationController)
    {
        if let selectedRow = super.tableView?.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }
    
    
    @IBAction func unwindToUserMapsView(segue: UIStoryboardSegue) {
        
        // Check that 'Save' button was tapped
        guard segue.identifier == "saveUnwind",
            let sourceController = segue.source as? AddUserMapViewController,
            let userMap = sourceController.userMap else {
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    tableView.deselectRow(at: selectedIndexPath, animated: true)
                }
                return }
        
        // If a tableView.row was selected, we're editing an already listed userMap
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            // Update data model
            userMaps[selectedIndexPath.row] = userMap
            // Update tableView row
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        }
            // No row was previously selected, we're adding a new user map
        else {
            // Get row number and section of new user map
            let newIndexPath = IndexPath(row: userMaps.count, section: 0)
            // Update data model
            userMaps.append(userMap)
            // Insert into tableView
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
}
