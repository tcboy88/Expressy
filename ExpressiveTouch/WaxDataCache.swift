//
//  WaxDataCache.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 20/02/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class WaxDataCache {
    private let data:WaxCache<WaxData>
    
    init() {
        data = WaxCache<WaxData>()
    }
    
    subscript(index: Int) -> WaxData {
        get {
            return data.items[index]
        }
    }
    
    func add(newData:WaxData) {
        data.push(newData)
    }
    
    func count() -> Int {
        return data.count()
    }
    
    private func getIndexForTime(time:NSTimeInterval) -> Int {
        var closest:Int = 0
        for i in 0..<data.count() {
            if(abs(time - self[closest].time) > abs(self[i].time - time)) {
                closest = i;
            }
        }
        return closest;
    }
    
    func getForTime(time:NSTimeInterval) -> WaxData {
        return self[getIndexForTime(time)]
    }
    
    func getRangeForTime(start:NSTimeInterval, end:NSTimeInterval) -> [WaxData] {
        let startIndex = getIndexForTime(start)
        let endIndex = getIndexForTime(end)
        
        return data.getRange(startIndex, endIndex: endIndex)
    }
}