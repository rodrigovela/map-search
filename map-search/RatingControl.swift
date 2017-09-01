//
//  RatingControl.swift
//  map-search
//
//  Created by Rodrigo Velazquez on 28/08/17.
//  Copyright © 2017 Rodrigo Velazquez. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    // MARK: Properties
    
    private var ratingButtons = [UIButton]()
    
    var rating = 0 {
        didSet{
            updateButtonSelectionStates()
        }
    }
    
    @IBInspectable var itemSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }

    @IBInspectable var itemCount: Int = 3 {
        didSet {
            setupButtons()
        }
    }
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    // MARK: Private methods
    
    private func setupButtons () {
        
        //ClearButtons
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        // Bundle
        let bundle = Bundle(for: type(of: self))
        
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        
        //CreateButtons
        for _ in 0..<itemCount {
            
            let button = UIButton()
            //button.backgroundColor = UIColor.red
            
            // Set the button images
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)

            
            //Constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: itemSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: itemSize.width).isActive = true
            
            addArrangedSubview(button)
            
            ratingButtons.append(button)
        }
    }
    
    private func updateButtonSelectionStates() {
        for (index,button) in ratingButtons.enumerated() {
            
            button.isSelected = index < rating
        }
    }

}
