//
//  CircleComponent.swift
//  KofktuSDK
//
//  Created by kofktu on 2017. 9. 7..
//  Copyright © 2017년 Kofktu. All rights reserved.
//

import Foundation
import UIKit

open class CornerRadiusButton: TouchExpandButton {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = cornerRadius
    }
    
    // MARK: - Private
    private func commonInit() {
        clipsToBounds = true
        layer.masksToBounds = true
    }
}

open class CircleButton: TouchExpandButton {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2.0
    }
    
    // MARK: - Private
    private func commonInit() {
        clipsToBounds = true
        layer.masksToBounds = true
    }
}

open class CircleImageView: UIImageView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2.0
    }
    
    // MARK: - Private
    private func commonInit() {
        clipsToBounds = true
        layer.masksToBounds = true
    }
}
