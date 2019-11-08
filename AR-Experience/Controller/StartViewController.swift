//
//  StartViewController.swift
//  AR-Experience
//
//  Created by Pavel Barros Quintanilla on 2019-11-08.
//  Copyright © 2019 Pavel Barros Quintanilla. All rights reserved.
//

import UIKit

class StartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var titleArray: NSArray = []
    var imageArray: NSArray = []
    var descriptionArray: NSArray = []
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        titleArray = ["Build", "Paint"]
        descriptionArray = ["Be creative and build stuff", "Paint in the 3d world"]
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = titleArray[indexPath.row] as! String
        
        return cell!
    }
    

    
}
