//
//  BalanceView.swift
//  InVoice
//
//  Created by Georg Kitz on 27/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxSwift

@IBDesignable
class BalanceView: UIView, XibSetupable {
    @IBOutlet weak var arrowView: UIImageView!
    @IBOutlet weak var subTotalSection: UIStackView!
    @IBOutlet weak var discountSection: UIStackView!
    @IBOutlet weak var vatSection: UIStackView!
    @IBOutlet weak var vatSubSection: UIStackView!
    @IBOutlet weak var paidSection: UIStackView!
    
    @IBOutlet weak var subTotalTitle: UILabel!
    @IBOutlet weak var discountTitle: UILabel!
    @IBOutlet weak var vatTitle: UILabel!
    @IBOutlet weak var paidTitle: UILabel!
    @IBOutlet weak var balanceTitle: UILabel!
    
    @IBOutlet weak var subTotal: UILabel!
    @IBOutlet weak var discount: UILabel!
    @IBOutlet weak var vat: UILabel!
    @IBOutlet weak var paid: UILabel!
    @IBOutlet weak var balance: UILabel!
    
    private var gesture = UISwipeGestureRecognizer()
    private let bag = DisposeBag()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromXib()

        gesture.rx.event.subscribe(onNext: { [unowned self] (_) in
                self.didTapOnView()
        }).disposed(by: bag)
        addGestureRecognizer(gesture)
        
        subTotalTitle.text = R.string.localizable.subtotalTitle()
        discountTitle.text = R.string.localizable.discountTitle()
        vatTitle.text = R.string.localizable.taxTitle()
        paidTitle.text = R.string.localizable.paidTitle()
        balanceTitle.text = R.string.localizable.balanceTitle()
        
        #if DEBUG
            subTotal.accessibilityIdentifier = "sub_total_value"
            discount.accessibilityIdentifier = "discount"
            vat.accessibilityIdentifier = "vat"
            paid.accessibilityIdentifier = "paid"
            balance.accessibilityIdentifier = "balance"
        #endif
        
        didTapOnView()
    }
    
    override var intrinsicContentSize: CGSize {
        return rootView?.intrinsicContentSize ?? CGSize.zero
    }
    
    @objc @IBAction func didTapOnView() {
        let hidden = !subTotalSection.isHidden
        
        gesture.direction = hidden ? .up : .down // change the direction of the gesture based on the hidden state.

        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.subTotalSection.isHidden = hidden
            self?.discountSection.isHidden = hidden
            self?.vatSection.isHidden = hidden
            self?.paidSection.isHidden = hidden
            self?.arrowView.transform = hidden ? CGAffineTransform.identity : CGAffineTransform(rotationAngle: CGFloat.pi)
            // we need this in ios 11, please read the post for an answer
            // https://stackoverflow.com/questions/46326302/uistackview-hide-view-animation
            self?.layoutIfNeeded()
        }
    }
    
    func update(with balanceItem: Balance) {
        subTotal.text = balanceItem.subtotal
        discount.text = balanceItem.discount
        vat.text = balanceItem.vat
        paid.text = balanceItem.paid
        balance.text = balanceItem.balance
        
        vatSubSection.arrangedSubviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        balanceItem.vatToTotalItems.forEach({ (item) in
            let label = UILabel()
            label.font = FiraSans.light.font(12, italic: true)
            label.textColor = UIColor.white
            label.text = item
            vatSubSection.addArrangedSubview(label)
        })
    }
}
