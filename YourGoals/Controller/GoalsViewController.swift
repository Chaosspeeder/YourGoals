//
//  ViewController.swift
//  YourGoals
//
//  Created by André Claaßen on 22.10.17.
//  Copyright © 2017 André Claaßen. All rights reserved.
//

import UIKit

class GoalsViewController: UIViewController, NewGoalCellDelegate, NewGoalViewControllerDelegate{

    // data properties
    var manager:GoalsStorageManager!
    var strategy:Goal?
    var selectedGoal:Goal?
    
    internal let presentStoryAnimationController = PresentStoryViewAnimationController()
    internal let dismissStoryAnimationController = DismissStoryViewAnimationController()

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.manager = GoalsStorageManager.defaultStorageManager
        self.strategy = try! StrategyManager(manager: self.manager).activeStrategy()
        
        configure(collectionView: collectionView)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
        destinationViewController.transitioningDelegate = self
        if let detailController = destinationViewController as? GoalDetailViewController {
            detailController.goal = self.selectedGoal
            return
        }
        
        if let newGoalController = destinationViewController as? NewGoalViewController {
            newGoalController.delegate = self
            return
        }
    }
    
    // MARK: - NewGoalCellDelegate
    
    func newGoalClicked() {
        performSegue(withIdentifier: "editGoal", sender: self)
    }
    
    // MARK: - NewGoalViewControllerDelegate
    
    func createNewGoal(goalInfo: GoalInfo) {
        do {
            let strategyManager = StrategyManager(manager: self.manager)
            let goalFactory = GoalFactory(manager: self.manager)
            let goal = try goalFactory.create(fromGoalInfo: goalInfo)
            try strategyManager.saveIntoStrategy(goal: goal)
        }
        catch let error {
            self.showNotification(forError: error)
        }
    }
}


