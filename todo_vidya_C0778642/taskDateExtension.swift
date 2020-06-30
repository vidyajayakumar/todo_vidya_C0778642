

import Foundation
import UIKit

extension Date {
    static func calculateDate(day: Int, month: Int, year: Int, hour: Int, minute: Int) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let calculatedDate = formatter.date(from: "\(year)-\(month)-\(day) \(hour):\(minute)")
        return calculatedDate!
    }
    
    func getDue(string: String) -> (day: Int, month: Int, year: Int, hour: Int, minute: Int){
        
        let calendar = Calendar.current
        
        let day = calendar.component(.day, from: self)
        let month = calendar.component(.month, from: self)
        let year = calendar.component(.year, from: self)
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        return (day, month, year, hour, minute)
    }
    func dateformatterDateString(dateString: String) -> NSDate? {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM/dd/yyyy hh:mm a Z"
        //      dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        dateFormatter.timeZone = NSTimeZone.local
        return dateFormatter.date(from: dateString) as NSDate?
    }
    
    
}
