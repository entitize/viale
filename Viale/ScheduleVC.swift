//
//  ScheduleVC.swift
//  Viale
//
//  Created by Kai Nakamura on 6/2/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import UIKit

class ScheduleVC : UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    let kCloseCellHeight: CGFloat = 80
    let kOpenCellHeight: CGFloat = 400 + 2 * 8
    
    var userIntervalKeys = [String]()
    var numberOfKeys = 0
    var cellHeights = [CGFloat]()
    
    override func viewDidLoad() {
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let _userIntervalKeys = UserDriver.currentUser.scheduleKeys!
        
        self.userIntervalKeys = []
        self.numberOfKeys = 0
        
        for key in _userIntervalKeys {
            self.userIntervalKeys.append(key)
            self.numberOfKeys += 1
        }
        
        self.createCellHeightsArray()
        self.tableView.reloadData()
        
        
    }
    func createCellHeightsArray() {
        self.cellHeights = []
        for _ in 0...self.numberOfKeys {
            cellHeights.append(kCloseCellHeight)
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as ScheduleCell = cell else {
            return
        }
        
        cell.backgroundColor = UIColor.clear
        
        if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight {
            cell.selectedAnimation(false, animated: false, completion:nil)
        } else {
            cell.selectedAnimation(true, animated: false, completion: nil)
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return cellHeights[(indexPath as NSIndexPath).row]
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ScheduleCell
        
        //Now assign to each cell the intervalKeys and then activate the setup function
        let intervalKey = userIntervalKeys[indexPath.row]
        cell.setupIntervalListener(intervalKey: intervalKey)
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfKeys
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! ScheduleCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight { // open cell
            cellHeights[(indexPath as NSIndexPath).row] = kOpenCellHeight
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {// close cell
            cellHeights[(indexPath as NSIndexPath).row] = kCloseCellHeight
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 0.8
        }
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    
}
