//
//  GoalComposer.swift
//  YourGoals
//
//  Created by André Claaßen on 27.10.17.
//  Copyright © 2017 André Claaßen. All rights reserved.
//

import Foundation
import CoreData

enum GoalComposerError:Error {
    case noTaskForIdFound
    case noGoalForActionableFound
}

/// modify and compose goals in core data and save the result in the database
class GoalComposer:StorageManagerWorker {
    /// add a new task with the information from the task info to the goal and save
    /// it back to the core data store
    ///
    /// - Parameters:
    ///   - actionableInfo: task info
    ///   - goal: the goal
    /// - Returns: the modified goal with the new task
    /// - Throws: core data exception
    func create(actionableInfo: ActionableInfo, toGoal goal: Goal) throws -> Goal {
        let factory = factoryForType(actionableInfo.type)
        var actionable = factory.create(actionableInfo: actionableInfo)
        actionable.prio = -1
        goal.add(actionable: actionable)
        let taskOrderManager = TaskOrderManager(manager: self.manager)
        taskOrderManager.updateOrderByPrio(forGoal: goal, andType: actionableInfo.type)
        try self.manager.dataManager.saveContext()
        return goal
    }
    
    
    func update(actionable: Actionable, withInfo info: ActionableInfo) throws -> Goal {
        guard let goal = actionable.goal else {
            throw GoalComposerError.noGoalForActionableFound
        }
        
        var actionable = actionable // make the actionable writeable.
        actionable.name = info.name
 
        try self.manager.dataManager.saveContext()
        return goal
    }
    
    func delete(task: Task, fromGoal goal: Goal) throws {
        goal.removeFromTasks(task)
        self.manager.tasksStore.managedObjectContext.delete(task)
    }
    
    func delete(habit: Habit, fromGoal goal: Goal) throws {
        goal.removeFromHabits(habit)
        self.manager.tasksStore.managedObjectContext.delete(habit)
    }
    
    /// delete an actionable from the given goal
    ///
    /// - Parameters:
    ///   - actinable: the actionable
    ///   - goal: the parent goal for the task
    /// - Returns: the goal without the task
    /// - Throws: core data exception
    func delete(actionable: Actionable) throws -> Goal {
        guard let goal = actionable.goal else {
            throw GoalComposerError.noGoalForActionableFound
        }
        
        switch actionable.type {
        case .habit:
            try delete(habit: actionable as! Habit, fromGoal: goal)
        case .task:
             try delete(task: actionable as! Task, fromGoal: goal)
        }
        try self.manager.dataManager.saveContext()
        return goal
    }
    
    func factoryForType(_ type:ActionableType) -> ActionableFactory {
        switch type {
        case .task:
            return TaskFactory(manager: self.manager)
            
        case .habit:
            return HabitFactory(manager: self.manager)
        }
    }
}