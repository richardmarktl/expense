//
//  Styling.swift
//  InVoice
//
//  Created by Georg Kitz on 16.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import SwiftRichString

extension StyleGroup {
    
    class func regularMediumMix(fontSize: CGFloat, textColor: UIColor, alignment: NSTextAlignment = .center) -> StyleGroup {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        
        let normalStyle = Style {
            $0.font = FiraSans.regular.font(fontSize)
            $0.color = textColor
            $0.paragraph = paragraph
        }
        
        let mediumStyle = Style {
            $0.font = FiraSans.medium.font(fontSize)
        }
        
        return StyleGroup(base: normalStyle, ["m": mediumStyle])
    }
    
    class func greetingStyleGroup() -> StyleGroup {
       return regularMediumMix(fontSize: 44, textColor: .white)
    }
    
    class func expireStyleGroup(with color: UIColor = .blackish) -> StyleGroup {
       return regularMediumMix(fontSize: 15, textColor: color)
    }
    
    class func headerFooterStyleGroup() -> StyleGroup {
        return regularMediumMix(fontSize: 13, textColor: UIColor(red: 0.42, green: 0.42, blue: 0.44, alpha: 1.0), alignment: .left)
    }
}
