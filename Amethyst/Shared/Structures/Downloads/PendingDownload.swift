//
//  PendingDownload.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 03.03.25.
//

import WebKit
import Foundation
import OSLog

struct PendingDownload: Equatable {
    static let logger = Logger(subsystem: AmethystApp.subSystem, category: "PendingDownload")
    init(navigationResponse: WKNavigationResponse) {
        let httpResponse = navigationResponse.response as? HTTPURLResponse
        Self.logger.info("\(navigationResponse.response.mimeType ?? "")")
        Self.logger.info("\(navigationResponse.response)")
        self.navigationResponse = navigationResponse
    }
    var navigationResponse: WKNavigationResponse
}
