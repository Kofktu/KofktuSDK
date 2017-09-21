//
//  UILineView.swift
//  KofktuSDK
//
//  Created by kofktu on 2016. 7. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit

open class KUILineView: UIView {

    @IBInspectable open var showTopLine: Bool = false {
        didSet {
            updateBorders()
        }
    }
    @IBInspectable open var showBottomLine: Bool = false {
        didSet {
            updateBorders()
        }
    }
    @IBInspectable open var lineHeight: CGFloat = snap(1.0 / UIScreen.main.scale) {
        didSet {
            updateWidths()
        }
    }
    @IBInspectable open var lineColor: UIColor = UIColor.lightGray {
        didSet {
            updateColors()
        }
    }
    open var topInsets: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            updateInsets()
        }
    }
    
    open var bottomInsets: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            updateInsets()
        }
    }
    
    override open class var layerClass: AnyClass {
        return KUIBorderedLayer.self
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        layer.frame = frame
    }
    
    // MARK: - Private
    private func setup() {
        updateBorders()
        updateWidths()
        updateColors()
        updateInsets()
    }
    
    private func updateBorders() {
        if showTopLine && showBottomLine {
            borderedLayer?.borders = [.top, .bottom]
        } else if showTopLine {
            borderedLayer?.borders = [.top]
        } else if showBottomLine {
            borderedLayer?.borders = [.bottom]
        } else {
            borderedLayer?.borders = []
        }
    }
    
    private func updateWidths() {
        borderedLayer?.borderWidths = [
            .top: lineHeight,
            .bottom: lineHeight
        ]
    }
    
    private func updateColors() {
        borderedLayer?.borderColors = [
            .top: lineColor,
            .bottom: lineColor
        ]
    }
    
    private func updateInsets() {
        borderedLayer?.borderInsets = [
            .top: (topInsets.left, topInsets.right),
            .bottom: (bottomInsets.left, bottomInsets.right)
        ]
    }
}

fileprivate extension KUILineView {
    
    var borderedLayer: KUIBorderedLayer? {
        return layer as? KUIBorderedLayer
    }
    
}

final fileprivate class KUIBorderedLayer: CALayer {
    struct Border: OptionSet, Hashable {
        var rawValue: UInt
        var hashValue: Int
        
        init(rawValue: UInt) {
            self.rawValue = rawValue
            self.hashValue = Int(rawValue)
        }
        
        static let top    = Border(rawValue: 1 << 0)
        static let left   = Border(rawValue: 1 << 1)
        static let bottom = Border(rawValue: 1 << 2)
        static let right  = Border(rawValue: 1 << 3)
    }
    
    typealias Insets = (CGFloat, CGFloat)
    
    fileprivate var borders: Border = [] {
        didSet {
            updateBordersHidden()
        }
    }
    
    fileprivate var borderColors = [Border: UIColor]() {
        didSet {
            updateBordersColor()
        }
    }
    
    fileprivate var borderWidths = [Border: CGFloat]() {
        didSet {
            updateBordersFrame()
        }
    }
    
    fileprivate var borderInsets = [Border: Insets]() {
        didSet {
            updateBordersFrame()
        }
    }
    
    override var frame: CGRect {
        didSet {
            updateBordersFrame()
        }
    }
    
    private let topBorder = CALayer()
    private let leftBorder = CALayer()
    private let bottomBorder = CALayer()
    private let rightBorder = CALayer()
    
    override init() {
        super.init()
        
        borderColor = nil
        borderWidth = 0
        
        addSublayer(topBorder)
        addSublayer(leftBorder)
        addSublayer(bottomBorder)
        addSublayer(rightBorder)
        
        updateBordersHidden()
        updateBordersColor()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        topBorder.zPosition = CGFloat(sublayers?.count ?? 0)
        leftBorder.zPosition = topBorder.zPosition
        bottomBorder.zPosition = topBorder.zPosition
        rightBorder.zPosition = topBorder.zPosition
    }
    
    // MARK: - Private
    private func updateBordersHidden() {
        topBorder.isHidden = !borders.contains(.top)
        leftBorder.isHidden = !borders.contains(.left)
        bottomBorder.isHidden = !borders.contains(.bottom)
        rightBorder.isHidden = !borders.contains(.right)
    }
    
    private func updateBordersColor() {
        topBorder.backgroundColor = colorForBorder(.top).cgColor
        leftBorder.backgroundColor = colorForBorder(.left).cgColor
        bottomBorder.backgroundColor = colorForBorder(.bottom).cgColor
        rightBorder.backgroundColor = colorForBorder(.right).cgColor
    }
    
    private func updateBordersFrame() {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        let topInsets = insetsForBorder(.top)
        topBorder.frame.size.width = frame.width - topInsets.0 - topInsets.1
        topBorder.frame.size.height = widthForBorder(.top)
        topBorder.frame.origin.x = topInsets.0
        
        let bottomInsets = insetsForBorder(.bottom)
        bottomBorder.frame.size.width = frame.width - bottomInsets.0 - bottomInsets.1
        bottomBorder.frame.size.height = widthForBorder(.bottom)
        bottomBorder.frame.origin.x = bottomInsets.0
        bottomBorder.frame.origin.y = frame.height - bottomBorder.frame.size.height
        
        let leftInsets = insetsForBorder(.left)
        leftBorder.frame.size.width = widthForBorder(.left)
        leftBorder.frame.size.height = frame.height - leftInsets.0 - leftInsets.1
        leftBorder.frame.origin.y = leftInsets.0
        
        let rightInsets = insetsForBorder(.right)
        rightBorder.frame.size.width = widthForBorder(.right)
        rightBorder.frame.size.height = frame.height - rightInsets.0 - rightInsets.1
        rightBorder.frame.origin.x = frame.width - rightBorder.frame.size.width
        rightBorder.frame.origin.y = rightInsets.0
        
        CATransaction.commit()
    }
    
    private func colorForBorder(_ border: Border) -> UIColor {
        if let value = borderColors[border] {
            return value
        }
        for (key, value) in borderColors {
            if key.contains(border) {
                return value
            }
        }
        return .lightGray
    }
    
    private func widthForBorder(_ border: Border) -> CGFloat {
        if let value = borderWidths[border] {
            return value
        }
        for (key, value) in borderWidths {
            if key.contains(border) {
                return value
            }
        }
        return snap(1.0 / UIScreen.main.scale)
    }
    
    private func insetsForBorder(_ border: Border) -> Insets {
        if let value = borderInsets[border] {
            return value
        }
        for (key, value) in borderInsets {
            if key.contains(border) {
                return value
            }
        }
        return (0, 0)
    }
}
