//
//  Place.swift
//  MapLog
//
//  Created by Nathan Chmielewski on 3/5/20.
//  Copyright © 2020 Nathan Chmielewski. All rights reserved.
//

import Foundation
import MapKit

class Place {
    var mapItem: MKMapItem
    var note: String
    
    init(mapItem: MKMapItem, note: String) {
        self.mapItem = mapItem
        self.note = note
    }
}
