//
//  NetworkManager.swift
//  LineTVInterviewProject
//
//  Created by 李泰儀 on 2021/5/6.
//

import UIKit
import Alamofire

public protocol NetworkObserver {
    func networkStateChanged(status: NetworkReachabilityManager.NetworkReachabilityStatus, networkManager: NetworkManager)
}

public class NetworkManager {
    
    public static let shared = NetworkManager()
    public var delegate: NetworkObserver?
    
    private let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")
    private (set) var status: NetworkReachabilityManager.NetworkReachabilityStatus = .unknown
    
    public func startNetworkReachabilityObserver() {
        reachabilityManager?.startListening(onUpdatePerforming: { [weak self] (status) in
            guard let self = self else { return }
            self.delegate?.networkStateChanged(status: status, networkManager: self)
            self.status = status
        })
    }
}
