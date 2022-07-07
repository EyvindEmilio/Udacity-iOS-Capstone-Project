//
//  CustomLogFormatter.swift
//  GPS Maps Measure
//
//  Created by Eyvind on 28/6/22.
//

import Foundation
import CocoaLumberjack

public class CustomLogFormatter: NSObject, DDLogFormatter {
    
    let dateFormmater = DateFormatter()
    
    public override init() {
        super.init()
        dateFormmater.dateFormat = "yyyy/MM/dd HH:mm:ss:SSS"
    }

    public func format(message logMessage: DDLogMessage) -> String? {
        
        let logLevel: String
        switch logMessage.flag {
        case DDLogFlag.error:
            logLevel = "E"
        case DDLogFlag.warning:
            logLevel = "W"
        case DDLogFlag.info:
            logLevel = "I"
        case DDLogFlag.debug:
            logLevel = "D"
        default:
            logLevel = "V"
        }
        
        let dt = dateFormmater.string(from: logMessage.timestamp)
        let logMsg = logMessage.message
        let lineNumber = logMessage.line
        let file = logMessage.fileName
        let functionName = logMessage.function
        let threadId = logMessage.threadID

        
        //return "\(dt) [\(threadId)] [\(logLevel)] [\(file):\(lineNumber)]\(functionName) - \(logMsg)"
        
        //return "[\(threadId)] [\(logLevel)] [\(file):\(lineNumber)]\(functionName ?? "") - \(logMsg)"
        return "[\(threadId)] [\(logLevel)] [\(file):\(lineNumber)] - \(logMsg)"
    }
    
}
