//
//  SiteTableViewCell.swift
//  Nightscouter
//
//  Created by Peter Ina on 1/14/16.
//  Copyright © 2016 Nothingonline. All rights reserved.
//

import UIKit
import NightscouterKit

class SiteTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var siteLastReadingHeader: UILabel!
    @IBOutlet private weak var siteLastReadingLabel: UILabel!
    @IBOutlet private weak var siteBatteryHeader: UILabel!
    @IBOutlet private weak var siteBatteryLabel: UILabel!
    @IBOutlet private weak var siteRawHeader: UILabel!
    @IBOutlet private weak var siteRawLabel: UILabel!
    @IBOutlet private weak var siteNameLabel: UILabel!
    @IBOutlet private weak var siteColorBlockView: UIView!
    @IBOutlet private weak var siteUrlLabel: UILabel!
    @IBOutlet private weak var siteCompassControl: CompassControl!
    
    private var dataSource: TableViewRowWithCompassDataSource?
    private var delegate: TableViewRowWithCompassDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.clearColor()
    }
    
    func configure(withDataSource dataSource: TableViewRowWithCompassDataSource, delegate: TableViewRowWithCompassDelegate?) {
        self.dataSource = dataSource
        self.delegate = delegate
        
        siteLastReadingHeader.text = LocalizedString.lastReadingLabel.localized
        siteLastReadingLabel.text = dataSource.lastReadingDate.timeAgoSinceNow()
        siteLastReadingLabel.textColor = delegate?.lastReadingColor
        
        siteBatteryHeader.text = LocalizedString.batteryLabel.localized
        siteBatteryLabel.text = dataSource.batteryLabel
        siteBatteryLabel.textColor = delegate?.batteryColor
        
        siteBatteryHeader.hidden = dataSource.batteryHidden
        siteBatteryLabel.hidden = dataSource.batteryHidden
        
        siteRawHeader.text = LocalizedString.rawLabel.localized
        siteRawLabel.text = dataSource.rawFormatedLabel
        siteRawLabel.textColor = delegate?.rawColor

        siteRawHeader?.hidden = dataSource.rawHidden
        siteRawLabel?.hidden = dataSource.rawHidden

        siteNameLabel.text = dataSource.nameLabel
        siteUrlLabel.text = dataSource.urlLabel
        
        siteColorBlockView.backgroundColor = delegate?.sgvColor
        
        siteCompassControl.configure(withDataSource: dataSource, delegate: delegate)
        
    }
}
