//
//  URL.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 25.03.25.
//
import Foundation

extension URL: @retroactive Identifiable {
    public var id: Int { self.hashValue }
}
