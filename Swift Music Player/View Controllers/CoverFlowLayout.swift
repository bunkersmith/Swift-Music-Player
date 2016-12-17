//
//  CoverFlowLayout.swift
//  FlickrSearch
//
//  Created by CarlSmith on 7/8/15.
//  Copyright (c) 2015 RookSoft Pte. Ltd. All rights reserved.
//

import UIKit

class CoverFlowLayout: UICollectionViewFlowLayout {
    let kMaxDistancePercentage:CGFloat = 0.5
    let kMaxRotation:CGFloat  = (CGFloat)(70.0 * (M_PI / 180.0))
    let kMaxZoom:CGFloat = 0.65
    let kMinZoom:CGFloat = 0.1
    
    convenience init(direction: UICollectionViewScrollDirection) {
        self.init()
        scrollDirection = direction
    }
    
    // Because cells in this layout are rotated and scaled, 
    // the collectionView's own indexPathForItemAtPoint 
    // doesn't always return an indexPath 
    //
    // This problem was confirmed by empirical evidence
    //
    // This function has returned an indexPath for many different cases,
    // and is considered to be thoroughly tested
    func indexPathForItemAtPoint(_ point: CGPoint) -> IndexPath? {
        if collectionView != nil {
            var frame = collectionView!.frame
            let contentOffset = collectionView!.contentOffset
            frame.origin.x += contentOffset.x
            frame.origin.y += contentOffset.y
            if let layoutArray:[UICollectionViewLayoutAttributes] = layoutAttributesForElements(in: frame) {
                for attributes:UICollectionViewLayoutAttributes in layoutArray {
                    if attributes.frame.contains(point) {
                        return attributes.indexPath
                    }
                }
            }
        }
        return nil
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItem(at: indexPath)
        
        guard attributes != nil else {
            return nil
        }
        
        /* 1
        You set up a couple of temporary variables. The first is the visible rectangle of
        the collection view, calculated using the content offset of the view and the bounds
        size. The next is the maximum distance away from the center, which defines the
        distance from the center at which each cell is fully rotated.*/
        
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let maxDistance = visibleRect.size.width * kMaxDistancePercentage
        
        /* 3
        You enumerate the attributes and first find the distance of the cell from the
        center of the current visible rectangle.*/
        
        let distance:CGFloat = visibleRect.midX - attributes!.center.x
        let beginningWidth = attributes!.frame.size.width
        
        //Logger.writeToLogFile("Frame for indexPath (before) \(attributes.indexPath.section), \(attributes.indexPath.row) = \(Utilities.stringFromCGRect(attributes.frame))")
        //Logger.writeToLogFile(String(format: "width (before) = %.2f", beginningWidth))
        
        /* 4
        You then normalize this distance against the maximum distance to give a
        percentage of how far the view is along the line from the center to the maximum
        points in either direction. You then limit this to a value between 1 and -1. */
        
        var normalizedDistance:CGFloat = distance / maxDistance
        normalizedDistance = min(normalizedDistance, 1.0)
        normalizedDistance = max(normalizedDistance, -1.0)
        
        /* 5
        You calculate the rotation and zoom. */
        
        let rotation:CGFloat = normalizedDistance * kMaxRotation
        let zoom:CGFloat = 1.0 + ((1.0 - abs(normalizedDistance)) * kMaxZoom)

        /* 6
        Finally, you create the required transform by first setting m34 so that when the
        rotation is done, skew is applied to make it have the appearance of coming out of
        and going into the screen. Then the transform is rotated and scaled appropriately. */
        
        //Logger.writeToLogFile(String(format: "rotation = %.2f, zoom = %.2f", rotation * CGFloat(M_PI) / 180.0, zoom))
        
        var transform:CATransform3D = CATransform3DIdentity
        transform.m34 = -0.002
        transform = CATransform3DRotate(transform,
                                        rotation,
                                        0.0,
                                        1.0,
                                        0.0)
        transform = CATransform3DScale(transform,
                                       zoom,
                                       zoom,
                                       0.0)
        
        //Logger.writeToLogFile(String(format: "zoomed width = %.2f", attributes.frame.size.width * zoom))
        
        //transform = CATransform3DTranslate(transform, 0.0, 0.0, 0.0)
        attributes!.transform3D = transform
        let endingWidth = attributes!.frame.size.width
        attributes!.center.x -= (endingWidth - beginningWidth) / 2.0
        
        //Logger.writeToLogFile("Frame for indexPath (after) \(attributes.indexPath.section), \(attributes.indexPath.row) = \(Utilities.stringFromCGRect(attributes.frame))")
        //Logger.writeToLogFile(String(format: "width (after) = %.2f", endingWidth))
        //Logger.writeToLogFile(String(format: "width change = %.2f", beginningWidth - endingWidth))
        
        return attributes
    }
    
    override
    func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if collectionView != nil {
            /* 2
            Then you defer the list of cells in the rectangle to the super-class, since this is a
            subclass of UICollectionViewFlowLayout. The super-class does the hard
            calculation work.*/
            
            if var array:[UICollectionViewLayoutAttributes] = super.layoutAttributesForElements(in: rect) {
                for i in 0..<array.count {
                    let layoutAttributes = array[i]
                    if let layoutAttributesForItem = layoutAttributesForItem(at: layoutAttributes.indexPath) {
                        array[i] = layoutAttributesForItem
                    }
                }
                
                /* 7
                You return the attributes. */
                
                return array
            }
        }
        return nil
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds:CGRect) -> Bool
    {
        return true
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint
    {
        if collectionView != nil {
            // 1
            var offsetAdjustment:CGFloat = CGFloat.greatestFiniteMagnitude
            let horizontalCenter:CGFloat = proposedContentOffset.x + (collectionView!.bounds.width / 2.0)
            
            //Logger.writeToLogFile( "collectionView.bounds = " + NSStringFromCGRect(collectionView!.bounds))
                
            // 2
            let targetRect:CGRect = CGRect(x: proposedContentOffset.x, y: 0.0,
                                               width: collectionView!.bounds.size.width, height: collectionView!.bounds.size.height)
            if let array:[UICollectionViewLayoutAttributes] = layoutAttributesForElements(in: targetRect) {
                for layoutAttributes:UICollectionViewLayoutAttributes in array {
                    // 3
                    //Logger.writeToLogFile( "layoutAttributes.frame = " + Utilities.stringFromCGRect(layoutAttributes.frame))
                    
                    let distanceFromCenter:CGFloat =
                    layoutAttributes.center.x - horizontalCenter
                    if (abs(distanceFromCenter) < abs(offsetAdjustment)) {
                        offsetAdjustment = distanceFromCenter
                    }
                }
                
                // 4
                return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
            }
        }
        return CGPoint.zero
    }
}
