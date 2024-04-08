//
//  DashboardStatsView.swift
//  ParentalControlSoftware
//
//  Created by Punit Thakali on 01/04/2024.
//

import UIKit

class ParentDashboardStatsView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let bundle = Bundle(for: type(of: self))
        let name = String(describing: type(of: self))
        bundle.loadNibNamed(name, owner: self, options: nil)
        self.addSubview(self.contentView)
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    
    @IBOutlet weak var childNameLabel: UILabel!
    @IBOutlet weak var screenTimeLabel: UILabel!
    @IBOutlet weak var noOfAlertsLabel: UILabel!
    @IBOutlet weak var noOfDevicesLabel: UILabel!
    
    
    
}
