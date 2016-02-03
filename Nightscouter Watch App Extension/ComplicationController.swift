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
        handler(.Backward) //([.Forward, .Backward])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        
        var date: NSDate? = nil
        
        let model = SitesDataSource.sharedInstance.oldestComplicationModel
        date = model?.lastReadingDate
        
        handler(date)
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        var date: NSDate? = nil
        
        let model = SitesDataSource.sharedInstance.latestComplicationModel
        date = model?.lastReadingDate
        
        handler(date)
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.ShowOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        // Call the handler with the current timeline entry
        
        var timelineEntry : CLKComplicationTimelineEntry? = nil
        
        let today: NSDate = NSDate()
        let minutesToRemove = NSTimeInterval(240).inThePast
        // Set up date components
        let dateComponents: NSDateComponents = NSDateComponents()
        dateComponents.minute = Int(minutesToRemove)
        
        // Create a calendar
        let gregorianCalendar: NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let fourMinsAgo: NSDate = gregorianCalendar.dateByAddingComponents(dateComponents, toDate: today, options:NSCalendarOptions(rawValue: 0))!
        
        guard let model = SitesDataSource.sharedInstance.latestComplicationModel else {
            handler(nil)
            return
        }
        
        let dateCompare = model.date.compare(fourMinsAgo)
        
        if let template = templateForComplication(complication, model: model) where model.date >= fourMinsAgo {
            timelineEntry = CLKComplicationTimelineEntry(date: model.date, complicationTemplate: template)
        }
        
        handler(timelineEntry)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        
        var timelineEntries = [CLKComplicationTimelineEntry]()
        
        let entries = SitesDataSource.sharedInstance.complicationDataFromDefaults
        
        for entry in entries {
            let entryDate = entry.date
            if entryDate < date {
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
        var timelineEntries = [CLKComplicationTimelineEntry]()
        
        let entries = SitesDataSource.sharedInstance.complicationDataFromDefaults
        
        for entry in entries {
            let entryDate = entry.date
            if entryDate > date {
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
        handler(NSDate().dateByAddingTimeInterval(240))
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        
        // print(">>> Entering \(__FUNCTION__) <<<")
        // print("complication family: \(complication.family)")
        
        var template: CLKComplicationTemplate? = nil
        
        _ = NSAssetKitWatchOS.predefinedNeutralColor
        
        let utilLargeSting = PlaceHolderStrings.sgv + " " + PlaceHolderStrings.delta + " " + PlaceHolderStrings.raw
        
        switch complication.family {
        case .ModularSmall:
            let modularSmall = CLKComplicationTemplateModularSmallStackText()
            modularSmall.line1TextProvider = CLKSimpleTextProvider(text: PlaceHolderStrings.sgv)
            modularSmall.line2TextProvider = CLKSimpleTextProvider(text: PlaceHolderStrings.delta)
            
            // Set the template
            template = modularSmall
        case .ModularLarge:
            let modularLarge = CLKComplicationTemplateModularLargeTable()
            
            modularLarge.headerTextProvider = CLKSimpleTextProvider(text: "Nightscouter")
            modularLarge.row1Column1TextProvider = CLKSimpleTextProvider(text: PlaceHolderStrings.delta)
            modularLarge.row1Column2TextProvider = CLKRelativeDateTextProvider(date: NSDate(), style: .Offset, units: [.Minute, .Hour, .Day])
            modularLarge.row2Column1TextProvider = CLKSimpleTextProvider(text: PlaceHolderStrings.raw)
            modularLarge.row2Column2TextProvider = CLKSimpleTextProvider(text: " ")
            
            // Set the template
            template = modularLarge
        case .UtilitarianSmall:
            let utilitarianSmall = CLKComplicationTemplateUtilitarianSmallFlat()
            utilitarianSmall.textProvider = CLKSimpleTextProvider(text: PlaceHolderStrings.sgv)
            
            // Set the template
            template = utilitarianSmall
        case .UtilitarianLarge:
            let utilitarianLarge = CLKComplicationTemplateUtilitarianLargeFlat()
            utilitarianLarge.textProvider = CLKSimpleTextProvider(text: utilLargeSting)
            
            // Set the template
            template = utilitarianLarge
        case .CircularSmall:
            let circularSmall = CLKComplicationTemplateCircularSmallStackText()
            circularSmall.line1TextProvider = CLKSimpleTextProvider(text: PlaceHolderStrings.sgv)
            circularSmall.line2TextProvider = CLKSimpleTextProvider(text: PlaceHolderStrings.delta)
            
            // Set the template
            template = circularSmall
        }
        
        handler(template)
    }
    
}

extension ComplicationController {
    private func templateForComplication(complication: CLKComplication, model: ComplicationModel) -> CLKComplicationTemplate? {
        #if DEBUG
            print(">>> Entering \(__FUNCTION__) <<<")
        #endif
        
        var template: CLKComplicationTemplate? = nil
        
        let displayName = model.nameLabel
        let sgv = model.sgvLabel + " " + model.direction.emojiForDirection
        let tintColor = model.sgvColor
        
        let delta = model.deltaLabel
        let deltaShort = model.deltaLabel.stringByReplacingOccurrencesOfString(model.units.description, withString: PlaceHolderStrings.deltaAltJ)
        
        let utilLargeSting = sgv + " [" + delta + "] " + model.rawLabel
        let utilLargeStingShort = sgv + " [" + deltaShort + "] " + model.rawLabel
        
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
            modularLarge.headerTextProvider = CLKSimpleTextProvider(text: sgv + " (" + displayName + ")")
            
            modularLarge.row1Column1TextProvider = CLKSimpleTextProvider(text:  model.rawFormatedLabel)
            modularLarge.row1Column2TextProvider = CLKRelativeDateTextProvider(date: model.lastReadingDate, style: .Natural, units: [.Minute, .Hour, .Day])
            
            modularLarge.row2Column1TextProvider = CLKSimpleTextProvider(text: delta, shortText: deltaShort)
            modularLarge.row2Column2TextProvider = CLKSimpleTextProvider(text: "")
            
            modularLarge.tintColor = tintColor
            
            // Set the template
            template = modularLarge
        case .UtilitarianSmall:
            let utilitarianSmall = CLKComplicationTemplateUtilitarianSmallFlat()
            utilitarianSmall.textProvider = CLKSimpleTextProvider(text: sgv)
            
            // Set the template
            template = utilitarianSmall
        case .UtilitarianLarge:
            let utilitarianLarge = CLKComplicationTemplateUtilitarianLargeFlat()
            utilitarianLarge.textProvider = CLKSimpleTextProvider(text: utilLargeSting, shortText: utilLargeStingShort)
            
            // Set the template
            template = utilitarianLarge
        case .CircularSmall:
            let circularSmall = CLKComplicationTemplateCircularSmallStackText()
            circularSmall.line1TextProvider = CLKSimpleTextProvider(text: sgv)
            circularSmall.line2TextProvider = CLKSimpleTextProvider(text: delta, shortText: deltaShort)
            
            // Set the template
            template = circularSmall
        }
        
        return template
        
    }
    
}


extension ComplicationController {
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
}