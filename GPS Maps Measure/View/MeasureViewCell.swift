//
//  MeasureViewCell.swift
//  GPS Maps Measure
//
//  Created by Eyvind on 7/7/22.
//

import Foundation
import UIKit

class MeasureViewCell: UITableViewCell {
    static let IDENTIFIER = "MeasureCell"

    @IBOutlet weak var ivMap: UIImageView!
    @IBOutlet weak var tvTitle: UILabel!
    @IBOutlet weak var tvDescription: UILabel!
    @IBOutlet weak var loadingIndicatpr: UIActivityIndicatorView!

    func startLoading() {
        loadingIndicatpr.startAnimating()
        loadingIndicatpr.isHidden = false
        ivMap.isHidden = true
    }

    func stopLoading() {
        loadingIndicatpr.stopAnimating()
        loadingIndicatpr.isHidden = true
        ivMap.isHidden = false
    }
}
