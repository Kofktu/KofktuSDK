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
    func numberOfImages(_ controller: KUIImageViewController) -> Int
    func imageUrlString(at index: Int, controller: KUIImageViewController) -> String?
    
    // Optional
    @objc optional func placeholderImage(at index: Int, controller: KUIImageViewController) -> UIImage?
    @objc optional func senderView(at index: Int, controller: KUIImageViewController) -> UIView?
}

@objc public protocol KUIImageViewControllerDelegate: class {
    
    // Optional
    @objc optional func gestureBegan(_ controller: KUIImageViewController)
    @objc optional func gestureChanged(_ controller: KUIImageViewController, translation: CGPoint)
    @objc optional func willShow(_ controller: KUIImageViewController)
    @objc optional func didShow(_ controller: KUIImageViewController)
    @objc optional func willDismiss(_ controller: KUIImageViewController)
    @objc optional func didDismiss(_ controller: KUIImageViewController)
    @objc optional func willRollback(_ controller: KUIImageViewController)
    @objc optional func didRollback(_ controller: KUIImageViewController)
    
    @objc optional func willDisplay(at index: Int, controller: KUIImageViewController, contentView: UIView)
    @objc optional func didEndDisplaying(at index: Int, controller: KUIImageViewController, contentView: UIView)
    
    @objc optional func singleTap(at index: Int, controller: KUIImageViewController)
}


open class KUIImageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, KUIPhotoViewDelegate {
    
    open weak var delegate: KUIImageViewControllerDelegate?
    open weak var dataSource: KUIImageViewControllerDataSource?
    open weak var senderView: UIView?
    
    fileprivate var panGesture: UIPanGestureRecognizer?
    fileprivate var startOrigin: CGPoint = CGPoint.zero
    fileprivate weak var fromViewController: UIViewController!
    fileprivate lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.sectionInset = UIEdgeInsets.zero
        
        let collectionView: UICollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = false
        collectionView.isPagingEnabled = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(KUIImageViewerContentCollectionViewCell.self, forCellWithReuseIdentifier: KUIImageViewerContentCollectionViewCell.reusableIdentifier)
        return collectionView
    }()
    fileprivate lazy var snapshotImgView: UIImageView = {
        let snapshotImgView = UIImageView(frame: CGRect.zero)
        snapshotImgView.contentMode = .scaleAspectFit
        return snapshotImgView
    }()
    
    fileprivate var snapshotImage: UIImage? {
        return (senderView as? UIImageView)?.image ?? (senderView as? UIButton)?.currentImage ?? senderView?.capture()
    }
    fileprivate(set) var currentIndex: Int = 0
    fileprivate let threshold: CGFloat = 100.0
    
    open override func loadView() {
        super.loadView()
        
        view.insertSubview(collectionView, at: 0)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", views: ["view": collectionView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", views: ["view": collectionView]))
    }
    
    open func show(_ fromViewController: UIViewController, completion: (() -> Void)? = nil) {
        if let senderView = senderView, let window = UIApplication.shared.keyWindow {
            snapshotImgView.frame = window.convert(senderView.frame, from: senderView.superview)
            snapshotImgView.image = snapshotImage
            snapshotImgView.clipsToBounds = senderView.clipsToBounds
            snapshotImgView.layer.cornerRadius = senderView.layer.cornerRadius
            snapshotImgView.isHidden = false
            view.addSubview(snapshotImgView)
            
            senderView.alpha = 0.0
            collectionView.alpha = 0.0
        }
        
        modalPresentationStyle = .custom
        modalPresentationCapturesStatusBarAppearance = true
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        delegate?.willShow?(self)
        
        fromViewController.present(self, animated: false, completion: {
            UIView.animate(withDuration: 0.25, animations: { 
                self.snapshotImgView.frame = self.view.convert(self.collectionView.frame, from: self.view)
                self.view.backgroundColor = UIColor.black
            }, completion: { (finished) in
                self.senderView?.alpha = 1.0
                self.collectionView.alpha = 1.0
                self.collectionView.reloadData()
                self.snapshotImgView.layer.cornerRadius = 0.0
                self.snapshotImgView.isHidden = true
                self.snapshotImgView.removeFromSuperview()
                self.fromViewController = fromViewController
                self.registerGesture()
                self.delegate?.didShow?(self)
                completion?()
            })
        })
    }
    
    open func dismiss() {
        if self.snapshotImgView.superview == nil {
            senderView?.alpha = 0.0
            collectionView.alpha = 0.0
            collectionView.isScrollEnabled = false
            snapshotImgView.image = (collectionView.visibleCells.first as? KUIImageViewerContentCollectionViewCell)?.image
            snapshotImgView.frame = collectionView.bounds
            snapshotImgView.isHidden = false
            view.addSubview(snapshotImgView)
        }
        
        panGesture?.isEnabled = false
        delegate?.willDismiss?(self)
        
        UIView.animate(withDuration: 0.25, animations: {
            if let senderView = self.senderView, let window = UIApplication.shared.keyWindow {
                self.snapshotImgView.frame = window.convert(senderView.frame, from: senderView.superview)
                self.snapshotImgView.layer.cornerRadius = senderView.layer.cornerRadius
            }
            
            self.view.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        }, completion: { (finished) in
            self.snapshotImgView.removeFromSuperview()
            self.senderView?.alpha = 1.0
            self.dismiss(animated: false, completion: { 
                self.delegate?.didDismiss?(self)
            })
        })
    }
    
    open func reloadData() {
        collectionView.reloadData()
    }
    
    open func move(at index: Int, animated: Bool = true) {
        collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: animated, scrollPosition: .centeredHorizontally)
    }
    
    // MARK: - Private
    fileprivate func registerGesture() {
        unregisterGesture()
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        panGesture?.delegate = self
        panGesture?.cancelsTouchesInView = false
        
        guard let gesture = panGesture else { return }
        collectionView.panGestureRecognizer.require(toFail: gesture)
        view.addGestureRecognizer(gesture)
    }
    
    fileprivate func unregisterGesture() {
        defer {
            panGesture?.delegate = nil
            panGesture = nil
        }
        
        guard let gesture = panGesture else { return }
        view.removeGestureRecognizer(gesture)
    }
    
    fileprivate func rollback() {
        panGesture?.isEnabled = false
        delegate?.willRollback?(self)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.snapshotImgView.y = 0.0
            self.view.backgroundColor = UIColor.black
        }, completion: { (finished) in
            self.snapshotImgView.isHidden = true
            self.snapshotImgView.removeFromSuperview()
            self.collectionView.alpha = 1.0
            self.collectionView.isScrollEnabled = true
            self.panGesture?.isEnabled = true
            self.delegate?.didRollback?(self)
        })
    }
    
    // MARK: - Actions
    func pan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state{
        case .began:
            senderView?.alpha = 0.0
            collectionView.alpha = 0.0
            collectionView.isScrollEnabled = false
            snapshotImgView.image = (collectionView.visibleCells.first as? KUIImageViewerContentCollectionViewCell)?.image
            snapshotImgView.frame = collectionView.frame
            snapshotImgView.isHidden = false
            view.addSubview(snapshotImgView)
            delegate?.gestureBegan?(self)
        case .changed:
            let translation = gesture.translation(in: view)
            let alpha = 1.0 - abs(translation.y) / view.height
            
            snapshotImgView.y = translation.y
            view.backgroundColor = UIColor(white: 0.0, alpha: max(alpha, 0.5))
            delegate?.gestureChanged?(self, translation: translation)
        default:
            let translation = gesture.translation(in: view)
            let alpha = 1.0 - abs(translation.y) / view.height
            
            if alpha < 0.8 {
                dismiss()
            } else {
                rollback()
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / scrollView.width)
        senderView = dataSource?.senderView?(at: currentIndex, controller: self) ?? senderView
    }
    
    // MARK: - UICollectionViewProtocol
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfImages(self) ?? 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as KUIImageViewerContentCollectionViewCell
        cell.delegate = self
        cell.imageUrl = (dataSource?.imageUrlString(at: indexPath.item, controller: self), dataSource?.placeholderImage?(at: indexPath.item, controller: self))
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        currentIndex = indexPath.item
        senderView = dataSource?.senderView?(at: indexPath.item, controller: self) ?? senderView
        delegate?.willDisplay?(at: indexPath.item, controller: self, contentView: cell)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.didEndDisplaying?(at: indexPath.item, controller: self, contentView: cell)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.size
    }
    
    // MARK: - UIGestureRecognizerDelegate
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let cell = (collectionView.visibleCells.first as? KUIImageViewerContentCollectionViewCell), !cell.isZooming else { return false }
        guard let velocity = (gestureRecognizer as? UIPanGestureRecognizer)?.velocity(in: gestureRecognizer.view), velocity.y != 0 else { return true }
        return abs(velocity.y) > abs(velocity.x) + threshold
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == panGesture
    }
    
    // MARK: - KUIPhotoViewDelegate
    open func singleTap(_ photoView: KUIPhotoView) {
        delegate?.singleTap?(at: currentIndex, controller: self)
    }
    
}

open class KUIImageViewerContentCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    open weak var delegate: KUIPhotoViewDelegate? {
        get {
            return photoView.photoDelegate
        }
        set {
            photoView.photoDelegate = newValue
        }
    }
    
    open var isZooming: Bool {
        return photoView.zoomScale != photoView.minimumZoomScale
    }
    
    open var imageUrl: (String?, UIImage?) {
        didSet {
            photoView.imageUrl = imageUrl
        }
    }
    
    open var image: UIImage? {
        return photoView.imageView.image
    }
    
    fileprivate lazy var photoView: KUIPhotoView = {
        let photoView = KUIPhotoView(frame: self.bounds)
        return photoView
    }()
    
    required public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        addSubviewAtFit(photoView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        photoView.resetZoom()
    }
    
}

@objc public protocol KUIPhotoViewDelegate: class {
    @objc optional func singleTap(_ photoView: KUIPhotoView)
}

open class KUIPhotoView: UIScrollView, UIScrollViewDelegate {
    
    open weak var photoDelegate: KUIPhotoViewDelegate?
    
    override open var frame: CGRect {
        didSet {
            let origin = imageView.origin
            
            contentSize = CGSize(width: frame.width * zoomScale, height: frame.height * zoomScale)
            imageView.frame = CGRect(origin: origin, size: contentSize)
        }
    }
    
    open var imageUrl: (String?, UIImage?) {
        didSet {
            imageView.setShowActivityIndicator(imageUrl.1 == nil)
            imageView.setImage(with: imageUrl.0, placeholder: imageUrl.1)
        }
    }
    
    lazy open var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.bounds)
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.setIndicatorStyle(.white)
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
        backgroundColor = UIColor.clear
        
        addSubview(imageView)
        registerGestures()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func resetZoom() {
        zoom(to: bounds, animated: false)
        setZoomScale(minimumZoomScale, animated: false)
        contentSize = CGSize(width: frame.width * zoomScale, height: frame.height * zoomScale)
    }
    
    func singleTap(_ gesture: UITapGestureRecognizer) {
        photoDelegate?.singleTap?(self)
    }
    
    func doubleTap(_ gesture: UITapGestureRecognizer) {
        guard zoomScale == minimumZoomScale else {
            setZoomScale(minimumZoomScale, animated: true)
            return
        }
        
        let location = gesture.location(in: self)
        let zoomRectSize = CGSize(width: frame.width / maximumZoomScale, height: frame.height / maximumZoomScale)
        var zoomRect = CGRect(origin: CGPoint(x: max(0.0, location.x - (zoomRectSize.width * 0.5)), y: max(0.0, location.y - (zoomRectSize.height * 0.5))), size: zoomRectSize)
        
        if zoomRect.origin.x + zoomRect.size.width > frame.width {
            zoomRect.origin.x = frame.width - zoomRect.size.width
        }
        
        if zoomRect.origin.y + zoomRect.size.height > frame.height {
            zoomRect.origin.y = frame.height - zoomRect.size.height
        }
        
        zoom(to: zoomRect, animated: true)
    }
    
    fileprivate func registerGestures() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTap(_:)))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        singleTap.require(toFail: doubleTap)
        
        addGestureRecognizer(singleTap)
        addGestureRecognizer(doubleTap)
    }
    
    // MARK: - UIScrollViewDelegate
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

open class KUISimpleImageViewerViewController: KUIImageViewController, KUIImageViewControllerDataSource, KUIImageViewControllerDelegate {
    
    @IBOutlet open weak var closeButton: UIButton!
    
    open var imageUrl: String? {
        didSet {
            guard isViewLoaded && imageUrl != oldValue else { return }
            reloadData()
        }
    }
    
    open var placeHolderImage: UIImage?
    fileprivate var originStatusBarStyle: UIStatusBarStyle = .`default`
    
    open override func loadView() {
        super.loadView()
        delegate = self
        dataSource = self
        
        if closeButton == nil {
            let dismissSelector = #selector(((KUISimpleImageViewerViewController.dismiss) as (KUISimpleImageViewerViewController) -> () -> Void))
            let button = UIButton(type: .custom)
            button.setImage(UIImage(named: "close"), for: [])
            button.addTarget(self, action: dismissSelector, for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
            view.addConstraint(NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 5.0))
            view.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .top, multiplier: 1.0, constant: 25.0))
            button.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40.0))
            button.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40.0))
            closeButton = button
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        originStatusBarStyle = UIApplication.shared.statusBarStyle
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: animated)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarStyle(originStatusBarStyle, animated: animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.setStatusBarStyle(originStatusBarStyle, animated: animated)
    }
    
    // MARK: - KUIImageViewControllerDataSource
    open func numberOfImages(_ controller: KUIImageViewController) -> Int {
        return 1
    }
    
    open func imageUrlString(at index: Int, controller: KUIImageViewController) -> String? {
        return imageUrl
    }
    
    open func placeholderImage(at index: Int, controller: KUIImageViewController) -> UIImage? {
        return snapshotImage ?? placeHolderImage
    }
    
    open func willShow(_ controller: KUIImageViewController) {
        closeButton.alpha = 0.0
    }
    
    open func didShow(_ controller: KUIImageViewController) {
        closeButton.alpha = 1.0
    }
    
    open func willDismiss(_ controller: KUIImageViewController) {
        closeButton.alpha = 0.0
    }
    
    open func didDismiss(_ controller: KUIImageViewController) {
        closeButton.alpha = 1.0
    }
    
    open func willRollback(_ controller: KUIImageViewController) {
        closeButton.alpha = 0.0
    }
    
    open func didRollback(_ controller: KUIImageViewController) {
        closeButton.alpha = 1.0
    }
    
    open func gestureBegan(_ controller: KUIImageViewController) {
        closeButton.alpha = 0.0
    }
    
    open func singleTap(at index: Int, controller: KUIImageViewController) {
        UIView.animate(withDuration: 0.25, animations: {
            if self.closeButton.alpha > 0.0 {
                self.closeButton.alpha = 0.0
            } else {
                self.closeButton.alpha = 1.0
            }
        })
    }
}

@objc public protocol KUIMultiImageViewerViewControllerDelegate: class {
    @objc optional func senderView(at index: Int, controller: KUIMultiImageViewerViewController) -> UIView?
}

open class KUIMultiImageViewerViewController: KUIImageViewController, KUIImageViewControllerDataSource, KUIImageViewControllerDelegate {
    
    @IBOutlet open weak var closeButton: UIButton!
    @IBOutlet open weak var titleLabel: UILabel!
    
    open weak var multiDelegate: KUIMultiImageViewerViewControllerDelegate?
    open var font = UIFont.systemFont(ofSize: 17.0)
    open var imageUrls: Array<String>?
    open var placeHolderImage: UIImage?
    
    fileprivate var originStatusBarStyle: UIStatusBarStyle = .`default`
    
    open override func loadView() {
        super.loadView()
        delegate = self
        dataSource = self
        
        if closeButton == nil {
            let dismissSelector = #selector(((KUIMultiImageViewerViewController.dismiss) as (KUIMultiImageViewerViewController) -> () -> Void))
            let button = UIButton(type: .custom)
            button.setImage(UIImage(named: "close"), for: [])
            button.addTarget(self, action: dismissSelector, for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
            view.addConstraint(NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 5.0))
            view.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .top, multiplier: 1.0, constant: 25.0))
            button.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40.0))
            button.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40.0))
            closeButton = button
        }
        
        if titleLabel == nil {
            let label = UILabel(frame: CGRect.zero)
            label.font = font
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: closeButton, attribute: .centerY, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            titleLabel = label
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        originStatusBarStyle = UIApplication.shared.statusBarStyle
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: animated)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarStyle(originStatusBarStyle, animated: animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.setStatusBarStyle(originStatusBarStyle, animated: animated)
    }
    
    // MARK: - KUIImageViewControllerDataSource
    open override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        super.scrollViewDidEndDecelerating(scrollView)
        titleLabel.text = "\(currentIndex + 1) / \(imageUrls?.count ?? 0)"
    }
    
    open func numberOfImages(_ controller: KUIImageViewController) -> Int {
        return imageUrls?.count ?? 0
    }
    
    open func imageUrlString(at index: Int, controller: KUIImageViewController) -> String? {
        return imageUrls?[index]
    }
    
    open func placeholderImage(at index: Int, controller: KUIImageViewController) -> UIImage? {
        guard let senderView = senderView(at: index, controller: self) else { return placeHolderImage }
        return (senderView as? UIImageView)?.image ?? (senderView as? UIButton)?.currentImage ?? senderView.capture()
    }
    
    open func senderView(at index: Int, controller: KUIImageViewController) -> UIView? {
        return multiDelegate?.senderView?(at: index, controller: self)
    }
    
    open func willDisplay(at index: Int, controller: KUIImageViewController, contentView: UIView) {
        titleLabel.text = "\(index + 1) / \(imageUrls?.count ?? 0)"
    }
    
    open func willShow(_ controller: KUIImageViewController) {
        closeButton.alpha = 0.0
        titleLabel.alpha = 0.0
    }
    
    open func didShow(_ controller: KUIImageViewController) {
        closeButton.alpha = 1.0
        titleLabel.alpha = 1.0
    }
    
    open func willDismiss(_ controller: KUIImageViewController) {
        closeButton.alpha = 0.0
        titleLabel.alpha = 0.0
    }
    
    open func didDismiss(_ controller: KUIImageViewController) {
        closeButton.alpha = 1.0
        titleLabel.alpha = 1.0
    }
    
    open func willRollback(_ controller: KUIImageViewController) {
        closeButton.alpha = 0.0
        titleLabel.alpha = 0.0
    }
    
    open func didRollback(_ controller: KUIImageViewController) {
        closeButton.alpha = 1.0
        titleLabel.alpha = 1.0
    }
    
    open func gestureBegan(_ controller: KUIImageViewController) {
        closeButton.alpha = 0.0
        titleLabel.alpha = 0.0
    }
    
    open func singleTap(at index: Int, controller: KUIImageViewController) {
        UIView.animate(withDuration: 0.25, animations: {
            if self.closeButton.alpha > 0.0 {
                self.closeButton.alpha = 0.0
                self.titleLabel.alpha = 0.0
            } else {
                self.closeButton.alpha = 1.0
                self.titleLabel.alpha = 0.0
            }
        })
    }
}
