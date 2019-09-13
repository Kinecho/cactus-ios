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
    }
}

class VideoFile: FlamelinkFile {
    var youtubeVideoId: String?
    var url: String?
}

class AudioFile: FlamelinkFile {
    var url: String?
}

class ImageFile: FlamelinkFile {
    var url: String?
    var storageUrl: String?
}
