//
//  ActionableTableCell.swift
//  YourGoals
//
//  Created by André Claaßen on 26.10.17.
//  Copyright © 2017 André Claaßen. All rights reserved.
//

import UIKit
import MGSwipeTableCell

/// the user
protocol ActionableTableCellDelegate {
    func actionableStateChangeDesired(actionable:Actionable)
}

protocol ActionableCell {
    func configure(manager: GoalsStorageManager, actionable: Actionable, forDate date: Date, estimatedStartingTime time: Date?,  delegate: ActionableTableCellDelegate)
    var actionable:Actionable! { get }
}

/// a table cell for displaying habits or tasks. experimental
class ActionableTableCell: MGSwipeTableCell, ActionableCell {
    @IBOutlet weak var totalWorkingTimeLabel: UILabel!
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var workingTimeLabel: UILabel!
    @IBOutlet weak var taskDescriptionLabel: UILabel!
    @IBOutlet weak var goalDescriptionLabel: UILabel!
    @IBOutlet weak var commmittingDateLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var pieProgressView: PieProgressView!
    @IBOutlet weak var progressViewHeightConstraint: NSLayoutConstraint!
    
    
    var actionable:Actionable!
    var delegateTaskCell: ActionableTableCellDelegate!
    let colorCalculator = ColorCalculator(colors: [UIColor.red, UIColor.yellow, UIColor.green])
    var taskProgressManager:TaskProgressManager!
    var defaultProgressViewHeight:CGFloat = 0.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        defaultProgressViewHeight = progressViewHeightConstraint.constant
        checkBoxButton.setImage(UIImage(named: "TaskCircle"), for: .normal)
        checkBoxButton.setImage(UIImage(named: "TaskChecked"), for: .selected)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Factory Method
    
    internal static func dequeue(fromTableView tableView: UITableView, atIndexPath indexPath: IndexPath) -> ActionableTableCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActionableTableCell", for: indexPath) as? ActionableTableCell else {
            fatalError("*** Failed to dequeue ActionableTableCell ***")
        }
        
        return cell
    }
    
    @IBAction func checkBoxAction(_ sender: Any) {
        delegateTaskCell.actionableStateChangeDesired(actionable: self.actionable)
    }
    
    // MARK: - Content
    
    func show(state: ActionableState) {
        switch state {
        case .active:
            self.checkBoxButton.isSelected = false
        case .done:
            self.checkBoxButton.isSelected = true
        }
    }
    
    /// show the task progress state and resize the control for the needed height
    ///
    /// - Parameter date: show progress for date
    func showTaskProgress(forDate date: Date) {
        let isProgressing = actionable.isProgressing(atDate: date)
        self.progressView.isHidden = !isProgressing
        self.progressViewHeightConstraint.constant = isProgressing ? defaultProgressViewHeight : 0.0
        if isProgressing {
            let remainingPercentage = CGFloat(actionable.calcRemainingPercentage(atDate: date))
            let progressColor = self.colorCalculator.calculateColor(percent: remainingPercentage)
            self.contentView.backgroundColor = progressColor.lighter(by: 75.0)
            self.remainingTimeLabel.text =  self.actionable.calcRemainingTimeInterval(atDate: date).formattedAsString()
            self.pieProgressView.progress = 1.0 - remainingPercentage
            self.pieProgressView.progressTintColor = progressColor.darker()
            self.pieProgressView.fillColor = UIColor.clear
            self.pieProgressView.trackTintColor = progressColor.darker()
            self.pieProgressView.clockwise = true
        } else {
            self.contentView.backgroundColor = UIColor.white
        }
    }
    
    /// show the date for committing and its state in the date label
    ///
    /// - Parameters:
    ///   - state: the state of the task
    ///   - date: date of the commitment
    func showTaskCommittingState(state: CommittingState, forDate date: Date?) {
        
        guard let date = date else {
            self.commmittingDateLabel.isHidden = true
            return
        }
        
        switch state {
        case .committedForDate:
            self.commmittingDateLabel.text = date.formattedWithTodayTommorrowYesterday()
            self.commmittingDateLabel.isHidden = false
            self.commmittingDateLabel.textColor  = UIColor.darkGreen
            
        case .committedForPast:
            self.commmittingDateLabel.text = date.formattedWithTodayTommorrowYesterday()
            self.commmittingDateLabel.isHidden = false
            self.commmittingDateLabel.textColor = UIColor.darkRed
            
        case .notCommitted:
            self.commmittingDateLabel.isHidden = true
        }
    }
    
    @IBAction func timerPlusTouched(_ sender: Any) {
        try? self.taskProgressManager.changeTaskSize(forTask: self.actionable, delta: 15.0)
        showTaskProgress(forDate: Date())
    }
    
    /// calculate several textes for the working time and progress
    /// of the actionables
    ///
    /// - Parameters:
    ///   - actionable: the task or habit
    ///   - date: calculate values for this date
    ///   - time: estimated starting time of the task
    /// - Returns: a tuple consisting of formatted strings of
    //             workingTimeRange, remaining time and the total working time
    func getTimeLabelTexts(actionable: Actionable, forDate date: Date, estimatedStartingTime time: Date?) -> (workingTime:String?, remainingTime: String?, totalWorkingTime: String?) {
        
        guard actionable.type == .task else {
            return (nil, nil, nil)
        }
        
        let totalWorkingTime = actionable.calcProgressDuration(atDate: date)?.formattedAsString()
        
        guard actionable.checkedState(forDate: date) == .active else {
            return (nil, nil, totalWorkingTime)
        }

        let remainingTime = actionable.calcRemainingTimeInterval(atDate: date)
        let remainingTimeText = remainingTime.formattedAsString()
        
        if let startingTime = time {
            let endingTime = startingTime.addingTimeInterval(remainingTime)
            let workingTimeText = startingTime.formattedTime() + " - " + endingTime.formattedTime()
            return (workingTimeText, remainingTimeText, totalWorkingTime)
        } else {
            return (nil, remainingTimeText, totalWorkingTime)
        }
    }
    
    /// show the working time on this task.
    ///
    /// - Parameter task: task
    func showWorkingTime(actionable: Actionable, forDate date: Date, estimatedStartingTime time: Date?) {
        let tuple = getTimeLabelTexts(actionable: actionable, forDate: date, estimatedStartingTime: time)
        self.workingTimeLabel.text = tuple.workingTime
        self.remainingTimeLabel.text = tuple.remainingTime
        self.totalWorkingTimeLabel.text = tuple.totalWorkingTime
    }
    
    func adaptUI(forActionableType type: ActionableType) {
        switch type {
        case .habit:
            checkBoxButton.setImage(UIImage(named: "HabitBox"), for: .normal)
            checkBoxButton.setImage(UIImage(named: "HabitBoxChecked"), for: .selected)
        case .task:
            checkBoxButton.setImage(UIImage(named: "TaskCircle"), for: .normal)
            checkBoxButton.setImage(UIImage(named: "TaskChecked"), for: .selected)
        }
    }
    
    /// show the content of the task in this cell
    ///
    /// - Parameters:
    ///   - manager: the storage manager
    ///   - actionable: show the actionable in the cell
    ///   - date: for this date
    ///   - time: with this optional estimated starting time
    ///   - delegate: a delegate for call back actions
    func configure(manager: GoalsStorageManager, actionable: Actionable, forDate date: Date, estimatedStartingTime time: Date?, delegate: ActionableTableCellDelegate) {
        self.taskProgressManager = TaskProgressManager(manager: manager)
        self.actionable = actionable
        self.delegateTaskCell = delegate
        self.taskDescriptionLabel.sizeToFit()
        adaptUI(forActionableType: actionable.type)
        show(state: actionable.checkedState(forDate: date))
        showTaskProgress(forDate: date)
        showTaskCommittingState(state: actionable.committingState(forDate: date), forDate: actionable.commitmentDate)
        showWorkingTime(actionable: actionable, forDate: date, estimatedStartingTime: time)
        taskDescriptionLabel.text = actionable.name
        
        if let goalName = actionable.goal?.name {
            goalDescriptionLabel.text = "Goal: \(goalName)"
            goalDescriptionLabel.isHidden = false
        } else {
            goalDescriptionLabel.isHidden = true
        }
    }
}