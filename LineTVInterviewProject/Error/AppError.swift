//
//  AppError.swift
//  LineTVInterviewProject
//
//  Created by 李泰儀 on 2021/5/6.
//

import Foundation

public enum AppError {
    case urlNotFound
    case decodeFailed
    case dataNil
    case getDataFailed
}

extension AppError: Error {
    var localizedDescription: String {
        return errorDescription ?? String(describing: self)
    }
}

extension AppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .urlNotFound:
            return "url not found"
        case .decodeFailed:
            return "decode failed"
        case .dataNil:
            return "data nil"
        case .getDataFailed:
            return "get data failed"
        }
    }
}
