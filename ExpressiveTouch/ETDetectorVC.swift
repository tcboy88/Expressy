//
//  ETDetectorVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 03/02/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class ETDetectorVC: UIViewController {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func exportData(sender: AnyObject) {
        let headerLine = "Time,ax,ay,az,gx,gy,gz,mx,my,mz,gravx,gravy,gravz,yaw,pitch,roll,Touch,Touch Force"
        let csv = CSVBuilder(fileNames: ["data.csv"], headerLines: [headerLine])
        
        let dataCache = WaxProcessor.getProcessor().dataCache
        
        for i in 0..<dataCache.count() {
            let data = dataCache[i]
            let ypr = data.getYawPitchRoll()
            csv.appendRow("\(data.time),\(data.acc.x),\(data.acc.y),\(data.acc.z),\(data.gyro.x),\(data.gyro.y),\(data.gyro.z),\(data.mag.x),\(data.mag.y),\(data.mag.z),\(data.grav.x),\(data.grav.y),\(data.grav.z),\(ypr.yaw),\(ypr.pitch),\(ypr.roll),\(data.touch),\(data.touchForce)", index: 0)
        }
        
        csv.emailCSV(self, subject: "Interaction Data")
    }
    
    override func viewDidDisappear(animated: Bool) {
        let interactionView = self.view as! InteractionView
        interactionView.detector.stopDetection()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}