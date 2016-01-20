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
        
        siteLastReadingLabel.text = dataSource.lastReadingDate.timeAgoSinceNow()
        siteLastReadingLabel.textColor = delegate?.lastReadingColor
        
        siteBatteryLabel.text = dataSource.batteryLabel
        siteBatteryLabel.textColor = delegate?.batteryColor
        
        siteRawLabel?.hidden = dataSource.rawHidden
        siteRawHeader?.hidden = dataSource.rawHidden
        
        siteRawLabel.text = dataSource.rawLabel
        siteRawLabel.textColor = delegate?.batteryColor
                
        siteNameLabel.text = dataSource.nameLabel
        siteColorBlockView.backgroundColor = delegate?.sgvColor
    }
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        
//        siteNameLabel.text = nil
//        siteBatteryLabel.text = nil
//        siteRawLabel.text = nil
//        siteLastReadingLabel.text = nil
//        siteColorBlockView.backgroundColor = colorForDesiredColorState(DesiredColorState.Neutral)
//        
//        siteSgvLabel.text = nil
//        siteSgvLabel.textColor = Theme.Color.labelTextColor
//        
//        siteDirectionLabel.text = nil
//        siteDirectionLabel.textColor = Theme.Color.labelTextColor
//        
//        siteLastReadingLabel.text = Constants.LocalizedString.tableViewCellLoading.localized
//        siteLastReadingLabel.textColor = Theme.Color.labelTextColor
//        
//        siteRawHeader.hidden = false
//        siteRawLabel.hidden = false
//        siteRawLabel.textColor = Theme.Color.labelTextColor
//    }
}
