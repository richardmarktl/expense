//
//  DashboardCell.swift
//  InVoice
//
//  Created by Georg Kitz on 10/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import UIKit
import Charts

class DashboardCell: ReusableCollectionViewCell, Shadowable {
    
    @IBOutlet weak var chart: LineChartView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func setDataSource(model: ChartModel) {
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        chart.isHidden = true
        chart.highlightPerTapEnabled = false  // disables the blue lines
        
        model.dataObservable.subscribe(onNext: { [weak self] (data) in
            
            self?.chart.data = data
            
            self?.chart.noDataFont = FiraSans.regular.font(14)
            self?.chart.noDataText = R.string.localizable.noChartData()
            self?.chart.noDataTextColor = UIColor.blueGrayish
            
            self?.activityIndicator.isHidden = true
            self?.chart.isHidden = false
            
        }).disposed(by: reusableBag)
        
        model.updateChartDesign(for: chart)
    }
}
