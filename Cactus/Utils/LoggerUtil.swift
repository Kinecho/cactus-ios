//
//  LoggerUtil.swift
//  Cactus
//
//  Created by Neil Poulin on 11/8/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
import Sentry
import FirebaseAuth

struct Emoji {
    static let info = "ℹ️"
    static let warning = "⚠️"
    static let error = "🛑"
    static let debug = "🐛"
    static let cactus = "🌵"
    static let siren = "🚨"
    static let exclamation = "❗️"
    static let exclamationDouble = "‼️"
    static let stop = "🛑"
    static let redCircle = "🔴"
    static let redFlag = "🚩"
    static let sweat = "😅"
    static let heartEyes = "😍"
    static let skullAndCrossbones = "☠️"
    static let outbox = "📤"
    static let inbox = "📥"
    static let tada = "🎉"
    static let flame = "🔥"
}

enum LogLevel: Int {
    case debug = 0
    case info = 1
    case warn = 2
    case error = 3
    case severe = 4

}

class Logger {
    static var shared = Logger()
    var fileName: String?
    var functionName: String?
    var logLevel = LogLevel.debug
    let dateFormatter = DateFormatter()
    
    func showLogLevel(_ logLevel: LogLevel) -> Bool {
        return self.logLevel.rawValue <= logLevel.rawValue
    }
    
    static func configureLogging(auth: Auth) {
        Logger.configureSentry(auth: auth)
    }
    
    static func configureSentry(auth: Auth) {
        // Create a Sentry client and start crash handler
        
        SentrySDK.start { options in
            options.dsn = "https://728bdc63f41d4c93a6ce0884a01b58ea@sentry.io/1515431"
            options.debug = true // Enabled debug when first installing is always helpful
            options.releaseName = getReleaseName()
            options.dist = getBuildVersion()
            options.environment = CactusConfig.environment.rawValue
            options.beforeSend = { event in
                guard let user = auth.currentUser else {
                    return event
                }
                
                event.user?.userId = user.uid
                event.user?.email = user.email
                event.user?.username = user.displayName
                
                var tags = event.tags ?? [:]
                if let email = user.email {
                    tags["user.email"] = email
                }
                if let member = CactusMemberService.sharedInstance.currentMember, let memberId = member.id {
                    tags["cactusMemberId"] = memberId
                }
                let providers = user.providerData.map({ $0.providerID })
                if !providers.isEmpty {
                    tags["providerIds"] = providers.joined(separator: ", ")
                }
                event.tags = tags
                return event
            }
        }
    }
    
    convenience init(_ fileName: String?=nil) {
        self.init(fileName: fileName)
    }
    
    init(fileName: String?) {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        self.fileName = fileName
    }
    
    func withFunctionName(_ functionName: String) -> Logger {
        let logger = Logger(self.fileName)
        
        logger.functionName = functionName
        return logger
    }
    
    func tada(_ message: String) {
        self.printLog(message, icon: Emoji.tada)
    }
    
    func custom(_ message: String, icon: String?, fileName: String?=nil, functionName: String?=nil, line: Int?=nil) {
        self.printLog("\(message)", icon: icon, fileName: fileName, functionName: functionName, line: line)
    }
    
    func debug(_ message: String, fileName: String?=nil, functionName: String?=nil, line: Int?=nil) {
        guard self.showLogLevel(LogLevel.debug) else {return}
        self.printLog("\(message)", icon: Emoji.debug, fileName: fileName, functionName: functionName, line: line)
    }
    
    func info(_ message: String, fileName: String?=nil, functionName: String?=nil, line: Int?=nil) {
        guard self.showLogLevel(LogLevel.info) else {return}
        self.printLog("\(message)", icon: Emoji.info, fileName: fileName, functionName: functionName, line: line)
    }
    
    func sentryInfo(_ message: String, fileName: String?=nil, functionName: String?=nil, line: Int?=nil) {
        guard self.showLogLevel(LogLevel.info) else {return}
        self.printLog("\(message)", icon: Emoji.info, fileName: fileName, functionName: functionName, line: line)
        self.sendSentryEvent(message, level: .info, fileName: fileName, functionName: functionName, line: line)
    }
    
    func warn(_ message: String, fileName: String?=nil, functionName: String?=nil, line: Int?=nil) {
        guard self.showLogLevel(LogLevel.warn) else {return}
        self.printLog(message, icon: Emoji.warning, fileName: fileName, functionName: functionName, line: line)
        self.sendSentryEvent(message, level: .warning, fileName: fileName, functionName: functionName, line: line)
    }
    
    func error(_ message: String, _ error: Any?=nil, fileName: String?=nil, functionName: String?=nil, line: Int?=nil) {
        guard self.showLogLevel(LogLevel.error) else {return}
        let errorMessage = "\(message)\n\(String(describing: error))".trimmingCharacters(in: .whitespacesAndNewlines)
        self.printLog(errorMessage, icon: Emoji.error, fileName: fileName, functionName: functionName, line: line)
        self.sendSentryEvent(errorMessage, level: .error, extra: error, fileName: fileName, functionName: functionName, line: line)
   }
    
    func severe(_ message: String, fileName: String?=nil, functionName: String?=nil, line: Int?=nil) {
        guard self.showLogLevel(LogLevel.severe) else {return}
        self.printLog(message, icon: Emoji.exclamationDouble, fileName: fileName, functionName: functionName, line: line)
        let errorMessage = "\(message)\n\(String(describing: error))".trimmingCharacters(in: .whitespacesAndNewlines)
        self.sendSentryEvent(errorMessage, level: .fatal, extra: error, fileName: fileName, functionName: functionName, line: line)
    }
    
    func formatDate(date: Date=Date()) -> String {
        return self.dateFormatter.string(from: date)
    }
    
    fileprivate func fileFuncName() -> String? {
        let names = [self.fileName, self.functionName].compactMap { $0 }
        if names.isEmpty {
            return nil
        }
        
        return names.joined(separator: ".")
    }
    
    func printLog(_ message: String, icon: String?=nil, includeDate: Bool=true) {
        var prefix = "\(Emoji.cactus) \(icon ?? "")".trimmingCharacters(in: .whitespaces)
        if includeDate {
            prefix = "\(prefix) \(self.formatDate())"
        }
        
        if let context = self.fileFuncName() {
            prefix = "\(prefix) | \(context)"
        }
        
        print("\(prefix) | \(message)")
    }
    
    // swiftlint:disable cyclomatic_complexity
    func sendSentryEvent(_ message: String, level: SentryLevel, extra: Any?=nil, fileName: String?=nil, functionName: String?=nil, line: Int?=nil) {
        var prefix = ""
        switch level {
        case .error:
            prefix = "\(Emoji.cactus)\(Emoji.error)"
        case .fatal:
            prefix = "\(Emoji.cactus)\(Emoji.exclamationDouble)"
        case .debug:
            prefix = "\(Emoji.cactus)\(Emoji.debug)"
        case .info:
            prefix = "\(Emoji.cactus)\(Emoji.info)"
        case .warning:
            prefix = "\(Emoji.cactus)\(Emoji.warning)"
        default:
            prefix = "\(Emoji.cactus)"
        }
        
        let contextArray = [fileName ?? self.fileName, functionName ?? self.functionName].compactMap {$0}
        if let context = contextArray.isEmpty ? nil : contextArray.joined(separator: ".") {
            prefix = "\(prefix) [\(context)]"
        }
        
        if let line = line {
            prefix = ":\(line)"
        }
        
        let eventMessage = "\(message)"
//        print("sending sentry event: \(eventMessage)")
        
        let event = Sentry.Event(level: level)
        event.message = eventMessage
        event.environment = CactusConfig.environment.rawValue
        var eventExtra: [String: Any] = [
            "ios": true,
        ]
        
        if let fileName = fileName ?? self.fileName {
            eventExtra["File Name"] = fileName
        }
        
        if let functionName = functionName ?? self.functionName {
            eventExtra["Function Name"] = functionName
        }
        
        if line != nil {
            eventExtra["Line Numbmer"] = line
        }
                
        switch extra {
        case let exception as Exception:
            event.exceptions = [exception]
        case .some(let val):
            eventExtra["error"] = val
        default: break
        }
        
        event.extra = eventExtra
        SentrySDK.capture(event: event)
    }
    // swiftlint:enable cyclomatic_complexity
    
    func printLog(_ message: String, icon: String?=nil, includeDate: Bool=true, fileName: String?=nil, functionName: String?=nil, line: Int?=nil) {
        var prefix = "\(Emoji.cactus)\(icon ?? "")".trimmingCharacters(in: .whitespaces)
        if includeDate {
            prefix = "\(prefix) \(self.formatDate())"
        }
        
        let contextArray = [fileName ?? self.fileName, functionName ?? self.functionName].compactMap {$0}
        
        if let context = contextArray.isEmpty ? nil : contextArray.joined(separator: ".") {
            prefix = "\(prefix) | \(context)"
        }
        
        if let line = line {
            prefix = ":\(line)"
        }
        
        print("[CACTUS] \(prefix) | \(message)")
    }
    
}
