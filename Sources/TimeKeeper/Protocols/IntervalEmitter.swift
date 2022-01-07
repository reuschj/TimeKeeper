//
//  IntervalEmitter.swift
//  TimeKeeper
//
//  Created by Justin Reusch on 11/3/19.
//  Copyright © 2019 Justin Reusch. All rights reserved.
//

import SwiftUI
import Combine

/**
 A protocol to define common characteristics of an emitter that emits according to an interval
 */
@available(OSX 10.15, *)
@available(iOS 13.0, *)
@available(watchOS 6.0, *)
public protocol IntervalEmitter: ObservableObject, Timed, Updatable, Hashable {
    
    /// The time interval on which to emit the current time and hand rotations
    var interval: TimeInterval { get set }
    
    /// A timer that will drive the updates
    var timer: Timer! { get set }
}

/**
 Default method implementations for `IntervalEmitter`
 */
@available(OSX 10.15, *)
@available(iOS 13.0, *)
@available(watchOS 6.0, *)
extension IntervalEmitter {
    /**
     Starts the timer with the specified interval and sets it's update action
     - Parameters:
        - interval: The interval which the emitter will update the current time and date
     */
    public func startTimer(withTimeInterval interval: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { [weak self] timer in
            self?.update()
        })
    }
    
    /**
     Starts the timer using the interval property specified in this class
     - Parameters:
        - interval: The interval which the emitter will update the current time and date
     */
    public func startTimer() {
        startTimer(withTimeInterval: interval)
    }
    
    /**
     Changes the time interval (by restarting the timer)
     - Parameters:
        - interval: The interval which the emitter will update the current time and date
     */
    public func updateTimerInterval(to interval: TimeInterval) {
        startTimer(withTimeInterval: interval)
    }
    
    /// Stops the timer
    public func stopTimer() {
        timer?.invalidate()
    }
    
    /// Hash method
    public func hash(into hasher: inout Hasher) {
        hasher.combine(interval)
    }
}
