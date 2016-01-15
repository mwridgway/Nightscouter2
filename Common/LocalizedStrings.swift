//
//  LocalizedStrings.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/15/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import Foundation

public enum LocalizedString: String {
    case tableViewCellRemove,
    tableViewCellLoading,
    lastUpdatedDateLabel,
    generalEditLabel,
    generalCancelLabel,
    generalRetryLabel,
    generalYesLabel,
    generalNoLabel,
    uiAlertBadSiteMessage,
    uiAlertBadSiteTitle,
    uiAlertScreenOverrideTitle,
    uiAlertScreenOverrideMessage,
    sgvLowString,
    directionRateOutOfRange,
    directionNotComputable,
    directionNone,
    directionDoubleUp,
    directionSingleUp,
    directionFortyFiveUp,
    directionFlat,
    directionFortyFiveDown,
    directionSingleDown,
    directionDoubleDown
}

extension LocalizedString {
    public var localized: String {
        return self.rawValue.localized
    }
}