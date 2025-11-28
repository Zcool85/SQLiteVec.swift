//
//  SQLiteVecTests.swift
//  SQLiteVec
//
//  Created by Zéro Cool on 28/11/2025.
//

import XCTest
@testable import SQLiteVec
import SQLite

final class SQLiteVecTests: XCTestCase {
    private var trace: [String: Int]!
    var db: Connection!

    override func setUp() async throws {
        db = try Connection(":memory:")
        try db.enableVec()
        db.trace { SQL in
            print("SQL: \(SQL)")
            self.trace[SQL, default: 0] += 1
        }
    }
    
    override func tearDown() async throws {
        db = nil
    }
    
    func testVecInitialization() throws {
        XCTAssertTrue(db.isVecEnabled)
    }
    
    func testVecVersion() throws {
        let version = db.vecVersion
        XCTAssertFalse(version == nil)
        print("sqlite-vec version: \(version!)")
    }
}
