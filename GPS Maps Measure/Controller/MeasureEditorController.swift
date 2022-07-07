//
//  MeasureEditorController.swift
//  GPS Maps Measure
//
//  Created by Eyvind on 6/7/22.
//

import Foundation
import UIKit
import CoreData
import MapKit
import CocoaLumberjackSwift

class MeasureEditorController: UIViewController, MKMapViewDelegate {
    
    public static let FROM_MAP_SEGUE_ID = "FromMapSegueToEditor"
    public static let FROM_MEASURES_SEGUE_ID = "FromMeasuresSegueToEditor"
    
    private let dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    private var measureType: MeasureType!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnGroups: UIButton!
    @IBOutlet weak var tfMeasureName: UITextField!
    
    private var fetchedGroupsController: NSFetchedResultsController<Group>!
    private var list = [MKPointAnnotation]()
    private var measure: Measure? = nil
    private var groupSelected: Group? = nil
    
    static func populateForNew(_ viewController: MeasureEditorController,_ type: MeasureType) {
        viewController.measureType = type
    }
    
    static func populateForEdit(_ viewController: UIViewController, _ measure: Measure) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onPointSelected(_:)))
        mapView.addGestureRecognizer(gestureRecognizer)
        
        setupFetchedGroupsController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    fileprivate func setupFetchedGroupsController() {
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedGroupsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "groups")

        do {
            try fetchedGroupsController.performFetch()
            populateGroups()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    private func populateGroups(){
        DDLogVerbose("populateGroups()")
        var groupAction = [UIAction]()
        var isPrimarySet = false

        btnGroups.imageView?.image = UIImage(systemName: "circle.fill")
        btnGroups.imageView?.isHidden = false
        fetchedGroupsController.fetchedObjects?.forEach({ group in

//            let image = UIImage(systemName: "circle.fill")?
//                .withTintColor(group.color.uiColor())
//                .withRenderingMode(.alwaysTemplate)
            
            let action = UIAction(title: group.name ?? "", image: nil, state: isPrimarySet ? .off : .on, handler: { uiAction in
                self.groupSelected = group
                self.drawArea()
            })
            groupAction.append(action)
            if !isPrimarySet {
                self.groupSelected = group
            }
            isPrimarySet = true
        })
        btnGroups.menu = UIMenu(children: groupAction)
        btnGroups.showsMenuAsPrimaryAction = true
        btnGroups.changesSelectionAsPrimaryAction = true
        
    }
    
    @objc func onPointSelected(_ gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == .ended {
            debugPrint("LongPress ended")
            let location = gestureReconizer.location(in: mapView)
            let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
            
            let currentAnnotation = generateAnnotation(coordinate.latitude, coordinate.longitude)
            mapView.addAnnotation(currentAnnotation)
            list.append(currentAnnotation)
            drawArea()
        }
    }
    
    func generateAnnotation(_ lat: Double,_ lon: Double) -> MKPointAnnotation {
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        return annotation
    }
    
    
    @objc func save() {
        DDLogVerbose("save()")
        if isNew() {
            measure = Measure(context: dataController.viewContext)
        } else {
            
        }
        
        measure?.name = tfMeasureName.text ?? ""
        measure?.group = groupSelected!
        measure?.area = 0.0
        measure?.perimeter = 0.0
        measure?.distance = 0.0
        measure?.circumference = 0.0
        measure?.simplePoints = ""
        measure?.radio = 0.0
        measure?.updatedAt = Date()
        measure?.type = measureType.rawValue
        
        try? dataController.viewContext.save()
        
    }
    
    private func isNew() -> Bool {
        return measure == nil
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.isDraggable = true
            //pinView!.animatesDrop = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = .orange
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        } else if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.fillColor =  groupSelected?.color.uiColor() ?? .blue
            polygonView.alpha = 0.6
            return polygonView
        }
        return MKPolylineRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        DDLogVerbose("didChangeState")
        DDLogVerbose(mapView.annotations.filter { anottation in
            return anottation.hash == mapView.annotations.first!.hash
        }.count)
//
//        if (newState == .starting) {
//            view.dragState = MKAnnotationView.DragState.dragging
//         } else if (newState == .ending || newState == .canceling){
//             view.dragState = .none
//        }
        
        drawArea()
    }
    
    func drawArea() {
        let coordinates = list.map { annotation in
            annotation.coordinate
        }
        let pol = MKPolygon(coordinates: coordinates, count: coordinates.count)
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(pol)
//        let polygon = MKPolygon(coordinates: &points, count: points.count)
//                mapView.add(polygon) //Add polygon areas
    }
}
