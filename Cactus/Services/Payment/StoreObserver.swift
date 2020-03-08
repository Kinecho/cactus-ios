//
//  StoreObserver.swift
//  Cactus
//
//  Created by Neil Poulin on 2/7/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import Foundation
import StoreKit
import UIKit

class StoreObserver: NSObject, SKPaymentTransactionObserver {
    let logger = Logger("StoreObserver")
    static var sharedInstance = StoreObserver()
    //Initialize the store observer.
    override init() {
        super.init()
        //Other initialization here.
    }
    
    func submitPayment() {
        //        self.
    }
    
    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    //Observe transaction updates.
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        //Handle transaction states here.
        logger.info("Processing \(transactions.count) Payment transactions from queue ")
        transactions.forEach { t in
            self.handleUpdatedTransaction(t)
        }
        
        //        logger.info("processed transactions")
    }
    
    func handleUpdatedTransaction(_ transaction: SKPaymentTransaction) {
        //        self.logger.info("\(String(describing: transaction))")
//        self.logger.info("Transaction identifier: \(transaction.transactionIdentifier ?? "no identifier")" )
        switch transaction.transactionState {
        case .purchasing: self.handlePurchasing(transaction)
        case .purchased: self.handlePurchased(transaction)
        case .failed: self.handleFailed(transaction)
        case .restored: self.handleRestored(transaction)
        case .deferred: self.handleDeferred(transaction)
        @unknown default:
            self.logger.error("Unknown...")
        }
    }
    
    func handlePurchasing(_ transaction: SKPaymentTransaction) {
        self.logger.info("Transaction State: Purchasing...")
    }
    
    func handlePurchased(_ transaction: SKPaymentTransaction) {
        self.logger.info("Handling purchased transaction")
        SubscriptionService.sharedInstance.verifyReceipt { (result) in
            guard let result = result else {
                self.logger.error("Failed to verify the receipt. Not removing the transaction from the queue")
                //TOOD: show error?
                return
            }
            if !result.success {
                self.logger.error("The receipt was not valid.... might need to do something different here, not removing from queue")
            } else {
                self.logger.info("Payment transactoin success. removing from queue")
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    func handleFailed(_ transaction: SKPaymentTransaction) {
        self.logger.info("Handle failed transaction")
        if let error = transaction.error {
//            message += "\n\(Messages.error) \(error.localizedDescription)"
            self.logger.error("\(error.localizedDescription)", error)
        }
        
        // Do not send any notifications when the user cancels the purchase.
        if (transaction.error as? SKError)?.code != .paymentCancelled {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Purchase Failed", message: "Unable to complete purchase. \(transaction.error?.localizedDescription ?? "")", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                NavigationService.sharedInstance.present(alert)
            }
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func handleRestored(_ transaction: SKPaymentTransaction) {
        self.logger.info("Transaction State: Restored...")                
        SubscriptionService.sharedInstance.verifyReceipt { (result) in
            guard let result = result else {
                self.logger.error("Failed to verify the receipt. Not removing the transaction from the queue")
                //TOOD: show error?
                return
            }
            if !result.success {
                self.logger.error("The receipt was not valid.... might need to do something different here, not removing from queue")
            } else {
                self.logger.info("Payment transactoin success. removing from queue")
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    func handleDeferred(_ transaction: SKPaymentTransaction) {
        self.logger.info("Transaction State: Deferred...")
    }        
}
