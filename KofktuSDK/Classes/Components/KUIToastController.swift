//
//  KUIToastController.swift
//  KofktuSDK
//
//  Created by Kofktu on 2016. 12. 28..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit
import Toaster

public class KUIToastController: NSObject {
    public static let shared = KUIToastController()
    
    var duration: TimeInterval = 0.6
    private var messageQueue = [String]()
    
    private override init() {
        super.init()
        ToastView.appearance().backgroundColor = UIColor.black.withAlphaComponent(0.7)
        ToastView.appearance().cornerRadius = 10.0
        ToastView.appearance().font = UIFont.systemFont(ofSize: 16.0)
        ToastView.appearance().textInsets = UIEdgeInsetsMake(15.0, 20.0, 15.0, 20.0)
        ToastView.appearance().bottomOffsetPortrait = 100.0
        ToastView.appearance().bottomOffsetLandscape = 80.0
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, keyPath == "isFinished", let change = change else { return }
        guard let newValue = change[NSKeyValueChangeKey.newKey] as? Bool, newValue else { return }
        guard let toast = object as? Toast, let message = toast.text else { return }
        
        if messageQueue.contains(message) {
            let _ = messageQueue.remove(object: message)
        }
        
        toast.removeObserver(self, forKeyPath: #keyPath(Toast.isFinished))
    }
    
    public func show(message: String?, duration: TimeInterval? = nil) {
        guard let message = message else { return }
        show(message, duration: duration ?? self.duration)
    }
    
    public func show(error: NSError?, duration: TimeInterval? = nil) {
        guard let error = error else { return }
        show(error.localizedDescription, duration: duration ?? self.duration)
    }
    
    private func show(_ message: String, duration: TimeInterval) {
        guard !messageQueue.contains(message) else { return }
        
        messageQueue.append(message)
        
        let toast = Toast(text: message, delay: 0.0, duration: duration)
        toast.addObserver(self, forKeyPath: #keyPath(Toast.isFinished), options: .new, context: nil)
        toast.show()
    }
}
