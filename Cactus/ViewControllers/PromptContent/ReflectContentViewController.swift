//
//  ReflectContentViewController.swift
//  Cactus
//
//  Created by Neil Poulin on 9/17/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit
import AVKit

protocol ReflectionContentViewControllerDelegate: class {
    func save(_ response: ReflectionResponse)
    func nextScreen()
}

class ReflectContentViewController: UIViewController {

    let padding: CGFloat = 8
    @IBOutlet weak var videoView: UIView!
    weak var delegate: ReflectionContentViewControllerDelegate?
    var content: Content!
    var promptContent: PromptContent!
    var player: AVPlayer!
    
    var doneButton: PrimaryButton!
    var reflectionResponse: ReflectionResponse?
    
    
    var startTime: Date?
    var endTime: Date?
    
//    @IBOutlet weak var inputToolbar: UIView!
    @IBOutlet weak var questionTextView: UITextView!
    var inputToolbar: UIView!
    var textView: GrowingTextView!
    private var textViewBottomConstraint: NSLayoutConstraint!
    private var doneButtonBottomConstraint: NSLayoutConstraint!
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Get the reflection response, either here or in the parent
        
        self.createInputView()
        self.configureView()
        self.createCactusGrowingVideo()
        if let response = self.reflectionResponse {
            self.textView.text = response.content.text
        } else {
            self.textView.text = nil
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if let video = self.player {
            video.seek(to: CMTime.zero)
            video.play()
        }
        
        self.startTime = Date()
        self.endTime = nil
    }
    
    func createCactusGrowingVideo() {
//        guard let path = Bundle.main.path(forResource: "cactus-growing", ofType: "mp4") else {
//            print("Video not found")
//            return
//        }
        guard let videoURL =  Bundle.main.url(forResource: "cactus-growing-green", withExtension: "mp4") else {
//        guard let videoURL =  Bundle.main.url(forResource: "playdoh-bat", withExtension: "mp4") else {
            print("Video not found")
            return
        }
        let item = AVPlayerItem(url: videoURL)
        let videoFrame = AVMakeRect(aspectRatio: CGSize(width: 1, height: 1), insideRect: self.videoView.bounds)
//        item.videoComposition = createVideoComposition(for: item)
        player = AVPlayer(playerItem: item)
//        player.rate
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoFrame
        self.videoView.clipsToBounds = true
        self.videoView.layer.addSublayer(playerLayer)
        playerLayer.pixelBufferAttributes = [(kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA]

        playerLayer.player?.play()
    }
    
    func getHue(red: CGFloat, green: CGFloat, blue: CGFloat) -> CGFloat {
           let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
           var hue: CGFloat = 0
           color.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
           return hue
       }
    
    func chromaKeyFilter(fromHue: CGFloat, toHue: CGFloat) -> CIFilter? {
        // 1
        let size = 64
        var cubeRGB = [Float]()

        // 2
        for z in 0 ..< size {
            let blue = CGFloat(z) / CGFloat(size-1)
            for y in 0 ..< size {
                let green = CGFloat(y) / CGFloat(size-1)
                for x in 0 ..< size {
                    let red = CGFloat(x) / CGFloat(size-1)

                    // 3
                    let hue = self.getHue(red: red, green: green, blue: blue)
                    let alpha: CGFloat = (hue >= fromHue && hue <= toHue) ? 0: 1

                    // 4
                    cubeRGB.append(Float(red * alpha))
                    cubeRGB.append(Float(green * alpha))
                    cubeRGB.append(Float(blue * alpha))
                    cubeRGB.append(Float(alpha))
                }
            }
        }

        let data = Data(buffer: UnsafeBufferPointer(start: &cubeRGB, count: cubeRGB.count))

        // 5
        let colorCubeFilter = CIFilter(name: "CIColorCube", parameters: ["inputCubeDimension": size, "inputCubeData": data])
        return colorCubeFilter
    }
    
    func filterPixels(foregroundCIImage: CIImage) -> CIImage {
        var hue: CGFloat = 0
        UIColor.white.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        // Remove Green from the Source Image
        let chromaCIFilter = self.chromaKeyFilter(fromHue: hue, toHue: hue)
        chromaCIFilter?.setValue(foregroundCIImage, forKey: kCIInputImageKey)
        let sourceCIImageWithoutBackground = chromaCIFilter?.outputImage
        var image = CIImage()
        if let filteredImage = sourceCIImageWithoutBackground {
            image = filteredImage
        }
        return image
    }
    
    func createVideoComposition(for playerItem: AVPlayerItem) -> AVVideoComposition {
        let composition = AVVideoComposition(asset: playerItem.asset, applyingCIFiltersWithHandler: { request in
            let videoImage = request.sourceImage
            let filteredImage = self.filterPixels(foregroundCIImage: videoImage)
            return request.finish(with: filteredImage, context: nil)
        })
        return composition
    }
    
    func configureDoneButton() {
        self.doneButton = PrimaryButton()
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.showsTouchWhenHighlighted = true
        doneButton.addTarget(self, action: #selector(self.doneAction(_:)), for: .primaryActionTriggered)
        doneButton.setTitle("Done", for: .normal)
        doneButton.isEnabled = true
        doneButton.isUserInteractionEnabled = true
        
        self.view.addSubview(doneButton)

        self.doneButtonBottomConstraint = doneButton.bottomAnchor.constraint(equalTo: inputToolbar.safeAreaLayoutGuide.topAnchor, constant: -padding)
        let doneButtonRightConstraint = doneButton.rightAnchor.constraint(equalTo: inputToolbar.safeAreaLayoutGuide.rightAnchor, constant: -2 * padding)
        let doneButtonLeftConstraint = doneButton.leftAnchor.constraint(greaterThanOrEqualTo: inputToolbar.safeAreaLayoutGuide.leftAnchor, constant: padding)
        NSLayoutConstraint.activate([
            doneButtonBottomConstraint,
            doneButtonRightConstraint,
            doneButtonLeftConstraint,
            ])
        
    }
    @objc func doneAction(_ sender: Any) {
        print("Done button tapped")
        self.saveResponse()
        view.endEditing(true)
        
    }
    
    func setSaving(_ isSaving: Bool) {
        if isSaving {
            doneButton.setTitle("Saving...", for: .disabled)
            doneButton.setEnabled(false)
        } else {
            doneButton.setEnabled(true)
        }
    }
    
    func saveResponse() {
        print("saving response...")
        guard let response = self.reflectionResponse else {
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
        
        let text = self.textView.text
        response.content.text = text
                
        self.setSaving(true)
        ReflectionResponseService.sharedInstance.save(response) { (_, error) in
            if let error = error {
                print("Error saving reflection response", error)
            }
            
            self.setSaving(false)
            if error == nil {
                self.delegate?.nextScreen()
            }
            
        }
    }
    
    func createInputView() {
        // *** Create Toolbar
        self.inputToolbar = UIView()
        inputToolbar.backgroundColor = self.view.backgroundColor
        inputToolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputToolbar)
        
        // *** Create GrowingTextView ***
        textView = GrowingTextView()
        textView.delegate = self
        textView.layer.cornerRadius = 12.0
        textView.maxHeight = 300
        textView.trimWhiteSpaceWhenEndEditing = true
        textView.placeholder = "Say something..."
        textView.layer.borderWidth = 1
        textView.layer.borderColor = CactusColor.green.cgColor
//        textView.contentInset = UIEdgeInsets(top: 10, left: 6, bottom: 10, right: 6)
        textView.placeholderColor = UIColor(white: 0.8, alpha: 1.0)
        textView.font = CactusFont.normal
        textView.textColor = .black
        textView.backgroundColor = .white
        textView.translatesAutoresizingMaskIntoConstraints = false
        inputToolbar.addSubview(textView)
        
        self.configureDoneButton()
        
        // *** Autolayout ***
        let topConstraint = textView.topAnchor.constraint(equalTo: inputToolbar.topAnchor, constant: padding)
        topConstraint.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate([
            inputToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputToolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            topConstraint,
            ])
        
        if #available(iOS 11, *) {
            textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: inputToolbar.safeAreaLayoutGuide.bottomAnchor, constant: -8)
            NSLayoutConstraint.activate([
                textView.leadingAnchor.constraint(equalTo: inputToolbar.safeAreaLayoutGuide.leadingAnchor, constant: padding),
                textView.trailingAnchor.constraint(equalTo: inputToolbar.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
                textViewBottomConstraint,
                ])
        } else {
            textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: inputToolbar.bottomAnchor, constant: -padding)
            NSLayoutConstraint.activate([
                textView.leadingAnchor.constraint(equalTo: inputToolbar.leadingAnchor, constant: padding),
                textView.trailingAnchor.constraint(equalTo: inputToolbar.trailingAnchor, constant: -padding),
                textViewBottomConstraint,
                ])
        }
        
        // *** Listen to keyboard show / hide ***
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // *** Hide keyboard when tapping outside ***
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandler))
//        tapGesture.end
//        view.addGestureRecognizer(tapGesture)
    }
    
    func configureView() {
        let questionText = !FormatUtils.isBlank(content.text_md) ? content.text_md : content.text
        self.questionTextView.attributedText = MarkdownUtil.centeredMarkdown(questionText, font: CactusFont.large)
        self.view.backgroundColor = CactusColor.lightBlue
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if #available(iOS 11, *) {
                if keyboardHeight > 0 {
                    keyboardHeight -= view.safeAreaInsets.bottom
                }
            }
            textViewBottomConstraint.constant = -keyboardHeight - padding
//            doneButtonBottomConstraint.constant = -keyboardHeight - padding
            view.layoutIfNeeded()
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
