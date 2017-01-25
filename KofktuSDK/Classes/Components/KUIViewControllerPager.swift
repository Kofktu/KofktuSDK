//
//  KUIViewControllerPager.swift
//  KofktuSDK
//
//  Created by Kofktu on 2016. 9. 7..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import Foundation
import UIKit

// view life cycle 중 will/did Appear/Disappear 메서드가 will/Did 가 동시에 일어나므로 did 에서 처리하길 권장
public protocol KMViewControllerPagerChildViewControllerProtocol {
    var pagerScrollView: UIScrollView? { get }
}

@objc public protocol KUIViewControllerPagerDelegate {
    @objc optional func pagerInitialized(_ pager: KUIViewControllerPager)
    @objc optional func pagerWillChangeIndex(_ pager: KUIViewControllerPager, viewController: UIViewController, atIndex index: Int)
    @objc optional func pagerDidChangeIndex(_ pager: KUIViewControllerPager, viewController: UIViewController, atIndex index: Int)
}

fileprivate class ReusableViewControllerCollectionViewCell: UICollectionViewCell {}

open class KUIViewControllerPager : NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    fileprivate weak var parentViewController: UIViewController!
    fileprivate weak var targetView: UIView!
    
    public fileprivate(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.sectionInset = UIEdgeInsets.zero
        
        let collectionView = UICollectionView(frame: self.targetView.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = false
        collectionView.clipsToBounds = true
        collectionView.scrollsToTop = false
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.addObserver(self, forKeyPath: "contentSize", options: [.new], context: nil)
        collectionView.register(ReusableViewControllerCollectionViewCell.self, forCellWithReuseIdentifier: ReusableViewControllerCollectionViewCell.reusableIdentifier)
        return collectionView
    }()
    
    open weak var delegate: KUIViewControllerPagerDelegate?
    open var viewControllers: [UIViewController]? {
        didSet {
            collectionView.reloadData()
        }
    }
    open var visibleViewController: UIViewController? {
        if let viewControllers = viewControllers, currentIndex < viewControllers.count {
            return viewControllers[currentIndex]
        }
        return nil
    }
    
    open var currentIndex: Int = 0
    public var isScrollEnabled: Bool {
        get {
            return collectionView.isScrollEnabled
        }
        set {
            collectionView.isScrollEnabled = newValue
        }
    }
    fileprivate var willMoveIndex: Int = 0
    fileprivate var contentSizeObserving = true
    fileprivate var scrollObserving = true
    fileprivate var latestOffset = CGPoint.zero
    
    deinit {
        if contentSizeObserving {
            collectionView.removeObserver(self, forKeyPath: "contentSize")
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, keyPath == "contentSize" else { return }
        
        if contentSizeObserving && !collectionView.contentSize.equalTo(CGSize.zero) {
            contentSizeObserving = false
            moveToIndex(currentIndex, animated: false)
            collectionView.removeObserver(self, forKeyPath: "contentSize")
            delegate?.pagerInitialized?(self)
        }
    }
    
    public init(parentViewController: UIViewController, targetView: UIView) {
        super.init()
        
        self.targetView = targetView
        self.parentViewController = parentViewController
        
        parentViewController.automaticallyAdjustsScrollViewInsets = false
        targetView.addSubviewAtFit(collectionView)
    }
    
    open func moveToIndex(_ index: Int, animated: Bool = true) {
        if collectionView.contentSize.equalTo(CGSize.zero) { return }
        
        let moveIndex = max(0, min(index, viewControllers?.count ?? 0))
        
        if animated {
            scrollObserving = false
            UIView.animate(withDuration: 0.25, animations: { 
                self.collectionView.contentOffset = CGPoint(x: CGFloat(moveIndex) * self.collectionView.width, y: 0.0)
            }, completion: { (finished) in
                self.scrollObserving = true
                self.scrollViewDidEndDecelerating(self.collectionView)
            })
        } else {
            UIView.setAnimationsEnabled(false)
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
                addViewControllerIfNeeded(cell, at: index)
            }
            
            collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: animated)
            scrollViewDidEndDecelerating(collectionView)
            UIView.setAnimationsEnabled(true)
        }
    }
    
    open func refreshLayout(_ animated: Bool = true) {
        if animated {
            collectionView.performBatchUpdates({ 
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.setCollectionViewLayout(self.collectionView.collectionViewLayout, animated: false)
            }, completion: nil)
        } else {
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.setCollectionViewLayout(collectionView.collectionViewLayout, animated: false)
        }
    }
    
    fileprivate func updateViewControllersScrollToTop() {
        guard let viewControllers = viewControllers else { return }
        
        for (index, viewController) in viewControllers.enumerated() {
            (viewController as? KMViewControllerPagerChildViewControllerProtocol)?.pagerScrollView?.scrollsToTop = (index == currentIndex)
        }
    }
    
    fileprivate func addViewControllerIfNeeded(_ cell: UICollectionViewCell, at index: Int) {
        guard let viewController = viewControllers?[index], viewController.parent == nil else { return }
        
        parentViewController.addChildViewController(viewController)
        cell.contentView.addSubviewAtFit(viewController.view)
        viewController.didMove(toParentViewController: parentViewController)
    }
    
    fileprivate func removeViewController(_ index: Int) {
        guard let viewController = viewControllers?[index] else { return }
        
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
    // MARK: UIScrollViewDelegate
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        self.scrollViewDidEndDecelerating(scrollView)
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let viewControllers = viewControllers else { return }
        
        let contentOffset = scrollView.contentOffset
        let index = Int(floor(contentOffset.x / scrollView.width))
        
        willMoveIndex = index
        currentIndex = index
        updateViewControllersScrollToTop()
        delegate?.pagerDidChangeIndex?(self, viewController: viewControllers[currentIndex], atIndex: currentIndex)
    }
    
    // MARK: - UICollectionViewProtocol
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers?.count ?? 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: ReusableViewControllerCollectionViewCell.reusableIdentifier, for: indexPath) as! ReusableViewControllerCollectionViewCell
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let viewControllers = viewControllers else { return }
        
        willMoveIndex = indexPath.item
        addViewControllerIfNeeded(cell, at: willMoveIndex)
        delegate?.pagerWillChangeIndex?(self, viewController: viewControllers[willMoveIndex], atIndex: willMoveIndex)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        removeViewController(indexPath.item)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.size
    }
}
