//
//  ViewController.swift
//  PagedCollectionView
//
//  Created by ricsantos on 03/08/2017.
//  Copyright (c) 2017 ricsantos. All rights reserved.
//

import UIKit
import PagedCollectionView

class ViewController: UIViewController, UICollectionViewDataSource {
    
    static let reuseIdentifier = "cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = CGRectMake(0.0, 20.0, self.view.frame.size.width, self.view.frame.size.height/2.0)
        let pagedCollectionView = PagedCollectionView(frame: frame)
        pagedCollectionView.itemSize = CGSizeMake(frame.size.width/2.0, frame.size.height - 60.0)
        pagedCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: ViewController.reuseIdentifier)
        pagedCollectionView.backgroundColor = UIColor.lightGrayColor()
        pagedCollectionView.dataSource = self
        pagedCollectionView.layout.shouldFadeInCells = true
        self.view.addSubview(pagedCollectionView)
    }
    
    // MARK: 
    
    func randomColor() -> UIColor {
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    // MARK: UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 32
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ViewController.reuseIdentifier, forIndexPath: indexPath)
        cell.layer.cornerRadius = 4.0
        cell.clipsToBounds = true
        cell.backgroundColor = UIColor.redColor()
        
        return cell
    }
}
