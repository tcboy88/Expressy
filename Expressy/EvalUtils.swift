//
//  EvalUtils.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 02/04/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class EvalUtils {
    /// Function to log a range of data between two time intervals.
    /// - parameter startTime: Time of start of range.
    /// - parameter endTime: Time of end of range.
    /// - parameter csv: CSV builder to append data to.
    class func logDataBetweenTimes(_ startTime:TimeInterval, endTime:TimeInterval, csv:CSVBuilder, file:String) {
        let data = SensorProcessor.dataCache.getRangeForTime(startTime, end: endTime)
        
        for d in data {
            csv.appendRow(d.print(), file: file)
        }
    }
    
    /// Function to retrive random particiapant ID.
    /// - returns: Random particiapnt ID.
    class func generateParticipantID() -> UInt32 {
        return arc4random_uniform(10000)
    }
}
