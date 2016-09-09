//
//  KUIImageViewController.swift
//  KofktuSDK
//
//  Created by Kofktu on 2016. 9. 9..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit

@objc public protocol KUIImageViewControllerDataSource: class {
    // Required
    func numberOfImages(controller: KUIImageViewController) -> Int
    func imageUrlString(at index: Int, controller: KUIImageViewController) -> String?
    
    // Optional
    optional func placeholderImage(at index: Int, controller: KUIImageViewController) -> UIImage?
    optional func senderView(at index: Int, controller: KUIImageViewController) -> UIView?
}

@objc public protocol KUIImageViewControllerDelegate: class {
    
    // Optional
    optional func gestureBegan(controller: KUIImageViewController)
    optional func gestureChanged(controller: KUIImageViewController, translation: CGPoint)
    optional func willShow(controller: KUIImageViewController)
    optional func didShow(controller: KUIImageViewController)
    optional func willDismiss(controller: KUIImageViewController)
    optional func didDismiss(controller: KUIImageViewController)
    optional func willRollback(controller: KUIImageViewController)
    optional func didRollback(controller: KUIImageViewController)
    
    optional func willDisplay(at index: Int, controller: KUIImageViewController, contentView: UIView)
    optional func didEndDisplaying(at index: Int, controller: KUIImageViewController, contentView: UIView)
    
    optional func singleTap(at index: Int, controller: KUIImageViewController)
}


public class KUIImageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, KUIPhotoViewDelegate {
    
    weak var delegate: KUIImageViewControllerDelegate?
    weak var dataSource: KUIImageViewControllerDataSource?
    weak var senderView: UIView?
    
    private var panGesture: UIPanGestureRecognizer?
    private var startOrigin: CGPoint = CGPointZero
    private weak var fromViewController: UIViewController!
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.sectionInset = UIEdgeInsetsZero
        
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = false
        collectionView.pagingEnabled = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.registerClass(KUIImageViewerContentCollectionViewCell.self, forCellWithReuseIdentifier: KUIImageViewerContentCollectionViewCell.reusableIdentifier)
        return collectionView
    }()
    private lazy var snapshotImgView: UIImageView = {
        let snapshotImgView = UIImageView(frame: CGRectZero)
        snapshotImgView.contentMode = .ScaleAspectFit
        return snapshotImgView
    }()
    
    private var snapshotImage: UIImage? {
        return (senderView as? UIImageView)?.image ?? (senderView as? UIButton)?.currentImage ?? senderView?.capture()
    }
    private(set) var currentIndex: Int = 0
    private let threshold: CGFloat = 100.0
    
    public override func loadView() {
        super.loadView()
        
        view.insertSubview(collectionView, atIndex: 0)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": collectionView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": collectionView]))
    }
    
    public func show(fromViewController: UIViewController, completion: (() -> Void)? = nil) {
        if let senderView = senderView, window = UIApplication.sharedApplication().keyWindow {
            snapshotImgView.frame = window.convertRect(senderView.frame, fromView: senderView.superview)
            snapshotImgView.image = snapshotImage
            snapshotImgView.clipsToBounds = senderView.clipsToBounds
            snapshotImgView.layer.cornerRadius = senderView.layer.cornerRadius
            snapshotImgView.hidden = false
            view.addSubview(snapshotImgView)
            
            senderView.alpha = 0.0
            collectionView.alpha = 0.0
        }
        
        modalPresentationStyle = .Custom
        modalPresentationCapturesStatusBarAppearance = true
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        delegate?.willShow?(self)
        
        fromViewController.presentViewController(self, animated: false) {
            UIView.animateWithDuration(0.25, animations: {
                self.snapshotImgView.frame = self.view.convertRect(self.collectionView.frame, fromView: self.view)
                self.view.backgroundColor = UIColor.blackColor()
                }, completion: { (finished) in
                    self.senderView?.alpha = 1.0
                    self.collectionView.alpha = 1.0
                    self.collectionView.reloadData()
                    self.snapshotImgView.layer.cornerRadius = 0.0
                    self.snapshotImgView.hidden = true
                    self.snapshotImgView.removeFromSuperview()
                    self.fromViewController = fromViewController
                    self.registerGesture()
                    self.delegate?.didShow?(self)
                    completion?()
            })
        }
    }
    
    public func dismiss() {
        if self.snapshotImgView.superview == nil {
            senderView?.alpha = 0.0
            collectionView.alpha = 0.0
            collectionView.scrollEnabled = false
            snapshotImgView.image = (collectionView.visibleCells().first as? KUIImageViewerContentCollectionViewCell)?.image
            snapshotImgView.frame = collectionView.bounds
            snapshotImgView.hidden = false
            view.addSubview(snapshotImgView)
        }
        
        panGesture?.enabled = false
        delegate?.willDismiss?(self)
        
        UIView.animateWithDuration(0.25, animations: {
            if let senderView = self.senderView, window = UIApplication.sharedApplication().keyWindow {
                self.snapshotImgView.frame = window.convertRect(senderView.frame, fromView: senderView.superview)
                self.snapshotImgView.layer.cornerRadius = senderView.layer.cornerRadius
            }
            
            self.view.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        }) { (finished) in
            self.snapshotImgView.removeFromSuperview()
            self.senderView?.alpha = 1.0
            self.dismissViewControllerAnimated(false, completion: {
                self.delegate?.didDismiss?(self)
            })
        }
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    func move(at index: Int, animated: Bool = true) {
        collectionView.selectItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), animated: animated, scrollPosition: .CenteredHorizontally)
    }
    
    // MARK: - Private
    private func registerGesture() {
        unregisterGesture()
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        panGesture?.delegate = self
        panGesture?.cancelsTouchesInView = false
        
        guard let gesture = panGesture else { return }
        collectionView.panGestureRecognizer.requireGestureRecognizerToFail(gesture)
        view.addGestureRecognizer(gesture)
    }
    
    private func unregisterGesture() {
        defer {
            panGesture?.delegate = nil
            panGesture = nil
        }
        
        guard let gesture = panGesture else { return }
        view.removeGestureRecognizer(gesture)
    }
    
    private func rollback() {
        panGesture?.enabled = false
        delegate?.willRollback?(self)
        
        UIView.animateWithDuration(0.25, animations: {
            self.snapshotImgView.y = 0.0
            self.view.backgroundColor = UIColor.blackColor()
        }) { (finished) in
            self.snapshotImgView.hidden = true
            self.snapshotImgView.removeFromSuperview()
            self.collectionView.alpha = 1.0
            self.collectionView.scrollEnabled = true
            self.panGesture?.enabled = true
            self.delegate?.didRollback?(self)
        }
    }
    
    // MARK: - Actions
    func pan(gesture: UIPanGestureRecognizer) {
        switch gesture.state{
        case .Began:
            senderView?.alpha = 0.0
            collectionView.alpha = 0.0
            collectionView.scrollEnabled = false
            snapshotImgView.image = (collectionView.visibleCells().first as? KUIImageViewerContentCollectionViewCell)?.image
            snapshotImgView.frame = collectionView.frame
            snapshotImgView.hidden = false
            view.addSubview(snapshotImgView)
            delegate?.gestureBegan?(self)
        case .Changed:
            let translation = gesture.translationInView(view)
            let alpha = 1.0 - abs(translation.y) / view.height
            
            snapshotImgView.y = translation.y
            view.backgroundColor = UIColor(white: 0.0, alpha: max(alpha, 0.5))
            delegate?.gestureChanged?(self, translation: translation)
        default:
            let translation = gesture.translationInView(view)
            let alpha = 1.0 - abs(translation.y) / view.height
            
            if alpha < 0.8 {
                dismiss()
            } else {
                rollback()
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / scrollView.width)
        senderView = dataSource?.senderView?(at: currentIndex, controller: self) ?? senderView
    }
    
    // MARK: - UICollectionViewProtocol
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfImages(self) ?? 0
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as KUIImageViewerContentCollectionViewCell
        cell.delegate = self
        cell.imageUrl = (dataSource?.imageUrlString(at: indexPath.item, controller: self), dataSource?.placeholderImage?(at: indexPath.item, controller: self))
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        currentIndex = indexPath.item
        senderView = dataSource?.senderView?(at: indexPath.item, controller: self) ?? senderView
        delegate?.willDisplay?(at: indexPath.item, controller: self, contentView: cell)
    }
    
    public func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.didEndDisplaying?(at: indexPath.item, controller: self, contentView: cell)
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.size
    }
    
    // MARK: - UIGestureRecognizerDelegate
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let cell = (collectionView.visibleCells().first as? KUIImageViewerContentCollectionViewCell) where !cell.isZooming else { return false }
        guard let velocity = (gestureRecognizer as? UIPanGestureRecognizer)?.velocityInView(gestureRecognizer.view) where velocity.y != 0 else { return true }
        return abs(velocity.y) > abs(velocity.x) + threshold
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == panGesture
    }
    
    // MARK: - KUIPhotoViewDelegate
    public func singleTap(photoView: KUIPhotoView) {
        delegate?.singleTap?(at: currentIndex, controller: self)
    }
    
}

public class KUIImageViewerContentCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    public weak var delegate: KUIPhotoViewDelegate? {
        get {
            return photoView.photoDelegate
        }
        set {
            photoView.photoDelegate = newValue
        }
    }
    
    public var isZooming: Bool {
        return photoView.zoomScale != photoView.minimumZoomScale
    }
    
    public var imageUrl: (String?, UIImage?) {
        didSet {
            photoView.imageUrl = imageUrl
        }
    }
    
    public var image: UIImage? {
        return photoView.imageView.image
    }
    
    private lazy var photoView: KUIPhotoView = {
        let photoView = KUIPhotoView(frame: self.bounds)
        return photoView
    }()
    
    required public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
        addSubviewAtFit(photoView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        photoView.resetZoom()
    }
    
}

@objc public protocol KUIPhotoViewDelegate: class {
    optional func singleTap(photoView: KUIPhotoView)
}

public class KUIPhotoView: UIScrollView, UIScrollViewDelegate {
    
    weak public var photoDelegate: KUIPhotoViewDelegate?
    
    override public var frame: CGRect {
        didSet {
            let origin = imageView.origin
            
            contentSize = CGSizeMake(CGRectGetWidth(frame) * zoomScale, CGRectGetHeight(frame) * zoomScale)
            imageView.frame = CGRectMake(origin.x, origin.y, CGRectGetWidth(frame) * zoomScale, CGRectGetHeight(frame) * zoomScale)
        }
    }
    
    public var imageUrl: (String?, UIImage?) {
        didSet {
            imageView.setShowActivityIndicatorView(imageUrl.1 == nil)
            imageView.setImageWithUrlString(imageUrl.0, placeholder: imageUrl.1)
        }
    }
    
    lazy public var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.bounds)
        imageView.backgroundColor = UIColor.clearColor()
        imageView.contentMode = .ScaleAspectFit
        imageView.setIndicatorStyle(.White)
        return imageView
    }()
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        delegate = self
        scrollsToTop = false
        minimumZoomScale = 1.0
        maximumZoomScale = 2.5
        decelerationRate = UIScrollViewDecelerationRateFast
        backgroundColor = UIColor.clearColor()
        
        addSubview(imageView)
        registerGestures()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func resetZoom() {
        zoomToRect(bounds, animated: false)
        setZoomScale(minimumZoomScale, animated: false)
        contentSize = CGSizeMake(CGRectGetWidth(frame) * zoomScale, CGRectGetHeight(frame) * zoomScale)
    }
    
    public func singleTap(gesture: UITapGestureRecognizer) {
        photoDelegate?.singleTap?(self)
    }
    
    public func doubleTap(gesture: UITapGestureRecognizer) {
        guard zoomScale == minimumZoomScale else {
            setZoomScale(minimumZoomScale, animated: true)
            return
        }
        
        let location = gesture.locationInView(self)
        let zoomRectSize = CGSizeMake(CGRectGetWidth(frame) / maximumZoomScale, CGRectGetHeight(frame) / maximumZoomScale)
        var zoomRect = CGRectMake(max(0.0, location.x - (zoomRectSize.width * 0.5)),
                                  max(0.0, location.y - (zoomRectSize.height * 0.5)),
                                  zoomRectSize.width,
                                  zoomRectSize.height)
        
        if zoomRect.origin.x + zoomRect.size.width > CGRectGetWidth(frame) {
            zoomRect.origin.x = CGRectGetWidth(frame) - zoomRect.size.width
        }
        
        if zoomRect.origin.y + zoomRect.size.height > CGRectGetHeight(frame) {
            zoomRect.origin.y = CGRectGetHeight(frame) - zoomRect.size.height
        }
        
        zoomToRect(zoomRect, animated: true)
    }
    
    private func registerGestures() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTap(_:)))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        singleTap.requireGestureRecognizerToFail(doubleTap)
        
        addGestureRecognizer(singleTap)
        addGestureRecognizer(doubleTap)
    }
    
    // MARK: - UIScrollViewDelegate
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}

public class KUISimpleImageViewerViewController: KUIImageViewController, KUIImageViewControllerDataSource, KUIImageViewControllerDelegate {
    
    @IBOutlet public weak var closeButton: UIButton!
    
    var imageUrl: String? {
        didSet {
            guard isViewLoaded() && imageUrl != oldValue else { return }
            reloadData()
        }
    }
    
    public var placeHolderImage: UIImage?
    private var originStatusBarStyle: UIStatusBarStyle = .Default
    
    public override func loadView() {
        super.loadView()
        delegate = self
        dataSource = self
        
        if closeButton == nil {
            let button = UIButton(type: .Custom)
            button.setImage(UIImage(named: "close"), forState: .Normal)
            button.addTarget(self, action: #selector(dismiss), forControlEvents: .TouchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
            view.addConstraint(NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 5.0))
            view.addConstraint(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Top, multiplier: 1.0, constant: 25.0))
            button.addConstraint(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0))
            button.addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0))
            closeButton = button
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        originStatusBarStyle = UIApplication.sharedApplication().statusBarStyle
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: animated)
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: animated)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(originStatusBarStyle, animated: animated)
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(originStatusBarStyle, animated: animated)
    }
    
    // MARK: - KUIImageViewControllerDataSource
    public func numberOfImages(controller: KUIImageViewController) -> Int {
        return 1
    }
    
    public func imageUrlString(at index: Int, controller: KUIImageViewController) -> String? {
        return imageUrl
    }
    
    public func placeholderImage(at index: Int, controller: KUIImageViewController) -> UIImage? {
        return snapshotImage ?? placeHolderImage
    }
    
    public func willShow(controller: KUIImageViewController) {
        closeButton.alpha = 0.0
    }
    
    public func didShow(controller: KUIImageViewController) {
        closeButton.alpha = 1.0
    }
    
    public func willDismiss(controller: KUIImageViewController) {
        closeButton.alpha = 0.0
    }
    
    public func didDismiss(controller: KUIImageViewController) {
        closeButton.alpha = 1.0
    }
    
    public func willRollback(controller: KUIImageViewController) {
        closeButton.alpha = 0.0
    }
    
    public func didRollback(controller: KUIImageViewController) {
        closeButton.alpha = 1.0
    }
    
    public func gestureBegan(controller: KUIImageViewController) {
        closeButton.alpha = 0.0
    }
    
    public func singleTap(at index: Int, controller: KUIImageViewController) {
        UIView.animateWithDuration(0.25) {
            if self.closeButton.alpha > 0.0 {
                self.closeButton.alpha = 0.0
            } else {
                self.closeButton.alpha = 1.0
            }
        }
    }
}

@objc public protocol KUIMultiImageViewerViewControllerDelegate: class {
    optional func senderView(at index: Int, controller: KUIMultiImageViewerViewController) -> UIView?
}

public class KUIMultiImageViewerViewController: KUIImageViewController, KUIImageViewControllerDataSource, KUIImageViewControllerDelegate {
    
    @IBOutlet public weak var closeButton: UIButton!
    @IBOutlet public weak var titleLabel: UILabel!
    
    public weak var multiDelegate: KUIMultiImageViewerViewControllerDelegate?
    public var font = UIFont.systemFontOfSize(17.0)
    public var imageUrls: Array<String>?
    public var placeHolderImage: UIImage?
    
    private var originStatusBarStyle: UIStatusBarStyle = .Default
    
    public override func loadView() {
        super.loadView()
        delegate = self
        dataSource = self
        
        if closeButton == nil {
            let button = UIButton(type: .Custom)
            button.setImage(UIImage(named: "close"), forState: .Normal)
            button.addTarget(self, action: #selector(dismiss), forControlEvents: .TouchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
            view.addConstraint(NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 5.0))
            view.addConstraint(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Top, multiplier: 1.0, constant: 25.0))
            button.addConstraint(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0))
            button.addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0))
            closeButton = button
        }
        
        if titleLabel == nil {
            let label = UILabel(frame: CGRectZero)
            label.font = font
            label.textColor = UIColor.whiteColor()
            label.textAlignment = .Center
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: closeButton, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            titleLabel = label
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        originStatusBarStyle = UIApplication.sharedApplication().statusBarStyle
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: animated)
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: animated)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(originStatusBarStyle, animated: animated)
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(originStatusBarStyle, animated: animated)
    }
    
    // MARK: - KUIImageViewControllerDataSource
    public override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        super.scrollViewDidEndDecelerating(scrollView)
        titleLabel.text = "\(currentIndex + 1) / \(imageUrls?.count ?? 0)"
    }
    
    public func numberOfImages(controller: KUIImageViewController) -> Int {
        return imageUrls?.count ?? 0
    }
    
    public func imageUrlString(at index: Int, controller: KUIImageViewController) -> String? {
        return imageUrls?[index]
    }
    
    public func placeholderImage(at index: Int, controller: KUIImageViewController) -> UIImage? {
        guard let senderView = senderView(at: index, controller: self) else { return placeHolderImage }
        return (senderView as? UIImageView)?.image ?? (senderView as? UIButton)?.currentImage ?? senderView.capture()
    }
    
    public func senderView(at index: Int, controller: KUIImageViewController) -> UIView? {
        return multiDelegate?.senderView?(at: index, controller: self)
    }
    
    public func willDisplay(at index: Int, controller: KUIImageViewController, contentView: UIView) {
        titleLabel.text = "\(index + 1) / \(imageUrls?.count ?? 0)"
    }
    
    public func willShow(controller: KUIImageViewController) {
        closeButton.alpha = 0.0
        titleLabel.alpha = 0.0
    }
    
    public func didShow(controller: KUIImageViewController) {
        closeButton.alpha = 1.0
        titleLabel.alpha = 1.0
    }
    
    public func willDismiss(controller: KUIImageViewController) {
        closeButton.alpha = 0.0
        titleLabel.alpha = 0.0
    }
    
    public func didDismiss(controller: KUIImageViewController) {
        closeButton.alpha = 1.0
        titleLabel.alpha = 1.0
    }
    
    public func willRollback(controller: KUIImageViewController) {
        closeButton.alpha = 0.0
        titleLabel.alpha = 0.0
    }
    
    public func didRollback(controller: KUIImageViewController) {
        closeButton.alpha = 1.0
        titleLabel.alpha = 1.0
    }
    
    public func gestureBegan(controller: KUIImageViewController) {
        closeButton.alpha = 0.0
        titleLabel.alpha = 0.0
    }
    
    public func singleTap(at index: Int, controller: KUIImageViewController) {
        UIView.animateWithDuration(0.25) {
            if self.closeButton.alpha > 0.0 {
                self.closeButton.alpha = 0.0
                self.titleLabel.alpha = 0.0
            } else {
                self.closeButton.alpha = 1.0
                self.titleLabel.alpha = 0.0
            }
        }
    }
    
}