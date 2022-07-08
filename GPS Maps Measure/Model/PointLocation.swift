//
//  PointLocation.swift
//  GPS Maps Measure
//
//  Created by Eyvind on 2/7/22.
//

import Foundation


struct PointLocation {
    var latitude: Double = 0.0
    var longitude: Double = 0.0

    init(_ lat: Double, _ lon: Double) {
        latitude = lat
        longitude = lon
    }
}
