//
//  AlbumDetailViewController.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 6/17/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumDetailViewController: PortraitViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var songCountLabel: UILabel!
    @IBOutlet weak var nowPlayingButton: UIBarButtonItem!
    
    var artistPersistentID: UInt64!
    var artistSummary:ArtistSummary?
    var artistSingleAlbumPersistentID: UInt64?
    var artistSingleAlbum:Album?
    var albumTracks:Array<NSOrderedSet>!
    var totalTrackCount:Int = 0
    
    lazy fileprivate var databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(NSNumber(value: artistPersistentID as UInt64), forKey: "artistPersistentID")
        if artistSingleAlbumPersistentID != nil {
            coder.encode(NSNumber(value: artistSingleAlbumPersistentID! as UInt64), forKey: "artistSingleAlbumPersistentID")
        }
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        let artistPersistentIDNumber:NSNumber = coder.decodeObject(forKey: "artistPersistentID") as! NSNumber
        artistSummary = ArtistFetcher.fetchArtistSummaryWithPersistentID(artistPersistentIDNumber.uint64Value, databaseInterface: databaseInterface)
        if let artistSingleAlbumPersistentIDNumber:NSNumber = coder.decodeObject(forKey: "artistSingleAlbumPersistentID") as? NSNumber {
            artistSingleAlbum = AlbumFetcher.fetchAlbumByAlbumPersistentID(artistSingleAlbumPersistentIDNumber.uint64Value, databaseInterface: databaseInterface)
        }
        populateAlbumTracks()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if SongManager.instance.song != nil {
            nowPlayingButton.show()
        }
        else {
            nowPlayingButton.hide()
        }

        populateAlbumTracks()
        songCountLabel.text = "\(totalTrackCount) Songs"
    }
    
    func populateAlbumTracks() {
        albumTracks = Array()
        
        if artistSummary != nil {
            artistPersistentID = artistSummary!.persistentID
            navigationItem.title = artistSummary!.name
            
            if artistSingleAlbum == nil {
                for (index, object) in artistSummary!.forArtist.albums.enumerated() {
                    let album = object as! Album
                    albumTracks.append(album.songs)
                    totalTrackCount += albumTracks[index].count
                }
            }
            else {
                artistSingleAlbumPersistentID = artistSingleAlbum!.summary.persistentID
                albumTracks.append(artistSingleAlbum!.songs)
                totalTrackCount += albumTracks[0].count
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
       if segue.identifier != "nowPlayingSegue" {
            if let nowPlayingViewController:NowPlayingViewController = segue.destination as? NowPlayingViewController {
                nowPlayingViewController.songNeedsPlaying = true
            
                let songManager = SongManager.instance
                songManager.fillSongListFromAlbumTracks(albumTracks, containsMultipleAlbums: artistSingleAlbum == nil)
            
                if segue.identifier == "songSelectionSegue" {
                    if let selectedIndexPath:IndexPath = tableView.indexPathForSelectedRow {
                        tableView.deselectRow(at: selectedIndexPath, animated: true)
                        if let song:Song = albumTracks[(selectedIndexPath as NSIndexPath).section].object(at: (selectedIndexPath as NSIndexPath).row) as? Song {
                            songManager.song = song
                        }
                        return
                    }
                }
                
                if segue.identifier == "shuffleAllSegue" {
                    UserPreferences().changeShuffleFlagSetting(true)
                    songManager.shuffleAll()
                    return
                }
            }
        }
     }
}
