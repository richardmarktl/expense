//
//  InfoSectionActions.swift
//  InVoice
//
//  Created by Georg Kitz on 20/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import StoreKit
import SupportEmail
import Moya
import RxCocoa

class EmailSupportAction: TapActionable {
    
    private var emailSupport: SupportEmail?
    typealias RowActionType = SettingsItem
    
    func performTap(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        emailSupport = SupportEmail()
        emailSupport?.sendAsTextFile = true

        Analytics.settingsSupport.logEvent()
        emailSupport?.send(to: ["info@invoicebot.io"], subject: "InvoiceBot - " + UUID().uuidString.lowercased(), from: ctr, completion: { (state, error) in
            if state == .failed {
                if let error = error {
                    ErrorPresentable.show(error: error)
                } else {
                    ErrorPresentable.show(error: R.string.localizable.noMailApp())
                }
            }
            tableView.deselectRow(at: indexPath, animated: true)
        })
    }
    
    func rewindAction(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
    }
}

class ShareAction: TapActionable {
    
    typealias RowActionType = SettingsItem
    
    func performTap(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
        let message = R.string.localizable.shareAppMessage()
        let activityCtr = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityCtr.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
            activityCtr.popoverPresentationController?.sourceRect = tableView.cellForRow(at: indexPath)?.bounds ?? CGRect.zero
        }
        
        Analytics.settingsShare.logEvent()
        ctr.present(activityCtr, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func rewindAction(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
    }
}

class RateAction: TapActionable {
    typealias RowActionType = SettingsItem
    
    func performTap(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        Analytics.settingsRate.logEvent()
        
        RatingDisplayable.showRatingDialog(openAppStore: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func rewindAction(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
    }
}

class TermsAndPrivacyAction: TapActionable {
    
    typealias RowActionType = SettingsItem
    
    func performTap(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        let pCtr = PrivacyController(nibName: nil, bundle: nil)
        Analytics.settingsTT.logEvent()
        ctr.navigationController?.pushViewController(pCtr, animated: true)
    }
    
    func rewindAction(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
    }
}

class NewsletterAction: TapActionable {
    typealias RowActionType = SettingsItem
    
    private let provider = MoyaProvider<Mailchimp>(plugins: [ApiLogger(), MailchimpAuthPlugin()])
    
    func performTap(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
        
        let alert = UIAlertController(title: R.string.localizable.subscribeToNewsletter(), message: R.string.localizable.pleaseEnterEmailAndHit(), preferredStyle: .alert)
        
        var externalTxt: UITextField?
        alert.addTextField { (txt) in
            txt.placeholder = R.string.localizable.email()
            txt.keyboardType = UIKeyboardType.emailAddress
            externalTxt = txt
        }
        
        let subscribe = UIAlertAction(title: R.string.localizable.subscribe(), style: UIAlertActionStyle.default) { (_) in
            
            if let email = externalTxt?.text {
                _ = self.provider.rx.request(Mailchimp.addMember(email: email)).asObservable().take(1).subscribe(onError: {
                    logger.error($0)
                })
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
        alert.addAction(subscribe)
        
        let cancel = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel) { (_) in
            tableView.deselectRow(at: indexPath, animated: true)
        }
        alert.addAction(cancel)
        Analytics.settingsNewsletter.logEvent()
        ctr.present(alert, animated: true)
    }
    
    func rewindAction(with rowItem: SettingsItem, indexPath: IndexPath, tableView: UITableView, ctr: UIViewController, model: TableModel) {
    }
}
