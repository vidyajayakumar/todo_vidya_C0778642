

import Foundation
import UIKit

extension Date {
    static func calculateDate(day: Int, month: Int, year: Int, hour: Int, minute: Int) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let calculatedDate = formatter.date(from: "\(year)-\(month)-\(day) \(hour):\(minute)")
        return calculatedDate!
    }
    
    func getDue() -> (day: Int, month: Int, year: Int, hour: Int, minute: Int, second: Int){
        let calendar = Calendar.current
        let day = calendar.component(.day, from: self)
        let month = calendar.component(.month, from: self)
        let year = calendar.component(.year, from: self)
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        let second = calendar.component(.second, from: self)
        return (day, month, year, hour, minute, second)
    }
    
    
}
