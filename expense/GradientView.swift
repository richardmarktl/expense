//
//  GradientView.swift
//  InVoice
//
//  Created by Georg Kitz on 25.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import CoreGraphics

@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var startColor: UIColor = .black {
        didSet {
            updateLayer()
        }
    }
    
    @IBInspectable var endColor: UIColor = .white {
        didSet {
            updateLayer()
        }
    }
    
    @IBInspectable var xStart: CGFloat = 0.5 {
        didSet {
            updateLayer()
        }
    }
    
    @IBInspectable var yStart: CGFloat = 0.0 {
        didSet {
            updateLayer()
        }
    }
    
    @IBInspectable var xEnd: CGFloat =  0.5 {
        didSet {
            updateLayer()
        }
    }
    
    @IBInspectable var yEnd: CGFloat =  1.0 {
        didSet {
            updateLayer()
        }
    }
    
    override final class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    private func updateLayer() {
        guard let layer = self.layer as? CAGradientLayer else {
            return
        }
        layer.startPoint = CGPoint(x: xStart, y: yStart)
        layer.endPoint = CGPoint(x: xEnd, y: yEnd)
        layer.colors = [startColor.cgColor, endColor.cgColor]
    }
}
