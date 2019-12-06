//
//  ImageService.swift
//  Cactus
//
//  Created by Neil Poulin on 9/17/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import Cloudinary
//import SwiftyGif

class ImageService {
    static var shared = ImageService()
    let logger = Logger("ImageService")
    let cloudinary: CLDCloudinary
    init() {
        let config = CLDConfiguration(cloudName: "cactus-app", secure: true)
        self.cloudinary = CLDCloudinary(configuration: config)
    }
    
    func setStorageUrl(_ imageView: UIImageView, url: String, gifDelegate: SwiftyGifDelegate?=nil) {
        guard let _url = cloudinary.createUrl().setType(.fetch).setFormat("png").generate(url) else {
            imageView.isHidden = true
            return
        }
        
        if FileUtils.isGif(url) {
            setGif(imageView, url, delegate: gifDelegate)
        } else {
            imageView.cldSetImage(_url, cloudinary: self.cloudinary)
//            imageView.isHidden = false
        }
    }
    
    func setGif(_ imageView: UIImageView, _ gifUrl: String, delegate: SwiftyGifDelegate?=nil) {
        guard FileUtils.isGif(gifUrl), let url = URL(string: gifUrl) else {
            imageView.isHidden = true
            return
        }
        
        imageView.delegate = delegate ?? self
        imageView.setGifFromURL(url)
        imageView.startAnimatingGif()
        
    }
    
    func setFromUrl(_ imageView: UIImageView, url: String, gifDelegate: SwiftyGifDelegate?=nil) {
        if FileUtils.isGif(url) {
            setGif(imageView, url, delegate: gifDelegate)
        } else {
            imageView.cldSetImage(url, cloudinary: self.cloudinary)
            imageView.isHidden = false
        }
    }
    
    func setFromUrl(_ imageView: UIImageView, url: URL, gifDelegate: SwiftyGifDelegate?=nil) {
        let url = url.absoluteString
        if FileUtils.isGif(url) {
            setGif(imageView, url, delegate: gifDelegate)
        } else {            
            imageView.cldSetImage(url, cloudinary: self.cloudinary)
            imageView.isHidden = false
        }
    }
    
    func setPhoto(_ imageView: UIImageView, photo: ImageFile?, gifDelegate: SwiftyGifDelegate?=nil) {
        guard let photo = photo else {
            imageView.isHidden = true
            return
        }
        
        guard !photo.isEmpty else {
            imageView.isHidden = true
            return
        }
        
        if let storageUrl = photo.storageUrl, !storageUrl.isEmpty {
            setStorageUrl(imageView, url: storageUrl, gifDelegate: gifDelegate)
            imageView.isHidden = false
        } else if let url = photo.url, !FormatUtils.isBlank(url) {
            self.setFromUrl(imageView, url: url, gifDelegate: gifDelegate)
            imageView.isHidden = false
        } else {
            imageView.isHidden = true
        }
    }
}

extension ImageService: SwiftyGifDelegate {
    func gifURLDidFail(sender: UIImageView, url: URL, error: Error?) {
        self.logger.error("Gif URL failed to load \(url)", String(describing: error))
    }
}
