//
//  TimeEmitter.swift
//  TimeKeeper
//
//  Created by Justin Reusch on 9/30/19.
//  Copyright © 2019 Justin Reusch. All rights reserved.
//

import SwiftUI
import Combine

/**
 Emits the current time at the specified time interval
 */
@available(OSX 10.15, *)
@available(iOS 13.0, *)
@available(watchOS 6.0, *)
public class TimeEmitter: IntervalEmitter {
    
    /// The current time to emit with accessors to all time components
    @Published public var time: TimeKeeper
    
    /// The time interval on which to emit the current time and hand rotations
    public var interval: TimeInterval {
        didSet { updateTimerInterval(to: interval) }
    }
    
    /// A timer that will drive the updates
    public var timer: Timer!
    
    /**
     Initializer specifying the interval directly
     - Parameters:
        - interval: The interval which the emitter will update the current time and date
     */
    public init(updatedEvery interval: TimeInterval = defaultTickInterval) {
        self.timer = nil
        self.interval = interval
        self.time = TimeKeeper()
        self.startTimer()
    }
    
    /// Updates the time and emits
    public func update() {
        time.update()
        objectWillChange.send()
    }
    
    /// Equatable method
    public static func == (lhs: TimeEmitter, rhs: TimeEmitter) -> Bool {
        lhs.interval == rhs.interval
    }
}
