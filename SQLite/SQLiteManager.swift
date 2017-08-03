//
//  SQLiteManager.swift
//  SQLite
//
//  Created by smallHappy on 2017/4/18.
//  Copyright © 2017年 SmallHappy. All rights reserved.
//

/*
 1. libsqlite3.tbd
 2. BridgeHeader.h -> #include "sqlite3.h"
 */

import UIKit

class SQLiteManager: NSObject {
    
    static var db: OpaquePointer? = nil
    static var path: String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let url = URL(fileURLWithPath: path).appendingPathComponent("myDB.sqlite")
        return url.path
    }
    
    static let initDataBase: () = {
        print("sqlite: " + SQLiteManager.path)
        if sqlite3_open(SQLiteManager.path.cString(using: .utf8), &SQLiteManager.db) == SQLITE_OK {
            print("資料庫連線成功")
        } else {
            print("資料庫連線失敗")
        }
    }()
    
    private static let instance = SQLiteManager()
    static var sharedInstance: SQLiteManager {
        self.initDataBase
        return self.instance
    }
    
    enum SelectCondition {
        case equal
        case like
    }
    
    enum OrderbyMode: String {
        case desc = "DESC"
        case asc = "ASC"
    }
    
    // CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, height DOUBLE)
    func create(table: String, column: [String]) -> Bool {
        var sql = "CREATE TABLE IF NOT EXISTS \(table) "
        sql += "("
        sql += column.joined(separator: ", ")
        sql += ")"
        print("\(#function) - sql: " + sql)
        
        if sqlite3_exec(SQLiteManager.db, sql.cString(using: .utf8), nil, nil, nil) == SQLITE_OK {
            return true
        }
        
        return false
    }
    
    // INSERT INTO students (name, height) VALUES ('John's mother', '168')
    // INSERT INTO students (name, height) VALUES ('大米', '169')
    func insert(table: String, rows: [[String: String]]) -> Bool {
        for row in rows {
            var sql = "INSERT INTO \(table) "
            sql += "("
            sql += row.keys.joined(separator: ", ")
            sql += ")"
            sql += " VALUES "
            sql += "("
            let rawValue = row.values.map({ (value) -> String in
                let escaping = value.replacingOccurrences(of: "'", with: "''")
                return "'\(escaping)'"
            })
            sql += rawValue.joined(separator: ", ")
            sql += ")"
            print("\(#function) - sql: " + sql)
            
            var statement: OpaquePointer? = nil
            if sqlite3_prepare_v2(SQLiteManager.db, sql.cString(using: .utf8), -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) != SQLITE_DONE {
                    return false
                }
                sqlite3_finalize(statement)
            }
        }
        return true
    }
    
    // SELECT * FROM students
    // SELECT * FROM students ORDER BY height DESC
    // SELECT * FROM students ORDER BY height ASC
    // SELECT * FROM students WHERE height = '168'
    // SELECT * FROM students WHERE name LIKE '%小%'
    func select(table: String, condition: (column: String, value: String, mode: SelectCondition)? = nil, orderby: (column: String, mode: OrderbyMode)? = nil) -> [[String: String]]? {
        var sql = "SELECT * FROM \(table)"
        if let condition = condition {
            switch condition.mode {
            case .equal:
                sql += " WHERE \(condition.column) = '\(condition.value.replacingOccurrences(of: "'", with: "''"))'"
            case .like:
                sql += " WHERE \(condition.column) LIKE '%\(condition.value.replacingOccurrences(of: "'", with: "''"))%'"
            }
        }
        if let orderby = orderby {
            sql += " ORDER BY \(orderby.column) \(orderby.mode.rawValue)"
        }
        print("\(#function) - sql: " + sql)
        
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(SQLiteManager.db, sql.cString(using: .utf8), -1, &statement, nil) == SQLITE_OK {
            var returnArray = [[String: String]]()
            while sqlite3_step(statement) == SQLITE_ROW {
                var dictionary = [String: String]()
                for index in 0 ..< sqlite3_column_count(statement) {
                    let key = String(cString: sqlite3_column_name(statement, index))
                    let value = String(cString: sqlite3_column_text(statement, index))
                    dictionary[key] = value
                }
                returnArray.append(dictionary)
            }
            sqlite3_finalize(statement)
            return returnArray
        }
        return nil
    }
    
    // UPDATE students SET name = 'John', height = '150' WHERE id = '1'
    // UPDATE students SET height = '0'
    func update(table: String, row: [String: String], condition: (column: String, value: String)? = nil) -> Bool {
        var sql = "UPDATE \(table) SET "
        var info = [String]()
        for data in row {
            info.append("\(data.key) = '\(data.value.replacingOccurrences(of: "'", with: "''"))'")
        }
        sql += info.joined(separator: ", ")
        if let condition = condition {
            sql += " WHERE \(condition.column) = '\(condition.value.replacingOccurrences(of: "'", with: "''"))'"
        }
        print("\(#function) - sql: " + sql)
        
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(SQLiteManager.db, sql.cString(using: .utf8), -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                return true
            }
        }
        return false
    }
    
    // DELETE FROM students WHERE id'2'
    // DELETE FROM students
    func delete(table: String, condition: [String: String]? = nil) -> Bool {
        var sql = "DELETE FROM \(table)"
        if let condition = condition {
            sql += " WHERE "
            for item in condition {
                sql += "\(item.key)"
                sql += " = "
                sql += "\(item.value.replacingOccurrences(of: "'", with: "''")) AND"
            }
            sql = String(sql.characters.dropLast(4))
        }
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(SQLiteManager.db, sql.cString(using: .utf8), -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                return true
            }
            sqlite3_finalize(statement)
        }
        return false
    }
    
}
