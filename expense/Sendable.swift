//
//  Sendable.swift
//  InVoice
//
//  Created by Georg Kitz on 07/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import MessageUI
import Crashlytics

private class EmailSender: NSObject, MFMailComposeViewControllerDelegate {
    private var completion: ((Bool) -> Void)?

    /// The method showEmailComposer will show the apple standard mail controller.
    ///
    /// - Parameters:
    ///   - data: the pdf as data object
    ///   - job: a job
    ///   - ctr: a view controller to present the mail controller
    ///   - completion: a completion block called if the mail was sent.
    func showEmailComposer(with data: Data, for job: Job, presentIn ctr: UIViewController, completion: @escaping ((Bool) -> Void)) {
        guard let companyName = Account.current().name, companyName.count != 0 else {
            ErrorPresentable.show(error: R.string.localizable.noCompanyName())
            return
        }

        guard MFMailComposeViewController.canSendMail() == true else {
            ErrorPresentable.show(error: R.string.localizable.noMailApp())
            return
        }

        self.completion = completion

        let composer = MFMailComposeViewController()

        composer.mailComposeDelegate = self

        if let email = job.client?.email {
            composer.setToRecipients([email])
        }

        let subject: String
        let filename: String
        if job is Offer {
            subject = R.string.localizable.offerFrom(job.number!, companyName)
            filename = R.string.localizable.offer() + "_" + job.number!
        } else {
            subject = R.string.localizable.invoiceFrom(job.number!, companyName)
            filename = R.string.localizable.invoice() + "_" + job.number!
        }

        composer.setSubject(subject)
        composer.addAttachmentData(data, mimeType: "application/pdf", fileName: filename)

        ctr.present(composer, animated: true)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        if let completion = completion {
            completion(result == MFMailComposeResult.sent)
        }
    }
}

protocol Sendable: Resetable {
    func presentSendPicker(for job: Job, with pdf: RenderedPDF, from sender: UIView, completion: @escaping (() -> Void))
    func presentShareSheet(for job: Job, with pdf: RenderedPDF, from sender: UIView)
}

extension Sendable where Self: UIViewController {
    
    /// This method will present the invoicebot mail controller (if pro) or the standard mail controller. Depending
    /// on the circumstances it may also shows an upsell controller.
    ///
    /// - Parameters:
    ///   - model: the job model
    ///   - sender: the sender view
    ///   - completion: the completion block
    func presentSendPicker(for job: Job, with pdf: RenderedPDF, from sender: UIView, completion: @escaping (() -> Void)) {
        let block = { [unowned self] in
            self.presentSendPicker(for: job, with: pdf, from: sender, completion: completion)
        }
        
        guard checkAccountName(retryBlock: block) else {
            Analytics.noCompanyDetailsYet.logEvent(["where": "email".asNSString])
            return
        }
        
        // Now that we changed the present mode and get the model we also generate the pdf here.
        // because now is it one place.
        
        self.showInvoiceMailComposer(for: job, with: pdf, completion: completion)
    }

    /// This method will present a share sheet by using the apple activity controller.
    ///
    /// - Parameters:
    ///   - model: the job model
    ///   - sender: the sender view
    func presentShareSheet(for job: Job, with pdf: RenderedPDF, from sender: UIView) {
        _ = self.shouldReset(showDialog: job.willResetSignature).filterTrue().subscribe(onNext: { (_) in
            do {
                let name = job.shareableName
                let path = (try FileManagerHelper.copyFile(at: pdf.path.path, to: .shared, in: .cachesDirectory, with: name))
                self.showShareSheet(with: path.asFileUrl, for: job, from: sender)
            } catch {
                Crashlytics.sharedInstance().recordError(error)
            }
        })
    }
    
    /// The method show share sheet will show the share activity controller provided by apple.
    ///
    /// - Parameters:
    ///   - path: The path of the file
    ///   - job: the job
    ///   - sender: the presenting view
    private func showShareSheet(with path: URL, for job: Job, from sender: UIView) {
        let block = {[unowned self] in self.showShareSheet(with: path, for: job, from: sender)}
        
        guard checkAccountName(retryBlock: block) else {
            Analytics.noCompanyDetailsYet.logEvent(["where": "sharesheet".asNSString])
            return
        }
        
        let activityCtr = UIActivityViewController(activityItems: [path], applicationActivities: nil)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityCtr.popoverPresentationController?.sourceView = sender
            activityCtr.popoverPresentationController?.sourceRect = sender.bounds
        }
        
        activityCtr.completionWithItemsHandler = { (activityType, completed, returnedItems, activityError) in
            if completed {
                Analytics.actionShareSheet.logEvent(with: activityType)
                job.markAsSend()
            } else {
                Analytics.actionShareSheetIncomplete.logEvent()
            }
        }
        present(activityCtr, animated: true)
    }

    private func showInvoiceMailComposer(for job: Job, with pdf: RenderedPDF, completion: @escaping (() -> Void)) {
        guard let ctr = R.storyboard.email.mailComposerViewController() else {
            return
        }

        ctr.job = job
        ctr.pdf = pdf
        navigationController?.pushViewController(ctr, animated: true)
    }
    
    /// The method checkAccountName will open the account controller with a prompt to inform
    /// the user about the fact that a name is needed for the email generation. After that
    /// the retryBlock is called.
    ///
    /// - Parameter block: the bock to call after the account controller finished successful.
    /// - Returns: True if the account name is set otherwise false
    private func checkAccountName(retryBlock: @escaping (() -> Void)) -> Bool {
        let account = Account.current()
        if let companyName = account.name, companyName.count != 0 {
            return true
        }
        
        let dismissActionBlock: ((UIViewController) -> Void) = { (ctr) in
            var dismissBlock: (() -> Void)? = retryBlock
            if let ctr = ctr as? AccountViewController, ctr.wasCancelled {
                dismissBlock = nil
            }
            ctr.dismiss(animated: true, completion: dismissBlock)
        }
        let nCtr = AccountViewController.show(item: account)
        nCtr.childViewControllers[0].navigationItem.prompt = R.string.localizable.noCompanyNameMessage()
        if let accountCtr = nCtr.childViewControllers[0] as? AccountViewController {
            accountCtr.dismissActionBlock = dismissActionBlock
        }
        
        present(nCtr, animated: true)
        return false
    }
}
