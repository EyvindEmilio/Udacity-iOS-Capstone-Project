//
//  LatLngBounds.swift
//  GPS Maps Measure
//
//  Created by Eyvind on 2/7/22.
//

import Foundation
 
class LatLngBounds {
    
    var southwest = PointLocation(0.0, 0.0)
    var northeast = PointLocation(0.0, 0.0)
 
    
    class Builder {
        var zza: Double = 1.0 / 0.0
        var zzb: Double  = -1.0 / 0.0
        var zzc: Double = 0.0 / 0.0
        var zzd: Double  = 0.0 / 0.0
        
        public func include(_ point: PointLocation) -> LatLngBounds.Builder {
            zza = min(zza, point.latitude)
            zzb = max(zzb, point.latitude)
            var var2 = point.longitude
            
            if Double.infinity == zzc {
                zzc = var2
                zzd = var2
            } else {
                var var4 = zzc
                var var6 = zzd
                
                if var4 <= var6 {
                    if var4 <= var2 && var2 <= var6 {
                        return self
                    }
                } else if var4 <= var2 || var2 <= var6 {
                    return self
                }
                
                var var1000 = 0.0
//                if (((var4 - var2 + 360.0) % 360.0) < ((var2 - var6 + 360.0) % 360.0)) {
//                    zzc = var2
//                } else {
//                    zzd = var2
//                }
            }
         
            return self
        }
    }
}
