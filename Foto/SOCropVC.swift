//
//  SOCropVC.swift
//  Foto
//
//  Created by Isabelle Xu on 11/12/18.
//  Copyright © 2018 WashU. All rights reserved.
//  Credits: https://www.spaceotechnologies.com/ios-tutorial-make-photo-editing-app-like-retrica/
//  (Contents editied to Swift 4.0 syntax for this project's purposes)

//
//  SOImageImageCropViewController.swift
//  SOImagePicker
//
//

import UIKit
import CoreGraphics

internal protocol SOCropVCDelegate {
    func imagecropvc(imagecropvc:SOCropVC, finishedcropping:UIImage)
}

internal class SOCropVC: UIViewController {
    var imgOriginal: UIImage!
    var delegate: SOCropVCDelegate?
    var cropSize: CGSize!
    var isAllowCropping = false
    
    private var imgCropped: UIImage!
    
    private var imageCropView: SOImageCropView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.isNavigationBarHidden = true
        
        self.setupCropView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.imageCropView.frame = self.view.bounds
        setupBottomViewView()
    }
    
    func setupBottomViewView() {
        let viewBottom = UIView()
        viewBottom.frame = CGRect(0, self.view.frame.size.height-64, self.view.frame.size.width, 64)
        viewBottom.backgroundColor = UIColor.darkGray
        self.view.addSubview(viewBottom)
        
        let btnCancel = UIButton()
        btnCancel.frame = CGRect(10, 17, 60, 30)
        btnCancel.layer.cornerRadius = 5.0
        btnCancel.layer.masksToBounds = true
        btnCancel.setTitleColor(UIColor.black, for: [])
        btnCancel.setTitle("Cancel", for: [])
        btnCancel.backgroundColor = UIColor.white
        btnCancel.addTarget(self, action: #selector(actionCancel), for: .touchUpInside)
        viewBottom.addSubview(btnCancel)
        
        let btnCrop = UIButton()
        btnCrop.frame = CGRect(self.view.frame.size.width-50-10, 17, 50, 30)
        btnCrop.layer.cornerRadius = 5.0
        btnCrop.layer.masksToBounds = true
        btnCrop.setTitleColor(UIColor.black, for: [])
        btnCrop.setTitle("Crop", for: [])
        btnCrop.backgroundColor = UIColor.white
        btnCrop.addTarget(self, action: #selector(actionCrop), for: .touchUpInside)
        viewBottom.addSubview(btnCrop)
        
    }
    
    @objc func actionCancel(sender: AnyObject?) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func actionCrop(sender: AnyObject) {
        imgCropped = self.imageCropView.croppedImage()
        self.delegate?.imagecropvc(imagecropvc: self, finishedcropping:imgCropped)
        self.actionCancel(sender: nil)
    }
    
    private func setupCropView() {
        self.imageCropView = SOImageCropView(frame: self.view.bounds)
        self.imageCropView.imgCrop = imgOriginal
        self.imageCropView.isAllowCropping = self.isAllowCropping
        self.imageCropView.cropSize = cropSize
        self.view.addSubview(self.imageCropView)
    }
}


internal class SOCropBorderView: UIView {
    private let kCircle: CGFloat = 20
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        context!.setStrokeColor(UIColor(red: 0.16, green: 0.25, blue: 0.75, alpha: 0.5).cgColor)
        context!.setLineWidth(1.5)
        context!.addRect(CGRect(kCircle / 2, kCircle / 2,
                                             rect.size.width - kCircle, rect.size.height - kCircle))
        context!.strokePath()
        
        context!.setFillColor(red:0.16, green:0.25, blue: 0.35, alpha:0.95)
        for handleRect in calculateAllNeededHandleRects() {
            context!.fillEllipse(in:handleRect)
        }
    }
    
    private func calculateAllNeededHandleRects() -> [CGRect] {
        
        let width = self.frame.width
        let height = self.frame.height
        
        let leftColX: CGFloat = 0
        let rightColX = width - kCircle
        let centerColX = rightColX / 2
        
        let topRowY: CGFloat = 0
        let bottomRowY = height - kCircle
        let middleRowY = bottomRowY / 2
        
        //starting with the upper left corner and then following clockwise
        let topLeft = CGRect(leftColX, topRowY, kCircle, kCircle)
        let topCenter = CGRect(centerColX, topRowY, kCircle, kCircle)
        let topRight = CGRect(rightColX, topRowY, kCircle, kCircle)
        let middleRight = CGRect(rightColX, middleRowY, kCircle, kCircle)
        let bottomRight = CGRect(rightColX, bottomRowY, kCircle, kCircle)
        let bottomCenter = CGRect(centerColX, bottomRowY, kCircle, kCircle)
        let bottomLeft = CGRect(leftColX, bottomRowY, kCircle, kCircle)
        let middleLeft = CGRect(leftColX, middleRowY, kCircle, kCircle)
        
        return [topLeft, topCenter, topRight, middleRight, bottomRight, bottomCenter, bottomLeft,
                middleLeft]
    }
}





private class ScrollView: UIScrollView {
    fileprivate override func layoutSubviews() {
        super.layoutSubviews()
        
        if let zoomView = self.delegate?.viewForZooming?(in: self) {
            let boundsSize = self.bounds.size
            var frameToCenter = zoomView.frame
            
            // center horizontally
            if frameToCenter.size.width < boundsSize.width {
                frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
            } else {
                frameToCenter.origin.x = 0
            }
            
            // center vertically
            if frameToCenter.size.height < boundsSize.height {
                frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
            } else {
                frameToCenter.origin.y = 0
            }
            
            zoomView.frame = frameToCenter
        }
    }
}

internal class SOImageCropView: UIView, UIScrollViewDelegate {
    var isAllowCropping = false
    
    private var scrollView: UIScrollView!
    private var imageView: UIImageView!
    private var cropOverlayView: SOCropOverlayView!
    private var xOffset: CGFloat!
    private var yOffset: CGFloat!
    
    private static func scaleRect(rect: CGRect, scale: CGFloat) -> CGRect {
        return CGRect(
            rect.origin.x * scale,
            rect.origin.y * scale,
            rect.size.width * scale,
            rect.size.height * scale)
    }
    
    var imgCrop: UIImage? {
        get {
            return self.imageView.image
        }
        set {
            self.imageView.image = newValue
        }
    }
    
    var cropSize: CGSize {
        get {
            return self.cropOverlayView.cropSize
        }
        set {
            if let view = self.cropOverlayView {
                view.cropSize = newValue
            } else {
                if self.isAllowCropping {
                    self.cropOverlayView = SOResizableCropOverlayView(frame: self.bounds,
                                                                      initialContentSize: CGSize(newValue.width, newValue.height))
                } else {
                    self.cropOverlayView = SOCropOverlayView(frame: self.bounds)
                }
                self.cropOverlayView.cropSize = newValue
                self.addSubview(self.cropOverlayView)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.black
        self.scrollView = ScrollView(frame: frame)
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.delegate = self
        self.scrollView.clipsToBounds = false
        self.scrollView.decelerationRate = 0
        self.scrollView.backgroundColor = UIColor.clear
        self.addSubview(self.scrollView)
        
        self.imageView = UIImageView(frame: self.scrollView.frame)
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.backgroundColor = UIColor.black
        self.scrollView.addSubview(self.imageView)
        
        self.scrollView.minimumZoomScale =
            self.scrollView.frame.width / self.scrollView.frame.height
        self.scrollView.maximumZoomScale = 20
        self.scrollView.setZoomScale(1.0, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !isAllowCropping {
            return self.scrollView
        }
        
        let resizableCropView = cropOverlayView as! SOResizableCropOverlayView
        let outerFrame = resizableCropView.cropBorderView.frame.insetBy(dx:-10, dy:-10)
        
        if outerFrame.contains(point) {
            if resizableCropView.cropBorderView.frame.size.width < 60 ||
                resizableCropView.cropBorderView.frame.size.height < 60 {
                return super.hitTest(point, with: event)
            }
            
            let innerTouchFrame = resizableCropView.cropBorderView.frame.insetBy(dx:30, dy:30)
            if innerTouchFrame.contains(point) {
                return self.scrollView
            }
            
            let outBorderTouchFrame = resizableCropView.cropBorderView.frame.insetBy(dx:-10, dy:-10)
            if outBorderTouchFrame.contains(point) {
                return super.hitTest(point, with: event)
            }
            
            return super.hitTest(point, with: event)
        }
        
        return self.scrollView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = self.cropSize;
        let toolbarSize = CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 0 : 54)
        self.xOffset = floor((self.bounds.width - size.width) * 0.5)
        self.yOffset = floor((self.bounds.height - toolbarSize - size.height) * 0.5)
        
        let height = self.imgCrop!.size.height
        let width = self.imgCrop!.size.width
        
        var factor: CGFloat = 0
        var factoredHeight: CGFloat = 0
        var factoredWidth: CGFloat = 0
        
        if width > height {
            factor = width / size.width
            factoredWidth = size.width
            factoredHeight =  height / factor
        } else {
            factor = height / size.height
            factoredWidth = width / factor
            factoredHeight = size.height
        }
        
        self.cropOverlayView.frame = self.bounds
        self.scrollView.frame = CGRect(xOffset, yOffset, size.width, size.height)
        self.scrollView.contentSize = CGSize(size.width, size.height)
        self.imageView.frame = CGRect(0, floor((size.height - factoredHeight) * 0.5),
                                          factoredWidth, factoredHeight)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func croppedImage() -> UIImage {
        // Calculate rect that needs to be cropped
        var visibleRect = isAllowCropping ?
            calcVisibleRectForResizeableCropArea() : calcVisibleRectForCropArea()
        
        // transform visible rect to image orientation
        let rectTransform = orientationTransformedRectOfImage(image: imgCrop!)
        visibleRect = visibleRect.applying(rectTransform);
        
        // finally crop image
        let imageRef = imgCrop!.cgImage!.cropping(to:visibleRect)
        let result = UIImage(cgImage: imageRef!, scale: imgCrop!.scale, orientation: imgCrop!.imageOrientation)
        return result
    }
    
    private func calcVisibleRectForResizeableCropArea() -> CGRect {
        let resizableView = cropOverlayView as! SOResizableCropOverlayView
        
        // first of all, get the size scale by taking a look at the real image dimensions. Here it
        // doesn't matter if you take the width or the hight of the image, because it will always
        // be scaled in the exact same proportion of the real image
        var sizeScale = self.imageView.image!.size.width / self.imageView.frame.size.width
        sizeScale *= self.scrollView.zoomScale
        
        // then get the postion of the cropping rect inside the image
        var visibleRect = resizableView.contentView.convert(resizableView.contentView.bounds,
                                                            to: imageView)
        visibleRect = SOImageCropView.scaleRect(rect: visibleRect, scale: sizeScale)
        
        return visibleRect
    }
    
    private func calcVisibleRectForCropArea() -> CGRect {
        // scaled width/height in regards of real width to crop width
        let scaleWidth = imgCrop!.size.width / cropSize.width
        let scaleHeight = imgCrop!.size.height / cropSize.height
        var scale: CGFloat = 0
        
        if cropSize.width == cropSize.height {
            scale = max(scaleWidth, scaleHeight)
        } else if cropSize.width > cropSize.height {
            scale = imgCrop!.size.width < imgCrop!.size.height ?
                max(scaleWidth, scaleHeight) :
                min(scaleWidth, scaleHeight)
        } else {
            scale = imgCrop!.size.width < imgCrop!.size.height ?
                min(scaleWidth, scaleHeight) :
                max(scaleWidth, scaleHeight)
        }
        
        // extract visible rect from scrollview and scale it
        var visibleRect = scrollView.convert(scrollView.bounds, to:imageView)
        visibleRect = SOImageCropView.scaleRect(rect: visibleRect, scale: scale)
        
        return visibleRect
    }
    
    private func orientationTransformedRectOfImage(image: UIImage) -> CGAffineTransform {
        var rectTransform: CGAffineTransform!
        
        switch image.imageOrientation {
        case .left:
            rectTransform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2)).translatedBy(x:0, y:-image.size.height)
        case .right:
            rectTransform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2)).translatedBy(x: -image.size.width, y:0)
        case .down:
            rectTransform = CGAffineTransform(rotationAngle: CGFloat(Double.pi)).translatedBy(x:-image.size.width, y:-image.size.height)
        default:
            rectTransform = .identity
        }
        
        return rectTransform.scaledBy(x: image.scale, y: image.scale)
    }
}


internal class SOResizableCropOverlayView: SOCropOverlayView {
    private let kBorderWidth: CGFloat = 12
    
    var contentView: UIView!
    var cropBorderView: SOCropBorderView!
    
    private var initialContentSize = CGSize(width: 0, height: 0)
    private var resizingEnabled: Bool!
    private var anchor: CGPoint!
    private var startPoint: CGPoint!
    
    var widthValue: CGFloat!
    var heightValue: CGFloat!
    var xValue: CGFloat!
    var yValue: CGFloat!
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = newValue
            
            let toolbarSize = CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 0 : 54)
            let width = self.bounds.size.width
            let height = self.bounds.size.height
            
            contentView?.frame = CGRect((
                width - initialContentSize.width) / 2,
                                            (height - toolbarSize - initialContentSize.height) / 2,
                                            initialContentSize.width,
                                            initialContentSize.height)
            
            cropBorderView?.frame = CGRect(
                (width - initialContentSize.width) / 2 - kBorderWidth,
                (height - toolbarSize - initialContentSize.height) / 2 - kBorderWidth,
                initialContentSize.width + kBorderWidth * 2,
                initialContentSize.height + kBorderWidth * 2)
        }
    }
    
    init(frame: CGRect, initialContentSize: CGSize) {
        super.init(frame: frame)
        
        self.initialContentSize = initialContentSize
        self.addContentViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchPoint = touch.location(in: cropBorderView)
            
            anchor = self.calculateAnchorBorder(anchorPoint: touchPoint)
            fillMultiplyer()
            resizingEnabled = true
            startPoint = touch.location(in: self.superview)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if resizingEnabled! {
                self.resizeWithTouchPoint(point: touch.location(in: self.superview))
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        //fill outer rect
        UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).set()
        UIRectFill(self.bounds)
        
        //fill inner rect
        UIColor.clear.set()
        UIRectFill(self.contentView.frame)
    }
    
    private func addContentViews() {
        let toolbarSize = CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 0 : 54)
        let width = self.bounds.size.width
        let height = self.bounds.size.height
        
        contentView = UIView(frame: CGRect((
            width - initialContentSize.width) / 2,
                                               (height - toolbarSize - initialContentSize.height) / 2,
                                               initialContentSize.width,
                                               initialContentSize.height))
        contentView.backgroundColor = UIColor.clear
        self.cropSize = contentView.frame.size
        self.addSubview(contentView)
        
        cropBorderView = SOCropBorderView(frame: CGRect(
            (width - initialContentSize.width) / 2 - kBorderWidth,
            (height - toolbarSize - initialContentSize.height) / 2 - kBorderWidth,
            initialContentSize.width + kBorderWidth * 2,
            initialContentSize.height + kBorderWidth * 2))
        self.addSubview(cropBorderView)
    }
    
    private func calculateAnchorBorder(anchorPoint: CGPoint) -> CGPoint {
        let allHandles = getAllCurrentHandlePositions()
        var closest: CGFloat = 3000
        var anchor: CGPoint!
        
        for handlePoint in allHandles {
            // Pythagoras is watching you :-)
            let xDist = handlePoint.x - anchorPoint.x
            let yDist = handlePoint.y - anchorPoint.y
            let dist = sqrt(xDist * xDist + yDist * yDist)
            
            closest = dist < closest ? dist : closest
            anchor = closest == dist ? handlePoint : anchor
        }
        
        return anchor
    }
    
    private func getAllCurrentHandlePositions() -> [CGPoint] {
        let leftX: CGFloat = 0
        let rightX = cropBorderView.bounds.size.width
        let centerX = leftX + (rightX - leftX) / 2
        
        let topY: CGFloat = 0
        let bottomY = cropBorderView.bounds.size.height
        let middleY = topY + (bottomY - topY) / 2
        
        // starting with the upper left corner and then following the rect clockwise
        let topLeft = CGPoint(leftX, topY)
        let topCenter = CGPoint(centerX, topY)
        let topRight = CGPoint(rightX, topY)
        let middleRight = CGPoint(rightX, middleY)
        let bottomRight = CGPoint(rightX, bottomY)
        let bottomCenter = CGPoint(centerX, bottomY)
        let bottomLeft = CGPoint(leftX, bottomY)
        let middleLeft = CGPoint(leftX, middleY)
        
        return [topLeft, topCenter, topRight, middleRight, bottomRight, bottomCenter, bottomLeft,
                middleLeft]
    }
    
    private func resizeWithTouchPoint(point: CGPoint) {
        // This is the place where all the magic happends
        // prevent goint offscreen...
        let border = kBorderWidth * 2
        var pointX = point.x < border ? border : point.x
        var pointY = point.y < border ? border : point.y
        pointX = pointX > self.superview!.bounds.size.width - border ?
            self.superview!.bounds.size.width - border : pointX
        pointY = pointY > self.superview!.bounds.size.height - border ?
            self.superview!.bounds.size.height - border : pointY
        
        let heightNew = (pointY - startPoint.y) * heightValue
        let widthNew = (startPoint.x - pointX) * widthValue
        let xNew = -1 * widthNew * xValue
        let yNew = -1 * heightNew * yValue
        
        var newFrame =  CGRect(
            cropBorderView.frame.origin.x + xNew,
            cropBorderView.frame.origin.y + yNew,
            cropBorderView.frame.size.width + widthNew,
            cropBorderView.frame.size.height + heightNew);
        newFrame = self.preventBorderFrameFromGettingTooSmallOrTooBig(frame: newFrame)
        self.resetFrame(to: newFrame)
        startPoint = CGPoint(pointX, pointY)
    }
    
    private func preventBorderFrameFromGettingTooSmallOrTooBig(frame: CGRect) -> CGRect {
        let toolbarSize = CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 0 : 54)
        var newFrame = frame
        
        if newFrame.size.width < 64 {
            newFrame.size.width = cropBorderView.frame.size.width
            newFrame.origin.x = cropBorderView.frame.origin.x
        }
        if newFrame.size.height < 64 {
            newFrame.size.height = cropBorderView.frame.size.height
            newFrame.origin.y = cropBorderView.frame.origin.y
        }
        
        if newFrame.origin.x < 0 {
            newFrame.size.width = cropBorderView.frame.size.width +
                (cropBorderView.frame.origin.x - self.superview!.bounds.origin.x)
            newFrame.origin.x = 0
        }
        
        if newFrame.origin.y < 0 {
            newFrame.size.height = cropBorderView.frame.size.height +
                (cropBorderView.frame.origin.y - self.superview!.bounds.origin.y)
            newFrame.origin.y = 0
        }
        
        if newFrame.size.width + newFrame.origin.x > self.frame.size.width {
            newFrame.size.width = self.frame.size.width - cropBorderView.frame.origin.x
        }
        
        if newFrame.size.height + newFrame.origin.y > self.frame.size.height - toolbarSize {
            newFrame.size.height = self.frame.size.height -
                cropBorderView.frame.origin.y - toolbarSize
        }
        
        return newFrame
    }
    
    private func resetFrame(to frame: CGRect) {
        cropBorderView.frame = frame
        contentView.frame = frame.insetBy(dx:kBorderWidth, dy:kBorderWidth)
        cropSize = contentView.frame.size
        self.setNeedsDisplay()
        cropBorderView.setNeedsDisplay()
    }
    
    private func fillMultiplyer() {
        heightValue = anchor.y == 0 ?
            -1 : anchor.y == cropBorderView.bounds.size.height ? 1 : 0
        widthValue = anchor.x == 0 ?
            1 : anchor.x == cropBorderView.bounds.size.width ? -1 : 0
        xValue = anchor.x == 0 ? 1 : 0
        yValue = anchor.y == 0 ? 1 : 0
    }
}





internal class SOCropOverlayView: UIView {
    
    var cropSize: CGSize!
    var toolbar: UIToolbar!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = true
    }
    
    override func draw(_ rect: CGRect) {
        
        let toolbarSize = CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 0 : 54)
        
        let width = self.frame.width
        let height = self.frame.height - toolbarSize
        
        let heightSpan = floor(height / 2 - self.cropSize.height / 2)
        let widthSpan = floor(width / 2 - self.cropSize.width / 2)
        
        // fill outer rect
        UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).set()
        UIRectFill(self.bounds)
        
        // fill inner border
        UIColor(red: 1, green: 1, blue: 1, alpha: 0.5).set()
        UIRectFrame(CGRect(widthSpan - 2, heightSpan - 2, self.cropSize.width + 4,
                               self.cropSize.height + 4))
        
        // fill inner rect
        UIColor.clear.set()
        UIRectFill(CGRect(widthSpan, heightSpan, self.cropSize.width, self.cropSize.height))
    }
}

extension CGRect{
    init(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat) {
        self.init(x:x,y:y,width:width,height:height)
    }
    
}
extension CGSize{
    init(_ width:CGFloat,_ height:CGFloat) {
        self.init(width:width,height:height)
    }
}
extension CGPoint{
    init(_ x:CGFloat,_ y:CGFloat) {
        self.init(x:x,y:y)
    }
}
