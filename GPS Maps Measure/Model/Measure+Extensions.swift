//
//  Measure+Extensions.swift
//  GPS Maps Measure
//
//  Created by Eyvind on 2/7/22.
//

import Foundation
import CoreData

extension Measure {

    static func newInstance(context: NSManagedObjectContext,
                            name: String,
                            group: Group,
                            type: MeasureType,
                            points: [PointLocation]) -> Measure {
        let measure = Measure(context: context)
        
        measure.name = name
        measure.group = group
        measure.type = type.rawValue
        
        measure.area = 0.0
        measure.perimeter = 0.0
        measure.distance = 0.0
        measure.radio = 0.0
        
        measure.setPointsList(points: points)
        
        measure.photo = nil
        measure.updatedAt = Date()
        
        measure.regenerateCalcs()
        
        return measure
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
    
    func regenerateCalcs() {
        area = 0.0
        perimeter = 0.0
        distance = 0.0
        radio = 0.0
        
        switch getMeasureType() {
        case .AREA:
            area = 1.0
            perimeter = 1.0
            break
        case .DISTANCE:
            distance = 1.0
            break
        case .CIRCLE:
            area = 1.0
            perimeter = 1.0
            radio = 1.0
            break
        case .POI:
            break
        case .none:
            break
        }
    }
    
    func getDescription() -> String {
        var mDescription = ""
        switch getMeasureType() {
        case .AREA:
            mDescription = "Area: \(roundValue(area)) [m²]\nPerimeter: \(roundValue(perimeter)) [m]"
            break
        case .DISTANCE:
            mDescription = "Distance: \(roundValue(perimeter)) [m]"
            break
        case .CIRCLE:
            mDescription = "Area: \(roundValue(area)) [m²]\nRadio: \(roundValue(radio)) [m]\nCircumference: \(roundValue(perimeter)) [m]"
            break
        case .POI:
            let points = getLayLngPoints()
            mDescription = "Latitude: \(points.first?.latitude ?? 0.0)\nLongitude: \(points.first?.longitude ?? 0.0)"
            break
        case .none:
            break
        }
        return mDescription
    }
    
    private func roundValue(_ value: Double) -> String{
        return String(format: "%.03f", value)
    }

    func needsFill() -> Bool {
        return getMeasureType() == .AREA || getMeasureType() == .CIRCLE
    }
}
