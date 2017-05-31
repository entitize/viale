//
//  DatePickerService.swift
//  Viale
//
//  Created by Kai Nakamura on 5/29/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation
import UIKit
import DateTimePicker

class DatePickerService {
    
    static let dps = DatePickerService()
    
    func getDatePicker(min:Date,max:Date) -> DateTimePicker {
        let picker = DateTimePicker.show(minimumDate: min, maximumDate: max)
        picker.highlightColor = UIColor(hex: "#90CAF9")
        picker.darkColor = UIColor(hex: "#5C6BC0")
        picker.doneButtonTitle = "Choose Time"
        picker.todayButtonTitle = "Today"
        picker.is12HourFormat = true
        picker.dateFormat = "hh:mm aa dd/MM/YYYY"
        return picker
    }
    
    func convertDateToString(date:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm aa dd/MM/YYYY"
        return formatter.string(from: date)
        
    }
    
    
    
    
}
