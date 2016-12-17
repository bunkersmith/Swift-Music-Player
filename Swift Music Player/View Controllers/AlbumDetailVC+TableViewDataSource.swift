//
//  AlbumDetailVC+TableViewDataSource.swift
//  Swift Music Player
//
//  Created by CarlSmith on 5/25/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit

extension AlbumDetailViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        if albumTracks != nil {
            return albumTracks.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if albumTracks != nil {
            return albumTracks[section].count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumDetailTableViewCell", for: indexPath) as! AlbumDetailTableViewCell
        let song = albumTracks[(indexPath as NSIndexPath).section].object(at: (indexPath as NSIndexPath).row) as! Song
        
        cell.trackNumberLabel.text = "\(song.trackNumber)"
        cell.trackDurationLabel.text = DateTimeUtilities.durationToMinutesAndSecondsString(song.duration)
        
        if song.summary.artistName == song.albumArtistName {
            cell.trackSingleArtistTitleLabel.text = song.summary.title
        }
        else {
            cell.trackTitleLabel.text = song.summary.title
            cell.trackArtistLabel.text = song.summary.artistName
        }
        
        return cell
    }
    
}
