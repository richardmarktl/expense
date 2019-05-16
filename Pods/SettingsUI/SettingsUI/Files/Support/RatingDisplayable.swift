//
//  RatingDisplayable.swift
//  Settings
//
// Created by Richard Marktl on 2019-05-09.
// Copyright (c) 2019 meisterwork. All rights reserved.
//

import UIKit
import StoreKit
import SupportEmail
import MessageUI
import CommonUtil
import CommonUI


struct RatingDisplayable {
    private static var emailSupport: SupportEmail? = nil

    static func showRatingDialog(openAppStore: Bool = false) {

        guard let topCtr = UIApplication.shared.topMostViewController() else {
            return
        }

        let alert = UIAlertController(
                title: PodLocalizedString("ratingHelpDoYouLike", comment: ""), 
                message: PodLocalizedString("ratingHelpUs", comment: ""), 
                preferredStyle: .alert
        )
        let loveItAction = UIAlertAction(title: PodLocalizedString("ratingHelpILoveIt", comment: ""), style: .default) { (_) in

            RatingService.instance.save(ratingResult: .happy)
            // Analytics.ratingHappy.logEvent()

            if openAppStore {
                openInAppStore()
            } else {
                SKStoreReviewController.requestReview()
            }
        }
        let feedbackAction = UIAlertAction(title: PodLocalizedString("ratingHelpCouldBeBetter", comment: ""), style: .cancel) { (_) in
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
                        ErrorPresentable.show(error: PodLocalizedString("noMailApp", comment: ""))
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
