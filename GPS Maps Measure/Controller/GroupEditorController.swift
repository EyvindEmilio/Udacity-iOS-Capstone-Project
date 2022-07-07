//
//  GroupEditorController.swift
//  GPS Maps Measure
//
//  Created by Eyvind on 6/7/22.
//

import UIKit
import CocoaLumberjackSwift

class GroupEditorController: UIViewController, UIColorPickerViewControllerDelegate {
    private static let CONTROLLER_ID = "GroupEditorController"
    
    private let dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    
    private var group: Group? = nil

    @IBOutlet weak var ivSelectColor: UIImageView!
    @IBOutlet weak var tfGroupName: UITextField!
    
    static func launchForNew(_ viewController: UIViewController){
        let newController = viewController.storyboard?.instantiateViewController(withIdentifier: CONTROLLER_ID) as! GroupEditorController
        newController.group = nil
        viewController.present(newController, animated: true, completion: nil)
    }
    
    static func launchForEdit(_ viewController: UIViewController, _ group: Group){
        let newController = viewController.storyboard?.instantiateViewController(withIdentifier: CONTROLLER_ID) as! GroupEditorController
        newController.group = group
        viewController.present(newController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogVerbose("viewDidLoad")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onImageToSelectTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        ivSelectColor.isUserInteractionEnabled = true
        ivSelectColor.addGestureRecognizer(tapGesture)
        
        if isNewGroup() {
            populateDefault()
        } else {
            populateGroup()
        }
    }
    
    @objc func onImageToSelectTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            DDLogVerbose("onImageToSelectTap()")
            selectColor()
        }
    }
    
    @IBAction func saveGroup(_ sender: Any) {
        let name = tfGroupName.text

        if name == nil || name?.isEmpty == true {
            showSingleAlert("Name is required")
            return
        }
        
        if isNewGroup() {
            self.group = Group(context: dataController.viewContext)
        }
        
        self.group?.name = name
        self.group?.updatedAt = Date()
        
        if let color = ivSelectColor.backgroundColor?.rgb() {
            self.group?.color = Int64(color)
        } else {
            group?.color = 0
        }
        
        try? dataController.viewContext.save()
        self.dismiss(animated: true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private func populateDefault() {
        ivSelectColor.backgroundColor = UIColor.blue
        tfGroupName.text = ""
    }
    
    private func populateGroup() {
        ivSelectColor.backgroundColor = group!.color.uiColor()
        tfGroupName.text = group?.name
    }
    
    private func isNewGroup() -> Bool {
        return group == nil
    }
    
    private func selectColor() {
        let pickerController = UIColorPickerViewController()
        if let color = self.ivSelectColor.backgroundColor {
            pickerController.selectedColor = color
        }
        pickerController.delegate = self
        self.present(pickerController, animated: true, completion: nil)
    }
             
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        self.ivSelectColor.backgroundColor = viewController.selectedColor
    }
}
