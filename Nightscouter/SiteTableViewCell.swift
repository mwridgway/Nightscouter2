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
//    var site: Site? {
//        didSet{
//            self.client?.fetchConfigurationData().startWithNext { site in
//                if let site = site {
//                    SitesDataSource.sharedInstance.updateSite(site)
//                }
//            }
//            
//            self.client?.fetchSocketData().observeNext { site in
//                SitesDataSource.sharedInstance.updateSite(site)
//                
//                let model = site.generateSummaryModelViewModel()
//                self.configure(withDataSource: model, delegate: model)
//            }
//            
//
//        }
//    }
//    lazy var client: NightscoutSocketIOClient? = self.initalizeClient()
//    
//    func initalizeClient() -> NightscoutSocketIOClient? {
//        
//        if let site = site {
//            return NightscoutSocketIOClient(site: site)
//        }
//        return nil
//    }
//    
    
    func configure(withDataSource dataSource: TableViewRowWithCompassDataSource, delegate: TableViewRowWithCompassDelegate?) {
        self.dataSource = dataSource
        self.delegate = delegate
        
        siteLastReadingLabel.text = dataSource.lastReadingDate.timeAgoSinceNow()
        siteLastReadingLabel.textColor = delegate?.lastReadingColor
        
        siteBatteryLabel.text = dataSource.batteryLabel
        siteBatteryLabel.textColor = delegate?.batteryColor
        
        siteRawLabel?.hidden = dataSource.rawHidden
        siteRawHeader?.hidden = dataSource.rawHidden
        
        siteRawLabel.text = dataSource.rawFormatedLabel
        siteRawLabel.textColor = delegate?.rawColor
        
        
        siteNameLabel.text = dataSource.nameLabel
        siteUrlLabel.text = dataSource.urlLabel
        
        siteColorBlockView.backgroundColor = delegate?.sgvColor
        
        siteCompassControl.configure(withDataSource: dataSource, delegate: delegate)
        
    }
}
