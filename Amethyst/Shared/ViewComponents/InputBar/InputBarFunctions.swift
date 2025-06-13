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
        if let meili = appViewModel.meili {
            async let results = await fetchSearchEngineSuggestions()
            async let meiliRes = await fetchHistorySuggestions(meili)
            await makeResult(searchEngineList: results, meiliList: meiliRes)
        } else {
            let results = await fetchSearchEngineSuggestions()
            makeResult(searchEngineList: results, meiliList: nil)
        }
    }
    
    private func fetchSearchEngineSuggestions() async -> [SearchSuggestion] {
        let searchEngine = SearchEngine(rawValue: UDKey.searchEngine.intValue) ?? .duckduckgo
        let searchEngineItems = await searchEngine.quickResults(text)
        
        let results = Array(searchEngineItems.prefix(Self.suggestionItemMaxCount)).sorted(by: {
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
        return results
    }
    
    private func fetchHistorySuggestions(_ meili: MeiliSearch) async -> [SearchSuggestion] {
        typealias MeiliResult = Result<Searchable<HistoryEntryResult>, Swift.Error>
        
        let meiliItems: [SearchHit<HistoryEntryResult>] = await withCheckedContinuation { continuation in
            meili.index("history").search(SearchParameters(
                query: text,
                limit: Self.suggestionItemMaxCount,
                attributesToSearchOn: ["title", "url"],
                sort: ["amount:desc", "lastSeen:desc"],
                showRankingScore: true
            )) { (result: MeiliResult) in
                switch result {
                case .success(let res):
                    continuation.resume(returning: res.hits)
                case .failure(let error):
                    Self.logger.error("An error occured while fetching Meilisearch suggestions: \(error.localizedDescription)")
                    continuation.resume(returning: [])
                }
            }
        }
        
        let meiliRes: [SearchSuggestion] = meiliItems.compactMap {
            if ($0._rankingScore ?? 0) > 0.6 {
                return SearchSuggestion(title: $0.title.isEmpty ? $0.url: $0.title, urlString: $0.url, origin: .history)
            }
            return nil
        }
        return meiliRes
    }
    
    private func makeResult(searchEngineList: [SearchSuggestion], meiliList: [SearchSuggestion]?) {
        var result: [SearchSuggestion] = []
        if let meiliList {
            if searchEngineList.count >= 1 {
                result = Array(meiliList.prefix(Self.suggestionItemMaxCount - Self.suggestionItemMaxCount / 2))
            } else {
                result = Array(meiliList.prefix(Self.suggestionItemMaxCount))
            }
        }
        for i in 0..<searchEngineList.count {
            if result.count < Self.suggestionItemMaxCount {
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
