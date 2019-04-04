//
//  ChartModel.swift
//  InVoice
//
//  Created by Georg Kitz on 10/01/2018.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import Charts
import RxSwift
import SwiftMoment
import CoreData

// MARK: - Sequence Group By Helper
public extension Sequence {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U: [Iterator.Element]] {
        var categories: [U: [Iterator.Element]] = [:]
        for element in self {
            let key = key(element)
            if case nil = categories[key]?.append(element) {
                categories[key] = [element]
            }
        }
        return categories
    }
}

public extension Sequence where Iterator.Element: Invoice {
    func total(with zeroDataDict: [Date: NSDecimalNumber], by date: (Iterator.Element) -> Date?) -> [NSDecimalNumber] {
        
        let groupedData: [Date: [Invoice]] = group(by: {
            let elementDate = date($0) ?? Date()
            return elementDate.asMoment.startOf(TimeUnit.Months).date
        })
        
        return groupedData.mapValues({ (invoices) -> NSDecimalNumber in
            return invoices.reduce(NSDecimalNumber.zero, { (current, invoice) -> NSDecimalNumber in
                return current + (invoice.total ?? NSDecimalNumber.zero)
            })
        })
        .merging(zeroDataDict, uniquingKeysWith: { (first, _) in first })
        .sorted(by: { $0.key < $1.key })
        .map({ $0.value })
    }
}

extension Date {
    var asMoment: Moment {
        return moment(self)
    }
}

// MARK: - Helper for Unpaid Invoices
private func unpaidObs(with start: Moment, in context: NSManagedObjectContext) -> Observable<LineChartDataSet> {
    
    let background = ConcurrentDispatchQueueScheduler(qos: .background)
    let createdInLast6Months = NSPredicate(format: "date >= %@ AND paidTimestamp == NULL", start.date as CVarArg).and(.undeletedItem())
    let zeroDataDict = zerodData(with: start)
    
    return Invoice.rxAllObjects(matchingPredicate: createdInLast6Months, sorted: [NSSortDescriptor(key: "date", ascending: true)], context: context)
        .observeOn(background)
        .map { (invoices) -> [NSDecimalNumber] in
            return invoices.total(with: zeroDataDict, by: { $0.date })
        }.map { (data) -> LineChartDataSet in
            return unpaidData(from: data)
        }.observeOn(MainScheduler.instance)
}

private func paidObs(with start: Moment, in context: NSManagedObjectContext) -> Observable<LineChartDataSet> {
    
    let background = ConcurrentDispatchQueueScheduler(qos: .background)
    let inLast6Months = NSPredicate(format: "paidTimestamp >= %@", start.date as CVarArg).and(.undeletedItem())
    let zeroDataDict = zerodData(with: start)
    
    return Invoice.rxAllObjects(matchingPredicate: inLast6Months, sorted: [NSSortDescriptor(key: "paidTimestamp", ascending: true)], context: context)
        .observeOn(background)
        .map { (invoices) -> [NSDecimalNumber] in
            return invoices.total(with: zeroDataDict, by: { $0.paidTimestamp })
        }.map { (data) -> LineChartDataSet in
            return paidData(from: data)
        }.observeOn(MainScheduler.instance)
}

private func unpaidData(from values: [NSDecimalNumber]) -> LineChartDataSet {
    //        let values = [2000, 5000, 6000, 100, 4000, 7000]
    let entries = values.enumerated().map { (value) -> ChartDataEntry in
        return ChartDataEntry(x: Double(value.offset), y: Double(truncating: value.element))
    }
    
    let line = LineChartDataSet(values: entries, label: R.string.localizable.unPaid())
    line.mode = .cubicBezier
    line.cubicIntensity = 0.2
    line.circleRadius = 5.0
    line.colors = [UIColor.redish]
    line.circleColors = [UIColor.white]
    line.circleHoleColor = UIColor.redish
    line.lineCapType = .round
    line.highlightColor = UIColor.main
    
    return line
}

private func paidData(from values: [NSDecimalNumber]) -> LineChartDataSet {
//    let values = [12000, 6000, 4000, 18000, 0, 5000]
    let entries = values.enumerated().map { (value) -> ChartDataEntry in
        return ChartDataEntry(x: Double(value.offset), y: Double(truncating: value.element))
    }
    
    let line = LineChartDataSet(values: entries, label: R.string.localizable.paid())
    line.mode = .cubicBezier
    line.cubicIntensity = 0.2
    line.circleRadius = 5.0
    line.colors = [UIColor.greenish]
    line.circleColors = [UIColor.white]
    line.circleHoleColor = UIColor.greenish
    line.lineCapType = .round
    line.highlightColor = UIColor.main
    
    return line
}

private func zerodData(with start: Moment) -> [Date: NSDecimalNumber] {
    var zerodData: [Date: NSDecimalNumber] = [:]
    for idx in 0...6 {
        let key = start.add(idx, TimeUnit.Months).startOf(TimeUnit.Months).date
        zerodData[key] = NSDecimalNumber.zero
    }
    return zerodData
}

class ChartModel: ChartViewDelegate {
    
    private let bag = DisposeBag()
    private let dataSubject: Variable<LineChartData> = Variable(LineChartData(dataSets: []))
    var dataObservable: Observable<LineChartData> {
        return dataSubject.asObservable()
    }
    
    var data: LineChartData {
        return dataSubject.value
    }
    
    var monthTransformer: MonthTransformer
    
    init(with context: NSManagedObjectContext) {
        
        let start = moment().subtract(5, TimeUnit.Months).startOf(TimeUnit.Months)
        Observable.combineLatest([unpaidObs(with: start, in: context), paidObs(with: start, in: context)]).map { (lineData) -> LineChartData in
            let data = LineChartData()
            lineData.forEach({ data.addDataSet($0) })
            data.setDrawValues(false)
            return data
        }.bind(to: dataSubject).disposed(by: bag)
        
        monthTransformer = MonthTransformer(start: start.month)
    }
    
    func updateChartDesign(for chart: LineChartView) {
        
        chart.chartDescription = nil
        
        let rightAxis = chart.rightAxis
        rightAxis.drawAxisLineEnabled = false
        rightAxis.drawLabelsEnabled = false
        rightAxis.drawGridLinesEnabled = false
        
        let leftAxis = chart.leftAxis
        leftAxis.drawAxisLineEnabled = false
        leftAxis.labelFont = FiraSans.regular.font(12)
        leftAxis.labelTextColor = UIColor.blueGrayish
        leftAxis.gridColor = UIColor.blueGrayish
        leftAxis.gridLineDashLengths = [4, 4]
        leftAxis.valueFormatter = AmountTransformer()
        
        let xAxis = chart.xAxis
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.labelFont = FiraSans.regular.font(12)
        xAxis.labelTextColor = UIColor.blueGrayish
        xAxis.labelPosition = .bottom
        xAxis.axisMinimum = 0
        xAxis.axisMaximum = 5
        xAxis.granularityEnabled = true
        xAxis.entries = [0, 1, 2, 3, 4, 5]
        xAxis.centeredEntries = [0, 1, 2, 3, 4, 5]
        xAxis.valueFormatter = monthTransformer
        
        chart.doubleTapToZoomEnabled = false
        chart.pinchZoomEnabled = false
        chart.drawMarkers = false
        
        let legend = chart.legend
        legend.xOffset = -10
        legend.textColor = UIColor.blueGrayish
        legend.font = FiraSans.regular.font(11)
    }
}

class MonthTransformer: IAxisValueFormatter {
    private let startMonth: Int
    init(start month: Int) {
        startMonth = month
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        var currentMonth = startMonth + Int(value)
        currentMonth = currentMonth > 12 ? currentMonth % 12 : currentMonth
        
        let date = moment([2018, currentMonth])!
        return date.format("MMM").uppercased()
    }
}

class AmountTransformer: IAxisValueFormatter {
    
    private let defaultTransformer = DefaultAxisValueFormatter()
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }()
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if value >= 1000.0 {
            
            guard let transformedValue = numberFormatter.string(from: NSNumber(value: value / 1000.0)) else {
                return defaultTransformer.stringForValue(value, axis: axis)
            }
            return R.string.localizable.amountXK(transformedValue)
            
        } else if value >= 1000000.0 {
            
            guard let transformedValue = numberFormatter.string(from: NSNumber(value: value / 1000000.0)) else {
                return defaultTransformer.stringForValue(value, axis: axis)
            }
            return R.string.localizable.amountXM(transformedValue)
        }
        
        return defaultTransformer.stringForValue(value, axis: axis)
    }
}
