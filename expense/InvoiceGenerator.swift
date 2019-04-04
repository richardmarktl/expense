//
//  InvoiceGenerator
//  InVoice
//
//  Created by Georg Kitz on 05/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import Foundation
import CoreData
import RxSwift
import WebKit
import Stencil

fileprivate func logVerbose(_ log: String) {
    #if DEBUG
    logger.verbose(log)
    #endif
}

private extension String {
    /// This method is used to generate a human readable string. This string is used to debug the html.
    func humanReadableHTMLString() -> NSAttributedString? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.plain,
            NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
        ]
            
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString
        }
        
        return nil
    }
}

class RenderWebViewDelegateWrapper: NSObject, WKNavigationDelegate {
    private let navigationFinishedSubject: ReplaySubject<Void> = ReplaySubject.create(bufferSize: 1)
    public var navigationObservable: Observable<Void> {
        return navigationFinishedSubject.asObservable()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        logVerbose("[Renderer] loading finished")
        navigationFinishedSubject.onNext(())
    }
    
    deinit {
        logVerbose("[Renderer] deinit delegate")
    }
}

/// Background *Fast* Invoice Generator
class PerformanceInvoiceGenerator: NSObject {
    
    private var bag = DisposeBag()
    private let filename: String
    private let pdfSubject: RxSwift.Variable<RenderedPDF?> = Variable(nil)
    public var pdfObservable: Observable<RenderedPDF> {
        return pdfSubject.asObservable().filterNil()
    }
    
    /// webview to render the html which gets transformed to pdf
    private lazy var renderWebViewHelper: WKWebView = {
        let contentController = WKUserContentController()
        let configuration = WKWebViewConfiguration()

        configuration.applicationNameForUserAgent = "InvoiceBot"
        configuration.userContentController = contentController

        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false

        return webView
    } ()
    //swiftlint:disable function_body_length
    init?(job: Job, template: String, color: String = UIColor.main.hexString, observeChangesIn context: NSManagedObjectContext) {
        
        let environment = Environment(loader: FileSystemLoader(bundle: [Bundle.main]))
        self.filename = (job.uuid ?? job.localizedType) + ".pdf"
        
        super.init()
        
        // To improve, let's check if the file is already stored on disk, when we create this thing, if that's true, we can skip the first generation and
        // just wait for a real change
        
        // Thus block basically listens to changes in the current context for invoice, client and order, combines them
        // and checks if the prev. generated pdf data is different from the newly one, if that's the case
        // we start a rerendering of the pdf
        let background = ConcurrentDispatchQueueScheduler(qos: .background)
        let jObs: Observable<Void>
        if job is Invoice {
            jObs = Invoice.rxMonitorChanges(context).observeOn(background).mapToVoid().startWith(())
        } else {
            jObs = Offer.rxMonitorChanges(context).observeOn(background).mapToVoid().startWith(())
        }
        
        let oObs = Order.rxMonitorChanges(context).observeOn(background).mapToVoid().startWith(())
        let easyObs = Observable.of(jObs, oObs).merge()
        .flatMap { () -> Observable<[String : Any]> in
            var values = job.pdfData()
            if job.hasSignature {  // in the case we have a signature load it.
                return job.loadUserSignature().map {(item) -> [String: Any] in
                    logVerbose("[Renderer] User signature loaded")
                    values["hasUserSignature"] = job.hasSignature
                    values["signature"] = ImageStorage.base64String(for: item.image, type: .png) as Any
                    return values
                }.catchError { (error) -> Observable<[String : Any]> in
                    logVerbose("[Renderer] User signature failed to load: \(error)")
                    return Observable.just(values)
                }
            }
            return Observable.just(values)
        }
        .distinctUntilChanged { (old, new) -> Bool in
            let equal = old.description.sorted() == new.description.sorted()
            if !equal {
                logVerbose("[Renderer] Updating Invoice")
            }
            logVerbose("[Renderer] Not updating invoice")
            return equal
        }
        .do(onNext: { [unowned self](_) in
            logVerbose("[Renderer] Cleanup current pdf data")
            self.pdfSubject.value = nil
        })
        
        // Observable for account
        let accountObs = Account.rxMonitorChanges(context).observeOn(background).mapToVoid().startWith(()).map { _ -> [String: Any] in
            let company = Account.current(context: context)
            
            var values: [String: Any] = [:]
            
            if let logoFilename = company.logoFileName, let image = ImageStorage.loadAlreadyLoadedItem(for: logoFilename) {
                values["logo"] = ImageStorage.base64String(for: image.image, type: .png)
            }
            values["companyName"] = company.name as Any
            values["companyTaxId"] = company.taxId as Any
            values["companyWeb"] = company.website as Any
            values["companyEmail"] = company.email as Any
            values["companyTaxId"] = company.taxId as Any
            values["companyPhone"] = company.phone as Any
            values["companyAddress"] = company.address as Any
            
            logVerbose("[Renderer] account rendering")
            
            return values
        }
        
        let designObs = JobDesign.rxMonitorChanges(context).observeOn(background).mapToVoid().startWith(()).map { _ -> [String: Any] in
            let design = JobDesign.current(in: context)
            
            var values: [String: Any] = [:]
            values["attachmentImageCss"] = design.attachmentFullWidth ? "attachment-centered" : "attachment-left"
            values["attachmentContainerCss"] = design.attachmentFullWidth ? "attachmentcontainer-centered" : ""
            values["attachmentTitleCss"] = design.attachmentFullWidth ? "attachment-title-centered" : "attachment-title-left"
            values["attachmentTitleHiddenCss"] = design.attachmentHideTitle ? "attachment-title-hidden" : ""
            values["pageSize"] = design.pageSize ?? JobPageSize.A4.rawValue
            values["showArticleNumber"] = design.showArticleNumber
            values["showArticleTitle"] = design.showArticleTitle
            values["showArticleDescription"] = design.showArticleDescription
            
            logVerbose("[Renderer] design rendering")
            
            return values
        }
        
        // Observable for attachments
        let aObs = Attachment.rxMonitorChanges(context).observeOn(background).mapToVoid().startWith(())
        .map { _ -> [String: Any] in
            var value: [String: Any] = [:]
            let attachments = job.attachmentTyped.asSorted()
            value["hasAttachments"] = attachments.count > 0
            value["attachments"] = attachments.map { $0.pdfData() }
            return value
        }
        
        // Observable for recipients
        let rObs = Recipient.rxMonitorChanges(context).observeOn(background).mapToVoid().startWith(())
        .flatMap { _ ->  Observable<[String: Any]> in
            var values: [String: Any] = [:]
            var observables: [Observable<[String: Any]>] = []

            job.recipientsTyped.asSorted().forEach { (recipient) in
                if let obs = recipient.loadRecipientSignature() {
                    observables.append(obs)
                } else {
                    logVerbose("[Renderer] Customer Signature failed: The recipient url or path was not set.")
                }
            }
            
            if observables.count > 0 {
                return Observable.zip(observables).map({ (array: [[String : Any]]) -> [String: Any] in
                    logVerbose("[Renderer] Customer Signature loaded")
                    values["recipients"] = array
                    values["hasRecipients"] = array.count > 0
                    return values
                })
            }

            return Observable.just(values)
        }
        
        // combines the 2 generated data streams (invoice + attachments) and generates one dictionary
        // renders it into the mustache template and returns the generated html
        let combineObs = Observable.combineLatest(easyObs, aObs, accountObs, designObs, rObs) { (invoiceData: [String: Any], attachmentData: [String: Any], accountData: [String: Any], designData: [String: Any], recipientData: [String: Any]) -> String in
            var combinedData = invoiceData
            combinedData.merge(attachmentData, uniquingKeysWith: { (_, new) in new })
            combinedData.merge(accountData, uniquingKeysWith: { (_, new) in new })
            combinedData.merge(designData, uniquingKeysWith: { (_, new) in new })
            combinedData.merge(recipientData, uniquingKeysWith: { (_, new) in new })
            combinedData["color"] = color

            let templateName = template + ".html"
            let renderedString = try environment.renderTemplate(name: templateName, context: combinedData)
            return renderedString
        }
        
        // loads the generated html in the webview, still on a background thread,
        // once the data is loaded in the hidden webview the navigation subject fires and
        // we start to render the html into pdf (this happens unfortunately on the main thread, but it's fast enough)
        combineObs.flatMap { [unowned self](htmlString) -> Observable<String> in
            logVerbose("[Renderer] load string in webview")
            
            let delegate = RenderWebViewDelegateWrapper()
            self.renderWebViewHelper.navigationDelegate = delegate
            self.renderWebViewHelper.loadHTMLString(htmlString, baseURL: nil)
            return delegate.navigationObservable
                .take(1)
                .map { _ in
                    _ = delegate
                    return htmlString
                }
        }
        .distinctUntilChanged()
        .flatMap { [unowned self](_) -> Observable<RenderedPDF> in
            logVerbose("[Renderer] convert to string to pdf")
            return renderPDF(with: self.renderWebViewHelper.viewPrintFormatter(), filename: self.filename)
        }
        .bind(to: pdfSubject).disposed(by: bag)
    }
    //swiftlint:enable function_body_length
}


