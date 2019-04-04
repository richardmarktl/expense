//
//  ReportsViewController.swift
//  InVoice
//
//  Created by Georg Kitz on 10/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Horreum

class ReportsViewController: UIViewController {
    
    fileprivate struct Static {
        static let collectionViewTopInset: CGFloat = 100.0
        static let defaultTopInsetForMovingView: CGFloat = 168.0
        static let itemInset: CGFloat = 14
        static let spacingBetweenItems: CGFloat = 24
        static let spacingBetweentSections: CGFloat = 21
    }
    
    private let bag = DisposeBag()
    
    private lazy var totalModel: TotalModel = {
        return TotalModel(with: Horreum.instance!.mainContext)
    }()
    
    private lazy var chartModel: ChartModel = {
        return ChartModel(with: Horreum.instance!.mainContext)
    }()
    
    private lazy var tileModel: TileModel = {
        return TileModel(with: Horreum.instance!.mainContext)
    }()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var movingTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var movingHeightConstraing: NSLayoutConstraint!
    @IBOutlet weak var totalContainerView: UIView!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var totalTitleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = UIColor.clear
        collectionView.contentInset = UIEdgeInsets(top: Static.collectionViewTopInset, left: 0, bottom: 0, right: 0)
        
        collectionView.rx.contentOffset.subscribe(onNext: { [unowned self] (value) in
            
            let currentOffset = value.y
            let normalizeValue = currentOffset + Static.collectionViewTopInset
            
            let delta: CGFloat
            if normalizeValue >= 0 {
                let factor = (Static.defaultTopInsetForMovingView - Static.spacingBetweentSections - Static.collectionViewTopInset) / (Static.collectionViewTopInset + Static.spacingBetweentSections)
                delta = (Static.collectionViewTopInset + currentOffset) * factor
            } else {
                delta = 0
            }
            
            self.movingTopConstraint.constant = Static.defaultTopInsetForMovingView - normalizeValue - delta
            self.view.layoutIfNeeded()
            
            if self.movingTopConstraint.constant <= 0 && self.navigationController?.navigationBar.shadowImage != nil {
                self.navigationController?.navigationBar.shadowImage = nil
            } else if self.movingTopConstraint.constant > 0 && self.navigationController?.navigationBar.shadowImage == nil {
                self.navigationController?.navigationBar.shadowImage = UIImage()
            }
            
            self.totalContainerView.alpha = self.movingTopConstraint.constant / Static.defaultTopInsetForMovingView
            
            if self.movingTopConstraint.constant <= 0 && self.navigationItem.title == nil {
                self.navigationItem.title = self.totalModel.total.total
            } else if self.movingTopConstraint.constant >= 0 && self.navigationItem.title != nil {
                self.navigationItem.title = nil
            }
            
        }).disposed(by: bag)
        
        updateMovingHeightConstraint()
        
        tileModel.itemObservable.subscribe(onNext: { [unowned self] (_) in
            self.collectionView.reloadData()
        }).disposed(by: bag)
        
        totalModel.totalObservable.subscribe(onNext: { [unowned self](totalItem) in
            self.totalTitleLabel.text = totalItem.totalMessage
            self.totalValueLabel.text = totalItem.total
        }).disposed(by: bag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
            collectionView.deselectItem(at: selectedIndexPath, animated: true)
        }
    }
}

extension ReportsViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : tileModel.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.dashboardCell, for: indexPath)!
            cell.setDataSource(model: chartModel)
            cell.addShadow()
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.tileCell, for: indexPath)!
        
        let item = tileModel.items[indexPath.row]
        cell.configure(with: item)
        
        cell.addShadow()
        return cell
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if isViewLoaded {
            collectionView.reloadData()
            updateMovingHeightConstraint()
        }
    }
    
    func updateMovingHeightConstraint() {
        movingHeightConstraing.constant = collectionView.frame.height * 2.0
    }
}

extension ReportsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = view.frame.width
        let inset: CGFloat = Static.itemInset * 2.0
        
        if indexPath.section == 0 {
            return CGSize(width: totalWidth - inset, height: 240)
        }
        
        let itemsPerRow: CGFloat = UIApplication.shared.statusBarOrientation == .landscapeLeft
            || UIApplication.shared.statusBarOrientation == .landscapeLeft
            || UIDevice.current.userInterfaceIdiom == .pad ? 4.0 : 2.0
        
        let spacing: CGFloat = Static.spacingBetweenItems * (itemsPerRow - 1)
        let cellWidth: CGFloat
        if UIDevice.current.userInterfaceIdiom == .pad {
            cellWidth = (totalWidth - inset - spacing) / itemsPerRow
        } else {
            cellWidth = min(((totalWidth - inset - spacing) / itemsPerRow), 161.5)
        }
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: Static.spacingBetweentSections, left: Static.itemInset, bottom: 0, right: Static.itemInset)
        }
        return UIEdgeInsets(top: Static.spacingBetweentSections, left: Static.itemInset, bottom: Static.spacingBetweentSections, right: Static.itemInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        
        tileModel.performTap(at: indexPath, for: collectionView, in: self)
    }
}
