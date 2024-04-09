//
//  UserSelectionViewController.swift
//  ParentalControl
//
//  Created by Punit Thakali on 09/04/2024.
//

import UIKit

class UserSelectionViewController: UIViewController {
    
    
    @IBOutlet weak var parentView: UserParentSelectionView!
    @IBOutlet weak var childView: UserChildSelectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "User Views"
    }

}
