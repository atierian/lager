//
//  File.swift
//  
//
//  Created by Ian Saultz on 7/15/22.
//

import Foundation
import SQLite3

enum SQLite {}
extension SQLite {
    enum Error: Swift.Error {
        case openDatabase(message: String)
        case prepare(message: String)
        case step(message: String)
        case bind(message: String)
    }
}

extension SQLite {
    actor Database {
        private let db: OpaquePointer?

        
        private init(db: OpaquePointer?) {
            self.db = db
        }
        
        deinit { sqlite3_close(db) }
        
        static func open(path: String) throws -> Database {
            var db: OpaquePointer?
            
            if sqlite3_open(path, &db) == SQLITE_OK {
                return Database(db: db)
            } else {
                defer { if db != nil { sqlite3_close(db) } }
                
                let errorMessage = Database
                    .generateErrorMessage(db)
                
                throw SQLite.Error
                    .openDatabase(message: errorMessage)
            }
        }
        
        private static func generateErrorMessage(_ p: OpaquePointer?) -> String {
            sqlite3_errmsg(p)
                .map(String.init(cString:))
            ?? "No error message provided from sqlite."
        }
        
        fileprivate var errorMessage: String {
            Database.generateErrorMessage(db)
        }
    }
}

extension SQLite.Database {
    func prepareState(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(
            db, sql, -1, &statement, nil
        ) == SQLITE_OK
        else {
            throw SQLite.Error.prepare(message: errorMessage)
        }
        return statement
    }
}

struct SQLTable<T> {
    let create: () throws -> String
}

struct Contact {
    let id: Int
    let name: String
}

extension SQLTable where T == Contact {
    static let contact = SQLTable {
        """
        CREATE TABLE Contact(
          Id INT PRIMARY KEY NOT NULL,
          Name CHAR(255)
        );
        """
    }
}

extension SQLite.Database {
    func create<T>(table: SQLTable<T>) throws {
        let statement = try prepareState(sql:  table.create())
        defer { sqlite3_finalize(statement) }
        guard sqlite3_step(statement) == SQLITE_OK
        else { throw SQLite.Error.step(message: errorMessage) }
        print("\(table) table created")
    }
}
