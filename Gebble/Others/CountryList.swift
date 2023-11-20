//
//  CountryList.swift
//  Gebble
//
//  Created by DjangoLin on 2023/11/15.
//

import Foundation
import IdentifiedCollections
enum Country: Hashable, Identifiable, Equatable {
    var id: Self {
        return self
    }
    case all
    case specify(id: String, name: String)
    
    var name: String {
        switch self {
        case .all:
            return "All"
        case let .specify(_, name):
            return name
        }
    }
}

let countryList: IdentifiedArrayOf<Country> = {
    var list: IdentifiedArrayOf<Country> = []
    let countryList: [Country] = NSLocale.isoCountryCodes.compactMap { code in
        let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
        let currentLocaleID = NSLocale.current.identifier
        guard let name = NSLocale(localeIdentifier: currentLocaleID).displayName(forKey: NSLocale.Key.identifier, value: id) else { return nil }
        return Country.specify(id: id, name: name)
    }
    list.append(contentsOf: countryList)
    return list
}()
