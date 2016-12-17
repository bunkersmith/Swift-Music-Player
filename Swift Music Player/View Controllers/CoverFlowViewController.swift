//
//  CoverFlowViewController.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 7/10/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class CoverFlowViewController: UIViewController {
    
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    @IBOutlet weak var albumArtistLabel: UILabel!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var songTitleLabel: UILabel!
    
    var previousNavBarHidden:Bool!
    var previousTabBarHidden:Bool!
    var albumCount = 3
    var currentAlbumIndex = 3
    let shadowColor = UIColor.black
    let shadowOffset = CGSize(width: 2.0, height: 2.0)
    fileprivate lazy var songManager = SongManager.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        albumCount = AlbumsInterface.numberOfAlbumsInDatabase(databaseInterface)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        previousNavBarHidden = navigationController!.isNavigationBarHidden
        previousTabBarHidden = tabBarController!.tabBar.isHidden
        
        navigationController!.isNavigationBarHidden = true
        tabBarController!.tabBar.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(CoverFlowViewController.handleUpdatePlayPauseButton(_:)), name: NSNotification.Name(rawValue: "Swift-Music-Player.updatePlayPauseButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CoverFlowViewController.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateCurrentAlbumIndexFromSongManager()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController!.isNavigationBarHidden = previousNavBarHidden
        tabBarController!.tabBar.isHidden = previousTabBarHidden
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "Swift-Music-Player.updatePlayPauseButton"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        // Prevents crashes when CoverFlowViewController is popped off the navigation stack
        collectionViewOutlet.delegate = nil
        
        super.viewWillDisappear(animated)
    }
    
    func rotated()
    {
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation)
        {
            if self.navigationController != nil {
                self.navigationController!.popViewController(animated: true)
            }
        }
    }
    
    func addShadowToLabel(_ label:UILabel) {
        label.shadowColor = shadowColor
        label.shadowOffset = shadowOffset
    }
    
    func updateCurrentAlbumIndexFromSongManager() {
        if let song = songManager.song {
            if let album = song.album {
                currentAlbumIndex = Int(album.internalID)
                scrollToIndexPath(IndexPath(row: currentAlbumIndex, section: 0), animated: false)
            }
        }
    }
    
    func handleUpdatePlayPauseButton(_ notification: Notification) {
        DispatchQueue.main.async(execute: { () -> Void in
            if let userInfo:[AnyHashable: Any] = (notification as NSNotification).userInfo {
                if let isPlayingNumber:NSNumber = userInfo["isPlaying"] as? NSNumber {
                    if isPlayingNumber.boolValue {
                        self.updateCurrentAlbumIndexFromSongManager()
                    }
                }
            }
        })
    }
    
    class func segueToCoverFlow(_ viewController: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let coverFlowViewController:UIViewController = storyboard.instantiateViewController(withIdentifier: "CoverFlowViewController")
            viewController.navigationController?.pushViewController(coverFlowViewController, animated: true)
        
    }

    // MARK: UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateTitle()
    }

    func scrollToIndexPath(_ indexPath: IndexPath?, animated: Bool) {
        if indexPath != nil {
            if let collectionViewLayout = collectionViewOutlet.collectionViewLayout as? CCoverflowCollectionViewLayout {
                collectionViewOutlet.setContentOffset(CGPoint(x: CGFloat((indexPath! as NSIndexPath).row) * collectionViewLayout.cellSpacing, y: 0), animated:animated)
                updateTitleWithIndexPath(indexPath)
            }
        }
        else {
            Logger.writeToLogFile("indexPath is nil")
        }
    }
    
    func updateTitleWithIndexPath(_ indexPath: IndexPath?) {
        if indexPath == nil {
            albumArtistLabel.text = ""
            albumTitleLabel.text = ""
            songTitleLabel.text = ""
        }
        else {
            if albumArtistLabel.shadowOffset.width == 0.0 {
                addShadowToLabel(albumArtistLabel!)
                addShadowToLabel(albumTitleLabel!)
                addShadowToLabel(songTitleLabel!)
            }
            
            let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
            AlbumFetcher.fetchAlbumTextDataWithAlbumInternalID((indexPath! as NSIndexPath).row, albumTitleString: &albumTitleLabel.text!, albumArtistString:
                &albumArtistLabel.text!, songTitleString: &songTitleLabel.text!, databaseInterface: databaseInterface)
        }
    }
    
    func updateTitle() {
        // Asking a collection view for indexPathForItem inside a scrollViewDidScroll: callback seems unreliable.
        //	NSIndexPath *theIndexPath = [self.collectionView indexPathForItemAtPoint:(CGPoint){ CGRectGetMidX(self.collectionView.frame) + self.collectionView.contentOffset.x, CGRectGetMidY(self.collectionView.frame) }];
        if let collectionViewLayout = self.collectionViewOutlet.collectionViewLayout as? CCoverflowCollectionViewLayout
        {
            let centerScreenIndexPath = collectionViewLayout.currentIndexPath
            updateTitleWithIndexPath(centerScreenIndexPath)
        }
    }
    
}
