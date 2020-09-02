//
//  FlamelinkTypes.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 9/10/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation

class FlamelinkFile: Codable {
    static let logger = Logger("FlamelinkFile")
    var fileIds: [String] = []
    var fileId: String? {
        get {
            return fileIds.first
        }
        set {
            fileIds.removeAll()
            if let fileId = newValue {
                fileIds.append(fileId)
            }
        }
    }
    
    var isEmpty: Bool {
        isBlank(fileId) && fileIds.isEmpty
    }

    enum CodingKeys: String, CodingKey {
        case fileIds
    }
    
    public init() {
        
    }
    
    public required init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let idArray = try? container.decode([String].self, forKey: CodingKeys.fileIds)
            
            if let ids = idArray {
                self.fileIds = ids
                return
            }
            let fileIdString = try? container.decode(String.self, forKey: .fileIds)
            if let fileId = fileIdString, !fileId.isEmpty {
                self.fileIds.append(fileId)
            }
        } catch {
//            FlamelinkFile.logger.error("error decoding FlamelinkFile", error)
        }
    }
}

class VideoFile: FlamelinkFile {
    var youtubeVideoId: String?
    var url: String?
    
    override var isEmpty: Bool {
        super.isEmpty && isBlank(youtubeVideoId) && isBlank(url)
    }
    
    enum VideoCodingKeys: String, CodingKey {
        case youtubeVideoId
        case url
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        do {
            let container = try decoder.container(keyedBy: VideoCodingKeys.self)
            self.url = try? container.decode(String.self, forKey: VideoCodingKeys.url)
            self.youtubeVideoId = try? container.decode(String.self, forKey: VideoCodingKeys.youtubeVideoId)
            
        } catch {
//            FlamelinkFile.logger.error("error init VideoFile", error)
        }
    }
}

class AudioFile: FlamelinkFile {
    var url: String?
    
    override var isEmpty: Bool {
        super.isEmpty && isBlank(url)
    }
}

class ImageFile: FlamelinkFile {
    var url: String?
    var storageUrl: String?
    var allowDarkModeInvert: Bool? = false
    
    override var isEmpty: Bool {
        super.isEmpty && FormatUtils.isBlank(self.url) && FormatUtils.isBlank(storageUrl) && FormatUtils.isBlank(self.fileId) && self.fileIds.isEmpty
    }
    
    enum ImageCodingKeys: String, CodingKey {
        case fileIds
        case url
        case storageUrl
        case allowDarkModeInvert
    }
    
    convenience init(storageUrl: String?=nil) {
        self.init(url: nil, storageUrl: storageUrl)
    }
    
    init(url: String?=nil, storageUrl: String?=nil) {
        super.init()
        self.url = url
        self.storageUrl = storageUrl
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        do {            
            let container = try decoder.container(keyedBy: ImageCodingKeys.self)
            self.url = try? container.decode(String.self, forKey: ImageCodingKeys.url)
            self.storageUrl = try? container.decode(String.self, forKey: ImageCodingKeys.storageUrl)
            self.allowDarkModeInvert = try? container.decode(Bool.self, forKey: ImageCodingKeys.allowDarkModeInvert)
        } catch {
//            FlamelinkFile.logger.error("error decoding ImageFile", error)
        }
    }
}
