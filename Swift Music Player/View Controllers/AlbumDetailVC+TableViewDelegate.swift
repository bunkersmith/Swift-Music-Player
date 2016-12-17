//
//  AlbumDetailVC+TableViewDelegate.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/25/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit
import MediaPlayer

extension AlbumDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 117.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let albumInfoView:AlbumInfoView = AlbumInfoView()
        
        if albumTracks[section].count > 0 {
            let song = albumTracks[section].object(at: 0) as! Song
            
            var albumArtworkImage:UIImage = UIImage(named: "no-album-artwork.png")!

            let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
            
            if let currentAlbum = AlbumFetcher.fetchAlbumByAlbumPersistentID(song.albumPersistentID, databaseInterface:databaseInterface) {
                if let localAlbumArtwork:MPMediaItemArtwork = currentAlbum.albumArtwork(databaseInterface) {
                    albumArtworkImage = localAlbumArtwork.image(at: CGSize (width: 320, height: 320))!
                }
                
                albumInfoView.albumArtworkImageView.image = albumArtworkImage
                if artistSummary != nil {
                    albumInfoView.albumArtistLabel.text = artistSummary!.name
                }
                albumInfoView.albumTitleLabel.text = currentAlbum.summary.title
                albumInfoView.albumInfoLabel.text = "\(currentAlbum.songs.count) Songs, \(DateTimeUtilities.durationToMinutesString(currentAlbum.duration)) Mins."
                albumInfoView.albumReleaseYearLabel.text = currentAlbum.releaseYearString
            }
        }
        
        return albumInfoView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
