//
//  GroupController.swift
//  GPS Maps Measure
//
//  Created by Eyvind on 2/7/22.
//

import Foundation
import UIKit
import CoreData
import CocoaLumberjackSwift

class GroupController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let dataController = (UIApplication.shared.delegate as! AppDelegate).dataController

    private var fetchedResultsController: NSFetchedResultsController<Group>!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tvNoItemsFound: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogVerbose("viewDidLoad()")
        setupFetchedResultsController()
        handleEmptyView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    @IBAction func addGroup(_ sender: Any) {
        GroupEditorController.launchForNew(self)
    }

    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "groups")
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

    func handleEmptyView() {
        tvNoItemsFound.isHidden = fetchedResultsController.fetchedObjects?.count != 0
    }

    func deleteGroup(at indexPath: IndexPath) {
        let groupToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(groupToDelete)
        try? dataController.viewContext.save()
    }

    // MARK: Table Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        fetchedResultsController.sections?.count ?? 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let group = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        cell.textLabel?.text = group.name
        cell.detailTextLabel?.text = "Measures: \(group.measures?.count ?? 0)"
        cell.imageView?.tintColor = group.color.uiColor()

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteGroup(at: indexPath)
        default: ()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = fetchedResultsController.object(at: indexPath)
        GroupEditorController.launchForEdit(self, group)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension GroupController: NSFetchedResultsControllerDelegate {
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


