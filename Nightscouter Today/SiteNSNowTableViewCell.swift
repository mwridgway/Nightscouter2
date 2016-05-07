//
//  SiteTableViewswift
//  Nightscouter
//
//  Created by Peter Ina on 6/16/15.
//  Copyright © 2015 Peter Ina. All rights reserved.
//

import UIKit
import NightscouterKit

class SiteNSNowTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var siteLastReadingHeader: UILabel!
    @IBOutlet weak private var siteLastReadingLabel: UILabel!
    
    @IBOutlet weak private var siteBatteryHeader: UILabel!
    @IBOutlet weak private var siteBatteryLabel: UILabel!
    
    @IBOutlet weak private var siteRawHeader: UILabel!
    @IBOutlet weak private var siteRawLabel: UILabel!
    
    @IBOutlet weak private var siteNameLabel: UILabel!
    
    @IBOutlet weak private var siteColorBlockView: UIView!
    @IBOutlet weak private var siteSgvLabel: UILabel!
    @IBOutlet weak private var siteDirectionLabel: UILabel!
    
    private var dataSource: TableViewRowWithOutCompassDataSource?
    private var delegate: TableViewRowWithOutCompassDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.clearColor()
    }
    
    func configure(withDataSource dataSource: TableViewRowWithOutCompassDataSource, delegate: TableViewRowWithOutCompassDelegate?) {
        self.dataSource = dataSource
        self.delegate = delegate
        
        siteLastReadingHeader.text = LocalizedString.lastReadingLabel.localized
        siteLastReadingLabel.text = dataSource.lastReadingDate.timeAgoSinceNow()
        siteLastReadingLabel.textColor = delegate?.lastReadingColor
        
        siteBatteryHeader.hidden = dataSource.batteryHidden
        siteBatteryHeader.text = LocalizedString.batteryLabel.localized
        siteBatteryLabel.hidden = dataSource.batteryHidden
        siteBatteryLabel.text = dataSource.batteryLabel
        siteBatteryLabel.textColor = delegate?.batteryColor
        
        siteRawHeader.text = LocalizedString.rawLabel.localized
        siteRawHeader?.hidden = dataSource.rawHidden
        
        siteRawLabel?.hidden = dataSource.rawHidden
        siteRawLabel.text = dataSource.rawFormatedLabel
        siteRawLabel.textColor = delegate?.batteryColor
                
        siteNameLabel.text = dataSource.nameLabel
        siteColorBlockView.backgroundColor = delegate?.sgvColor
        
        let sgvString = dataSource.sgvLabel + " " + dataSource.direction.emojiForDirection

        siteSgvLabel.text = sgvString
        siteSgvLabel.textColor = delegate?.sgvColor
        
        siteDirectionLabel.text = dataSource.deltaLabel
        siteDirectionLabel.textColor = delegate?.sgvColor
    }
}
