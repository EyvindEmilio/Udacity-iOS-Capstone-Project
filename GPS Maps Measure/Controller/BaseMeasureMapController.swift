//
//  BaseMeasureMapController.swift
//  GPS Maps Measure
//
//  Created by Eyvind on 7/7/22.
//

import Foundation
import UIKit
import CocoaLumberjackSwift

class BaseMeasureMapController: UIViewController {
    
    var measureTypeSelected = MeasureType.AREA
    
    func performMeasureSegue(withIdentifier identifier: String, sender: Any?) {
        let alertVC = UIAlertController(title: "Select type", message: "", preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: "Area", style: .default, handler: { action in
            DDLogVerbose("Area Selected")
            self.measureTypeSelected = .AREA
            self.performSegue(withIdentifier: identifier, sender: sender)
        }))
        alertVC.addAction(UIAlertAction(title: "Distance", style: .default, handler: { action in
            DDLogVerbose("Distance Selected")
            self.measureTypeSelected = .DISTANCE
            self.performSegue(withIdentifier: identifier, sender: sender)
        }))
        alertVC.addAction(UIAlertAction(title: "Circle", style: .default, handler: { action in
            DDLogVerbose("Circle Selected")
            self.measureTypeSelected = .CIRCLE
            self.performSegue(withIdentifier: identifier, sender: sender)
        }))
        alertVC.addAction(UIAlertAction(title: "Marker", style: .default, handler: { action in
            DDLogVerbose("Marker Selected")
            self.measureTypeSelected = .POI
            self.performSegue(withIdentifier: identifier, sender: sender)
        }))
        
        present(alertVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == MeasureEditorController.FROM_MAP_SEGUE_ID ||
            segue.identifier == MeasureEditorController.FROM_MEASURES_SEGUE_ID {
            let measureEditorController = segue.destination as! MeasureEditorController
            if sender == nil {
                MeasureEditorController.populateForNew(measureEditorController, measureTypeSelected)
            } else {
                MeasureEditorController.populateForEdit(measureEditorController, sender as! Measure)
            }
        }
    }
}
