//
//  BaseMeasureMapController.swift
//  GPS Maps Measure
//
//  Created by Eyvind on 7/7/22.
//

import Foundation
import UIKit
import CocoaLumberjackSwift
import CoreData

class BaseMeasureMapController: UIViewController {
    private var fetchedGroupsController: NSFetchedResultsController<Group>!
    
    var measureTypeSelected = MeasureType.AREA
    let dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedGroupsController()
    }
    
    fileprivate func setupFetchedGroupsController() {
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedGroupsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "groups")

        do {
            try fetchedGroupsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func performMeasureSegue(withIdentifier identifier: String, sender: Any?) {
        if fetchedGroupsController.fetchedObjects?.count == 0 {
            showSingleAlert("Please add a group at least")
            return
        }
        if sender != nil {
            self.performSegue(withIdentifier: identifier, sender: sender)
            return
        }
        
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
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in

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
