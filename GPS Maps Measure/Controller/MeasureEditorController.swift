//
//  MeasureEditorController.swift
//  GPS Maps Measure
//
//  Created by Eyvind on 6/7/22.
//

import Foundation
import UIKit
import CoreData
import CocoaLumberjackSwift

class MeasureEditorController: UIViewController {
    
    public static let FROM_MAP_SEGUE_ID = "FromMapSegueToEditor"
    public static let FROM_MEASURES_SEGUE_ID = "FromMeasuresSegueToEditor"
    
    private let dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    
    private var measureType: MeasureType!
    
    static func populateForNew(_ viewController: MeasureEditorController,_ type: MeasureType) {
        viewController.measureType = type
    }
    
    static func populateForEdit(_ viewController: UIViewController, _ measure: Measure) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func save() {
        DDLogVerbose("save()")
    }
}
