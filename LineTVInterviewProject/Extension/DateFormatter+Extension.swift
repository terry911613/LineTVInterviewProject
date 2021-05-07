//
//  DateFormatter+Extension.swift
//  LineTVInterviewProject
//
//  Created by 李泰儀 on 2021/5/5.
//

import Foundation

extension DateFormatter {
    public static let UTCFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter
    }()
    
    public static let normalDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter
    }()
}
