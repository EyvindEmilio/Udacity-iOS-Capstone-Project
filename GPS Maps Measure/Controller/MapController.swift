//
//  MapController.swift
//  GPS Maps Measure
//
//  Created by Eyvind on 28/6/22.
//

import Foundation
import UIKit
import CoreData
import CocoaLumberjackSwift

class MapController: BaseMeasureMapController {
    
    @IBOutlet weak var tvMeasureInfo: UILabel!
    
    private let dataController = (UIApplication.shared.delegate as! AppDelegate).dataController

    private var fetchedResultsController: NSFetchedResultsController<Measure>!
    
    override func viewDidLoad() {
        DDLogVerbose("viewDidLoad")
        setupFetchedResultsController()
        
        // Test
        self.measureTypeSelected = .AREA
        self.performSegue(withIdentifier: MeasureEditorController.FROM_MAP_SEGUE_ID, sender: nil)
    }
    
    @IBAction func newMeasure(_ sender: Any) {
        performMeasureSegue(withIdentifier: MeasureEditorController.FROM_MAP_SEGUE_ID, sender: nil)
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Measure> = Measure.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "measures")
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    private func populateMeasures() {
        
    }
}

extension MapController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                break
            case .delete:
                break
            case .update:
                break
            case .move:
                break
            @unknown default:
                fatalError()
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
}
