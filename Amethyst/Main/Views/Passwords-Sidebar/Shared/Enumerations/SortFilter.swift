//
//  SortFilter.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 12.03.25.
//
import AmethystAuthenticatorCore
import Foundation

enum SortFilter: CaseIterable {
    case edited
    case created
    case website
    case title
    
    func shouldPrecede(lhs: Account, rhs: Account, ascending: Bool) -> Bool {
        switch self {
        case .edited:
            guard lhs.editedAt !=  rhs.editedAt else {
                return lhs.id < rhs.id
            }
            guard ascending else {
                return lhs.editedAt ?? Date(timeIntervalSince1970: 0) > rhs.editedAt ?? Date(timeIntervalSince1970: 0)
            }
            return lhs.editedAt ?? Date(timeIntervalSince1970: 0) < rhs.editedAt ?? Date(timeIntervalSince1970: 0)
        case .created:
            guard lhs.createdAt !=  rhs.createdAt else {
                return lhs.id < rhs.id
            }
            guard ascending else {
                return lhs.createdAt > rhs.createdAt
            }
            return lhs.createdAt < rhs.createdAt
        case .website:
            guard lhs.service.lowercased() !=  rhs.service.lowercased() else {
                return lhs.id < rhs.id
            }
            guard ascending else {
                return lhs.service.lowercased() > rhs.service.lowercased()
            }
            return lhs.service.lowercased() < rhs.service.lowercased()
        case .title:
            guard lhs.title?.lowercased() ?? lhs.service.lowercased() != rhs.title?.lowercased() ?? rhs.service.lowercased() else {
                return lhs.id < rhs.id
            }
            guard ascending else {
                return lhs.title?.lowercased() ?? lhs.service.lowercased() > rhs.title?.lowercased() ?? rhs.service.lowercased()
            }
            return lhs.title?.lowercased() ?? lhs.service.lowercased() < rhs.title?.lowercased() ?? rhs.service.lowercased()
        }
    }
    
}
