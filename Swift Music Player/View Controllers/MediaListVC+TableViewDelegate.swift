//
//  MediaListVC+TableViewDelegate.swift
//  MusicByCarlSwift
//
//  Created by CarlSmith on 5/24/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit

extension MediaListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if useFetchedResultsController && section > 0 {
            return 22.0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if useFetchedResultsController {
            let sectionView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.bounds.size.width, height: 22.0))
            sectionView.backgroundColor = UIColor.black
            
            let headerLabel = UILabel(frame: CGRect(x: 15.0, y: 0.0, width: tableView.bounds.size.width, height: 22.0))
            headerLabel.textColor = UIColor.orange
            headerLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
            
            if let sectionTitle = self.tableView(tableView, titleForHeaderInSection:section) {
                let attString:NSMutableAttributedString = NSMutableAttributedString(string: sectionTitle)
                attString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleDouble.rawValue, range: NSRange(location:0, length:attString.length))
                headerLabel.attributedText = attString
            }
            
            sectionView.addSubview(headerLabel)
            
            return sectionView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Logger.writeToLogFile("Section \(indexPath.section), row \(indexPath.row) selected")
        guard segueIdentifier != nil else {
            return
        }
        
        guard segueIdentifier != "" else {
            return
        }
        
        self.performSegue(withIdentifier: segueIdentifier, sender: self)
    }
    
}
