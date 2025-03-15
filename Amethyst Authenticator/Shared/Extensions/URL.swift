//
//  URL.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 15.03.25.
//
import Foundation

extension URL: Identifiable {
    public var id: Int { hashValue }
}
