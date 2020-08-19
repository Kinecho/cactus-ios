//
//  EditNoteView.swift
//  Cactus
//
//  Created by Neil Poulin on 8/19/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI

struct EditReflectionControllerRepresentable: UIViewControllerRepresentable {
    let response: ReflectionResponse
    let prompt: ReflectionPrompt?
    let title: String?
    let saving: Bool
    
    /** Callback when the prompt is closed - The text of the reflection, the response and the prompt */
    let onDone: (_: String?, _: ReflectionResponse?, _: String?, _ prompt: ReflectionPrompt?) -> Void
    let onCancel: () -> Void
    
    func makeUIViewController(context: Context) -> EditReflectionViewController {
        let uiViewController = EditReflectionViewController.loadFromNib()
        uiViewController.delegate = context.coordinator
        uiViewController.prompt = self.prompt
        uiViewController.response = self.response
        uiViewController.isSaving = self.saving
        uiViewController.questionText = self.title
        return uiViewController
    }
    
    func updateUIViewController(_ uiViewController: EditReflectionViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        uiViewController.prompt = self.prompt
        uiViewController.response = self.response
        uiViewController.isSaving = self.saving
        uiViewController.questionText = self.title
    }
    
    
    class Coordinator:EditReflectionViewControllerDelegate {
        let parent: EditReflectionControllerRepresentable
        
        init(_ parent: EditReflectionControllerRepresentable) {
            self.parent = parent
        }
        
        func done(text: String?, response: ReflectionResponse?, title: String?, prompt: ReflectionPrompt?) {
            self.parent.onDone(text, response, title, prompt)
        }
        
        func cancel() {
            self.parent.onCancel()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    typealias UIViewControllerType = EditReflectionViewController
    
    
    
}

struct EditNoteView: View {
    let entry: JournalEntry
        
    var response: ReflectionResponse {
        self.entry.responses?.first ?? ReflectionResponse.Builder(self.entry.promptId ?? self.prompt?.id ?? self.entry.promptContent?.promptId).build()
    }
    var prompt: ReflectionPrompt? {
        self.entry.prompt
    }
    
    /** Callback when the prompt is closed - The text of the reflection, the response and the prompt */
    let onDone: () -> Void
    let onCancel: () -> Void
    
    @EnvironmentObject var session: SessionStore
    @State var saving: Bool = false
    
    func handleDone(text: String?, response: ReflectionResponse?, title: String?, prompt: ReflectionPrompt?) {
        self.saving = true
        self.response.content.text = text
        self.response.promptQuestion = title ?? self.response.promptQuestion
                
        self.onDone()
        self.saving = false
    }
    
    func handleCancel() {
        self.onCancel()
    }
    
    var questionTitle: String? {
        
        let member = self.session.member
        let coreValue = self.response.coreValue
        let questionText = self.entry.promptContent?.getDisplayableQuestion(member: member, coreValue: coreValue) ?? self.prompt?.question ?? self.response.promptQuestion
        
        return questionText
    }
    
    var body: some View {
        VStack {
            Text(self.questionTitle ?? "No Title Found")
            Text("Why didn't the other work?")
                    EditReflectionControllerRepresentable(response: self.response,
                                                          prompt: self.prompt,
                                                          title: self.questionTitle,
                                                          saving: self.saving,
                                                          onDone: self.handleDone,
                                                          onCancel: self.handleCancel)
        }
    }
}

struct EditNoteView_Previews: PreviewProvider {
    static let entry: JournalEntry = MockData.getAnsweredEntry()
    
    static var previews: some View {
        Group {
            EditNoteView(
                    entry: entry,
                 onDone: { print("DONE!") },
                 onCancel: { print("Cancel tapped") }
            ).environmentObject(SessionStore.mockLoggedIn())
        }
    }
}
