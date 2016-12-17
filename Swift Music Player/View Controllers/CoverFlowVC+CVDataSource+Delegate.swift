//
//  CoverFlowVC+CollectionViewDataSource.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 5/24/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit

extension CoverFlowViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:CoverFlowCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CoverFlowCollectionViewCell
        
        cell.backgroundColor = UIColor(hue: CGFloat((indexPath as NSIndexPath).row) / CGFloat(albumCount), saturation: 0.333, brightness: 1.0, alpha: 1.0)
        
        if (indexPath as NSIndexPath).row < albumCount {
            let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
            let albumImage = AlbumFetcher.fetchAlbumImageWithAlbumInternalID((indexPath as NSIndexPath).row, size: CGSize(width: 220.0, height: 220.0), databaseInterface: databaseInterface)
            cell.imageView.image = albumImage
            cell.reflectionImageView.image = albumImage
            cell.reflectionImageView.transform = cell.reflectionImageView.transform.scaledBy(x: 1.0, y: -1.0)
            cell.backgroundColor = UIColor.clear
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        scrollToIndexPath(indexPath, animated: true)
    }
    
}
