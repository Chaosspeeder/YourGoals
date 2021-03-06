//
//  EditGoalSegueParameter.swift
//  YourGoals
//
//  Created by André Claaßen on 27.12.17.
//  Copyright © 2017 André Claaßen. All rights reserved.
//

import Foundation

protocol EditGoalSegueParameter {
    var delegate:EditGoalFormControllerDelegate! { get set }
    var editGoal:Goal? { get set }
    func commit()
}

protocol EditGoalFormControllerDelegate {
    func createNewGoal(goalInfo: GoalInfo)
    func update(goal: Goal, withGoalInfo goalInfo:GoalInfo)
    func delete(goal: Goal)
    func dismissController()
}
