//
//  AppDelegate+Appearance.swift
//  InVoice
//
//  Created by Georg Kitz on 20/11/2017.
//  Copyright © 2017 meisterwork GmbH. All rights reserved.
//

import UIKit

struct AppAppearance {
    
    private static var searchBarIconBackup: UIImage?
    private static var searchbarBackgroundBackup: UIImage?
    
    //swiftlint:disable function_body_length
    static func updateAppearance() {
        
        let labelInSectionHeader = UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self])
        labelInSectionHeader.font = UIFont.headerFooterFont()
        
        let barButtonItem = UIBarButtonItem.appearance(whenContainedInInstancesOf: [NavigationController.self])
        barButtonItem.tintColor = UIColor.white
        barButtonItem.setTitleTextAttributes([NSAttributedStringKey.font: FiraSans.regular.font(16),
                                              NSAttributedStringKey.foregroundColor: UIColor.white], for: [])
        
        barButtonItem.setTitleTextAttributes([NSAttributedStringKey.font: FiraSans.regular.font(16)], for: [.selected])
        barButtonItem.setTitleTextAttributes([NSAttributedStringKey.font: FiraSans.regular.font(16)], for: [.highlighted])
        barButtonItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor(white: 1.0, alpha: 0.1)], for: .disabled)
        let barButtonItemInToolBar = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self])
        barButtonItemInToolBar.tintColor = UIColor.main
                
        let navigationBar = UINavigationBar.appearance(whenContainedInInstancesOf: [NavigationController.self])
        navigationBar.barStyle = .blackOpaque
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = UIColor.main //UIColor(red: 21.0/255.0, green: 153.0/255.0, blue: 249.0/255.0, alpha: 1)
        navigationBar.titleTextAttributes = [NSAttributedStringKey.font: FiraSans.medium.font(16),
                                             NSAttributedStringKey.foregroundColor: UIColor.white]
        
        navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.font: FiraSans.medium.font(34),
                                                  NSAttributedStringKey.foregroundColor: UIColor.white]
        
        let searchBar = UISearchBar.appearance(whenContainedInInstancesOf: [NavigationController.self])
        searchBar.tintColor = UIColor.white
        searchBar.barTintColor = UIColor.white

        // we need to do this stupid hack, bc setting the searchBackground breaks the insets of the
        // text from the image on the left side
        UITextField.mw_selectorReplacement()
        UITextField.appearance().tintColor = .main
        UITextView.appearance().tintColor = .main
        
        AppAppearance.searchbarBackgroundBackup = searchBar.backgroundImage
        AppAppearance.searchBarIconBackup = searchBar.image(for: UISearchBarIcon.search, state: .normal)
        
        let searchBackground = R.image.searchbar_background()!
        searchBar.setSearchFieldBackgroundImage(searchBackground, for: [])
        let searchIcon = R.image.searchbar_icon()!
        searchBar.setImage(searchIcon, for: UISearchBarIcon.search, state: .normal)

        let searchTextField = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        searchTextField.defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
        searchTextField.attributedPlaceholder = NSAttributedString(string: R.string.localizable.search(), attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        
        let tabBarItem = UITabBarItem.appearance()
        tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font: FiraSans.regular.font(10)], for: [])
    
        let tabBar = UITabBar.appearance()
        tabBar.tintColor = UIColor.main
        
        let segmentedControl = UISegmentedControl.appearance()
        segmentedControl.tintColor = UIColor.white
        
        let segmentedControlInToolbar = UISegmentedControl.appearance(whenContainedInInstancesOf: [UIToolbar.self])
        segmentedControlInToolbar.tintColor = UIColor.main
        
        let viewAlert = UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self])
        viewAlert.tintColor = UIColor.main
    }
    //swiftlint:enable function_body_length
}

extension UIBarButtonItem {
    func makeStrong() {
        setTitleTextAttributes([
            NSAttributedStringKey.font: FiraSans.medium.font(16),
            NSAttributedStringKey.foregroundColor: UIColor.white], for: []
        )
    }
}
