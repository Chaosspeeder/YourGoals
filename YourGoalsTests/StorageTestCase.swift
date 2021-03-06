//
//  StorageTestCase.swift
//  YourFitnessPlan
//
//  Created by André Claaßen on 21.05.16.
//  Copyright © 2016 André Claaßen. All rights reserved.
//

import Foundation
import XCTest
@testable import YourGoals

/// base class for unit testing with the core data objects
class StorageTestCase:XCTestCase {

    var manager:GoalsStorageManager!
    var generator:TestDataGenerator!
    var testDataCreator:TestDataCreator!
    
    override func setUp() {
        super.setUp()
        self.manager = GoalsStorageManager.defaultUnitTestStorageManager
        try! self.manager.deleteRepository()
        self.generator = TestDataGenerator.defaultUnitTestGenerator
        let _ = try! StrategyManager(manager: self.manager).assertValidActiveStrategy()
        self.testDataCreator = TestDataCreator(manager: self.manager)
    }
    
    var activeStrategy:Goal {
        return try! StrategyManager(manager: self.manager).retrieveActiveStrategy()!
    }
}
