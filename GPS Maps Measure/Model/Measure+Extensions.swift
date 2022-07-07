//
//  Measure+Extensions.swift
//  GPS Maps Measure
//
//  Created by Eyvind on 2/7/22.
//

import Foundation

extension Measure{
    static func newInstance(){
        
    }
    
    func getLayLngPoints() -> [PointLocation] {
        var list: [PointLocation] = []
        
        guard let simplePoints = self.simplePoints else {
            return list
        }

        let pairPoints = simplePoints.split(separator: "|")
        
        pairPoints.forEach { pairPoint in
            let latLng = pairPoint.split(separator: ",")
            let lat = Double(latLng[0]) ?? 0
            let lon = Double(latLng[1]) ?? 0
            
            list.append(PointLocation(lat, lon))
        }
        
        return list
    }
    
    func setPointsList(points: [PointLocation]){
        self.simplePoints = points.map { point in "\(point.latitude),\(point.longitude)" }.joined(separator: "|")
    }
    
    func getMeasureType() -> MeasureType? {
        var measureType: MeasureType? = nil
        switch self.type {
        case MeasureType.AREA.rawValue:
            measureType = MeasureType.AREA
            break
        case MeasureType.DISTANCE.rawValue:
            measureType = MeasureType.DISTANCE
            break
        case MeasureType.CIRCLE.rawValue:
            measureType = MeasureType.CIRCLE
            break
        case MeasureType.POI.rawValue:
            measureType = MeasureType.POI
            break
        case .none:
            measureType = nil
        case .some(_):
            measureType = nil
        }
        return measureType
    }
}
