//
//  TimeKeeper.swift
//  TimeKeeper
//
//  Created by Justin Reusch on 2/5/19.
//  Copyright © 2019 Justin Reusch. All rights reserved.
//

import Foundation
import DecimalTime

/**
 A class to hold a time and date that updates itself on a regular interval
 */
public class TimeKeeper: Timed, Updatable, CustomStringConvertible {
    
    /// Stores the current date
    public private(set) var date: Date
    
    /// The stored system calendar
    public let calendar: Calendar
    
    /// The timer which will drive any updates
    private var timer: Timer?
    
    /// Decimal time - Will not be initialized unless called for
    public lazy var decimalTime: DecimalTime? = { [unowned self] in
        self.decimalTimeInitialized = true
        return DecimalTime(from: self.date, using: self.calendar)!
    }()
    // The two properties below provide an internal way to access the decimal time without initializing it
    private var decimalTimeInitialized: Bool = false
    // When not not initialized, this property will be `nil` and will _not_ initialize the time. After initialization, this will return the decimal time
    private var _decimalTime: DecimalTime? {
        get {
            guard decimalTimeInitialized else { return nil }
            return self.decimalTime
        }
        set { if let newValue = newValue { self.decimalTime = newValue } }
    }
    
    /// Computed property extracting date components from the current date based on the current calendar
    private var dateComponents: DateComponents {
        calendar.dateComponents([.year,.month,.day,.weekday,.hour,.minute,.second,.nanosecond], from: date)
    }
    
    /*
     Year
     -----------------------------------------------
     */
    
    /// The current year
    public var year: Int? { dateComponents.year }
    
    /*
     Month
     -----------------------------------------------
     */
    
    /// The current month (numerical)
    public var month: Int? { dateComponents.month }
    
    /// The current month as a full-length string, using the current locale and capitalized
    public var monthName: String? {
        guard let month = month else { return nil }
        let index = month - 1
        guard index >= 0 && index < calendar.monthSymbols.count else { return nil }
        return calendar.monthSymbols[index].capitalized
    }
    
    /// The current month as a short string, using the current locale and capitalized
    public var monthNameShort: String? {
        guard let month = month else { return nil }
        let index = month - 1
        guard index >= 0 && index < calendar.shortMonthSymbols.count else { return nil }
        return calendar.shortMonthSymbols[index].capitalized
    }
    
    /*
     Day
     -----------------------------------------------
     */
    
    /// The current day of the month
    public var day: Int? { dateComponents.day }
    
    /// The current weekday as an integer, starting with 1 as Sunday
    public var weekday: Int? { dateComponents.weekday }
    
    /// The current weekday name as a full-length string, using the current locale and capitalized
    public var weekdayName: String? {
        guard let weekday = weekday else { return nil }
        let index = weekday - 1
        guard index >= 0 && index < calendar.weekdaySymbols.count else { return nil }
        return calendar.weekdaySymbols[index].capitalized
    }
    
    /// The current weekday name as a short string, using the current locale and capitalized
    public var weekdayNameShort: String? {
        guard let weekday = weekday else { return nil }
        let index = weekday - 1
        guard index >= 0 && index < calendar.shortWeekdaySymbols.count else { return nil }
        return calendar.shortWeekdaySymbols[index].capitalized
    }
    
    /*
     Date
     -----------------------------------------------
     */
    
    /// A date string with month, day and year, formatted using the current locale
    public var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let day = weekdayName ?? ""
        return "\(day)\(day.isEmpty ? "" : ", ")\(formatter.string(from: date))"
    }
    
    /// A date string with month, day and year, formatted using the current locale
    public var description: String { dateString }
    
    /*
     Hours
     -----------------------------------------------
     */
    
    /// The current hour
    public var hour: Int? { dateComponents.hour }
    
    /// The current hour for a 12-hour clock
    public var hour12: Int? {
        guard let hour = dateComponents.hour else { return nil }
        if hour == 0 {
            return 12
        } else if hour <= 12 {
            return hour
        } else {
            return hour % 12
        }
    }
    
    /// The current hour for a 12-hour clock, converted to a `String`
    public var hour12String: String? {
        guard let hour12 = hour12 else { return nil }
        return String(hour12)
    }
    
    // 24 hour ------ /
    
    /// The current hour for a 24-hour clock
    public var hour24: Int? { dateComponents.hour }
    
    /// The current hour for a 24-hour clock, converted to a padded, 2-digit `String`
    public var hour24String: String? {
        guard let hour24 = hour24 else { return nil }
        return padTimeUnit(hour24)
    }
    
    // Decimal hour ------ /
    
    /// The current hour for a decimal clock
    public var hourDecimal: Int? { decimalTime?.hours }
    
    /// The current hour for a decimal clock, converted to a padded, 2-digit `String`
    public var hourDecimalString: String? {
        guard let hourDecimal = hourDecimal else { return nil }
        return padTimeUnit(hourDecimal)
    }
    
    /*
     Period
     -----------------------------------------------
     */
    
    /// The current period on a 12-hour clock, AM or PM
    public var period: Period? {
        guard let hour = dateComponents.hour else { return nil }
        return hour >= 0 && hour < 12 ? .am : .pm
    }
    
    /// The current period on a 12-hour clock, AM or PM, formatted as a  `String` using the current locale
    public var periodString: String? {
        guard let period = period else { return nil }
        return period == .am ? calendar.amSymbol : calendar.pmSymbol
    }
    
    /*
     Minute
     -----------------------------------------------
     */
    
    /// The current minute
    public var minute: Int? { dateComponents.minute }
    
    /// The current minute, converted to a padded, 2-digit `String`
    public var paddedMinute: String? {
        guard let minute = minute else { return nil }
        return padTimeUnit(minute)
    }
    
    // Decimal minute ------ /
    
    /// The current minute for a decimal clock
    public var minuteDecimal: Int? { decimalTime?.minutes }
    
    /// The current decimal minute, converted to a padded, 2-digit `String`
    public var paddedDecimalMinute: String? {
        guard let minuteDecimal = minuteDecimal else { return nil }
        return padTimeUnit(minuteDecimal)
    }
    
    /*
     Second
     -----------------------------------------------
     */
    
    /// The current second
    public var second: Int? { dateComponents.second }
    
    /// The current second, converted to a padded, 2-digit `String`
    public var paddedSecond: String? {
        guard let second = second else { return nil }
        return padTimeUnit(second)
    }
    
    // Precise second ------ /
    
    /// The current second plus nanoseconds
    public var preciseSecond: Double? {
        Double(dateComponents.second ?? 0) + (Double(dateComponents.nanosecond ?? 0) / 1_000_000_000)
    }
    
    /// The current second plus nanoseconds, converted to a rounded, 2-digit, padded `String`
    public var paddedPreciseSecond: String? {
        guard let preciseSecond = preciseSecond else { return nil }
        return padTimeUnit(Int(round(preciseSecond)))
    }
    
    // Decimal second ------ /
    
    /// The current decimal  second
    public var secondDecimal: Int? { decimalTime?.seconds }
    
    /// The current decimal  second, converted to a padded, 2-digit `String`
    public var paddedDecimalSecond: String? {
        guard let secondDecimal = secondDecimal else { return nil }
        return padTimeUnit(secondDecimal)
    }
    
    // Precise decimal second ------ /
    
    /// The current decimal second with remainder
    public var preciseSecondDecimal: Double? { decimalTime?.secondsWithRemainder }
    
    /// The current decimal second with remainder, converted to a rounded, 2-digit, padded `String`
    public var paddedPreciseDecimalSecond: String? {
        guard let preciseSecondDecimal = preciseSecondDecimal else { return nil }
        return padTimeUnit(Int(round(preciseSecondDecimal)))
    }
    
    /*
     Milliseconds
     -----------------------------------------------
     */
    
    /// The current milliseconds
    public var millisecond: Int? {
        guard let nanosecond = nanosecond else { return nil }
        return nanosecond / 1_000_000
    }
    
    /// The current decimal  milliseconds
    public var millisecondDecimal: Int? { decimalTime?.milliseconds }
    
    // Decimal millisecond ------ /
    
    /*
     Nanoseconds
     -----------------------------------------------
     */
    
    /// The current nanoseconds
    public var nanosecond: Int? { dateComponents.nanosecond }
    
    // Decimal nanosecond ------ /
    
    /// The current decimal  nanoseconds
    public var nanosecondDecimal: Int? { decimalTime?.nanoseconds }
    
    /*
     Other
     -----------------------------------------------
     */
    
    /// Every second alternates between tick and tock
    public var tickTock: TickTock? {
        guard let second = dateComponents.second else { return nil }
        return (second != 0 && second % 2 == 0) ? .tick : .tock
    }
    
    // Decimal tick-tock ------ /
    
    /// Every second alternates between tick and tock (for decimal time)
    public var tickTock: TickTock? {
        guard let second = decimalTime?.seconds else { return nil }
        return (second != 0 && second % 2 == 0) ? .tick : .tock
    }
    
    
    /*
     Initializers
     -----------------------------------------------
     */
    
    /// Initializer without own timer
    public init() {
        timer = nil
        date = Date()
        calendar = Calendar.current
    }
    
    /**
     Initializer with own timer
     - Parameter interval: The interval which the emitter will update the current time and date
     */
    public init(updatedEvery interval: TimeInterval = defaultTickInterval) {
        date = Date()
        calendar = Calendar.current
        timer = nil
        startTimer(withTimeInterval: interval)
    }
    
    /*
     Methods
     -----------------------------------------------
     */
    
    /**
     Called to update time, this refreshes the date property with the current date
     Will be called every time the timer fires, or can be called from an external `Timer`
     */
    public func update() {
        date = Date()
        _decimalTime?.setTime(from: date, using: calendar)
    }
    
    /**
     Creates a timer
     - Parameter interval: The interval which the emitter will update the current time and date
     */
    public func startTimer(withTimeInterval interval: TimeInterval) {
        timer?.invalidate()
        if #available(iOS 10.0, *), #available(OSX 10.12, *) {
            print("Started timer")
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { [weak self] timer in
                self?.update()
            })
        } else {
            // Fallback on earlier versions
            print("Started timer with legacy")
            timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        }
    }
    
    /*
     Timer methods
     -----------------------------------------------
     */
    
    /// Creates a timer
    public func startTimer() {
        startTimer(withTimeInterval: defaultTickInterval)
    }
    
    /// Stops the timer
    public func stopTimer() {
        timer?.invalidate()
    }
    
    /**
     Called every time the timer fires, this refreshes the date property with the current date
     */
    @objc public func updateTimer() {
        self.update()
    }
    
}
