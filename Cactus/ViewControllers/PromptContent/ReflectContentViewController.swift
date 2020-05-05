//
//  ReflectContentViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 9/17/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import AVKit

class ReflectContentViewController: PromptContentViewController {
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var pottedCactusPlaceholderImage: UIImageView!
    @IBOutlet weak var addNoteButton: BorderedButton!
    @IBOutlet weak var reflectionTextView: UITextView!
    @IBOutlet weak var cactusAnimationContainerView: UIView!
    @IBOutlet weak var sharedNoteStackView: UIStackView!
    var reflectLogger = Logger(fileName: "ReflectionContentViewController")
    var animationVc: GenericCactusElementAnimationViewController?
    var player: AVPlayer!
    var reflectionResponse: ReflectionResponse? {
        didSet {
            self.configureResponseView()
        }
    }
    var editViewController: EditReflectionViewController?
        
    var startTime: Date?
    var endTime: Date?
          
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pottedCactusPlaceholderImage.removeFromSuperview()
        
        if let promptId = self.promptContent.promptId, self.reflectionResponse == nil {
            let question = self.promptContent.getQuestion()
            let element = self.promptContent.cactusElement
            self.reflectionResponse = ReflectionResponseService.sharedInstance.createReflectionResponse(promptId, promptQuestion: question, element: element, medium: .PROMPT_IOS)
        }
        self.configureView()
        self.videoView.isHidden = true
        self.createAnimation()
    }
   
    func createAnimation() {
        let container = self.cactusAnimationContainerView!
        
        var cactusVc: GenericCactusElementAnimationViewController?
        
        switch self.promptContent.cactusElement {
        case .meaning:
            cactusVc = MeaningAnimationViewController.loadFromNib()
        case .emotions:
            cactusVc = EmotionsAnimationViewController.loadFromNib()
        case .experience:
            cactusVc = ExperienceAnimationViewController.loadFromNib()
        case .relationships:
            cactusVc = RelationshipsAnimationViewController.loadFromNib()
        case .energy:
            cactusVc = EnergyAnimationViewController.loadFromNib()
        default:
            cactusVc = EnergyAnimationViewController.loadFromNib()
        }
        
        guard let animationVc = cactusVc else {
            self.reflectLogger.warn("Unable to find an animation vc for the element \(String(describing: self.promptContent.cactusElement))")
            return
        }
        
        self.animationVc = animationVc
        animationVc.willMove(toParent: self)
        animationVc.view.frame = container.bounds
        container.addSubview(animationVc.view)
        
        let cactus = animationVc.view
        cactus?.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        cactus?.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        cactus?.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        cactus?.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        
        animationVc.didMove(toParent: self)
    }
    
    func configureNote() {
        guard self.isViewLoaded else {
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let video = self.player {
            video.seek(to: CMTime.zero)
            video.play()
        }
        
        self.startTime = Date()
        self.endTime = nil
        self.animationVc?.startAnimations()        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.animationVc?.pauseAnimations()
    }
    
    @IBAction func addNoteTapped(_ sender: Any) {
        let editVc = self.createEditReflectionModal()
        self.editViewController = editVc
        self.present(editVc, animated: true)
    }
       
    func createCactusGrowingVideo() {
        guard let videoURL =  Bundle.main.url(forResource: "cactus-growing-green-588", withExtension: "mp4") else {
            self.reflectLogger.warn("Video not found")
            return
        }
        let item = AVPlayerItem(url: videoURL)
        let videoFrame = AVMakeRect(aspectRatio: CGSize(width: 1, height: 1), insideRect: self.videoView.bounds)
        player = AVPlayer(playerItem: item)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoFrame
        self.videoView.clipsToBounds = true
        self.videoView.layer.addSublayer(playerLayer)
        playerLayer.pixelBufferAttributes = [(kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA]

        playerLayer.player?.play()
    }
        
    @objc func doneAction(_ sender: Any) {
        self.reflectLogger.info("Done button tapped")
        self.saveResponse(nextPageOnSuccess: true, silent: false) { (saved, _) in
            if let saved = saved {
                self.reflectionResponse = saved
            }
        }
        view.endEditing(true)
    }
    
    func setSaving(_ isSaving: Bool) {
        self.editViewController?.isSaving = isSaving
        if isSaving {
            self.addNoteButton.setTitle("Saving...", for: .disabled)
            self.addNoteButton.isEnabled = false
        } else {
            self.addNoteButton.isEnabled = true
        }
    }
    
    func saveResponse(nextPageOnSuccess: Bool=true, silent: Bool = false, _ completion: ((ReflectionResponse?, Any?) -> Void)?=nil) {
        //Note: The text must be set on the ReflectionResponse object, we will not grab it from the text input here.
        self.reflectLogger.debug("saving response...")
        guard let response = self.reflectionResponse else {
            self.reflectLogger.warn("No reflection Response found on the ReflectContentCardViewControler. Unable to save the response")
            completion?(nil, "No reflection response was found")
            return
        }
        self.endTime = Date()
        var durationMs: Double?
        if let startTime = self.startTime, let endTime = self.endTime {
            durationMs = endTime.timeIntervalSince(startTime) * 1000
        }
        if let duration = durationMs {
            response.reflectionDurationMs = (response.reflectionDurationMs ?? 0) + Int(duration)
        }
        response.cactusElement = self.promptContent.cactusElement
        if !silent {
            self.setSaving(true)
        }
        
        ReflectionResponseService.sharedInstance.save(response) { (saved, error) in
            if let error = error {
                self.reflectLogger.error("Error saving reflection response", error)
            }
            
            if !silent {
                self.setSaving(false)
            }
            completion?(saved, error)
            if error == nil, nextPageOnSuccess {
                self.delegate?.nextScreen()
            }
        }
    }
    
    func createEditReflectionModal() -> EditReflectionViewController {
        let editView = EditReflectionViewController.loadFromNib()
        editView.delegate = self
        editView.response = self.reflectionResponse
        editView.questionText = self.content.text
        
        return editView
    }
    
    func configureView() {
        let questionText = !FormatUtils.isBlank(content.text_md) ? content.text_md : content.text
        self.questionTextView.attributedText = MarkdownUtil.centeredMarkdown(questionText?.preventOrphanedWords(), font: CactusFont.normal(24))
        self.view.backgroundColor = CactusColor.promptBackground
        self.reflectionTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.addNoteTapped)))
        self.reflectionTextView.layer.borderWidth = 1
        self.reflectionTextView.layer.cornerRadius = 12
        self.reflectionTextView.layer.borderColor = CactusColor.textMinimized.cgColor
        
        self.configureResponseView()
    }

    func configureResponseView() {
        guard self.isViewLoaded else {return}
        if FormatUtils.isBlank(self.reflectionResponse?.content.text) {
            self.reflectionTextView.isHidden = true
            self.addNoteButton.isHidden = false
            self.sharedNoteStackView.isHidden = true
        } else {
            self.reflectionTextView.isHidden = false
            self.reflectionTextView.text = self.reflectionResponse?.content.text
            self.addNoteButton.isHidden = true            
            self.sharedNoteStackView.isHidden = !(self.reflectionResponse?.shared ?? false)
        }
    }
    
    @objc private func tapGestureHandler() {
        view.endEditing(true)
    }
    
    override func viewWillLayoutSubviews() {
        self.view.backgroundColor = CactusColor.promptBackground
    }
}

extension ReflectContentViewController: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        self.reflectLogger.debug("text view did change height")
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension ReflectContentViewController: EditReflectionViewControllerDelegate {    
    func done(text: String?, response: ReflectionResponse?) {
        self.reflectLogger.info("Saving text: \(text ?? "None provided")")
        self.reflectionResponse?.content.text = text
        self.configureResponseView()
        self.saveResponse(nextPageOnSuccess: false) { (_, error) in
            self.editViewController?.isSaving = false
            if error == nil {
                self.editViewController?.dismiss(animated: true, completion: {
                    self.delegate?.nextScreen()
                })
            } else {
                self.reflectLogger.error("Failed to save the reflection response", error)
            }
        }
    }
    
    func cancel() {
        self.editViewController?.dismiss(animated: true, completion: nil)
    }
}
