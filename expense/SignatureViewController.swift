//
//  SignatureViewController.swift
//  InVoice
//
//  Created by Richard Marktl on 29.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import SwiftSignatureView

class SignatureViewController: UIViewController, UITextFieldDelegate, SwiftSignatureViewDelegate {
    private var bag = DisposeBag()
    public static let defaultSignatureFileName = "userSignature"
    private var isSigned: Bool = false
    
    private let cancelSubject = PublishSubject<Bool>()  // true if cancelled by the user, false if an error.
    public var cancelObservable: Observable<Bool> {
        return cancelSubject.asObservable()
    }
    
    private let signatureSubject = PublishSubject<UIImage>()
    public var signatureObservable: Observable<UIImage> {
        return signatureSubject.asObservable()
    }
    
    // the switch is currently not in use, but will be if we add customer signatures
    public var showSaveAsDefaulfSwitch: Bool = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var signatureView: SwiftSignatureView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveAsDefaulfSwitch: UISwitch!
    @IBOutlet weak var saveAsDefaultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. try to load the old signature
        // 2. if visible show signature
        // 3. add a class method to load the signature and it to the invoice or job before this controller is created
        //    ImageStorage is your friend.
        // 4. add a settings controller class
        signatureView.backgroundColor = .clear
        scrollView.isScrollEnabled = false
        nameTextField.delegate = self
        navigationItem.rightBarButtonItem?.isEnabled = false

        let font = FiraSans.medium.font(16)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font: font], for: .disabled)
        
        // try to load the old signature and then try set it.
        signatureView.delegate = self
        saveAsDefaulfSwitch.isHidden = showSaveAsDefaulfSwitch == false
        saveAsDefaultLabel.isHidden = saveAsDefaulfSwitch.isHidden
        
        if SignatureViewController.hasSignatureImage() {
            nameTextField.text = Account.current().signatureName
        }
        
        nameTextField.rx.text.skip(1).subscribe(onNext: { [unowned self](value: String?) in
            self.updateNavigationButton()
        }).disposed(by: bag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let unregisterSignal = rx.viewWillDisappear.mapToVoid()
        let notificationCenter = NotificationCenter.default
        _ = notificationCenter.rx.notification(NSNotification.Name.UIKeyboardWillShow, object: nil).takeUntil(unregisterSignal).subscribe(onNext: { [unowned self](notification) in
            guard let responder = self.scrollView.firstResponder(),
                let userInfo = (notification as NSNotification).userInfo,
                let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
                let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
                return
            }
                
            var contentInset = self.scrollView.contentInset
            contentInset.bottom = keyboardFrame.height
            self.scrollView.contentInset = contentInset
            self.signatureView.isUserInteractionEnabled = false
            
            let responderFrame = responder.convert(responder.bounds, to: self.scrollView) 
            let scrollViewRect = self.scrollView.frame
            let visibleRect = CGRect(
                x: 0,
                y: self.scrollView.contentOffset.y,
                width: scrollViewRect.width,
                height: scrollViewRect.height - keyboardFrame.height // add the missing height
            )
                
            if !visibleRect.contains(responderFrame) {
                UIView.animate(withDuration: animationDuration, animations: { [weak self] in
                    self?.scrollView.scrollRectToVisible(responderFrame, animated: false)
                });
            }
        });
        
        _ = notificationCenter.rx.notification(NSNotification.Name.UIKeyboardWillHide, object: nil).takeUntil(unregisterSignal).subscribe(onNext: { [unowned self](notification) in
            self.scrollView.setContentOffset(CGPoint.zero, animated: true)
            self.signatureView.isUserInteractionEnabled = true
        })
    }
    
    // MARK: SwiftSignature Delegate
    
    func swiftSignatureViewDidTapInside(_ view: SwiftSignatureView) {
        isSigned = true
        updateNavigationButton()
    }
    
    func swiftSignatureViewDidPanInside(_ view: SwiftSignatureView) {
        isSigned = true
        updateNavigationButton()
    }
    
    // MARK: Textfield delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Update Save Button
    
    /// This method will update the save navigation bar button
    func updateNavigationButton() {
        navigationItem.rightBarButtonItem?.isEnabled = isSigned && (nameTextField.text?.isEmpty == false)
    }
    
    // MARK: Action Methods
    /// The save method will save the signature path and the image.
    @IBAction func save() -> Void {
        if let image = signatureView.signature?.imageByCroppingTransparentPixels() {
            let name = SignatureViewController.defaultSignatureFileName
            _ = ImageStorage.storeImage(originalImage: image, filename: name).take(1).subscribe(onNext: { [unowned self] (storageItem) in
                let account = Account.current()
                account.signatureName = self.nameTextField.text
                try? account.managedObjectContext?.save()
                
                // return the image
                self.signatureSubject.onNext(storageItem.image)
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    @IBAction func cancel() -> Void {
        cancelSubject.onNext(true)
        navigationController?.popViewController(animated: true)
    }
    
    /// This method will clear the signature view.
    @IBAction func reload() -> Void {
        signatureView.clear()
    }
    
    // MARK: Image helper
    // MARK: SignatureViewController class methods to load and store the signature
    
    /// This static method checks if a default user signature is available.
    ///
    /// - Returns: Bool true if the user stored and image.
    static func hasSignatureImage() -> Bool {
        return ImageStorage.hasItemStoredOnFileSystem(filename: defaultSignatureFileName)
    }
    
    /// This static method tries to load the image and will return it if not available.
    ///
    /// - Returns: an Observable deliviering an image.
    static func signatureImage() -> Observable<UIImage> {
        return ImageStorage.loadImage(for: defaultSignatureFileName).map({ (item) -> UIImage in
            return item.image;
        });
    }
    
    /// The static method removeSignature will remove the signature from the app and also sets the
    /// signature name back to nil.
    static func removeSignature() -> Void {
        ImageStorage.deleteImage(for: defaultSignatureFileName)
        let account = Account.current()
        account.signatureName = nil
        try? account.managedObjectContext?.save()
    }
}

