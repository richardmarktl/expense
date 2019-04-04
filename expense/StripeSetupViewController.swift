//
//  StripeSetupViewController.swift
//  InVoice
//
//  Created by Richard Marktl on 30.03.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//
import UIKit
import WebKit
import RxSwift
import RxCocoa

class StripeSetupViewController: UIViewController, WKNavigationDelegate {
    private let cancelSubject = PublishSubject<Bool>()  // true if cancelled by the user, false if an error.
    public var cancelObservable: Observable<Bool> {
        return cancelSubject.asObservable()
    }
    
    private let bag = DisposeBag()
    private let webView: WKWebView = {
        
        let contentController = WKUserContentController()
        let configuration = WKWebViewConfiguration()
        
        configuration.applicationNameForUserAgent = "InvoiceBot"
        configuration.userContentController = contentController
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        return webView
    } ()
    
    private var loadingObservation: NSKeyValueObservation?
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .black
        return spinner
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = R.string.localizable.stripeSetup()
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        navigationItem.leftBarButtonItem?.rx.tap.subscribe(onNext: { [unowned self] (_) in
            self.cancelSubject.onNext(true)
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: bag)

        view.addSubview(webView)
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.navigationDelegate = self
        
        setupLoadingIndicator()
        
        if var url = URL(string: baseURLString()), let token = UserDefaults.appGroup.token() {
            url.appendPathComponent("/payment/stripe/authorize")
            var request = URLRequest(url: url)
            request.setValue( "Token " + token, forHTTPHeaderField: "Authorization")
            webView.load(request)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        // the following code is used to test redirects on the localhost server
        // localhostRedirect()
        
        // handle the success or error redirects. The stripe account creds are stored on the server
        // only a boolean is set if the they are avialable.
        if let url = webView.url, url.absoluteString.hasPrefix("https://invoicebot.io/bot/stripe/") {
            if url.absoluteString.hasPrefix("https://invoicebot.io/bot/stripe/success") {
                _ = AccountRequest.load(Account.current(), updatedAfter: nil).take(1).subscribe(onNext: { (account) in
                     try? account.managedObjectContext?.save()
                })
                self.navigationController?.popViewController(animated: true)
            } else {
                cancelSubject.onNext(false)
                
                let handler: ((UIAlertAction) -> Void) = {_ in
                    self.navigationController?.popViewController(animated: true)
                }
                var dict: [String: String] = StripeSetupViewController.parseErrors(from: url)
                
                if let message = dict["message"] {
                    if let state = dict["state"] {
                        logger.error("Stripe redirect failed: \(state) with: \(message)")
                    } else {
                        logger.error("Stripe redirect failed: \(message)")
                    }
                    ErrorPresentable.show(error: message, handler: handler)
                } else {
                    logger.error("Stripe redirect unknown error: \(dict)")
                    ErrorPresentable.show(error: R.string.localizable.invalidJSON(), handler: handler)
                }
            }
        }
    }
   
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        ErrorPresentable.show(error: error)
    }
    
    /// This method should only be used in the development modes.
    private func localhostRedirect() {
        if let url = webView.url, url.absoluteString.hasPrefix("http://localhost:8000") == true {
            if let redirectURL = URL(string: url.absoluteString.replacingOccurrences(of: "localhost", with: "192.168.25.4")) {
                webView.load(URLRequest(url: redirectURL))
            }
        }
    }
    
    private func setupLoadingIndicator() {
        loadingObservation = webView.observe(\.isLoading, options: [.new, .old]) { [weak self] (_, change) in
            guard let strongSelf = self else {
                return
            }
            
            // this is fine
            let new = change.newValue!
            let old = change.oldValue!
            
            if new && !old {
                strongSelf.view.addSubview(strongSelf.loadingIndicator)
                strongSelf.loadingIndicator.startAnimating()
                NSLayoutConstraint.activate([
                    strongSelf.loadingIndicator.centerXAnchor.constraint(equalTo: strongSelf.view.centerXAnchor),
                    strongSelf.loadingIndicator.centerYAnchor.constraint(equalTo: strongSelf.view.centerYAnchor)
                ])
                strongSelf.view.bringSubview(toFront: strongSelf.loadingIndicator)
            } else if !new && old {
                strongSelf.loadingIndicator.stopAnimating()
                strongSelf.loadingIndicator.removeFromSuperview()
            }
        }
    }
    
    private func baseURLString() -> String {
        guard let urlString = Bundle.main.infoDictionary!["API_ENDPOINT"] as? String else {
            fatalError()
        }
        return urlString
        // TEST url used for local testing.
        // return "http://192.168.25.4:8000"
    }
    
    class func parseErrors(from url: URL) -> [String: String] {
        var errorDictionary: [String: String] = [:]
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        if let queryItems = components.queryItems {
            for item in queryItems {
                errorDictionary[item.name] = item.value!
            }
        }
        return errorDictionary
    }
}
