//
//  SavedTabExtension.swift
//  Amethyst Project
//
//  Created by Mia Koring on 17.04.25.
//

import Foundation
import CoreData

import Foundation
import CoreData

extension SavedTab {
  @nonobjc public class func createFetchRequest() -> NSFetchRequest<SavedTab> {
    return NSFetchRequest<SavedTab>(entityName: "SavedTab")
  }

  @NSManaged public var sortingID: Int16
  @NSManaged public var tabID: UUID?
  @NSManaged public var url: URL?
  @NSManaged public var windowID: String?
}
