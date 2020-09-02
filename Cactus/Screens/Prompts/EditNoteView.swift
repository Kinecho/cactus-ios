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
    
    
    class Coordinator: EditReflectionViewControllerDelegate {
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
    static let logger = Logger("EditNoteView")
    let entry: JournalEntry?
    let response: ReflectionResponse?
    
    /// For freeform prompts, If no prompt is provided, it will be created along with a sent prompt
    let prompt: ReflectionPrompt?
    /** Callback when the prompt is closed - The text of the reflection, the response and the prompt */
    let onDone: () -> Void
    let onCancel: () -> Void
    
    @EnvironmentObject var session: SessionStore
    @State var saving: Bool = false
    
    init(response: ReflectionResponse, prompt: ReflectionPrompt?=nil, onDone: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.response = response
        self.entry = nil
        self.prompt = prompt
        self.onDone = onDone
        self.onCancel = onCancel
    }
    
    init(entry: JournalEntry, onDone: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.entry = entry
        self.prompt = entry.prompt
        self.onDone = onDone
        self.onCancel = onCancel
        if let r = (entry.responses?.first {!isBlank($0.content.text)} ?? entry.responses?.first) {
            self.response = r
        } else {
            guard let promptId = entry.promptId ?? entry.prompt?.id ?? entry.promptContent?.promptId else {
                EditNoteView.logger.warn("No prompt found, can not create response")
                self.response = nil
                return
            }
            EditNoteView.logger.info("No existing response found, creating new one with promptId \(promptId)")            
            let newResponse = ReflectionResponseService.sharedInstance.createReflectionResponse(promptId, promptQuestion: entry.prompt?.question, element: entry.promptContent?.cactusElement, medium: .JOURNAL_IOS)
            self.response = newResponse
        }
        
    }
    
    func handleDone(text: String?, response: ReflectionResponse?, title: String?, prompt: ReflectionPrompt?) {
        
        guard let response = self.response else {
            self.onDone()
            return
        }
        self.saving = true
        response.content.text = text
        response.promptQuestion = title        
        if response.promptType == .FREE_FORM, let member = self.session.member {
            ReflectionResponseService.sharedInstance.saveFreeformNote(response, member: member, prompt: self.prompt) {
                DispatchQueue.main.async {
                    self.saving = false
                    self.onDone()
                }
            }
            return
        }
                
        ReflectionResponseService.sharedInstance.save(response) { _, _ in
            if let prompt = self.prompt, prompt.promptType == PromptType.FREE_FORM {
                self.prompt?.question = title
                ReflectionPromptService.sharedInstance.save(prompt: prompt) { _, _ in
                    DispatchQueue.main.async {
                        self.saving = false
                        self.onDone()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.saving = false
                    self.onDone()
                }
            }
        }
    }
    
    func handleCancel() {
        self.onCancel()
    }
    
    var questionTitle: String? {
        let member = self.session.member
        let coreValue = self.response?.coreValue
        let questionText = self.entry?.promptContent?.getDisplayableQuestion(member: member, coreValue: coreValue) ?? self.prompt?.question ?? self.response?.promptQuestion
        
        return questionText
    }
    
    var body: some View {
        Group {
            if self.response != nil {
                EditReflectionControllerRepresentable(
                    response: self.response!,
                    prompt: self.prompt,
                    title: self.questionTitle,
                    saving: self.saving,
                    onDone: self.handleDone,
                    onCancel: self.handleCancel)
            } else {
                Text("Whoops! No note was found.")
            }
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
