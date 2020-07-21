//
//  PromptContentView.swift
//  Cactus
//
//  Created by Neil Poulin on 7/20/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct PromptContentController: UIViewControllerRepresentable {
    var promptContent: PromptContent
    @EnvironmentObject var session: SessionStore
    weak var delegate: PromptContentPageViewControllerDelegate?
    
    func makeUIViewController(context: Context) -> PromptContentPageViewController {
        let view = ScreenID.promptContentPageView.getViewController() as! PromptContentPageViewController
        view.promptContent = self.promptContent
        view.promptDelegate = self.delegate
        view.member = session.member
        view.appSettings = session.settings
        return view
    }
    
    func updateUIViewController(_ uiViewController: PromptContentPageViewController, context: Context) {
        uiViewController.promptDelegate = self.delegate
        uiViewController.member = session.member
        uiViewController.appSettings = session.settings
        uiViewController.promptContent = self.promptContent
        
    }
}

struct PromptContentView: View {
    @EnvironmentObject var session: SessionStore
    var entry: JournalEntry
    weak var delegate: PromptContentPageViewControllerDelegate?
    var body: some View {
        Group {
            if self.entry.promptContent == nil || !self.entry.promptContentLoaded {
                Loading("No Content Found Yet")
            } else {
                PromptContentController(promptContent: self.entry.promptContent!, delegate: self.delegate)
                    .edgesIgnoringSafeArea(.bottom)
            }
        }
        
    }
}

struct PromptContentView_Previews: PreviewProvider {
    
    static func getEntry() -> JournalEntry {
        var entry = JournalEntry(promptId: "testId")
        entry.loadingComplete = false
        return entry
    }
    
    static var previews: some View {
        PromptContentView(entry: getEntry()).environmentObject(SessionStore.mockLoggedIn())
    }
}
