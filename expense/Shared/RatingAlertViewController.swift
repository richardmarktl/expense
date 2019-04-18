//
//  RatingAlertViewController.swift
//  InVoice
//
//  Created by Georg Kitz on 17.09.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import StoreKit
import SupportEmail
import MessageUI
import CommonUI

// protocol
struct RatingDisplayable {
    private static var emailSupport: SupportEmail? = nil
    static func showRatingDialog(openAppStore: Bool = false) {
        
        guard let topCtr = UIApplication.shared.topMostViewController() else {
            return
        }
        
        let alert = UIAlertController(title: R.string.localizable.ratingHelpDoYouLike(), message: R.string.localizable.ratingHelpUs(), preferredStyle: .alert)
        let loveItAction = UIAlertAction(title: R.string.localizable.ratingHelpILoveIt(), style: .default) { (_) in
            
            RatingService.instance.save(ratingResult: .happy)
            // Analytics.ratingHappy.logEvent()
            
            if openAppStore {
                openInAppStore()
            } else {
                SKStoreReviewController.requestReview()
            }
        }
        let feedbackAction = UIAlertAction(title: R.string.localizable.ratingHelpCouldBeBetter(), style: .cancel) { (_) in
            RatingService.instance.save(ratingResult: .unhappy)
            // Analytics.ratingUnhappy.logEvent()
            
            emailSupport = SupportEmail()
            emailSupport?.sendAsTextFile = true

            emailSupport?.send(to: ["info@invoicebot.io"], subject: "InvoiceBot - " + UUID().uuidString.lowercased(), from: topCtr, completion: { (state, error) in
                if state == .failed {
                    // Analytics.ratingFeedbackFailed.logEvent()
                    if let error = error {
                        ErrorPresentable.show(error: error)
                    } else {
                        ErrorPresentable.show(error: R.string.localizable.noMailApp())
                    }
                } else if state == .cancelled {
                    // Analytics.ratingFeedbackCancelled.logEvent()
                } else if state == .sent {
                    // Analytics.ratingFeedbackSuccess.logEvent()
                }
            })
        }
        alert.addAction(loveItAction)
        alert.addAction(feedbackAction)
        
        topCtr.present(alert, animated: true, completion: nil)
    }
    
    private static func openInAppStore() {
        guard let url = URL(string: "itms://itunes.apple.com/app/id1311274386?action=write-review") else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
