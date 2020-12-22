//
//  SearchResultsTableViewController.swift
//  MapLog
//
//  Created by Nathan Chmielewski on 3/4/20.
//  Copyright © 2020 Nathan Chmielewski. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class SearchResultTableViewController: UITableViewController {
    
    private enum SegueID: String {
        case showDetail
        case showAll
    }
    
    // NC: Data model array holds results from user's location search
    // NC: Filled in search(searchRequest:)
    private var places: [MKMapItem]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    // NC: The suggestion controller is passed to UISearchController, appears when the user taps the search bar
    private var suggestionController: SuggestionsTableTableViewController!
    // NC: The search controller will display a new view controller with the search results
    private var searchController: UISearchController!
    
    @IBOutlet private var locationManager: LocationManager!
    
    private var locationManagerObserver: NSKeyValueObservation?
    
    private var foregroundRestorationObserver: NSObjectProtocol?
    
    private var localSearch: MKLocalSearch? {
        willSet {
            // Clear the results and cancel the currently running local search before starting a new search.
            places = nil
            localSearch?.cancel()
        }
    }
    
    // NC: boundingRegion set in awakeFromNib() to bound search results to user's nearby locations
    private var boundingRegion: MKCoordinateRegion?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        suggestionController = SuggestionsTableTableViewController()
        suggestionController.tableView.delegate = self
        
        // NC: Instantiate search controller with SuggestionsTableTVC as the view controller that will display the suggested search terms
        searchController = UISearchController(searchResultsController: suggestionController)
        searchController.searchResultsUpdater = suggestionController
        
        searchController.searchBar.isUserInteractionEnabled = false
        searchController.searchBar.alpha = 0.5
        
        // NC: Manages asking for user location, setting search interaction to true and setting search location bounding area to search for nearby locations
        locationManagerObserver = locationManager.observe(\LocationManager.currentLocation) { [weak self] (_, _) in
            if let location = self?.locationManager.currentLocation {
                // This sample only searches for nearby locations, defined by the device's location. Once the current location is
                // determined, enable the search functionality.
                
                let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 12_000, longitudinalMeters: 12_000)
                self?.suggestionController.searchCompleter.region = region
                self?.boundingRegion = region
                
                self?.searchController.searchBar.isUserInteractionEnabled = true
                self?.searchController.searchBar.alpha = 1.0
                
                self?.tableView.reloadData()
            }
        }
        
        let name = UIApplication.willEnterForegroundNotification
        foregroundRestorationObserver = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil, using: { [weak self] (_) in
            // Get a new location when returning from Settings to enable location services.
            self?.locationManager.requestLocation()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Place the search bar in the navigation bar.
        navigationItem.searchController = searchController
        
        // Keep the search bar visible at all times.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // NC: Sets SearchResultsTableVC as delegate of the UISearchController.searchBar, so that this VC's searchBarSearchButtonClicked(searchBar:) func is notified to begin search
        searchController.searchBar.delegate = self
        
        /*
         Search is presenting a view controller, and needs the presentation context to be defined by a controller in the presented view controller hierarchy.
         */
        definesPresentationContext = true
    }
    
    // NC: Request user's location using location manage after view appears
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.requestLocation()
    }

    // NC: Called when user taps row item from table list of places
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let placesTableViewController = segue.destination as? PlacesTableViewController else { return }
        
        // Get the single place selected
        guard let selectedItemPath = tableView.indexPathForSelectedRow,
            let mapItem = places?[selectedItemPath.row] else { return }
        
        let place = Place(mapItem: mapItem, note: "")
        
        // Add it to places list in PlacesTVC
        placesTableViewController.userMap?.places.append(place)

        
    }
 
    
    /// - Parameter suggestedCompletion: A search completion provided by `MKLocalSearchCompleter` when tapping on a search completion table row
    private func search(for suggestedCompletion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
        search(using: searchRequest)
    }
    
    /// - Parameter queryString: A search string from the text the user entered into `UISearchBar`
    private func search(for queryString: String?) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = queryString
        search(using: searchRequest)
    }
    
    /// - Tag: SearchRequest
    private func search(using searchRequest: MKLocalSearch.Request) {
        // Confine the map search area to an area around the user's current location.
        if let region = boundingRegion {
            searchRequest.region = region
        }
                
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start { [weak self] (response, error) in
            guard error == nil else {
                self?.displaySearchError(error)
                return
            }
            
            // NC: Fill data model 'places' with mapItems from search
            self?.places = response?.mapItems
            
            // Used when setting the map's region in `prepareForSegue`.
            self?.boundingRegion = response?.boundingRegion
            
        }
    }
    
    private func displaySearchError(_ error: Error?) {
        if let error = error as NSError?, let errorString = error.userInfo[NSLocalizedDescriptionKey] as? String {
            let alertController = UIAlertController(title: "Could not find any places.", message: errorString, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
}

extension SearchResultTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard locationManager.currentLocation != nil else { return 1 }
        return places?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard locationManager.currentLocation != nil else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "Acquiring current location…"
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            cell.accessoryView = spinner
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath)
        
        if let mapItem = places?[indexPath.row] {
            cell.textLabel?.text = mapItem.name
            cell.detailTextLabel?.text = mapItem.placemark.formattedAddress
        }
        
        return cell
    }
}

extension SearchResultTableViewController {
    // NC: Called when the user completes a search by tapping a suggested search result
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard locationManager.currentLocation != nil else { return }
        
        // NC: Get the search term (the suggested result tapped by the user) and assign to 'suggestion' in Optional unwrapping, dismiss searchController, update search bar text to show suggestion text tapped by user to search with
        if tableView == suggestionController.tableView, let suggestion = suggestionController.completerResults?[indexPath.row] {
            searchController.isActive = false
            searchController.searchBar.text = suggestion.title
            search(for: suggestion)
        }
    }
}

extension SearchResultTableViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    // NC: Func called when user taps "search" button on keyboard, did not select a row from the suggested completions while typing search query. Dismiss searchController and call search(for:)
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        // The user tapped search on the `UISearchBar` or on the keyboard. Since they didn't select a row with a suggested completion, run the search with the query text in the search field.
        search(for: searchBar.text)
    }
}
