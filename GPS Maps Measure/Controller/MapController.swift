//
//  MapController.swift
//  GPS Maps Measure
//
//  Created by Eyvind on 28/6/22.
//

import Foundation
import UIKit
import CocoaLumberjackSwift

class MapController: UIViewController {
    
    
    
    override func viewDidLoad() {
        debugPrint("viewDidLoad")
        DDLogVerbose("viewDidLoad")
        
        let dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
        
        DDLogVerbose(dataController.viewContext)
        
        
    }
}
