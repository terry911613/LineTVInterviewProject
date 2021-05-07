//
//  CoreDBError.swift
//  LineTVInterviewProject
//
//  Created by 李泰儀 on 2021/5/6.
//

import Foundation

public enum CoreDBError {
    case emptyEntities
    case decodeFailed
}

extension CoreDBError: Error {
    var localizedDescription: String {
        return errorDescription ?? String(describing: self)
    }
}

extension CoreDBError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyEntities:
            return "empty entities"
        case .decodeFailed:
            return "decode failed"
        }
    }
}
