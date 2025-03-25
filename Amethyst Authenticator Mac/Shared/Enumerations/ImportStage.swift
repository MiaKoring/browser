//
//  ImportStage.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 25.03.25.
//

enum ImportStage {
    case waiting
    case readFile
    case parseData
    case fetchExistingAccounts
    case importAccounts
    case complete
}
