//
//  EmailReceiptPermissionController.swift
//  InVoice
//
//  Created by Georg Kitz on 02/02/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import Horreum
import RxSwift
import FirebaseMessaging

class EmailReceiptPermissionController: UIViewController {
    @IBOutlet weak var permissionButton: ActionButton!
    @IBOutlet weak var permissionView: UIView!
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var stateBagedView: BadgeView!
    
    private let model = RegisterNotificationModel()
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = R.string.localizable.emailReadReceipts()
        explanationLabel.text = R.string.localizable.pushNotificationExplanationText()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        
        let currentStateObs = Observable.just(model.pushNotificationsRegistered)
        let registerObs = permissionButton.tapObservable.do(onNext: { [unowned self] in
            return self.permissionButton.button?.isEnabled = false
        }).flatMap { [unowned self]_ -> Observable<APNState> in
            if self.model.pushNotificationsRegistered == APNState.denied {
                Analytics.readReceiptShowSettings.logEvent()
                return self.model.showSettings()
            }
            Analytics.readReceiptAskForAllowance.logEvent()
            return self.model.registerForRemoteNotifications()
        }.do(onNext: { [unowned self](state) in
            
            if state == APNState.denied {
                Analytics.readReceiptNotAllowed.logEvent()
            } else {
                Analytics.readReceiptAllowed.logEvent()
            }
            self.permissionButton.button?.isEnabled = true
        })
        
        Observable.of(currentStateObs, registerObs).merge().debug().subscribe(onNext: { [unowned self] (state) in
            
            if state == APNState.denied {
                self.permissionButton.title = R.string.localizable.allowInSettings()
            } else {
                self.permissionButton.title = R.string.localizable.allow()
            }
            
            self.permissionButton.isHidden = state == APNState.accepted
            self.permissionView.isHidden = state != APNState.accepted
            
            if let token = Messaging.messaging().fcmToken, state == APNState.accepted {
                _ = DeviceRequest.upload(token: token, context: Horreum.instance!.mainContext).subscribe()
            }
            
        }).disposed(by: bag)
        
        sequentiallyUpdateSentState()
    }
    
    private func sequentiallyUpdateSentState() {

        let states = [JobState.notSend, JobState.sent, JobState.opened, JobState.downloaded]
        Observable<Int>.timer(0, period: 2, scheduler: MainScheduler.instance).subscribe(onNext: { [weak self](value: Int) in
            
            let idx = value % states.count
            let currentState = states[idx]

            self?.stateBagedView.title = currentState.title
            self?.stateBagedView.badgeColor = currentState.color

        }).disposed(by: bag)
    }
}
