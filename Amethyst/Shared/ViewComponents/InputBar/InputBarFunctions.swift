//
//  InputBarFunctions.swift
//  Amethyst Browser
//
//  Created by Mia Koring on 02.12.24.
//
import Foundation
import MeiliSearch

extension InputBar {
    func timerSuggestionFetch() async {
        let searchEngine = SearchEngine(rawValue: UDKey.searchEngine.intValue) ?? .duckduckgo
        if let meili = appViewModel.meili {
            typealias MeiliResult = Result<Searchable<HistoryEntryResult>, Swift.Error>
            async let searchEngineItems = await searchEngine.quickResults(text)
            let meiliItems: [SearchHit<HistoryEntryResult>] = await withCheckedContinuation { continuation in
                meili.index("history").search(SearchParameters(
                    query: text,
                    limit: 5,
                    attributesToSearchOn: ["title", "url"],
                    sort: ["amount:desc", "lastSeen:desc"],
                    showRankingScore: true
                )) { (result: MeiliResult) in
                    switch result {
                    case .success(let res):
                        continuation.resume(returning: res.hits)
                        //print("hits: \(res.hits)")
                    case .failure(let error):
                        print(error.localizedDescription)
                        continuation.resume(returning: [])
                    }
                }
            }
            
            let results = await Array(searchEngineItems.prefix(5)).sorted(by: {
                let a = $0.wholeMatch(of: Regexpr.urlWithoutProtocol.regex)
                let b = $1.wholeMatch(of: Regexpr.urlWithoutProtocol.regex)
                return a != nil && b == nil
            }).map({
                if let _ = $0.wholeMatch(of: Regexpr.urlWithoutProtocol.regex) {
                    SearchSuggestion(title: $0, urlString: "https://\($0)", origin: .searchEngine)
                } else {
                    SearchSuggestion(title: $0, urlString: "\(searchEngine.makeSearchUrl($0)?.absoluteString ?? searchEngine.root)", origin: .searchEngine)
                }
            })
            //print("DDG: \(results)")
            let meiliRes: [SearchSuggestion] = meiliItems.compactMap {
                if $0._rankingScore ?? 0 > 0.6 {
                    return SearchSuggestion(title: $0.title.isEmpty ? $0.url: $0.title, urlString: $0.url, origin: .history)
                }
                return nil
            }
            makeResult( searchEngineList: results, meiliList: meiliRes)
            lastInput = text
        } else {
            async let searchEngineItems = await (SearchEngine(rawValue: UDKey.searchEngine.intValue) ?? .duckduckgo).quickResults(text)
            
            let results = await Array(searchEngineItems.prefix(5)).sorted(by: {
                let a = $0.wholeMatch(of: Regexpr.urlWithoutProtocol.regex)
                let b = $1.wholeMatch(of: Regexpr.urlWithoutProtocol.regex)
                return a != nil && b == nil
            }).map({
                if let _ = $0.wholeMatch(of: Regexpr.urlWithoutProtocol.regex) {
                    SearchSuggestion(title: $0, urlString: "https://\($0)", origin: .searchEngine)
                } else {
                    SearchSuggestion(title: $0, urlString: "\(searchEngine.makeSearchUrl($0)?.absoluteString ?? searchEngine.root)", origin: .searchEngine)
                }
            })
            makeResult(searchEngineList: results, meiliList: nil)
            lastInput = text
        }
    }
    
    func makeResult(searchEngineList: [SearchSuggestion], meiliList: [SearchSuggestion]?) {
        var result: [SearchSuggestion] = []
        if let meiliList {
            if searchEngineList.count >= 1 {
                result = Array(meiliList.prefix(4))
            } else {
                result = Array(meiliList.prefix(5))
            }
        }
        for i in 0..<searchEngineList.count {
            if result.count < 5 {
                result.append(searchEngineList[i])
            } else {
                quickSearchResults = result
                return
            }
        }
        quickSearchResults = result
    }
    
    func updateSelection(up: Bool = true) {
        let currentIndex = selectedResult
        
        if up {
            let index = currentIndex - 1 >= 0 ? currentIndex - 1: quickSearchResults.count
            selectedResult = index
        } else {
            let index = currentIndex + 1 < quickSearchResults.count + 1 ? currentIndex + 1: 0
            selectedResult = index
        }
    }
}
