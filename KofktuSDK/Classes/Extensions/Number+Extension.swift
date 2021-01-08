//
//  Number+Extension.swift
//  KofktuSDK
//
//  Created by USER on 2021/01/08.
//  Copyright © 2021 Kofktu. All rights reserved.
//

import Foundation

public extension IntegerLiteralType {
    
    var f: CGFloat {
        return CGFloat(self)
    }
    
    var formatted: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(for: self) ?? String(self)
    }
    
    func formatted(fractionDigits: Int = 2) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = fractionDigits
        return numberFormatter.string(for: self) ?? String(self)
    }
}

public extension FloatLiteralType {
    
    var f: CGFloat {
        return CGFloat(self)
    }
    
    var formatted: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(for: self) ?? String(self)
    }
    
    func formatted(fractionDigits: Int = 2) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = fractionDigits
        return numberFormatter.string(for: self) ?? String(self)
    }
    
}
