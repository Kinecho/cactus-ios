//
//  ImageService.swift
//  Cactus
//
//  Created by Neil Poulin on 9/17/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import Cloudinary
import SwiftyGif

class ImageService {
    static var shared = ImageService()
    
    let cloudinary: CLDCloudinary
    init() {
        let config = CLDConfiguration(cloudName: "cactus-app", secure: true)
        self.cloudinary = CLDCloudinary(configuration: config)
    }
    
    func setStorageUrl(_ imageView: UIImageView, url: String) {
        guard let _url = cloudinary.createUrl().setType(.fetch).setFormat("png").generate(url) else {
            imageView.isHidden = true
            return
        }
        
        if FileUtils.isGif(url) {
            setGif(imageView, url)
        } else {
            imageView.cldSetImage(_url, cloudinary: self.cloudinary)
            imageView.isHidden = false
        }
    }
    
    func setGif(_ imageView: UIImageView, _ gifUrl: String) {
        guard FileUtils.isGif(gifUrl), let url = URL(string: gifUrl) else {
            imageView.isHidden = true
            return
        }
        
        imageView.setGifFromURL(url)
        imageView.startAnimatingGif()

        imageView.isHidden = false
    }
    
    func setFromUrl(_ imageView: UIImageView, url: String) {
        if FileUtils.isGif(url) {
            setGif(imageView, url)
        } else {
            imageView.cldSetImage(url, cloudinary: self.cloudinary)
            imageView.isHidden = false
        }
    }
    
    func setFromUrl(_ imageView: UIImageView, url: URL) {
        let url = url.absoluteString
        if FileUtils.isGif(url) {
            setGif(imageView, url)
        } else {            
            imageView.cldSetImage(url, cloudinary: self.cloudinary)
            imageView.isHidden = false
        }
    }
    
    func setPhoto(_ imageView: UIImageView, photo: ImageFile?) {
        guard let photo = photo else {
            imageView.isHidden = true
            return
        }
        
        print("Download Image - storageUrl", photo.storageUrl ?? "none")
        print("Download Image - url", photo.url ?? "none")
        
        if let storageUrl = photo.storageUrl, !storageUrl.isEmpty {
            print("Downloading image with storageURL \(storageUrl)")
            setStorageUrl(imageView, url: storageUrl)
            imageView.isHidden = false
        } else if let url = photo.url, !FormatUtils.isBlank(url) {
            self.setFromUrl(imageView, url: url)
        } else {
            print("Image type not handled")
            imageView.isHidden = true
        }
    }
}
