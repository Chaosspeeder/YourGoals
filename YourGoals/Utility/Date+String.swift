//
//  Date+String.swift
//  YourGoals
//
//  Created by André Claaßen on 08.11.17.
//  Copyright © 2017 André Claaßen. All rights reserved.
//

import Foundation

extension Date {
    
    /// format a date in short locale format
    ///
    /// - Returns: a string representation of the date without the time
    public func formattedInLocaleFormat() -> String {
        let formattedDate = DateFormatter.createShortDateFormatter().string(from: self)
        return formattedDate
    }
    
    /// get a weekday as a single capital char
    var weekdayChar: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        return String(dateFormatter.string(from: self).capitalized.prefix(1))
    }

    /// get the current day in locale format except if it is today, yesterday or tomorrow
    /// in those cases a nice string will this text will be returned
    ///
    /// - Parameter date: a date
    /// - Returns: a formatted string or today, yesterday, tomorrow
    public func formattedWithTodayTommorrowYesterday() -> String {
        let date = self.day()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return NSLocalizedString("Today", comment: "today")
        }
        
        if calendar.isDateInTomorrow(date) {
            return NSLocalizedString("Tomorrow", comment: "tomorrow")
        }
        
        if calendar.isDateInYesterday(date) {
            return NSLocalizedString("Yesterday", comment: "yesterday")
        }
        
        let sevenDaysFromNow = Date().addDaysToDate(7)
        if date >= Date() && date <= sevenDaysFromNow {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: date)
        }
        
        return date.formattedInLocaleFormat()
    }
 }
