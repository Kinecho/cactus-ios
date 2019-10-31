//
//  AppSettings.swift
//  Cactus
//
//  Created by Neil Poulin on 10/31/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
class AppSettings: FlamelinkIdentifiable {    
    static var schema = FlamelinkSchema.appSettings_ios
    var _fl_meta_: FlamelinkMeta?
    var documentId: String?
    var entryId: String?
    var order: Int?
    var firstPromptContentEntryId: String?
}
