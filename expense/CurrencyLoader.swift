//
//  CurrencyLoader.swift
//  InVoice
//
//  Created by Georg Kitz on 29.08.18.
//  Copyright © 2018 meisterwork GmbH. All rights reserved.
//

import Foundation
import RxSwift

struct CurrencyLoader {
    
    private static let currentCurrencyVariable: Variable<Currency> = Variable(allCurrencies[0])
    static var currentCurrencyObservable: Observable<Currency> {
        return currentCurrencyVariable.asObservable().distinctUntilChanged()
    }
    static var currentCurrency: Currency {
        return currentCurrencyVariable.value
    }
    
    static let allCurrencies: [Currency] = loadAll()
    
    static func loadAll() -> [Currency] {
        guard let url = Bundle.main.path(forResource: "currencies", ofType: "json")?.asFileUrl else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let currencies = try JSONDecoder().decode([Currency].self, from: data)
            return currencies
        }
        catch {
            print(error)
        }
        
        return []
    }
    
    static func update(_ currency: Currency) {
        currentCurrencyVariable.value = currency
    }
}
