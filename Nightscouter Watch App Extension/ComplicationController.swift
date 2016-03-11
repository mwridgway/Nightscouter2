//
//  ComplicationController.swift
//  Nightscouter Watch WatchKit Extension
//
//  Created by Peter Ina on 1/11/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import ClockKit
import NightscouterWatchKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.Backward])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        #if DEBUG
            // print(">>> Entering \(__FUNCTION__) <<<")
        #endif
        var date: NSDate?
        let model = SitesDataSource.sharedInstance.oldestComplicationDataForPrimarySite
        date = model?.date
        
        #if DEBUG
            // print("getTimelineStartDateForComplication:\(date)")
        #endif
        
        handler(date)
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        #if DEBUG
            // print(">>> Entering \(__FUNCTION__) <<<")
        #endif
        var date: NSDate? = nil
        let model = SitesDataSource.sharedInstance.latestComplicationDataForPrimarySite
        date = model?.date
        
        
        #if DEBUG
            // print("getTimelineStartDateForComplication:\(date)")
        #endif
        
        handler(date)
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.ShowOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        // Call the handler with the current timeline entry
        #if DEBUG
            print(">>> Entering \(__FUNCTION__) <<<")
        #endif
        
        getTimelineEntriesForComplication(complication, beforeDate: NSDate(), limit: 1) { (timelineEntries) -> Void in
            handler(timelineEntries?.first)
        }
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        
        #if DEBUG
            // print(">>> Entering \(__FUNCTION__) <<<")
            // print("complication: \(complication.family)")
        #endif
        
        var timelineEntries = [CLKComplicationTimelineEntry]()
        
        let entries = SitesDataSource.sharedInstance.primarySite?.complicationTimeline ?? []
        
        for entry in entries {
            let entryDate = entry.date
            if date.compare(entryDate) == .OrderedDescending {
                if let template = templateForComplication(complication, model: entry) {
                    let entry = CLKComplicationTimelineEntry(date: entryDate, complicationTemplate: template)
                    timelineEntries.append(entry)
                    if timelineEntries.count == limit {
                        break
                    }
                }
            }
        }
        handler(timelineEntries)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        #if DEBUG
            // print(">>> Entering \(__FUNCTION__) <<<")
            // print("complication: \(complication.family)")
        #endif
        
        var timelineEntries = [CLKComplicationTimelineEntry]()
        
        let entries = SitesDataSource.sharedInstance.primarySite?.complicationTimeline ?? []
        
        for entry in entries {
            let entryDate = entry.date
            if date.compare(entryDate) == .OrderedAscending {
                if let template = templateForComplication(complication, model: entry) {
                    let entry = CLKComplicationTimelineEntry(date: entryDate, complicationTemplate: template)
                    timelineEntries.append(entry)
                    if timelineEntries.count == limit {
                        break
                    }
                }
            }
        }
        
        handler(timelineEntries)
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        let nextUpdate = SitesDataSource.sharedInstance.nextRequestedComplicationUpdateDate
        
        #if DEBUG
            print("Next Requested Update Date is:\(nextUpdate)")
        #endif
        
        handler(nextUpdate)
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        
        var template: CLKComplicationTemplate? = nil
        
        let utilLargeSting = PlaceHolderStrings.sgv + " " + PlaceHolderStrings.delta + " " + PlaceHolderStrings.raw
        
        switch complication.family {
        case .ModularSmall:
            let modularSmall = CLKComplicationTemplateModularSmallStackText()
            modularSmall.line1TextProvider = CLKSimpleTextProvider(text: PlaceHolderStrings.sgv)
            modularSmall.line2TextProvider = CLKSimpleTextProvider(text: PlaceHolderStrings.delta)
            
            template = modularSmall
        case .ModularLarge:
            let modularLarge = CLKComplicationTemplateModularLargeTable()
            
            modularLarge.headerTextProvider = CLKSimpleTextProvider(text: PlaceHolderStrings.appName)
            modularLarge.row1Column1TextProvider = CLKSimpleTextProvider(text: PlaceHolderStrings.delta)
            modularLarge.row1Column2TextProvider = CLKSimpleTextProvider(text: PlaceHolderStrings.date)//CLKRelativeDateTextProvider(date: NSDate(), style: .Offset, units: [.Minute, .Hour, .Day])
            modularLarge.row2Column1TextProvider = CLKSimpleTextProvider(text: PlaceHolderStrings.raw)
            modularLarge.row2Column2TextProvider = CLKSimpleTextProvider(text: "")
            
            template = modularLarge
        case .UtilitarianSmall:
            let utilitarianSmall = CLKComplicationTemplateUtilitarianSmallFlat()
            utilitarianSmall.textProvider = CLKSimpleTextProvider(text: PlaceHolderStrings.sgv)
            
            template = utilitarianSmall
        case .UtilitarianLarge:
            let utilitarianLarge = CLKComplicationTemplateUtilitarianLargeFlat()
            utilitarianLarge.textProvider = CLKSimpleTextProvider(text: utilLargeSting)
            
            template = utilitarianLarge
        case .CircularSmall:
            let circularSmall = CLKComplicationTemplateCircularSmallStackText()
            circularSmall.line1TextProvider = CLKSimpleTextProvider(text: PlaceHolderStrings.sgv)
            circularSmall.line2TextProvider = CLKSimpleTextProvider(text: PlaceHolderStrings.delta)
            
            template = circularSmall
        }
        
        handler(template)
    }
}

extension ComplicationController {
    private func templateForComplication(complication: CLKComplication, model: ComplicationTimelineEntry) -> CLKComplicationTemplate? {
        #if DEBUG
            print(">>> Entering \(__FUNCTION__) <<<")
        #endif
        
        var template: CLKComplicationTemplate? = nil
        
        let displayName = model.nameLabel
        let sgv = model.sgvLabel + " " + model.direction.emojiForDirection
        let tintColor = model.sgvColor
        let delta = model.deltaLabel
        let deltaShort = model.deltaShort
        let raw = !model.rawHidden ? model.rawFormatedLabel : ""
        let rawShort = !model.rawHidden ? model.rawFormatedLabelShort : ""
        
        let utilLargeSting = sgv + " " + delta + " " + raw
        let utilLargeStingShort = sgv + " " + deltaShort + " " + raw
        
        switch complication.family {
        case .ModularSmall:
            let modularSmall = CLKComplicationTemplateModularSmallStackText()
            modularSmall.line1TextProvider = CLKSimpleTextProvider(text: sgv)
            modularSmall.line2TextProvider = CLKSimpleTextProvider(text: delta, shortText: deltaShort)
            modularSmall.tintColor = tintColor
            
            // Set the template
            template = modularSmall
        case .ModularLarge:
            let modularLarge = CLKComplicationTemplateModularLargeTable()
            modularLarge.headerTextProvider = CLKSimpleTextProvider(text: sgv + " " + delta , shortText: sgv + " " + deltaShort)
            modularLarge.row1Column1TextProvider = CLKSimpleTextProvider(text: displayName)
            modularLarge.row1Column2TextProvider = CLKRelativeDateTextProvider(date: model.date, style: .Natural, units: [.Minute, .Hour, .Day])
            modularLarge.row2Column1TextProvider = CLKSimpleTextProvider(text: raw, shortText: rawShort)
            modularLarge.row2Column2TextProvider = CLKSimpleTextProvider(text: "")
            modularLarge.tintColor = tintColor
            
            template = modularLarge
        case .UtilitarianSmall:
            let utilitarianSmall = CLKComplicationTemplateUtilitarianSmallFlat()
            utilitarianSmall.textProvider = CLKSimpleTextProvider(text: sgv)
            
            template = utilitarianSmall
        case .UtilitarianLarge:
            let utilitarianLarge = CLKComplicationTemplateUtilitarianLargeFlat()
            utilitarianLarge.textProvider = CLKSimpleTextProvider(text: utilLargeSting, shortText: utilLargeStingShort)
            utilitarianLarge.tintColor = tintColor
            
            template = utilitarianLarge
        case .CircularSmall:
            let circularSmall = CLKComplicationTemplateCircularSmallStackText()
            circularSmall.line1TextProvider = CLKSimpleTextProvider(text: sgv)
            circularSmall.line2TextProvider = CLKSimpleTextProvider(text: delta, shortText: deltaShort)
            circularSmall.tintColor = tintColor
            
            template = circularSmall
        }
        
        return template
    }
    
}

extension ComplicationController {
    func requestedUpdateDidBegin() {
        #if DEBUG
            print(">>> Entering \(__FUNCTION__) <<<")
        #endif
        
        // TODO: Start up connecitivty session ask for data from data source. and update.
        
        // Ask data store for new data..
    }
    
    func requestedUpdateBudgetExhausted() {
        #if DEBUG
            print(">>> Entering \(__FUNCTION__) <<<")
        #endif
        // TODO: Start up connecitivty session ask for data from data source. and update. Also bookmark when this happened. Maybe add a new timeline entry informing the user.
        // Ask data store for new data.. log when this happened.
    }
    
    static func reloadComplications() {
        #if DEBUG
            print(">>> Entering \(__FUNCTION__) <<<")
        #endif
        
        let complicationServer = CLKComplicationServer.sharedInstance()
        if let activeComplications = complicationServer.activeComplications {
            for complication in activeComplications {
                complicationServer.reloadTimelineForComplication(complication)
            }
        }
        
    }
    
    static func extendComplications() {
        #if DEBUG
            print(">>> Entering \(__FUNCTION__) <<<")
        #endif
        
        let complicationServer = CLKComplicationServer.sharedInstance()
        if let activeComplications = complicationServer.activeComplications {
            for complication in activeComplications {
                complicationServer.extendTimelineForComplication(complication)
            }
        }
        
    }
}