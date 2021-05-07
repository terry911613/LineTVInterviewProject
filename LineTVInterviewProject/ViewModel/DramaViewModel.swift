//
//  DramaViewModel.swift
//  LineTVInterviewProject
//
//  Created by 李泰儀 on 2021/5/5.
//

import Foundation

public class DramaViewModel {
    
    private let coreDataDB = CoreDataDB()
    
    private var dramas = [Drama]()
    private var showDramas = [Drama]()
    
    // MARK: - Bind
    public var dramasCount: Int {
        showDramas.count
    }
    
    public func dramaName(for indexPath: IndexPath) -> String {
        showDramas[indexPath.row].name
    }
    
    public func dramaTotalView(for indexPath: IndexPath) -> Int {
        showDramas[indexPath.row].total_views
    }
    
    public func dramaCreatedDate(for indexPath: IndexPath) -> String? {
        showDramas[indexPath.row].createdDateDisplayString
    }
    
    public func dramaThumbString(for indexPath: IndexPath) -> String {
        showDramas[indexPath.row].thumb
    }
    
    public func dramaThumbData(for indexPath: IndexPath) -> Data? {
        showDramas[indexPath.row].thumbData
    }
    
    public func dramaRating(for indexPath: IndexPath) -> String? {
        showDramas[indexPath.row].ratingDisplayString
    }
    
    public func totalViews(for indexPath: IndexPath) -> String? {
        showDramas[indexPath.row].totalViewsDisplayString
    }
    
    public var searchHistoryCount: Int {
        searchHistories.count
    }
    
    public func searchHistory(for indexPath: IndexPath) -> String {
        searchHistories[indexPath.row]
    }
    
    // MARK: - Get Data
    public func getDrama(for indexPath: IndexPath) -> Drama {
        showDramas[indexPath.row]
    }
    
    // MARK: - Set Data
    public func setImageData(for indexPath: IndexPath, urlString: String, data: Data) {
        if showDramas.count > indexPath.row {
            var drama = showDramas[indexPath.row]
            if drama.thumb == urlString {
                drama.thumbData = data
                showDramas[indexPath.row] = drama
                if let index = dramas.firstIndex(where: { $0.drama_id == drama.drama_id }) {
                    dramas[index].thumbData = data
                }
            }
        }
    }
    
    // MARK: - API
    private struct Response<T: Codable>: Codable {
        let data: T
    }
    
    public func fetchDramas(completion: @escaping (Result<Void, Error>) -> ()) {
        if let url = URL(string: "https://static.linetv.tw/interview/dramas-sample.json") {
            NetworkRouter.request(url: url, type: [Drama].self) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let dramas):
                    self.dramas = dramas
                    self.searching(text: self.searchHistory, updateHistory: false)
                    completion(.success(()))
                    DispatchQueue.global().async {
                        self.updateDramaCoreDB(dramas: dramas)
                    }
                case .failure(let error):
                    print("error = \(error.localizedDescription)")
                    self.fetchDramaCoreDB(completion: completion)
                }
            }
        }
        else {
            completion(.failure(AppError.urlNotFound))
        }
    }
    
    // MARK: - CoreDB
    public func fetchDramaCoreDB(completion: @escaping (Result<Void, Error>) -> ()) {
        coreDataDB.fetch(entityClass: Drama_CoreDB.self, entity: .Drama_CoreDB) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let drama_coreDBs):
                print("drama_coreDBs = \(drama_coreDBs.map { $0.thumbData })")
                var dramas = [Drama]()
                for drama_coreDB in drama_coreDBs {
                    if let drama = drama_coreDB.drama {
                        dramas.append(drama)
                    }
                }
                self.dramas = dramas
                self.searching(text: self.searchHistory, updateHistory: false)
                
                if dramas.isEmpty {
                    completion(.failure(CoreDBError.emptyEntities))
                }
                else {
                    completion(.success(()))
                }
            case .failure(let error):
                print("error = \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    public func updateDramaCoreDB(dramas: [Drama]) {
        for drama in dramas {
            drama.getThumbData { (result) in
                var thumbData: Data?
                switch result {
                case .success(let data):
                    thumbData = data
                case .failure(let error):
                    print("error = \(error.localizedDescription)")
                }
                
                let predicate = NSPredicate(format: "drama_id == %d", drama.drama_id)
                self.coreDataDB.update(entityClass: Drama_CoreDB.self, entity: .Drama_CoreDB, predicate: predicate) { (drama_coreDBs) in
                    if drama_coreDBs.count == 1 {
                        drama_coreDBs.first?.name = drama.name
                        drama_coreDBs.first?.created_at = drama.created_at
                        drama_coreDBs.first?.rating = drama.rating
                        drama_coreDBs.first?.thumb = drama.thumb
                        drama_coreDBs.first?.total_views = Int64(drama.total_views)
                        drama_coreDBs.first?.thumbData = thumbData
                    }
                } completion: { [weak self] (result) in
                    guard let self = self else { return }
                    switch result {
                    case .success(_):
                        print("success")
                    case .failure(let error):
                        print(error.localizedDescription)
                        if let error = error as? CoreDBError {
                            if error == CoreDBError.emptyEntities {
                                self.addDramaCoreDB(drama: drama, thumbData: thumbData)
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func addDramaCoreDB(drama: Drama, thumbData: Data?) {
        coreDataDB.insert(entityClass: Drama_CoreDB.self, entity: .Drama_CoreDB) { (drama_coreDB) in
            drama_coreDB.drama_id = Int64(drama.drama_id)
            drama_coreDB.name = drama.name
            drama_coreDB.total_views = Int64(drama.total_views)
            drama_coreDB.created_at = drama.created_at
            drama_coreDB.thumb = drama.thumb
            drama_coreDB.rating = drama.rating
            drama_coreDB.thumbData = thumbData
        } completion: { (result) in
            switch result {
            case .success(let drama_coreDB):
                print("success, drama_coreDB = \(drama_coreDB)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Search History
    private var searchHistories: [String] {
        get {
            let searchHistories = UserDefaults.standard.object(forKey: "searchHistories") as? [String] ?? [String]()
            print("searchHistories = \(searchHistories)")
            return searchHistories
        }
        set {
            print("newValue = \(newValue)")
            UserDefaults.standard.set(newValue, forKey: "searchHistories")
        }
    }
    
    public func searching(text: String, updateHistory: Bool = true) {
        if text.isEmpty {
            showDramas = dramas
        }
        else {
            showDramas = dramas.filter { $0.name.contains(text) }
        }
        
        if updateHistory {
            searchHistory = text
        }
    }
    
    public func storeSearchHistory(text: String) {
        var histories = searchHistories
        if let index = histories.firstIndex(of: text) {
            histories.remove(at: index)
        }
        histories.insert(text, at: 0)
        searchHistories = histories
    }
    
    public func deleteSearchHistory(indexPath: IndexPath) {
        var histories = searchHistories
        histories.remove(at: indexPath.row)
        searchHistories = histories
    }
    
    
    public var searchHistory: String {
        get {
            let searchHistory = UserDefaults.standard.string(forKey: "searchHistory") ?? ""
            print("searchHistory = \(searchHistory)")
            return searchHistory
        }
        set {
            print("newValue = \(newValue)")
            UserDefaults.standard.set(newValue, forKey: "searchHistory")
        }
    }
    
    public func setSearchHistory(text: String) {
        searchHistory = text
    }
}
