//
//  BorderedButton.swift
//  Cactus
//
//  Created by Neil Poulin on 7/26/19.
//  Copyright © 2019 Cactus. All rights reserved.
//

import UIKit

class BorderedButton: UIButton {
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    var ringColor = UIColor.black
    
    
    
    var ringThickness: CGFloat = 2
    
    //    @IBInspectable
    var score:Int?=1 {
        didSet {
            print("set score \(String(self.score ?? -1))")
            self.updateScore()
        }
    }
    
    private var scoreLabel:UILabel?
    var shapeLayer:CAShapeLayer?
    var borderLayer:CAShapeLayer?
    //initWithFrame to init view from code
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        self.setupView()
//        self.updateImage()
    }
    
    func updateScore(){
        self.scoreLabel?.text = self.score != nil ? String(self.score!) : ""
        self.updateColors()
    }
//
//    func updateImage(){
//        self.metricImage?.image = getMetricImage()
//
//
//    }
//
    //common func to init our view
    private func setupView() {
        
        self.makeCircle()
        self.drawRingFittingInsideView(rect: self.bounds)
        
//        let radius = min(self.bounds.size.height, self.bounds.size.width)
//        let imageView = UIImageView(frame: self.bounds.insetBy(dx: radius/8 + ringThickness/2, dy: radius/8 + ringThickness/2))
//        self.metricImage = imageView
//        imageView.image = getMetricImage()
        
//        addSubview(imageView)
        
    }
    
    
    func getMainColor() -> UIColor {
        return .clear
    }
    
    func getBorderColor() -> UIColor {
        return self.getMainColor().darker(by: 20.0) ?? UIColor.clear
    }
    
    func getImageColor() -> UIColor {
        return self.getMainColor().darker(by: 15)!
    }
    
    func updateColors(){
        self.shapeLayer?.fillColor = getMainColor().cgColor
        self.borderLayer?.strokeColor = getBorderColor().cgColor
//        self.metricImage?.tintColor = getImageColor()
    }
    
    
    func makeCircle()
    {
        let dotPath = UIBezierPath(ovalIn: self.bounds)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = dotPath.cgPath
        self.shapeLayer = shapeLayer
        shapeLayer.fillColor = getMainColor().cgColor
        layer.addSublayer(shapeLayer)
    }
    
    internal func drawRingFittingInsideView(rect: CGRect)->()
    {
        let hw:CGFloat = ringThickness/2
        let circlePath = UIBezierPath(ovalIn: rect.insetBy(dx: hw, dy: hw))
        
        let shapeLayer = CAShapeLayer()
        self.borderLayer = shapeLayer
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = getBorderColor().cgColor
        shapeLayer.lineWidth = ringThickness
        layer.addSublayer(shapeLayer)
    }
    
    //    override func layoutSubviews(){ layer.cornerRadius = bounds.size.width/2; }
}
