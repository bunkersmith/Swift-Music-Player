//
//  MoreViewController.swift
//  Swift Music Player
//
//  Created by CarlSmith on 6/8/15.
//  Copyright (c) 2015 CarlSmith. All rights reserved.
//

import UIKit

class MoreViewController: PortraitViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var nowPlayingButton: UIBarButtonItem!
    
    fileprivate var labels = ["Genres", "Database", "Email Log", "Email Played Songs"]
    fileprivate var icons = [UIImage(named: "genres-tab-bar-icon.png"),
                         UIImage(named: "database-tab-bar-icon.png"),
                         UIImage(named: "email-log-tab-bar-icon.png"),
                         UIImage(named: "email-log-tab-bar-icon.png")]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SongsInterface.totalSongCount() == 0 {
            performSegue(withIdentifier: "databaseSegue", sender: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        if SongManager.instance.song != nil {
            nowPlayingButton.show()
        }
        else {
            nowPlayingButton.hide()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoreTableViewCell", for: indexPath) 
        cell.imageView!.image = icons[(indexPath as NSIndexPath).row]
        cell.textLabel!.text = labels[(indexPath as NSIndexPath).row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath as NSIndexPath).row {
            case 0:
                performSegue(withIdentifier: "genresSegue", sender: self)
            break
            
            case 1:
                performSegue(withIdentifier: "databaseSegue", sender: self)
            break
            
            case 2:
                performSegue(withIdentifier: "emailLogSegue", sender: self)
            break
            
            case 3:
                performSegue(withIdentifier: "emailPlayedSongsSegue", sender: self)
            break
            
            default:
            break
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "emailLogSegue"{
            if let emailLogViewController = segue.destination as? EmailLogViewController {
                emailLogViewController.requestMailComposeViewController()
            }
        }
        else {
            if segue.identifier == "emailPlayedSongsSegue"{
                if let emailPlayedSongsViewController = segue.destination as? EmailPlayedSongsViewController {
                    emailPlayedSongsViewController.requestMailComposeViewController()
                }
            }
        }
    }
}

