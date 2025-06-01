//
//  Array.swift
//  Amethyst Project
//
//  Created by Mia Koring on 01.06.25.
//
import Foundation

extension Array {
    public subscript(index: Int, default defaultValue: @autoclosure () -> Element) -> Element {
        guard index >= 0, index < endIndex else {
            return defaultValue()
        }

        return self[index]
    }
}
