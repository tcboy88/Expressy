//
//  WaxProcessor.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 12/22/14.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

var waxProcessor:WaxProcessor = nil
var initialisedProcessor = false

class WaxProcessor: NilLiteralConvertible {
    internal var accCache:WaxCache
    internal var gyroCache:WaxCache
    internal var magCache:WaxCache
    
    private let accNorm:Double = 1 / 4096.0
    private let gyroNorm:Double = 0.07
    private let magNorm:Double = 0.1
    
    required init(nilLiteral: ()) {
        accCache = nil
        gyroCache = nil
        magCache = nil
    }
    
    init() {
        assert(!initialisedProcessor)
        
        accCache = WaxCache()
        gyroCache = WaxCache()
        magCache = WaxCache()
        
        waxProcessor = self
        
        initialisedProcessor = true
    }
    
    class func getProcessor() -> WaxProcessor {
        return waxProcessor
    }
    
    func updateCache(data:NSData) {
        var ax:CShort = 0;
        var ay:CShort = 0;
        var az:CShort = 0;
        var gx:CShort = 0;
        var gy:CShort = 0;
        var gz:CShort = 0;
        var mx:CShort = 0;
        var my:CShort = 0;
        var mz:CShort = 0;
        
        var dataLength = data.length;
        
        assert( dataLength == 20 );
        
        var buffer = [UInt8](count: dataLength, repeatedValue: 0)
        
        data.getBytes(&buffer, length: dataLength)
        
        ax = CShort(buffer[ 3]) << 8 + CShort(buffer[ 2])
        ay = CShort(buffer[ 5]) << 8 + CShort(buffer[ 4])
        az = CShort(buffer[ 7]) << 8 + CShort(buffer[ 6])
        
        gx = CShort(buffer[ 9]) << 8 + CShort(buffer[ 8])
        gy = CShort(buffer[11]) << 8 + CShort(buffer[10])
        gz = CShort(buffer[13]) << 8 + CShort(buffer[12])
        
        mx = CShort(buffer[15]) << 8 + CShort(buffer[14])
        my = CShort(buffer[17]) << 8 + CShort(buffer[16])
        mz = CShort(buffer[19]) << 8 + CShort(buffer[18])
        
        accCache.push(WaxData(x: Double(ax) * accNorm, y: Double(ay) * accNorm, z: Double(az) * accNorm))
        gyroCache.push(WaxData(x: Double(gx) * gyroNorm, y: Double(gy) * gyroNorm, z: Double(gz) * gyroNorm))
        magCache.push(WaxData(x: Double(mx) * magNorm, y: Double(my) * magNorm, z: Double(mz) * magNorm))
    }
    
    func startRecording() {
        accCache.startRecording()
        gyroCache.startRecording()
        magCache.startRecording()
    }
    
    func stopRecording() {
        accCache.stopRecording()
        gyroCache.stopRecording()
        magCache.stopRecording()
    }
    
    func tapped() {
        accCache.tapped()
        gyroCache.tapped()
        magCache.tapped()
    }
    
    func pinched() {
        accCache.pinched()
        gyroCache.pinched()
        magCache.pinched()
    }
    
    func rotated() {
        accCache.rotated()
        gyroCache.rotated()
        magCache.rotated()
    }
    
    func swiped() {
        accCache.swiped()
        gyroCache.swiped()
        magCache.swiped()
    }
    
    func panned() {
        accCache.panned()
        gyroCache.panned()
        magCache.panned()
    }
    
    func edgePan() {
        accCache.edgePan()
        gyroCache.edgePan()
        magCache.edgePan()
    }
    
    func longPress() {
        accCache.longPress()
        gyroCache.longPress()
        magCache.longPress()
    }
}