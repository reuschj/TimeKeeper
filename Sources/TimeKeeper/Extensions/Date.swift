//
//  Date.swift
//  
//
//  Created by Justin Reusch on 5/1/20.
//

import Foundation

extension Date {
    
    /// Gets date components from date using a calendar
    func dateComponents(_ components: Set<Calendar.Component>, from calendar: Calendar = Calendar.current) -> DateComponents {
        calendar.dateComponents(components, from: self)
    }
}
