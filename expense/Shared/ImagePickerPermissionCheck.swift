//
// Created by Georg Kitz on 2019-04-25.
// Copyright (c) 2019 meisterwork GmbH. All rights reserved.
//


import Foundation
import RxSwift
import UIKit
import Photos
import AVFoundation

class ImagePickerPermissionCheck {

    private let rootController: UIViewController

    init(controller: UIViewController) {
        rootController = controller
    }

    func checkPermission(for type: UIImagePickerController.SourceType, showErrorAlert: Bool = true) -> Observable<Bool> {
        return canAccess(type: type).do(onError: { [weak self](error) in
            if let message = error as? String {
                self?.showSettingsAlert(with: message)
            }
        })
    }

    private func canAccess(type: UIImagePickerController.SourceType) -> Observable<Bool> {
        if type == .camera {

            let state = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if state == .notDetermined {
                let subject: PublishSubject<Bool> = PublishSubject()
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (allowed) in
                    DispatchQueue.main.async {
                        if allowed {
                            subject.onNext(allowed)
                        } else {
                            subject.onError(NSLocalizedString("CameraCannotBeAccessed", comment: ""))
                        }
                    }
                })
                return subject
            } else if state == .authorized {
                return Observable.just(true)
            } else {
                return Observable.error(NSLocalizedString("CameraCannotBeAccessed", comment: ""))
            }
        } else if type == .photoLibrary {

            let subject: PublishSubject<Bool> = PublishSubject()
            PHPhotoLibrary.requestAuthorization({ (status) in

                DispatchQueue.main.async {

                    switch status {
                    case .authorized:
                        subject.onNext(true)
                    default:
                        subject.onNext(false)
                    }
                }
            })

            return subject.asObservable()
        }

        return Observable.just(false)
    }

    private func showSettingsAlert(with message: String) {

        let alert = UIAlertController(title: NSLocalizedString("Information", comment: ""), message: message, preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment:
        ""), style: .default) { _ -> Void in
            alert.dismiss(animated: true, completion: nil)
            UIApplication.shared.open(
                    URL(string: UIApplication.openSettingsURLString)!,
                    options: [:],
                    completionHandler: nil
            )
        }

        let cancel = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .cancel) { _ -> Void in
            alert.dismiss(animated: true, completion: nil)
        }

        alert.addAction(settingsAction)
        alert.addAction(cancel)

        rootController.present(alert, animated: true, completion: nil)
    }
}
