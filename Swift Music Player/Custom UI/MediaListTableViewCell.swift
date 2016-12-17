//
//  MediaListTableViewCell.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 6/22/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

class MediaListTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var persistentID: UInt64!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
