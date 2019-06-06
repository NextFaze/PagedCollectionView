//
//  PagedCollectionView.swift
//  PagedCollectionView
//
//  Created by Ricardo Santos on 8/3/17.
//
//  Adapted from https://github.com/BenEmdon/CenteredCollectionView

import UIKit

open class PagedCollectionView: UICollectionView {
    
    open var itemSize: CGSize {
        get {
            return self.layout.itemSize
        }
        set(newValue)  {
            self.layout.itemSize = newValue
        }
    }
    
    open var currentPage: Int {
        get {
            let center = CGPoint(x: self.contentOffset.x + self.bounds.size.width/2.0, y: self.contentOffset.y + self.bounds.size.height/2.0)
            let indexPath = self.indexPathForItem(at: center)
            return indexPath?.row ?? 0
        }
    }
    
    public let layout = PagedCollectionViewFlowLayout()
    
    public init(frame: CGRect) {
        self.layout.scrollDirection = .horizontal
        super.init(frame: frame, collectionViewLayout: self.layout)
        self.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        fatalError("use init(frame:) instead")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var pageWidth: CGFloat {
        switch self.layout.scrollDirection {
        case .horizontal:
            return self.layout.itemSize.width + self.layout.minimumLineSpacing
        case .vertical:
            return self.layout.itemSize.height + self.layout.minimumLineSpacing
        @unknown default:
            return 0.0
        }
    }
    
    open func setCurrentPage(_ page: Int, animated: Bool) {
        let pageOffset: CGFloat
        let proposedContentOffset: CGPoint
        
        switch self.layout.scrollDirection {
        case .horizontal:
            pageOffset = CGFloat(page) * self.pageWidth - contentInset.left
            proposedContentOffset = CGPoint(x: pageOffset, y: 0)
        case .vertical:
            pageOffset = CGFloat(page) * pageWidth - contentInset.top
            proposedContentOffset = CGPoint(x: 0, y: pageOffset)
        @unknown default:
            return
        }
        self.setContentOffset(proposedContentOffset, animated: animated)
    }
    
}

open class PagedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    open var shouldFadeInCells: Bool = false
    open var fadeInMinAlpha: CGFloat = 0.3
    
    fileprivate var lastCollectionViewSize: CGSize = CGSize.zero
    fileprivate var lastScrollDirection: UICollectionView.ScrollDirection!
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return self.shouldFadeInCells
    }

    open override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        guard let collectionView = self.collectionView else { return }
        // invalidate layout to center first and last
        
        let currentCollectionViewSize = collectionView.bounds.size
        if !currentCollectionViewSize.equalTo(self.lastCollectionViewSize) || self.lastScrollDirection != scrollDirection {
            let inset: CGFloat
            switch scrollDirection {
            case .horizontal:
                inset = (collectionView.bounds.size.width - itemSize.width) / 2
                collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
                collectionView.contentOffset = CGPoint(x: -inset, y: 0)
            case .vertical:
                inset = (collectionView.bounds.size.height - itemSize.height) / 2
                collectionView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
                collectionView.contentOffset = CGPoint(x: 0, y: -inset)
            @unknown default:
                break
            }
            self.lastCollectionViewSize = currentCollectionViewSize
            self.lastScrollDirection = scrollDirection
        }
    }
    
    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        
        let proposedRect: CGRect
        
        switch scrollDirection {
        case .horizontal:
            proposedRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
        case .vertical:
            proposedRect = CGRect(x: 0, y: proposedContentOffset.y, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
        @unknown default:
            return .zero
        }
        
        guard let layoutAttributes = self.layoutAttributesForElements(in: proposedRect) else { return proposedContentOffset }
        
        var candidateAttributes: UICollectionViewLayoutAttributes?
        let proposedContentOffsetCenter: CGFloat
        
        switch scrollDirection {
        case .horizontal:
            proposedContentOffsetCenter = proposedContentOffset.x + collectionView.bounds.size.width / 2
        case .vertical:
            proposedContentOffsetCenter = proposedContentOffset.y + collectionView.bounds.size.height / 2
        @unknown default:
            return .zero
        }
        
        for attributes: UICollectionViewLayoutAttributes in layoutAttributes {
            guard attributes.representedElementCategory == .cell else { continue }
            guard candidateAttributes != nil else {
                candidateAttributes = attributes
                continue
            }
            
            switch scrollDirection {
            case .horizontal:
                if abs(attributes.center.x - proposedContentOffsetCenter) < abs(candidateAttributes!.center.x - proposedContentOffsetCenter) {
                    candidateAttributes = attributes
                }
            case .vertical:
                if abs(attributes.center.y - proposedContentOffsetCenter) < abs(candidateAttributes!.center.y - proposedContentOffsetCenter) {
                    candidateAttributes = attributes
                }
            @unknown default:
                break
            }
        }
        
        guard let candidateAttributesForRect = candidateAttributes else { return proposedContentOffset }
        
        var contentOffset = proposedContentOffset
        var newOffset: CGFloat
        let offset: CGFloat
        switch scrollDirection {
        case .horizontal:
            newOffset = candidateAttributesForRect.center.x - collectionView.bounds.size.width / 2
            offset = newOffset - collectionView.contentOffset.x
            
            if (velocity.x < 0 && offset > 0) || (velocity.x > 0 && offset < 0) {
                let pageWidth = self.itemSize.width + self.minimumLineSpacing
                newOffset += velocity.x > 0 ? pageWidth : -pageWidth
            }
            contentOffset = CGPoint(x: newOffset, y: proposedContentOffset.y)
        case .vertical:
            newOffset = candidateAttributesForRect.center.y - collectionView.bounds.size.height / 2
            offset = newOffset - collectionView.contentOffset.y
            
            if (velocity.y < 0 && offset > 0) || (velocity.y > 0 && offset < 0) {
                let pageHeight = self.itemSize.height + self.minimumLineSpacing
                newOffset += velocity.y > 0 ? pageHeight : -pageHeight
            }
            contentOffset = CGPoint(x: proposedContentOffset.x, y: newOffset)
        @unknown default:
            break
        }
        
        return contentOffset
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        guard let collectionView = self.collectionView else { return layoutAttributes }
        if self.shouldFadeInCells == false { return layoutAttributes }
        
        let minAlpha: CGFloat = self.fadeInMinAlpha
        let maxAlpha: CGFloat = 1.0
        let alphaDelta = maxAlpha - minAlpha
        
        if let layoutAttributes = layoutAttributes {
            for attributes: UICollectionViewLayoutAttributes in layoutAttributes {
                if attributes.isHidden { continue }
                
                switch self.scrollDirection {
                case .horizontal:
                    let centeredOffsetX = collectionView.contentOffset.x + self.itemSize.width// + self.minimumLineSpacing
                    var alpha: CGFloat = maxAlpha
                    if attributes.center.x < centeredOffsetX {
                        alpha = maxAlpha - alphaDelta*((centeredOffsetX - attributes.center.x)/self.itemSize.width)
                    } else if attributes.center.x > centeredOffsetX {
                        alpha = maxAlpha - alphaDelta*((attributes.center.x - centeredOffsetX)/self.itemSize.width)
                    }
                    
                    attributes.alpha = min(max(alpha, minAlpha), maxAlpha)
                default:
                    continue // TODO: vertical scrolling fade support
                    
                }
            }
        }
        return layoutAttributes
    }
    
}
