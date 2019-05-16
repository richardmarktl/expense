//
//  PrivacyController.swift
//  SettingsUI
//
// Created by Richard Marktl on 2019-05-09.
// Copyright (c) 2019 meisterwork. All rights reserved.
//

import UIKit
import CommonUtil
import WebKit
import RxSwift

open class PrivacyController: UIViewController {
    private let bag = DisposeBag()
    private let webView: WKWebView = {

        let contentController = WKUserContentController()
        let configuration = WKWebViewConfiguration()

        configuration.applicationNameForUserAgent = AppInfo.name
        configuration.userContentController = contentController

        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false

        return webView
    }()

    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: [
            PodLocalizedString("subscription", comment: ""),
            PodLocalizedString("terms", comment: ""), 
            PodLocalizedString("privacy", comment: "")
        ])
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

    public var storeService: StoreService?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        hidesBottomBarWhenPushed = true
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = false

        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        }

        view.addSubview(webView)

        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        navigationItem.titleView = segmentedControl

        segmentedControl.rx.value.asObservable().startWith(0).subscribe(onNext: { [unowned self] (idx) in
            self.handleSegmentedControlChange(to: idx)
        }).disposed(by: bag)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func handleSegmentedControlChange(to index: Int) {
        guard let file = filePath(for: index), let service = storeService else {
            return
        }

        let url = URL(fileURLWithPath: file)
        if index == 0 {
            service.loadProducts()
            service.productsObservable.subscribe(onNext: { [weak self](products) in
                let monthlyProduct = products.filter({ $0.isMonthBasedPeriod }).first
                let html = try? String(contentsOf: url)

                if let monthlyProduct = monthlyProduct, let html = html {
                    let formattedHTML = String(format: html, monthlyProduct.monthlyPrice, monthlyProduct.periodPrice)
                    self?.webView.loadHTMLString(formattedHTML, baseURL: url)
                }
            }).disposed(by: bag)

        } else {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }
    }

    private func filePath(for index: Int) -> String? {
        switch index {
        case 0:
            return AppInfo.pathToSubscriptionHtml
        case 1:
            return AppInfo.pathToTermsOfServiceHtml
        case 2:
            return AppInfo.pathToPrivacyHtml
        default:
            return nil
        }
    }
}
