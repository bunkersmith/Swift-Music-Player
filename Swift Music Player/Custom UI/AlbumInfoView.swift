//
//  AlbumInfoView.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 6/17/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

class AlbumInfoView: UIView {

    @IBOutlet weak var albumArtworkImageView: UIImageView!
    @IBOutlet weak var albumArtistLabel: UILabel!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var albumInfoLabel: UILabel!
    @IBOutlet weak var albumReleaseYearLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: max(frame.size.height, 117.0)))
        let subviews:NSArray = UINib(nibName: "AlbumInfoView", bundle: nil).instantiate(withOwner: self, options: nil) as NSArray
        self.addSubview(subviews.firstObject as! UIView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("AlbumInfoView class does not support NSCoding")
    }
}
