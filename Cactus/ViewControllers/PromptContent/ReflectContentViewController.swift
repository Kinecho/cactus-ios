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
    
    var player: AVPlayer!
    var reflectionResponse: ReflectionResponse?
    var editViewController: EditReflectionViewController?
        
    var startTime: Date?
    var endTime: Date?
          
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pottedCactusPlaceholderImage.removeFromSuperview()
        
        if let promptId = self.promptContent.promptId, self.reflectionResponse == nil {
            let question = self.content.title
            self.reflectionResponse = ReflectionResponseService.sharedInstance.createReflectionResponse(promptId, promptQuestion: question)
        }
        self.configureView()
        self.videoView.isHidden = true
        self.createAnimation()
//        self.createCactusGrowingVideo()
    }
   
    func createAnimation() {
        let container = self.cactusAnimationContainerView!
        
//        let cactusVc = MeaningAnimationViewController.loadFromNib()
//        let cactusVc = EmotionsAnimationViewController.loadFromNib()
//          let cactusVc = ExperienceAnimationViewController.loadFromNib()
//        let cactusVc = EnergyAnimationViewController.loadFromNib()
        let cactusVc = RelationshipsAnimationViewController.loadFromNib()
        
        cactusVc.willMove(toParent: self)
        cactusVc.view.frame = container.bounds
        container.addSubview(cactusVc.view)
        
        let cactus = cactusVc.view
        cactus?.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        cactus?.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        cactus?.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        cactus?.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        
        cactusVc.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let video = self.player {
            video.seek(to: CMTime.zero)
            video.play()
        }
        
        self.startTime = Date()
        self.endTime = nil
    }
    
    @IBAction func addNoteTapped(_ sender: Any) {
        let editVc = self.createEditReflectionModal()
        self.editViewController = editVc
        self.present(editVc, animated: true)
    }
       
    func createCactusGrowingVideo() {
        guard let videoURL =  Bundle.main.url(forResource: "cactus-growing-green-588", withExtension: "mp4") else {
            print("Video not found")
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
        print("Done button tapped")
        self.saveResponse()
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
    
    func saveResponse(nextPageOnSuccess: Bool=true, _ completion: ((ReflectionResponse?, Any?) -> Void)?=nil) {
        //Note: The text must be set on the response object, we will not grab it from here.
        print("saving response...")
        guard let response = self.reflectionResponse else {
            print("No reflection Response found on the ReflectContentCardViewControler. Unable to save the response")
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
        
        self.setSaving(true)
        ReflectionResponseService.sharedInstance.save(response) { (saved, error) in
            if let error = error {
                print("Error saving reflection response", error)
            }
            
            self.setSaving(false)
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
        self.questionTextView.attributedText = MarkdownUtil.centeredMarkdown(questionText, font: CactusFont.large)
        self.view.backgroundColor = CactusColor.lightBlue
        self.reflectionTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.addNoteTapped)))
        self.reflectionTextView.layer.borderWidth = 1
        self.reflectionTextView.layer.cornerRadius = 12
        self.reflectionTextView.layer.borderColor = CactusColor.green.cgColor
        
        self.configureResponseView()
    }

    func configureResponseView() {
        if FormatUtils.isBlank(self.reflectionResponse?.content.text) {
            self.reflectionTextView.isHidden = true
            self.addNoteButton.isHidden = false
        } else {
            self.reflectionTextView.isHidden = false
            self.reflectionTextView.text = self.reflectionResponse?.content.text
            self.addNoteButton.isHidden = true
        }
    }
    
    @objc private func tapGestureHandler() {
        view.endEditing(true)
    }
    
    override func viewWillLayoutSubviews() {
        self.view.backgroundColor = CactusColor.lightBlue
    }
}

extension ReflectContentViewController: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        print("text view did change height")
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension ReflectContentViewController: EditReflectionViewControllerDelegate {
    func done(text: String?) {
        print("Saving text: \(text ?? "None provided")")
        self.reflectionResponse?.content.text = text
        self.configureResponseView()
        self.saveResponse(nextPageOnSuccess: false) { (_, error) in
            self.editViewController?.isSaving = false
            if error == nil {
                self.editViewController?.dismiss(animated: true, completion: {
                    self.delegate?.nextScreen()
                })
            }
        }
    }
    
    func cancel() {
        self.editViewController?.dismiss(animated: true, completion: nil)
    }
}
