//
//  UserMap.swift
//  MapLog
//
//  Created by Nathan Chmielewski on 3/4/20.
//  Copyright © 2020 Nathan Chmielewski. All rights reserved.
//

import Foundation
import MapKit

enum MapCategory: String {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case bars = "Bars"
    case nightlife = "Nightlife"
    case cafés = "Cafés"
    case dessert = "Dessert"
}

struct UserMap {
    var places: [Place]
    var name: String
    var description: String
    var mapCategory: MapCategory
    
    init(places: [Place], name: String, description: String, mapCategory: MapCategory) {
        self.places = places
        self.name = name
        self.description = description
        self.mapCategory = mapCategory
    }
}

