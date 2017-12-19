//
//  EditActionableFormController.swift
//  YourGoals
//
//  Created by André Claaßen on 04.12.17.
//  Copyright © 2017 André Claaßen. All rights reserved.
//

import Foundation
import Eureka

protocol EditActionableViewControllerDelegate {
    func createNewActionable(actionableInfo: ActionableInfo) throws
    func updateActionable(actionable: Actionable,  updateInfo: ActionableInfo) throws
    func deleteActionable(actionable: Actionable) throws
}

protocol EditActionableViewControllerParameter {
    var manager:GoalsStorageManager! { get set }
    var goal:Goal! { get set }
    var editActionable:Actionable? { get set }
    var editActionableType:ActionableType? { get set }
    var delegate:EditActionableViewControllerDelegate? { get set }
    func commitParameter()
}

/// new form controller for editing tasks and habits based on eureka
class EditActionableFormController : FormViewController, EditActionableViewControllerParameter {
    var goal:Goal!
    var editActionable:Actionable?
    var editActionableType:ActionableType?
    var delegate:EditActionableViewControllerDelegate?
    var manager:GoalsStorageManager!
    var parameterCommitted = false
    
    func commitParameter() {
        assert(self.manager != nil)
        assert(self.delegate != nil)
        assert(self.goal != nil)
        assert(self.editActionableType != nil)
        if editActionable != nil {
            assert(self.editActionable?.type == self.editActionableType)
        }
        
        self.parameterCommitted = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewModel = createViewModel()
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.topItem?.title = viewModel.item(tag: EditTaskFormTag.titleTag.rawValue).value
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.leftBarButtonItem?.target = self
        self.navigationItem.leftBarButtonItem?.action = #selector(cancelTapped(_:))
        self.navigationItem.rightBarButtonItem?.target = self
        self.navigationItem.rightBarButtonItem?.action = #selector(saveTapped(_:))
        
        self.createForm(withViewModel: viewModel)
    }
 
    func createViewModel() -> FormViewModel {
        var viewModel:FormViewModel!
        do {
            let formModelCreator = ActionableViewModelCreator(manager: self.manager)
            if let actionable = self.editActionable {
                viewModel = try formModelCreator.createViewModel(for: actionable, atDate: Date())
            } else {
                viewModel = try formModelCreator.createViewModel(for: self.goal, andType: self.editActionableType!, atDate: Date())
            }
        }
        catch let error {
            self.showNotification(forError: error)
        }
        
        return viewModel
    }
    
    private func createForm(withViewModel viewModel:FormViewModel) {
        assert(self.parameterCommitted, "The parameter weren't committed")
        form
            +++ Section()
            <<< TextRow(tag: EditTaskFormTag.taskTag.rawValue).cellSetup { cell, row in
                cell.textField.placeholder = row.tag
                row.value = viewModel.item(tag: row.tag).value
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesAlways
            }
            
            <<< PushRow<Goal>(EditTaskFormTag.goalTag.rawValue) { row in
                row.title = "Select a Goal"
                let goalItem:TypedFormItem<Goal> = viewModel.item(tag: row.tag) as TypedFormItem<Goal>
                row.value = goalItem.value
                row.options = goalItem.options
                }.onPresent{ (_, to) in
                    to.selectableRowCellUpdate = { cell, row in
                        cell.textLabel?.text = row.selectableValue?.name
                    }
                }.cellUpdate{ (cell, row) in
                    cell.textLabel?.text = "Goal"
                    cell.detailTextLabel?.text = row.value?.name
            }
            
            +++ Section() {
                section in
                section.hidden = Condition.function([], { (_) -> Bool in
                    self.editActionableType == .habit
                })
            }
            <<< PushRow<CommitDateTuple>() { row in
                row.tag = EditTaskFormTag.commitDateTag.rawValue
                let item:OptionFormItem<CommitDateTuple> = viewModel.item(tag: row.tag) as! OptionFormItem<CommitDateTuple>
                row.title = "Select a commit date"
                row.value = item.value
                row.options = item.options
            }
            +++ Section()
            <<< TextAreaRow() {
                $0.placeholder = "Remarks on your task"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
        }
    }
    
    // MARK: Navigation Bar Button Events
    
    @objc func cancelTapped(_ barButtonItem: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @objc func saveTapped(_ barButtonItem: UIBarButtonItem) {
        do {
            
            let validationErrors = form.validate()
            guard validationErrors.count == 0 else {
                showNotification(text: "There are validation errors")
                return
            }
            
            guard let actionableInfo = actionableInfoFromFields() else {
                showNotification(text: "Bug: Could not create a task or habit")
                return
            }
            
            if let actionable = self.editActionable  {
                try delegate?.updateActionable(actionable: actionable, updateInfo: actionableInfo)
            } else {
                try delegate?.createNewActionable(actionableInfo: actionableInfo)
            }
            
            self.dismiss(animated: true)
        }
        catch let error {
            NSLog("could not create a new task info from fields. \(error.localizedDescription)")
            self.showNotification(forError: error)
        }
    }
    
    func actionableInfoFromFields() -> ActionableInfo? {
        let row:TextRow = self.form.rowBy(tag: EditTaskFormTag.taskTag.rawValue)!
        guard let name = row.value else {
            fatalError("couldn't read name of task or habit")
        }
   
        guard let rowGoal:PushRow<Goal> = self.form.rowBy(tag: EditTaskFormTag.goalTag.rawValue) else {
            fatalError("couldn't extract row for Goal")
        }
        
        let parentGoal = rowGoal.value
        
        var commitDate:Date? = nil
        
        if self.editActionableType == .task {
            guard let rowCommitDate:PushRow<CommitDateTuple> = self.form.rowBy(tag: EditTaskFormTag.commitDateTag.rawValue) else {
                fatalError("couldn't extract row by commit date")
            }
            
            commitDate = rowCommitDate.value?.date
        }
        
        return ActionableInfo(type: editActionableType!, name: name, commitDate: commitDate, parentGoal: parentGoal)
    }
    
    
    // Mark: - data helper methods
}
