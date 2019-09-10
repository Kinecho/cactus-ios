//
//  FlamelinkTypes.swift
//  Cactus Stage
//
//  Created by Neil Poulin on 9/10/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation

class FlamelinkFile:Codable {
    var fileIds: [String] = [];
    var fileId:String? {
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
    
    public required init(from decoder: Decoder) throws {
        let fileIdString = try? decoder.singleValueContainer().decode(String.self)
        if let fileId = fileIdString, !fileId.isEmpty {
            self.fileIds.append(fileId)
        }
    }
}

class VideoFile:FlamelinkFile {
    var youtubeVideoId: String?
    var url: String?
}

class AudioFile:FlamelinkFile {
    var url: String?;
}

class ImageFile:FlamelinkFile {
    var url:String?;
    var storageUrl:String?;
}
