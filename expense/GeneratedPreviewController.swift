//
//  GeneratedPreviewController.swift
//  InVoice
//
//  Created by Georg Kitz on 05/12/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import MessageUI


class GeneratedPreviewController: UIViewController, WKNavigationDelegate, Sendable {
    @IBOutlet weak var sendButton: ActionButton!
    
    private var bag = DisposeBag()
    
    // The hideSendButton will remove the send button, in view did load. The hide button is also
    // not visible in the case that the model is not set.
    var hideSendButton: Bool = false
    
    var job: Job!
    var pdf: RenderedPDF?
    var renderer: PerformanceInvoiceGenerator?
    
    private lazy var renderWebViewHelper: WKWebView = {
        let contentController = WKUserContentController()
        let configuration = WKWebViewConfiguration()
        
        configuration.applicationNameForUserAgent = "InvoiceBot"
        configuration.userContentController = contentController
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.isHidden = true
        
        return webView
    } ()
    
    private lazy var pdfWebView: WKWebView = { [unowned self] in
        
        let contentController = WKUserContentController()
        let configuration = WKWebViewConfiguration()
        
        configuration.applicationNameForUserAgent = "InvoiceBot"
        configuration.userContentController = contentController
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        
        return webView
    } ()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        return activityIndicator
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Only in the case a job model is set we show the present picker otherwise we do not present a picker
        // because the mail picker needs one.
        sendButton.button?.isHidden = hideSendButton
        sendButton.button?.setTitle(R.string.localizable.mailSend(), for: .normal)
        
        title = job.number
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        let views = ["pdfWebView": pdfWebView]
        
        view.addSubview(pdfWebView)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[pdfWebView]-(0)-|", metrics: nil, views: views))
        
        if hideSendButton {
            view.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-(0)-[pdfWebView]-(0)-|",
                metrics: nil, views: views)
            )
        } else {
            view.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-[pdfWebView]-[sendButton]",
                metrics: nil, views: ["pdfWebView": pdfWebView, "sendButton": sendButton])
            )
        }
        
        view.addSubview(activityIndicator)
        view.addConstraints([
            NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        ])
        
        let expiredObs = sendButton.tapObservable.filter { CurrentAccountState.value == .trialExpired }
        let notExpiredObs = sendButton.tapObservable.filter { CurrentAccountState.value != .trialExpired }
        var actionObs =  Observable.just(pdf).filterNil()
        
        if let renderer = renderer {
            actionObs = renderer.pdfObservable
        }

        expiredObs.subscribe(onNext: { [unowned self](_) in
            UpsellTrialExpiredController.present(in: self)
        }).disposed(by: bag)

        actionObs.subscribe(onNext: { [unowned self] (pdf) in
            self.pdf = pdf
            self.pdfWebView.loadFileURL(pdf.path, allowingReadAccessTo: pdf.directory)
        }).disposed(by: bag)

        Observable.combineLatest(actionObs, notExpiredObs) { (pdf, _) -> RenderedPDF in
            return pdf
        }.subscribe(onNext: { [unowned self] (pdf) in
            Analytics.actionSendEmail.logEvent()
            self.presentSendPicker(for: self.job, with: pdf, from: self.sendButton, completion: {/*do nothing */})
        }).disposed(by: bag)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView == pdfWebView {
            activityIndicator.stopAnimating()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // in the case the controller reappears in the view hierachy show the pdf again.
        // if not set here the webview will be empty.
        if let pdf = pdf {
            pdfWebView.loadFileURL(pdf.path, allowingReadAccessTo: pdf.directory)
        }
    }
}
