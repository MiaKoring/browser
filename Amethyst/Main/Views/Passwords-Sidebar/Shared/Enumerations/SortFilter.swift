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

    // A very early date to ensure nil dates are sorted first when ascending
    private static let distantPast = Date(timeIntervalSince1970: 0)

    func shouldPrecede(lhs: Account, rhs: Account, ascending: Bool) -> Bool {
        switch self {
        case .edited:
            // Use distantPast for nil dates to ensure consistent sorting
            // nil values will be treated as older than any actual date
            let lhsValue = lhs.editedAt ?? SortFilter.distantPast
            let rhsValue = rhs.editedAt ?? SortFilter.distantPast
            return compare(lhsValue, rhsValue, lhsId: lhs.id, rhsId: rhs.id, ascending: ascending)
        case .created:
            // Assuming createdAt is non-optional based on original code
            return compare(lhs.createdAt, rhs.createdAt, lhsId: lhs.id, rhsId: rhs.id, ascending: ascending)
        case .website:
            return compare(lhs.service.lowercased(), rhs.service.lowercased(), lhsId: lhs.id, rhsId: rhs.id, ascending: ascending)
        case .title:
            let lhsValue = lhs.title?.lowercased() ?? lhs.service.lowercased()
            let rhsValue = rhs.title?.lowercased() ?? rhs.service.lowercased()
            return compare(lhsValue, rhsValue, lhsId: lhs.id, rhsId: rhs.id, ascending: ascending)
        }
    }

    // Helper function to handle the common comparison logic
    private func compare<T: Comparable>(
        _ lhsValue: T,
        _ rhsValue: T,
        lhsId: Account.ID, // Use the actual type of Account.id
        rhsId: Account.ID,
        ascending: Bool
    ) -> Bool {
        if lhsValue == rhsValue {
            // Fallback to ID for stable sort if primary values are equal
            return lhsId < rhsId
        }
        // Primary comparison
        return ascending ? (lhsValue < rhsValue) : (lhsValue > rhsValue)
    }
    
}

extension String: @retroactive Identifiable {
    public var id: Int { self.hashValue }
}

extension URL: @retroactive Identifiable {
    public var id: Int { self.hashValue }
}
