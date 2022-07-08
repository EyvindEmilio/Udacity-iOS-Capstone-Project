//
//  RestClient.swift
//  GPS Maps Measure
//
//  Created by Eyvind on 7/7/22.
//

import Foundation
import CocoaLumberjackSwift

class RestClient {

    struct Auth {
//        static let STATIC_MAPS_API_KEY = "<YOUR_CUSTOMER_KEY>"
        static let STATIC_MAPS_API_KEY = "AIzaSyCAMS-q3d-74J1a6og37-vmQFY4OjAZQv4"
    }

    enum Endpoints {
        static let BASE = "https://maps.googleapis.com/maps/api"

        case downloadPhoto(Bool, String, String)

        var stringValue: String {
            switch self {
            case .downloadPhoto(let needsFill, let fillColor, let points):
                return "\(Endpoints.BASE)/staticmap?" +
                        "key=\(Auth.STATIC_MAPS_API_KEY)&" +
                        "size=144x144&" +
                        "maptype=satellite&" +
                        "sensor=false&" +
                        "path=color:\(fillColor)|weight:\(needsFill ? "1" : "7")|fillcolor:\(needsFill ? "0x\(fillColor)" : "0x01000000")|\(points)"
            }
        }

        var url: URL {
            URL(string: stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        }
    }

    class func downloadMap(_ points: String, needsFill: Bool, color: String, completion: @escaping (Data?, Error?) -> Void) {
        let url = Endpoints.downloadPhoto(needsFill, color, points).url
        DDLogVerbose("downloadPhoto() url=\(url)")

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
        task.resume()
    }

}
