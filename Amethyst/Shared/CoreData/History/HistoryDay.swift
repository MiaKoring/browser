//
//  HistoryDay.swift
//  Amethyst Project
//
//  Created by Mia Koring on 17.04.25.
//
import Foundation
import CoreData

@objc(HistoryDay)
public class HistoryDay: NSManagedObject {
    convenience init() {
        self.init(context: CDHistoryController.shared.container.viewContext)
        self.dayID = UUID()
    }
}
