//
//  UserPref.swift
//  GPS Maps Measure
//
//  Created by Eyvind on 8/7/22.
//

import Foundation

class UserPref{
    private static let PREF_LAST_LAT = "PREF_LAST_LAT"
    private static let PREF_LAST_LONG = "PREF_LAST_LONG"
    private static let PREF_LAST_SPAN_LAT = "PREF_LAST_SPAN_LAT"
    private static let PREF_LAST_SPAN_LONG = "PREF_LAST_SPAN_LONG"
    private static let PREF_IS_DEFEULT_GROUP_CREATED = "PREF_IS_DEFEULT_GROUP_CREATED"
    
    static func getUserDef() -> UserDefaults {
        return UserDefaults.standard
    }
    
    static func setLastLocation(_ lat: Double, _ long: Double){
        getUserDef().set(lat, forKey: PREF_LAST_LAT)
        getUserDef().set(long, forKey: PREF_LAST_LONG)
    }
    
    static func setLastSpan(_ lat: Double, _ long: Double){
        getUserDef().set(lat, forKey: PREF_LAST_SPAN_LAT)
        getUserDef().set(long, forKey: PREF_LAST_SPAN_LONG)
    }
    
    static func getLastLocation() -> PointLocation? {
        let lat = getUserDef().double(forKey: PREF_LAST_LAT)
        let long = getUserDef().double(forKey: PREF_LAST_LONG)
        
        if lat != 0 && long != 0 {
            return PointLocation(lat, long)
        } else {
            return nil
        }
    }
    
    static func getLastSpanLocation() -> PointLocation? {
        let lat = getUserDef().double(forKey: PREF_LAST_SPAN_LAT)
        let long = getUserDef().double(forKey: PREF_LAST_SPAN_LONG)
        
        if lat != 0 && long != 0 {
            return PointLocation(lat, long)
        } else {
            return nil
        }
    }
    
    static func createDefaultGroupIsNeeded() -> Bool {
        let flag = getUserDef().bool(forKey: PREF_IS_DEFEULT_GROUP_CREATED)
        getUserDef().set(true, forKey: PREF_IS_DEFEULT_GROUP_CREATED)
        return !flag
    }
}
