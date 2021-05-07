//
//  CoreDB.swift
//  LineTVInterviewProject
//
//  Created by 李泰儀 on 2021/5/6.
//

import UIKit
import CoreData

public enum Entity: String {
    case Drama_CoreDB
}

public class CoreDataDB {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    public func fetch<T>(entityClass: T.Type,
                  entity: Entity,
                  predicate: NSPredicate? = nil,
                  sortDescriptors: [NSSortDescriptor]? = nil,
                  limit: Int? = nil,
                  completion: @escaping (Result<[T], Error>) -> ()) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
        if let predicate = predicate {
            request.predicate = predicate
        }
        if let sortDescriptors = sortDescriptors {
            request.sortDescriptors = sortDescriptors
        }
        if let limit = limit {
            request.fetchLimit = limit
        }
        do {
            if let entities = try self.context.fetch(request) as? [T] {
                completion(.success(entities))
            }
        }
        catch {
            completion(.failure(error))
        }
    }
    
    public func insert<T>(entityClass: T.Type, entity: Entity, block: @escaping (T) -> (), completion: @escaping (Result<T, Error>) -> ()) {
        if let entity = NSEntityDescription.insertNewObject(forEntityName: entity.rawValue, into: self.context) as? T {
            block(entity)
            do {
                try self.context.save()
                completion(.success(entity))
            }
            catch {
                completion(.failure(error))
            }
        }
    }
    
    public func update<T>(entityClass: T.Type,
                          entity: Entity,
                          predicate: NSPredicate? = nil,
                          block: @escaping ([T]) -> (),
                          completion: @escaping (Result<Void, Error>) -> ()) {
        performChange(entityClass: entityClass, entity: entity, predicate: predicate, block: { block($0) }, completion: completion)
    }
    
    public func delete(entity: Entity, predicate: NSPredicate? = nil, completion: @escaping (Result<Void, Error>) -> ()) {
        performChange(entityClass: NSManagedObject.self, entity: entity, predicate: predicate, block: { (entities) in
            for entity in entities {
                self.context.delete(entity)
            }
        }, completion: completion)
    }
    
    private func performChange<T>(entityClass: T.Type,
                                  entity: Entity,
                                  predicate: NSPredicate?,
                                  block: @escaping ([T]) -> (),
                                  completion: @escaping (Result<Void, Error>) -> ()) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
        if let predicate = predicate {
            request.predicate = predicate
        }
        do {
            if let entities = try self.context.fetch(request) as? [T] {
                if entities.isEmpty {
                    completion(.failure(CoreDBError.emptyEntities))
                }
                else {
                    block(entities)
                    try self.context.save()
                    completion(.success(()))
                }
            }
            else {
                completion(.failure(CoreDBError.decodeFailed))
            }
        }
        catch {
            completion(.failure(error))
        }
    }
}
