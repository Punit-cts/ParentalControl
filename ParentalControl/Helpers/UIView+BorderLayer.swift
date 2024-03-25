//
//  UIView+BorderLayer.swift
//

import UIKit

extension UIView {
    public func set(border: UIColor) {
        self.layer.borderColor = border.cgColor;
    }
    
    public func set(borderWidth: CGFloat) {
        self.layer.borderWidth = borderWidth
    }
    
    public func set(borderWidth width: CGFloat, of color: UIColor) {
        self.set(border: color)
        self.set(borderWidth: width)
    }
}
