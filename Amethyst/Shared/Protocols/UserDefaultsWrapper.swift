//
//  UserDefaults.swift
//  Browser
//
//  Created by Mia Koring on 27.11.24.
//

import Foundation

protocol UserDefaultWrapper: CaseIterable, RawRepresentable where RawValue == String  {
}
extension UserDefaultWrapper {
    static func reset() {
        for setting in self.allCases {
            UserDefaults.standard.removeObject(forKey: setting.key)
        }
    }
    
    var key: String {
        switch self {
        default: self.rawValue
        }
    }

    var stringValue: String {
        get { UserDefaults.standard.string(forKey: self.key) ?? "" }
        nonmutating set { UserDefaults.standard.setValue(newValue, forKey: self.key) }
    }

    var intValue: Int {
        get { UserDefaults.standard.integer(forKey: self.key) }
        nonmutating set { UserDefaults.standard.setValue(newValue, forKey: self.key) }
    }

    var doubleValue: Double {
        get { UserDefaults.standard.double(forKey: self.key) }
        nonmutating set { UserDefaults.standard.setValue(newValue, forKey: self.key) }
    }

    var boolValue: Bool {
        get { UserDefaults.standard.bool(forKey: self.key) }
        nonmutating set { UserDefaults.standard.setValue(newValue, forKey: self.key) }
    }
    
    var data: Data? {
        get { UserDefaults.standard.data(forKey: self.key) }
        nonmutating set { UserDefaults.standard.setValue(newValue, forKey: self.key) }
    }

    var value: Any? {
        get { UserDefaults.standard.object(forKey: self.key) }
        nonmutating set { UserDefaults.standard.setValue(newValue, forKey: self.rawValue) }
    }
}
