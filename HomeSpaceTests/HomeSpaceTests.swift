//
//  HomeSpaceTests.swift
//  HomeSpaceTests
//
//  Created by axiom1234 on 13/03/2019.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import XCTest
@testable import HomeSpace

class HomeSpaceTests: XCTestCase {
//
//
//
    func getTasksTest() {

        var arrTask:[Task]?
        let taskExpectation = expectation(description: "task")

        taskManager.shared.getAllTask { (tasks, err) in
            arrTask = tasks
            taskExpectation.fulfill()

        }
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNotNil(arrTask)
        }



    }
//
//    func createTasksTest() {
//
//        let task = Task(name: "ali", date: "\(Date())")
//        var errTask:String?
//        let errorExpectation = expectation(description: "error")
//
//        taskManager.shared.addTask(task: task) { (err) in
//            errorExpectation.fulfill()
//            errTask = err
//        }
//
//        waitForExpectations(timeout: 1) { (error) in
//            XCTAssertNotNil(errTask)
//        }
//    }
}
