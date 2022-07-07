//
//  MapController.swift
//  GPS Maps Measure
//
//  Created by Eyvind on 28/6/22.
//

import Foundation
import UIKit
import CocoaLumberjackSwift

class MapController: BaseMeasureMapController {
    
    @IBOutlet weak var tvMeasureInfo: UILabel!
    
    let dataController = (UIApplication.shared.delegate as! AppDelegate).dataController

    override func viewDidLoad() {
        DDLogVerbose("viewDidLoad")
    }
    
    @IBAction func newMeasure(_ sender: Any) {
        performMeasureSegue(withIdentifier: MeasureEditorController.FROM_MAP_SEGUE_ID, sender: nil)
    }
    
}
