//
//  CountProcess.swift
//  Cactus
//
//  Created by Neil Poulin on 10/1/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import Foundation
class CountProcess {

    let minValue: Int
    let maxValue: Int
    var currentValue: Int
    var duration: UInt32?
    var maxDuration: UInt32?
    
    //TODO: Do we really need to use semaphors here? 
    private let progressQueue: DispatchQueue
    private let semaphore: DispatchSemaphore

    init (minValue: Int, maxValue: Int, name: String, threads: Int = 1) {
        self.minValue = minValue
        self.currentValue = minValue
        self.maxValue = maxValue
        self.progressQueue = DispatchQueue(label: name, attributes: .concurrent)
        self.semaphore = DispatchSemaphore(value: threads)
    }

    private func delay(stepDelayUsec: useconds_t, completion: @escaping () -> Void) {
        usleep(stepDelayUsec)
        DispatchQueue.main.async {
            completion()
        }
    }

    func simulateLoading(toValue: Int, step: Int = 1, stepDelayUsec: useconds_t? = 10_000,
                         valueChanged: @escaping (_ currentValue: Int) -> Void,
                         completion: ((_ currentValue: Int) -> Void)? = nil) {

        semaphore.wait()
        progressQueue.async {
            if self.currentValue <= toValue && self.currentValue <= self.maxValue {
                usleep(stepDelayUsec!)
                DispatchQueue.main.async {
                    valueChanged(self.currentValue)
                    self.currentValue += step
                    self.semaphore.signal()
                    self.simulateLoading(toValue: toValue, step: step, stepDelayUsec: stepDelayUsec, valueChanged: valueChanged, completion: completion)
                }

            } else {
                self.semaphore.signal()
                completion?(self.currentValue)
            }
        }
    }

    func finish(step: Int = 1,
                stepDelayUsec: useconds_t = 10_000,
                valueChanged: @escaping (_ currentValue: Int) -> Void,
                completion: ((_ currentValue: Int) -> Void)? = nil) {
        
        let numSteps = UInt32((self.maxValue - self.minValue) / step)
        var delay = stepDelayUsec
        
        if let duration = self.duration {
            delay = UInt32(duration / numSteps) * 1000
        }
        
        if let maxDuration = self.maxDuration {
            delay = min(UInt32(maxDuration / numSteps) * 1000, delay)
        }
        
        let actualDelay = delay
        
        simulateLoading(toValue: maxValue, step: step, stepDelayUsec: actualDelay, valueChanged: valueChanged, completion: completion)
    }
}
