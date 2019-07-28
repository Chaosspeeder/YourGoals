//
//  CalendarBarCell.swift
//  YourGoals
//
//  Created by André Claaßen on 26.07.19.
//  Copyright © 2019 André Claaßen. All rights reserved.
//

import UIKit
import Foundation

class CalendarBarCell: UICollectionViewCell {

    let dayNumberLabel = UILabel()
    let dayNameLabel = UILabel()
    let dayProgressRing = UIProgressView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupControls()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupControls()
    }
    
    
    fileprivate func setupControls() {
    
        self.addSubview(dayProgressRing)
        self.addSubview(dayNumberLabel)
        self.addSubview(dayNameLabel)
        
        let views: [String: Any] = [
            "dayNumberLabel": dayNumberLabel,
            "dayProgressRing": dayProgressRing,
            "dayNameLabel": dayNameLabel
        ]
        
        // disable autoresizing in all views
        views.values.forEach { ($0 as! UIView).translatesAutoresizingMaskIntoConstraints = false }
        
        var constraints = [NSLayoutConstraint]()
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[dayNumberLabel(24)]-[dayNameLabel(14)]-8@250-|", options: [], metrics: nil, views: views)
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-[dayProgressRing(==dayNumberLabel)]", options: [], metrics: nil, views: views)
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[dayNumberLabel(24@250)]-|", options: [.alignAllCenterX], metrics: nil, views: views)
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[dayProgressRing(==dayNumberLabel@250)]-|", options: [.alignAllCenterX], metrics: nil, views: views)
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[dayNameLabel(24@250)]-|", options: [.alignAllCenterX], metrics: nil, views: views)
    
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Factory Method
    
    /// get a resuable cell from the collection view.
    ///
    /// - Preconditions
    ///     You must register the cell first
    ///
    /// - Parameters:
    ///   - collectionView: a ui collecition view
    ///   - indexPath: the index path
    /// - Returns: a calendar bar cell
    internal static func dequeue(fromCollectionView collectionView: UICollectionView, atIndexPath indexPath: IndexPath) -> CalendarBarCell {
        guard let cell: CalendarBarCell = collectionView.dequeueReusableCell(indexPath: indexPath) else {
            fatalError("*** Failed to dequeue CalendarBarCell ***")
        }
        return cell
    }
}