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
    optional func pagerInitialized(pager: KUIViewControllerPager)
    optional func pagerWillChangeIndex(pager: KUIViewControllerPager, viewController: UIViewController, atIndex index: Int)
    optional func pagerDidChangeIndex(pager: KUIViewControllerPager, viewController: UIViewController, atIndex index: Int)
}

private class ReusableViewControllerCollectionViewCell: UICollectionViewCell {}

public class KUIViewControllerPager : NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private weak var parentViewController: UIViewController!
    private weak var targetView: UIView!
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.sectionInset = UIEdgeInsetsZero
        
        let collectionView = UICollectionView(frame: self.targetView.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = false
        collectionView.clipsToBounds = true
        collectionView.scrollsToTop = false
        collectionView.pagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.addObserver(self, forKeyPath: "contentSize", options: [.New], context: nil)
        collectionView.registerClass(ReusableViewControllerCollectionViewCell.self, forCellWithReuseIdentifier: ReusableViewControllerCollectionViewCell.reusableIdentifier)
        return collectionView
    }()
    
    public weak var delegate: KUIViewControllerPagerDelegate?
    public var viewControllers: [UIViewController]? {
        didSet {
            collectionView.reloadData()
        }
    }
    public var visibleViewController: UIViewController? {
        if let viewControllers = viewControllers where currentIndex < viewControllers.count {
            return viewControllers[currentIndex]
        }
        return nil
    }
    
    public var currentIndex: Int = 0
    private var willMoveIndex: Int = 0
    private var contentSizeObserving = true
    private var scrollObserving = true
    private var latestOffset = CGPointZero
    
    deinit {
        if contentSizeObserving {
            collectionView.removeObserver(self, forKeyPath: "contentSize")
        }
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let keyPath = keyPath where keyPath == "contentSize" else { return }
        
        if contentSizeObserving && !CGSizeEqualToSize(collectionView.contentSize, CGSizeZero)  {
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
    
    public func moveToIndex(index: Int, animated: Bool = true) {
        if CGSizeEqualToSize(collectionView.contentSize, CGSizeZero) { return }
        
        let moveIndex = max(0, min(index, viewControllers?.count ?? 0))
        
        if animated {
            scrollObserving = false
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.collectionView.contentOffset = CGPointMake(CGFloat(moveIndex) * self.collectionView.width, 0.0)
                }, completion: { (finished) -> Void in
                    self.scrollObserving = true
                    self.scrollViewDidEndDecelerating(self.collectionView)
            })
        } else {
            UIView.setAnimationsEnabled(false)
            if let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0)) {
                addViewControllerIfNeeded(cell, at: index)
            }
            
            collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: animated)
            scrollViewDidEndDecelerating(self.collectionView)
            UIView.setAnimationsEnabled(true)
        }
    }
    
    private func updateViewControllersScrollToTop() {
        guard let viewControllers = viewControllers else { return }
        
        for (index, viewController) in viewControllers.enumerate() {
            (viewController as? KMViewControllerPagerChildViewControllerProtocol)?.pagerScrollView?.scrollsToTop = (index == currentIndex)
        }
    }
    
    private func addViewControllerIfNeeded(cell: UICollectionViewCell, at index: Int) {
        guard let viewController = viewControllers?[index] where viewController.parentViewController == nil else { return }
        
        parentViewController.addChildViewController(viewController)
        cell.contentView.addSubviewAtFit(viewController.view)
        viewController.didMoveToParentViewController(parentViewController)
    }
    
    private func removeViewController(index: Int) {
        guard let viewController = viewControllers?[index] else { return }
        
        viewController.willMoveToParentViewController(nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
    // MARK: UIScrollViewDelegate
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        self.scrollViewDidEndDecelerating(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        guard let viewControllers = viewControllers else { return }
        
        let contentOffset = scrollView.contentOffset
        let index = Int(floor(contentOffset.x / scrollView.width))
        
        willMoveIndex = index
        currentIndex = index
        updateViewControllersScrollToTop()
        delegate?.pagerDidChangeIndex?(self, viewController: viewControllers[currentIndex], atIndex: currentIndex)
    }
    
    // MARK: - UICollectionViewProtocol
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers?.count ?? 0
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(ReusableViewControllerCollectionViewCell.reusableIdentifier, forIndexPath: indexPath) as! ReusableViewControllerCollectionViewCell
    }
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let viewControllers = viewControllers else { return }
        
        willMoveIndex = indexPath.item
        addViewControllerIfNeeded(cell, at: willMoveIndex)
        delegate?.pagerWillChangeIndex?(self, viewController: viewControllers[willMoveIndex], atIndex: willMoveIndex)
    }
    
    public func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        removeViewController(indexPath.item)
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.size
    }
}