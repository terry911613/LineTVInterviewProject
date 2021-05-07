//
//  Drama.swift
//  LineTVInterviewProject
//
//  Created by 李泰儀 on 2021/5/5.
//

import Foundation

public struct Drama: Codable {
    public let drama_id: Int
    public let name: String
    public let total_views: Int
    public let created_at: String
    public let thumb: String
    public let rating: Double
    public var thumbData: Data?
    
    // MARK: - turn thumb to Data
    public func getThumbData(completion: (Result<Data, Error>) -> ()) {
        if let url = URL(string: thumb), let data = try? Data(contentsOf: url) {
            completion(.success(data))
        }
        else {
            completion(.failure(AppError.getDataFailed))
        }
    }
    
    // MARK: - Display
    public var createdDateDisplayString: String? {
        if let date = DateFormatter.UTCFormatter.date(from: created_at) {
            return "出版日期: " + DateFormatter.normalDateFormatter.string(from: date)
        }
        return nil
    }
    
    public var ratingDisplayString: String {
        String(format: "%.1f", rating)
    }
    
    public var totalViewsDisplayString: String? {
        var text = ""
        if total_views < 1000 {
            text = "\(total_views)"
        }
        else if total_views < 10000 {
            let thousand = total_views / 1000
            let hundred = (total_views - (thousand * 1000)) / 100
            text = "\(thousand).\(hundred)千"
        }
        else {
            let uponThousand = total_views / 10000
            let thousand = (total_views - (uponThousand * 10000)) / 1000
            text = "\(uponThousand).\(thousand)萬"
        }
        if text.isEmpty {
            return nil
        }
        else {
            return "觀看次數: \(text)次"
        }
    }
}
