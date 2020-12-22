//
//  MapViewController.swift
//  MapLog
//
//  Created by Nathan Chmielewski on 3/4/20.
//  Copyright © 2020 Nathan Chmielewski. All rights reserved.
//

import UIKit
import MapKit
import EventKit
import EventKitUI

class MapViewController: UIViewController, UITextViewDelegate, EKEventEditViewDelegate, UINavigationControllerDelegate {
    
    // NC: Pin annotation used to display pin of place on map
    enum AnnotationReuseID: String {
        case pin
    }
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var placeNameLabel: UILabel!
    @IBOutlet var placeAddressLabel: UILabel!
    @IBOutlet var notesTextView: UITextView!
    
    var places: [Place]!
    var boundingRegion: MKCoordinateRegion?
    
    // userMapsRow is the row position of the userMap this place is a part of in master userMaps array
    var userMapsRow: Int!
    // placesRow is the row position of the place in its UserMap.places array
    var placesRow: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewController.handleSingleTap))
        singleTapRecognizer.numberOfTapsRequired = 1
        singleTapRecognizer.numberOfTouchesRequired = 1
        view.addGestureRecognizer(singleTapRecognizer)
        
        registerForKeyboardNotifications()
        
        if let region = boundingRegion {
            mapView.region = region
        }
        mapView.delegate = self
        
        // Use the compass in the map view
        //        mapView.showsCompass = true
        
        
        // Make sure `MKPinAnnotationView` and the reuse identifier is recognized in this map view.
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: AnnotationReuseID.pin.rawValue)
    }
    
    @objc
    func handleSingleTap(_ sender: UITapGestureRecognizer) {
        notesTextView.resignFirstResponder()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        placeNameLabel.text = places[0].mapItem.name
        placeAddressLabel.text = places[0].mapItem.placemark.formattedAddressByLine
        notesTextView.text = places[0].note
        
        super.viewDidAppear(true)
        
        guard let places = places else { return }
        
        if places.count == 1, let item = places.first {
            title = item.mapItem.name
        }
        
        // Turn the array of MKMapItem objects into an annotation with a title and URL that can be shown on the map.
        let annotations = places.compactMap { (place) -> PlaceAnnotation? in
            guard let coordinate = place.mapItem.placemark.location?.coordinate else { return nil }
            
            let annotation = PlaceAnnotation(coordinate: coordinate)
            annotation.title = place.mapItem.name
            annotation.url = place.mapItem.url
            
            return annotation
        }
        mapView.addAnnotations(annotations)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        userMaps[userMapsRow].places[placesRow].note = notesTextView.text
        
    }
    
    @objc func keyboardWasShown(_ notification: NSNotification) {
        
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    @objc func keyboardWasHidden(_ notification: NSNotification) {
        
        let bottomOffset = CGPoint(x: 0, y: 0)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    func registerForKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector:
            #selector(keyboardWasShown(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasHidden(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    /*
     * Event Kit Functionality
     */
    @IBAction func composeEventButtonTapped(_ sender: UIBarButtonItem) {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            let eventStore = EKEventStore()
            eventStore.requestAccess(to: .event) { (allowed, error) in
                if allowed {
                    DispatchQueue.main.async {
                        self.showEventViewController()
                    }
                }
            }
        case .authorized:
            DispatchQueue.main.async {
                self.showEventViewController()
            }
        case .denied:
            let alertTitle = "Calendar Access Not Granted"
            let alertMeessage = "To create events via MapLog, grant access by going to Settings -> Privacy -> Calendars."
            
            let alertController = UIAlertController(title: alertTitle, message: alertMeessage, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func showEventViewController() {
        let eventViewController = EKEventEditViewController()
        eventViewController.editViewDelegate = self
        eventViewController.eventStore = EKEventStore()
        
        let event = EKEvent(eventStore: eventViewController.eventStore)
        event.title = "Reservation at \(placeNameLabel.text!)"
        event.location = places[0].mapItem.placemark.formattedAddress
        event.startDate = Date()
        
        eventViewController.event = event
        
        present(eventViewController, animated: true)
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        dismiss(animated: true, completion: nil)
    }
    /*
     * End Event Kit Functionality
     */
}



extension MapViewController: MKMapViewDelegate {
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print("Failed to load the map: \(error)")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PlaceAnnotation else { return nil }
        
        // Annotation views should be dequeued from a reuse queue to be efficent.
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationReuseID.pin.rawValue, for: annotation) as? MKMarkerAnnotationView
        view?.canShowCallout = true
        
        // If the annotation has a URL, add an extra Info button to the annotation so users can open the URL.
        if annotation.url != nil {
            let infoButton = UIButton(type: .detailDisclosure)
            view?.rightCalloutAccessoryView = infoButton
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? PlaceAnnotation else { return }
        if let url = annotation.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}
