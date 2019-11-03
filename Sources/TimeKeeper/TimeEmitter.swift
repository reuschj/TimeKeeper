//
//  TimeEmitter.swift
//  AnalogClock
//
//  Created by Justin Reusch on 9/30/19.
//  Copyright © 2019 Justin Reusch. All rights reserved.
//

import SwiftUI
import Combine

/**
 Emits the current time and clock hand position at the specified time interval
 */
public class TimeEmitter: ObservableObject, Timed, Updatable, Hashable {
    
    /// The current time to emit with accessors to all time components
    @Published public var time: TimeKeeper
    
    /// Outputs hand rotation to emit in degrees or radians
    @Published public var handController: ClockHandController!
    
    /// The time interval on which to emit the current time and hand rotations
    public var interval: TimeInterval {
        didSet { updateTimerInterval(to: interval) }
    }
    
    /// A timer that will drive the updates
    private var timer: Timer!
    
    /**
     Initializer specifying the interval directly
     - Parameters:
     - interval: The interval which the emitter will update the current time and date
     - rotationOutput: The desired rotation output unit, degrees or radians
     */
    public init(updatedEvery interval: TimeInterval = defaultTickInterval, rotationOutput: RotationUnit = .degrees) {
        self.interval = interval
        time = TimeKeeper()
        handController = nil
        handController = ClockHandController(using: time, output: rotationOutput)
        startTimer()
    }
    
    /**
     Starts the timer with the specified interval and sets it's update action
     - Parameters:
     - interval: The interval which the emitter will update the current time and date
     */
    func startTimer(withTimeInterval interval: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            self?.update()
        }
    }
    
    /**
     Starts the timer using the interval property specified in this class
     - Parameters:
     - interval: The interval which the emitter will update the current time and date
     */
    func startTimer() {
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
    func stopTimer() {
        timer?.invalidate()
    }
    
    /// Updates the time and emits
    func update() {
        time.update()
        objectWillChange.send()
    }
    
    /// Hash method
    public func hash(into hasher: inout Hasher) {
        hasher.combine(interval)
    }
    
    /// Equatable method
    public static func == (lhs: TimeEmitter, rhs: TimeEmitter) -> Bool {
        lhs.interval == rhs.interval
    }
}