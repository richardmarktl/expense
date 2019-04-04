//
// Created by Richard Marktl on 14.09.18.
// Copyright (c) 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import WebKit
import RxSwift

class RecipientViewController: UITableViewController {
    private var bag = DisposeBag()

    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var signatureNameLabel: UILabel!
    @IBOutlet weak var signedOnLabel: UILabel!
    @IBOutlet weak var signatureView: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    var recipient: Recipient!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = R.string.localizable.recipient()
        toLabel.text = R.string.localizable.to()
        nameLabel.text = R.string.localizable.name()

        signatureNameLabel.text = recipient.signatureName ?? R.string.localizable.noName()
        emailLabel.text = recipient.to ?? ""

        if let date = recipient.signedOn {
            signedOnLabel.text = R.string.localizable.userSignedOn(date.asString())
        }

        loadSignature()?.subscribe(onNext: { [unowned self] (item) in
            self.signatureView.image = item.image
            self.loadingIndicator.stopAnimating()
        }).disposed(by: bag)
    }

    private func loadSignature() -> Observable<ImageStorageItem>? {
        guard let signature = recipient.signature, let localPath = recipient.signatureImagePath else {
            return nil
        }
        
        
        if ImageStorage.hasItemStoredOnFileSystem(filename: localPath) {
            return ImageStorage.loadImage(for: localPath)
        }
        
        loadingIndicator.startAnimating()
        return ImageStorage.download(fromURL: signature, filename: localPath)
    }
}

