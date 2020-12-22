//
//  PlacesTableViewController.swift
//  MapLog
//
//  Created by Nathan Chmielewski on 3/4/20.
//  Copyright © 2020 Nathan Chmielewski. All rights reserved.
//

import UIKit
import MapKit

class PlacesTableViewController: UITableViewController {

//    var places: [MKMapItem]?
    var userMap: UserMap!
    var row: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return userMap.places.count
        }
        else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath)

        // Configure the cell...
        
        if let places = userMap?.places {
            let place = places[indexPath.row]
            // Configure the cell with places model
            cell.textLabel?.text = place.mapItem.name
            cell.detailTextLabel?.text = place.mapItem.placemark.formattedAddress
        }
        
//        cell.showsReorderControl = true
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    
    // implement the tableView(_:, moveRowAt fromIndexPath:, to:) method. When called, you should remove the data within places at fromIndexPath.row and add it back at to.row
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let movedPlace = userMap.places.remove(at: sourceIndexPath.row)
        userMap.places.insert(movedPlace, at: destinationIndexPath.row)
        
        userMaps[row].places.remove(at: sourceIndexPath.row)
        userMaps[row].places.insert(movedPlace, at: destinationIndexPath.row)
        
        tableView.reloadData()
        
    }
    
    // delete row with delete button in EditingMode
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // remove from userMaps data model array
            userMap.places.remove(at: indexPath.row)
            // remove appropriate cell
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            userMaps[row].places.remove(at: indexPath.row)

        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        
        if segue.identifier == "ShowPlaceOnMap" {
            // Get index of row tapped by user
            let indexPath = tableView.indexPathForSelectedRow!
            // Get place to view on the map
            let place = userMap.places[indexPath.row]
            // Get mapViewController destination
            let mapViewController = segue.destination as! MapViewController
            
            // Pass properties to map view
            mapViewController.userMapsRow = row
            mapViewController.places = [place]
            mapViewController.placesRow = indexPath.row
            
            let region = MKCoordinateRegion(center: place.mapItem.placemark.coordinate, latitudinalMeters: 1_000, longitudinalMeters: 1_000)
            mapViewController.boundingRegion = region
            
            tableView.deselectRow(at: indexPath, animated: false)
        }
        
        // Pass the selected object to the new view controller.
    }
    
    
    @IBAction func unwindToPlacesTableView(_ segue : UIStoryboardSegue) {
            
        userMaps.remove(at: row!)
        userMaps.insert(userMap!, at: row!)
        
        tableView.reloadData()
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
