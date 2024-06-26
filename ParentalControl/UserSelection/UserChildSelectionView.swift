//
//  UserChildSelectionView.swift
//  ParentalControl
//
//  Created by Punit Thakali on 09/04/2024.
//

import UIKit

class UserChildSelectionView: UIView {
    
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
        self.contentView.addTapGesture(tapNumber: 1, target: self, action: #selector(viewDashboard))
    }

    @IBOutlet weak var childLabel: UILabel!
    @IBOutlet weak var childImageView: UIImageView!
    
    @objc func viewDashboard(_ sender: UIButton) {
        let vc = ChildDashboardViewController()
        vc.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
