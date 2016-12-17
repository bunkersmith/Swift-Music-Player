//
//  AlbumDetailTableViewCell.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 6/17/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

class AlbumDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var trackNumberLabel: UILabel!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var trackArtistLabel: UILabel!
    @IBOutlet weak var trackSingleArtistTitleLabel: UILabel!
    @IBOutlet weak var trackDurationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
