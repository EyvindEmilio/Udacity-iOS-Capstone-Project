//
//  MeasureController.swift
//  GPS Maps Measure
//
//  Created by Eyvind on 2/7/22.
//

import Foundation
import UIKit
import CoreData
import CocoaLumberjackSwift

class MeasureController: BaseMeasureMapController, UITableViewDataSource, UITableViewDelegate {
    
    private let dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    
    private var fetchedResultsController: NSFetchedResultsController<Measure>!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tvNoItemsFound: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogVerbose("viewDidLoad()")
        setupFetchedResultsController()
        handleEmptyView()
    }
    
    @IBAction func newMeasure(_ sender: Any) {
        performMeasureSegue(withIdentifier: MeasureEditorController.FROM_MEASURES_SEGUE_ID, sender: nil)
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
    
    func deleteMeasure(at indexPath: IndexPath) {
        let measureToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(measureToDelete)
        try? dataController.viewContext.save()
    }
    
    func handleEmptyView() {
        tvNoItemsFound.isHidden = fetchedResultsController.fetchedObjects?.count != 0
    }
    
    // MARK: Table Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let measure = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeaureCell", for: indexPath)
        cell.textLabel?.text = measure.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
            case .delete: deleteMeasure(at: indexPath)
            default: ()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let measure = fetchedResultsController.object(at: indexPath)
        performMeasureSegue(withIdentifier: MeasureEditorController.FROM_MEASURES_SEGUE_ID, sender: measure)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


extension MeasureController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
                break
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
                break
            case .update:
                tableView.reloadRows(at: [indexPath!], with: .fade)
            case .move:
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            @unknown default:
                fatalError()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
            case .insert: tableView.insertSections(indexSet, with: .fade)
            case .delete: tableView.deleteSections(indexSet, with: .fade)
            case .update, .move:
                fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
            @unknown default:
                fatalError()
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        tableView.reloadData()
        handleEmptyView()
    }
}
