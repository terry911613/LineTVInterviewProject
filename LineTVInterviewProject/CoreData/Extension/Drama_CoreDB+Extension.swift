//
//  Drama_CoreDB+Extension.swift
//  LineTVInterviewProject
//
//  Created by 李泰儀 on 2021/5/6.
//

import Foundation

extension Drama_CoreDB {
    public var drama: Drama? {
        if let name = name,
           let created_at = created_at,
           let thumb = thumb {
            var drama = Drama(drama_id: Int(drama_id), name: name, total_views: Int(total_views), created_at: created_at, thumb: thumb, rating: rating)
            drama.thumbData = thumbData
            return drama
        }
        return nil
    }
}
