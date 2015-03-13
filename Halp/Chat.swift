import Foundation

var dateFormatter = NSDateFormatter()

class Chat {
    var otherUser:Dictionary<String, AnyObject>
    
    var lastMessageText: String
    var lastMessageSentDate: NSDate
    var lastMessageSentDateString: String {
        return formatDate(lastMessageSentDate)
    }
    var loadedMessages = [[Message]]()
    var unreadMessageCount: Int = 0 // subtacted from total when read
    var hasUnloadedMessages = false
    var draft = ""

    init(rootMessage:JSON) {
        self.otherUser = Dictionary<String, AnyObject>()
        self.otherUser.updateValue(rootMessage["otherUser"]["userId"].intValue, forKey: "userId")
        self.otherUser.updateValue(rootMessage["otherUser"]["firstname"].stringValue, forKey: "firstname")
        
        self.lastMessageText = rootMessage["lastMessage"]["body"].stringValue
        self.lastMessageSentDate = NSDate(timeIntervalSince1970: NSTimeInterval(rootMessage["lastMessage"]["timestamp"].intValue))
        
        self.unreadMessageCount = rootMessage["unreadMessages"].intValue
    }

    func formatDate(date: NSDate) -> String {
        let calendar = NSCalendar.currentCalendar()

        let last18hours = (-18*60*60 < date.timeIntervalSinceNow)
        let isToday = calendar.isDateInToday(date)
        let isLast7Days = (calendar.compareDate(NSDate(timeIntervalSinceNow: -7*24*60*60), toDate: date, toUnitGranularity: .CalendarUnitDay) == NSComparisonResult.OrderedAscending)

        if last18hours || isToday {
            dateFormatter.dateStyle = .NoStyle
            dateFormatter.timeStyle = .ShortStyle
        } else if isLast7Days {
            dateFormatter.dateFormat = "ccc"
        } else {
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .NoStyle
        }
        return dateFormatter.stringFromDate(date)
    }
}
