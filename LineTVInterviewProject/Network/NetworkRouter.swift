//
//  NetworkRouter.swift
//  LineTVInterviewProject
//
//  Created by 李泰儀 on 2021/5/6.
//

import Foundation

public class NetworkRouter {
    
    private struct Response<T: Codable>: Codable {
        let data: T
    }
    
    public static func request<T: Codable>(url: URL, type: T.Type, completion: @escaping (Result<T, Error>) -> ()) {
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            else {
                if let data = data {
                    print(String(data: data, encoding: .utf8) ?? "")
                    let decoder = JSONDecoder()
                    do {
                        let response = try decoder.decode(Response<T>.self, from: data)
                        DispatchQueue.main.async {
                            completion(.success(response.data))
                        }
                    }
                    catch {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        completion(.failure(AppError.dataNil))
                    }
                }
            }
        }
        task.resume()
    }
}
