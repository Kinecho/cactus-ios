//
//  FormatUtils.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation


struct FormatUtils {
    static func formatDate(_ date: Date?, currentYearFormat: String="MMMM d", previousYearFormat: String="MMM d, yyyy") -> String?{
        var dateString:String?
        if let date = date {
            let df = DateFormatter()
            let calendar = Calendar.current
            let dateYear = calendar.component(.year, from: date)
            let currentYear = calendar.component(.year, from: Date())
            if currentYear > dateYear {
                df.dateFormat = previousYearFormat
            } else {
                df.dateFormat = currentYearFormat
            }
            
            dateString = df.string(from: date)
        }
        return dateString
    }
}
