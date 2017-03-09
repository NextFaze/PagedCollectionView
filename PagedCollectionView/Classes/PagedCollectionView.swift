//
//  PagedCollectionView.swift
//  PagedCollectionView
//
//  Created by Ricardo Santos on 8/3/17.
//
//  Adapted from https://github.com/BenEmdon/CenteredCollectionView

import UIKit

public class PagedCollectionView: UICollectionView {
    
    public var itemSize: CGSize {
        get {
            return self.layout.itemSize
        }
        set(newValue)  {
            self.layout.itemSize = newValue
        }
    }
    
    public var currentPage: Int {
        get {
            let center = CGPointMake(self.contentOffset.x + self.bounds.size.width/2.0, self.contentOffset.y + self.bounds.size.height/2.0)
            let indexPath = self.indexPathForItemAtPoint(center)
            return indexPath?.row ?? 0
        }
    }
    
    private let layout = PagedCollectionViewFlowLayout()
    
    public init(frame: CGRect) {
        self.layout.scrollDirection = .Horizontal
        super.init(frame: frame, collectionViewLayout: self.layout)
        self.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        fatalError("use init(frame:) instead")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var pageWidth: CGFloat {
        switch self.layout.scrollDirection {
        case .Horizontal:
            return self.layout.itemSize.width + self.layout.minimumLineSpacing
        case .Vertical:
            return self.layout.itemSize.height + self.layout.minimumLineSpacing
        }
    }
    
    public func setCurrentPage(page: Int, animated: Bool) {
        let pageOffset: CGFloat
        let proposedContentOffset: CGPoint
        
        switch self.layout.scrollDirection {
        case .Horizontal:
            pageOffset = CGFloat(page) * self.pageWidth - contentInset.left
            proposedContentOffset = CGPoint(x: pageOffset, y: 0)
            
        case .Vertical:
            pageOffset = CGFloat(page) * pageWidth - contentInset.top
            proposedContentOffset = CGPoint(x: 0, y: pageOffset)
            
        }
        self.setContentOffset(proposedContentOffset, animated: animated)
    }
    
}

private class PagedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    private var lastCollectionViewSize: CGSize = CGSize.zero
    private var lastScrollDirection: UICollectionViewScrollDirection!

    override func invalidateLayoutWithContext(context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayoutWithContext(context)
        guard let collectionView = self.collectionView else { return }
        // invalidate layout to center first and last
        
        let currentCollectionViewSize = collectionView.bounds.size
        if !CGSizeEqualToSize(currentCollectionViewSize, self.lastCollectionViewSize) || self.lastScrollDirection != scrollDirection {
            let inset: CGFloat
            switch scrollDirection {
            case .Horizontal:
                inset = (collectionView.bounds.size.width - itemSize.width) / 2
                collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
                collectionView.contentOffset = CGPoint(x: -inset, y: 0)
            case .Vertical:
                inset = (collectionView.bounds.size.height - itemSize.height) / 2
                collectionView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
                collectionView.contentOffset = CGPoint(x: 0, y: -inset)
            }
            self.lastCollectionViewSize = currentCollectionViewSize
            self.lastScrollDirection = scrollDirection
        }
    }
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        
        let proposedRect: CGRect
        
        switch scrollDirection {
        case .Horizontal:
            proposedRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
        case .Vertical:
            proposedRect = CGRect(x: 0, y: proposedContentOffset.y, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
        }
        
        guard let layoutAttributes = self.layoutAttributesForElementsInRect(proposedRect) else { return proposedContentOffset }
        
        var candidateAttributes: UICollectionViewLayoutAttributes?
        let proposedContentOffsetCenter: CGFloat
        
        switch scrollDirection {
        case .Horizontal:
            proposedContentOffsetCenter = proposedContentOffset.x + collectionView.bounds.size.width / 2
        case .Vertical:
            proposedContentOffsetCenter = proposedContentOffset.y + collectionView.bounds.size.height / 2
        }
        
        for attributes: UICollectionViewLayoutAttributes in layoutAttributes {
            guard attributes.representedElementCategory == .Cell else { continue }
            guard candidateAttributes != nil else {
                candidateAttributes = attributes
                continue
            }
            
            switch scrollDirection {
            case .Horizontal:
                if fabs(attributes.center.x - proposedContentOffsetCenter) < fabs(candidateAttributes!.center.x - proposedContentOffsetCenter) {
                    candidateAttributes = attributes
                }
            case .Vertical:
                if fabs(attributes.center.y - proposedContentOffsetCenter) < fabs(candidateAttributes!.center.y - proposedContentOffsetCenter) {
                    candidateAttributes = attributes
                }
            }
        }
        
        guard let candidateAttributesForRect = candidateAttributes else { return proposedContentOffset }
        
        var contentOffset = proposedContentOffset
        var newOffset: CGFloat
        let offset: CGFloat
        switch scrollDirection {
        case .Horizontal:
            newOffset = candidateAttributesForRect.center.x - collectionView.bounds.size.width / 2
            offset = newOffset - collectionView.contentOffset.x
            
            if (velocity.x < 0 && offset > 0) || (velocity.x > 0 && offset < 0) {
                let pageWidth = self.itemSize.width + self.minimumLineSpacing
                newOffset += velocity.x > 0 ? pageWidth : -pageWidth
            }
            contentOffset = CGPoint(x: newOffset, y: proposedContentOffset.y)
            
        case .Vertical:
            newOffset = candidateAttributesForRect.center.y - collectionView.bounds.size.height / 2
            offset = newOffset - collectionView.contentOffset.y
            
            if (velocity.y < 0 && offset > 0) || (velocity.y > 0 && offset < 0) {
                let pageHeight = self.itemSize.height + self.minimumLineSpacing
                newOffset += velocity.y > 0 ? pageHeight : -pageHeight
            }
            contentOffset = CGPoint(x: proposedContentOffset.x, y: newOffset)
        }
        
        return contentOffset
    }
    
}
