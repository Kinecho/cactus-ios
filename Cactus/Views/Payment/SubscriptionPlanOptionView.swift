//
//  SubscriptionPlanOptionView.swift
//  Cactus
//
//  Created by Neil Poulin on 2/27/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import UIKit

@IBDesignable
class SubscriptionPlanOptionView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var dividerLabel: UILabel!
    
    var selectedTextColor: UIColor = CactusColor.textWhite
    var defaultTextColor: UIColor = CactusColor.textDefault
    
    var selected: Bool = false {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var view: UIView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    func initView() {
        let view = loadViewFromNib()
        view.frame = self.bounds
        self.view = view
        self.addSubview(view)
        self.configure()
                
    }
    
    func configure() {
        self.layer.borderColor = CactusColor.white.withAlphaComponent(0.6).cgColor
        self.layer.borderWidth = CGFloat(1)
        self.layer.cornerRadius = CGFloat(12)
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.selected {
            self.backgroundColor = CactusColor.white
            self.setTextColor(self.selectedTextColor)
        } else {
            self.backgroundColor = .clear
            self.setTextColor(self.defaultTextColor)
        }
    }
    
    func setTextColor(_ color: UIColor) {
        self.titleLabel.textColor = color
        self.priceLabel.textColor = color
        self.periodLabel.textColor = color
        self.dividerLabel.textColor = color
        
    }
    
}
