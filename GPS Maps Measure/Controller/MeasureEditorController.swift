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
    @IBOutlet weak var tvMeasureInfo: UILabel!
    @IBOutlet weak var btnDeletePoint: UIButton!
    
    private var fetchedGroupsController: NSFetchedResultsController<Group>!
    private var list = [MKPointAnnotation]()
    private var measure: Measure? = nil
    private var groupSelected: Group? = nil
    
    private var selectedAnnotation: MKAnnotation? = nil
    
    
    static func populateForNew(_ viewController: MeasureEditorController,_ type: MeasureType) {
        viewController.measureType = type
    }
    
    static func populateForEdit(_ viewController: MeasureEditorController, _ measure: Measure) {
        viewController.measureType = measure.getMeasureType()
        viewController.groupSelected = measure.group
        viewController.measure = measure
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onPointSelected(_:)))
        mapView.addGestureRecognizer(gestureRecognizer)
        
        setupFetchedGroupsController()
        
        if isNew() {
            populateGroups()
        } else {
            populateMeasure()
        }
        
        btnDeletePoint.isEnabled = !list.isEmpty
        loadLastPosition()
    }

    @IBAction func removePin(_ sender: Any) {
        _ = list.popLast()
        drawAnnotaions()
        drawFigure()
        redrawDetail()
        btnDeletePoint.isEnabled = !list.isEmpty
    }
    
    private func populateMeasure() {
        tfMeasureName?.text = measure?.name
        groupSelected = measure?.group
        measure?.getLayLngPoints().forEach({ point in
            let annotation = generateAnnotation(point.latitude, point.longitude)
            self.mapView.addAnnotation(annotation)
            self.list.append(annotation)
            self.selectedAnnotation = annotation
        })
        drawFigure()
        autoZoomToOverlay()
        populateGroups()
        redrawDetail()
    }
    
    private func autoZoomToOverlay() {
        let insets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        if let overlay = mapView.overlays.first {
            mapView.setVisibleMapRect(overlay.boundingMapRect, edgePadding: insets, animated: true)
        }
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
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    private func populateGroups() {
        DDLogVerbose("populateGroups()")
        var groupAction = [UIAction]()
        var isPrimarySet = false

        btnGroups.imageView?.image = UIImage(systemName: "circle.fill")
        btnGroups.imageView?.isHidden = false
        
        var canAutoSelect: Bool = false
        if let groupSelected = groupSelected {
            fetchedGroupsController.fetchedObjects?.forEach({ group in
                if group.id == groupSelected.id {
                    canAutoSelect = true
                }
            })
        }
        
        fetchedGroupsController.fetchedObjects?.forEach({ group in
//            let image = UIImage(systemName: "circle.fill")?
//                .withTintColor(group.color.uiColor())
//                .withRenderingMode(.alwaysTemplate)
            var state: UIMenuElement.State = .off
            
            if canAutoSelect { // To look for the group
                if group.id == self.groupSelected?.id {
                    state = .on
                }
            } else { // To set the first group
                state = isPrimarySet ? .off : .on
            }
            
            let action = UIAction(title: group.name ?? "", image: nil, state: state, handler: { uiAction in
                self.groupSelected = group
                self.drawFigure()
            })
            groupAction.append(action)
            
            if !canAutoSelect {
                if !isPrimarySet {
                    self.groupSelected = group
                }
                isPrimarySet = true
            }
        })
        btnGroups.menu = UIMenu(children: groupAction)
        btnGroups.showsMenuAsPrimaryAction = true
        btnGroups.changesSelectionAsPrimaryAction = true
        
    }
    
    @objc func onPointSelected(_ gestureReconizer: UITapGestureRecognizer) {
        dump(gestureReconizer)
        if gestureReconizer.state == .ended {
            let location = gestureReconizer.location(in: mapView)
            let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
            
            handleNewPointSelected(coordinate)
        }
    }
    
    private func handleNewPointSelected(_ coordinate: CLLocationCoordinate2D){
        switch measureType {
        case .CIRCLE:
            let annotation = generateAnnotation(coordinate.latitude, coordinate.longitude)
            if list.count >= 2 { // remove the last
                _ = list.popLast()
                drawAnnotaions() // Needed for CIRCLE
            }
            addAnnotation(annotation)
            break
        case .DISTANCE:
            let annotation = generateAnnotation(coordinate.latitude, coordinate.longitude)
            addAnnotation(annotation)
            break
        case .AREA:
            let annotation = generateAnnotation(coordinate.latitude, coordinate.longitude)
            addAnnotation(annotation)
            break
        case .POI:
            list.removeAll()
            let annotation = generateAnnotation(coordinate.latitude, coordinate.longitude)
            addAnnotation(annotation)
            drawAnnotaions() // Needed for POI
            break
        case .none:
            break
        case .some(_):
            break
        }
        
        drawFigure()
        redrawDetail()
        btnDeletePoint.isEnabled = !list.isEmpty
    }
    
    private func addAnnotation(_ annotation: MKPointAnnotation){
        mapView.addAnnotation(annotation)
        list.append(annotation)
    }
    
    func generateAnnotation(_ lat: Double,_ lon: Double) -> MKPointAnnotation {
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        return annotation
    }
    
    @objc func save() {
        DDLogVerbose("save()")
        let name = tfMeasureName.text
        
        if name == nil || name?.isEmpty == true {
            showSingleAlert("Please enter the measure name")
            return
        }
        
        if list.isEmpty {
            showSingleAlert("Please select a point at least in the map")
            return
        }
        
        if measureType == .CIRCLE && list.count < 2 {
            showSingleAlert("Circle needs 2 points at least")
            return
        }
        
        if measureType == .AREA && list.count < 3 {
            showSingleAlert("Area needs 3 points at least")
            return
        }
        
        if measureType == .DISTANCE && list.count < 2 {
            showSingleAlert("Distance needs 2 points at least")
            return
        }
        
        if isNew() {
            measure = Measure.newInstance(context: dataController.viewContext,
                                name: name!,
                                group: groupSelected!,
                                type: measureType,
                                points: list.toPointLocation())
        } else {
            measure?.name = name!
            measure?.group = groupSelected!
            measure?.setPointsList(points: list.toPointLocation())
        }
        
        measure?.updatedAt = Date()
        
        try? dataController.viewContext.save()
        
        navigationController?.popViewController(animated: true)
    }
    
    private func loadLastPosition() {
        let lastLocation = UserPref.getLastLocation()
        let lastSpanLocation = UserPref.getLastSpanLocation()
        
        if lastLocation != nil && lastSpanLocation != nil {
            let center = CLLocationCoordinate2D(latitude: lastLocation!.latitude, longitude: lastLocation!.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: lastSpanLocation!.latitude, longitudeDelta: lastSpanLocation!.longitude))
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func isNew() -> Bool {
        return measure == nil
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView!.isDraggable = true
            pinView!.animatesDrop = false
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = groupSelected?.color.uiColor() ?? .blue
            renderer.lineWidth = 5
            return renderer
        } else if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(overlay: overlay)
            renderer.fillColor =  groupSelected?.color.uiColor() ?? .blue
            renderer.alpha = 0.6
            return renderer
        } else if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor =  groupSelected?.color.uiColor() ?? .blue
            renderer.alpha = 0.6
            return renderer
        }
        return MKPolylineRenderer(overlay: overlay)
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        DDLogVerbose("mapView didSelect annotationView")
        if view.dragState == .none {
            view.dragState = .starting
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        drawFigure()
        redrawDetail()
    }
    
    func drawFigure() {
        switch measureType {
        case .AREA:
            let coordinates = list.map { annotation in annotation.coordinate }
            let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
            mapView.removeOverlays(mapView.overlays)
            mapView.addOverlay(polygon)
            break
        case .DISTANCE:
            let coordinates = list.map { annotation in annotation.coordinate }
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            mapView.removeOverlays(mapView.overlays)
            mapView.addOverlay(polyline)
            break
        case .CIRCLE:
            if list.count >= 2 {
                let center = list[0].coordinate
                let secondPoint = list[1].coordinate
                let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
                let secondPointLocation = CLLocation(latitude: secondPoint.latitude, longitude: secondPoint.longitude)
                
                let circle = MKCircle(center: center, radius: centerLocation.distance(from: secondPointLocation))
                mapView.removeOverlays(mapView.overlays)
                mapView.addOverlay(circle)
            }
            break
        case .POI: break
        case .none: break
        }
    }
    
    private func drawAnnotaions() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(list)
    }
    
    private func redrawDetail() {
        measure?.setPointsList(points: list.toPointLocation())
        measure?.regenerateCalcs()
        tvMeasureInfo.text = measure?.getDescription()
    }
}
