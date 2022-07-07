//
//  GlobalExtensions.swift
//  GPS Maps Measure
//
//  Created by Eyvind on 7/7/22.
//

import Foundation
import UIKit

extension UIColor {
    func rgb() -> Int? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            return rgb
        } else {
            return nil
            
        }
    }
}

extension UIViewController {
    func showSingleAlert(_ message: String, _ handler: @escaping ((_ action: UIAlertAction) -> Void) = {action in }) {
        let alertVC = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
        present(alertVC, animated: true)
    }
}


extension Int64 {
    func uiColor() -> UIColor {
        let alpha = CGFloat((self & 0xFF000000) >> 24) / 0xFF
        let red = CGFloat((self & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((self & 0x00FF00) >> 8) / 0xFF
        let blue = CGFloat(self & 0x0000FF) / 0xFF
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
