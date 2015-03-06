//
//  GraphBuilder.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 19/11/2014.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class GraphBuilder : NSObject, CPTPlotDataSource {
    private var graphView:CPTGraphHostingView!
    private var dataCache:WaxDataCache!
    private var infoCache:WaxInfoCache!
    private let title:String
    private let live:Bool
    private var timer:NSTimer!
    private var recordedStartPos:Int
    
    init(title:String, live:Bool) {
        self.title = title
        self.live = live
        
        recordedStartPos = 0
    }
    
    func initLoad(graphView:CPTGraphHostingView, dataCache:WaxDataCache, infoCache:WaxInfoCache) {
        self.graphView = graphView
        self.dataCache = dataCache
        self.infoCache = infoCache
        
        configureHost()
        configureGraph()
        configurePlots()
        configureAxes()
    }
    
    private func configureHost() {
        graphView.allowPinchScaling = true
    }
    
    private func configureGraph() {
        var graph = CPTXYGraph(frame: CGRectZero)
        graphView.hostedGraph = graph
        
        var titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.blackColor()
        titleStyle.fontName = "HelveticaNeue-Medium"
        titleStyle.fontSize = 16.0
        
        graph.titleTextStyle = titleStyle
        graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop
        graph.titleDisplacement = CGPointMake(0.0, 10.0)
        
        graph.plotAreaFrame.paddingBottom = 30.0
        graph.plotAreaFrame.paddingLeft = 30.0
        
        graph.paddingTop = 40.0
        graph.paddingBottom = 40.0
        graph.paddingLeft = 40.0
        graph.paddingRight = 40.0
        
        graph.defaultPlotSpace.allowsUserInteraction = !live
    }
    
    private func configurePlots() {
        var graph = graphView.hostedGraph
        var plotSpace = graph.defaultPlotSpace
        
        var dataPlotX = CPTScatterPlot()
        var dataPlotY = CPTScatterPlot()
        var dataPlotZ = CPTScatterPlot()
        
        dataPlotX.dataSource = self
        dataPlotY.dataSource = self
        dataPlotZ.dataSource = self
        
        dataPlotX.identifier = WaxDataAxis.X.rawValue
        dataPlotY.identifier = WaxDataAxis.Y.rawValue
        dataPlotZ.identifier = WaxDataAxis.Z.rawValue
        
        graph.addPlot(dataPlotX, toPlotSpace: plotSpace)
        graph.addPlot(dataPlotY, toPlotSpace: plotSpace)
        graph.addPlot(dataPlotZ, toPlotSpace: plotSpace)
        
        var dataXColor = CPTColor.redColor()
        var dataYColor = CPTColor.greenColor()
        var dataZColor = CPTColor.blueColor()
        
        var dataXLineStyle = dataPlotX.dataLineStyle.mutableCopy() as! CPTMutableLineStyle
        dataXLineStyle.lineWidth = 2.5
        dataXLineStyle.lineColor = dataXColor
        dataPlotX.dataLineStyle = dataXLineStyle
        
        var dataYLineStyle = dataPlotY.dataLineStyle.mutableCopy() as! CPTMutableLineStyle
        dataYLineStyle.lineWidth = 2.5
        dataYLineStyle.lineColor = dataYColor
        dataPlotY.dataLineStyle = dataYLineStyle
        
        var dataZLineStyle = dataPlotZ.dataLineStyle.mutableCopy() as! CPTMutableLineStyle
        dataZLineStyle.lineWidth = 2.5
        dataZLineStyle.lineColor = dataZColor
        dataPlotZ.dataLineStyle = dataZLineStyle
    }
    
    private func configureAxes() {
        var axisTitleStyle = CPTMutableTextStyle.textStyle() as! CPTMutableTextStyle
        axisTitleStyle.color =  CPTColor.blackColor()
        axisTitleStyle.fontName = "HelveticaNeue-Medium"
        axisTitleStyle.fontSize = 12.0
        var axisLineStyle = CPTMutableLineStyle.lineStyle() as! CPTMutableLineStyle
        axisLineStyle.lineWidth = 2.0
        axisLineStyle.lineColor = CPTColor.blackColor()
        var axisTextStyle = CPTMutableTextStyle()
        axisTextStyle.color = CPTColor.blackColor()
        axisTextStyle.fontName = "HelveticaNeue-Medium"
        axisTextStyle.fontSize = 11.0
        
        var axisSet = graphView.hostedGraph.axisSet as! CPTXYAxisSet
        
        var x = axisSet.xAxis as CPTAxis
        x.title = "Time"
        x.titleTextStyle = axisTitleStyle
        x.titleOffset = 15.0
        x.axisLineStyle = axisLineStyle
        x.labelingPolicy = CPTAxisLabelingPolicyNone
        x.labelTextStyle = axisTextStyle
        x.majorTickLineStyle = axisLineStyle
        x.majorTickLength = 4.0
        x.tickDirection = CPTSignNegative
        
        var y = axisSet.yAxis as CPTAxis
        y.title = "Value"
        y.titleTextStyle = axisTitleStyle
        y.titleOffset = -20.0
        y.axisLineStyle = axisLineStyle
        y.labelingPolicy = CPTAxisLabelingPolicyNone;
        y.labelTextStyle = axisTextStyle
        y.labelOffset = 16.0
        y.majorTickLineStyle = axisLineStyle
        y.majorTickLength = 4.0
        y.minorTickLength = 2.0
        y.tickDirection = CPTSignPositive
    }
    
    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        if (dataCache.count() <= 100 && live) {
            return UInt(dataCache.count())
        }
        else if (!live) {
            for (var i = dataCache.count() - 1; i >= 0; i--) {
                if (infoCache[i].startRecording) {
                    recordedStartPos = i
                    return UInt(dataCache.count() - i)
                }
            }
        }
        
        return 100
    }
    
    func numberForPlot(plot: CPTPlot!, field fieldEnum: UInt, recordIndex idx: UInt) -> NSNumber! {
        switch (UInt32(fieldEnum)) {
        case CPTScatterPlotFieldX.value:
            return idx
        case CPTScatterPlotFieldY.value:
            var index = Int(idx)
            if (dataCache.count() > 100 && live) {
                var shift = dataCache.count() - 100
                
                index = index + shift
            }
            else if (!live) {
                index += recordedStartPos
            }
            
            switch plot.identifier as! Int {
            case WaxDataAxis.X.rawValue:
                return dataCache[index].x
            case WaxDataAxis.Y.rawValue:
                return dataCache[index].y
            case WaxDataAxis.Z.rawValue:
                return dataCache[index].z
            default:
                break
            }
        default:
            break
        }
        
        return 0
    }
    
    func dataLabelForPlot(plot: CPTPlot!, recordIndex idx: UInt) -> CPTLayer! {
        let info = infoCache[Int(idx)]
        
        if (!live && (info.startRecording || info.stopRecording || info.tapped || info.pinched || info.rotated || info.swiped || info.panned || info.edgePan || info.longPress)) {
            var labelText = ""
            
            labelText += info.startRecording ? "Started Recording\n" : ""
            labelText += info.stopRecording ? "Stopped Recording\n" : ""
            labelText += info.tapped ? "Tapped\n" : ""
            labelText += info.pinched ? "Pinched\n" : ""
            labelText += info.rotated ? "Rotated\n" : ""
            labelText += info.swiped ? "Swiped\n" : ""
            labelText += info.panned ? "Panned\n" : ""
            labelText += info.edgePan ? "Edge Pan\n" : ""
            labelText += info.longPress ? "Long Press\n" : ""
            
            return CPTTextLayer(text: labelText)
        }
        
        return CPTLayer()
    }
    
    func refresh() {
        graphView.hostedGraph.reloadData()
        graphView.hostedGraph.defaultPlotSpace.scaleToFitPlots(graphView.hostedGraph.allPlots())
    }
    
    func pause() {
        timer.invalidate()
    }
    
    func resume() {
        if (live) {
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "refresh", userInfo: nil, repeats: true)
        }
    }
}