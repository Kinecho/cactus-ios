//
//  WordBubblesChartView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/24/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct WordBubblesChartController: UIViewControllerRepresentable {
    typealias UIViewControllerType = WordBubbleWebViewController
    
    var words: [InsightWord]?
    
    func makeUIViewController(context: Context) -> WordBubbleWebViewController {
        let uiViewController = WordBubbleWebViewController()
        uiViewController.words = self.words
        uiViewController.loadInsights()
        uiViewController.unlockInsights()
        return uiViewController
    }
    
    func updateUIViewController(_ uiViewController: WordBubbleWebViewController, context: Context) {
        uiViewController.words = self.words
        uiViewController.loadInsights()
        uiViewController.unlockInsights()
    }
}

struct WordBubblesChartView: View {
    var words: [InsightWord]?
    
    var body: some View {
        WordBubblesChartController(words: self.words)
            .frame(width: 300, height: 300)
    }
}

struct WordBubblesChartView_Previews: PreviewProvider {
    static var previews: some View {
        WordBubblesChartView(words: [
            InsightWord(frequency: 1, word: "XCode"),
            InsightWord(frequency: 1, word: "Swift"),
            InsightWord(frequency: 1, word: "SwiftUI")
        ])
    }
}
