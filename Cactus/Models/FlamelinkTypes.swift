//
//  FlamelinkTypes.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 9/10/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation

class FlamelinkFile: Codable {
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
    
    enum CodingKeys: String, CodingKey {
        case fileIds
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
            Logger.shared.error("error decoding FlamelinkFile", error)
        }
    }
}

class VideoFile: FlamelinkFile {
    var youtubeVideoId: String?
    var url: String?
    
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
            print("error init VideoFile", error)
        }
    }
}

class AudioFile: FlamelinkFile {
    var url: String?
}

class ImageFile: FlamelinkFile {
    var url: String?
    var storageUrl: String?
//    var allowDarkModeInvert: Bool? = false
    
    enum ImageCodingKeys: String, CodingKey {
        case fileIds
        case url
        case storageUrl
//        case allowDarkModeInvert
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        do {            
            let container = try decoder.container(keyedBy: ImageCodingKeys.self)
            self.url = try? container.decode(String.self, forKey: ImageCodingKeys.url)
            self.storageUrl = try? container.decode(String.self, forKey: ImageCodingKeys.storageUrl)
//            self.allowDarkModeInvert = try? container.decode(Bool.self, forKey: ImageCodingKeys.allowDarkModeInvert)
        } catch {
            Logger.shared.error("error decoding ImageFile", error)
        }
    }
    
    func isEmpty() -> Bool {
        return FormatUtils.isBlank(self.url) && FormatUtils.isBlank(storageUrl) && FormatUtils.isBlank(self.fileId) && self.fileIds.isEmpty
    }
}
