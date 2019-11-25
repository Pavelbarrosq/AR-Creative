//
//  StartViewController.swift
//  AR-Experience
//
//  Created by Pavel Barros Quintanilla on 2019-11-08.
//  Copyright © 2019 Pavel Barros Quintanilla. All rights reserved.
//

import UIKit

class StartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    var objectArray: [SelectionObject] = []
    
    override func viewDidLoad() {
        
        objectArray = addToArray()
        
        title = "AR-Create"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    
    func addToArray() -> [SelectionObject] {
        var placeholderArray: [SelectionObject] = []
        
        let buildObject = SelectionObject(title: "Build", image: #imageLiteral(resourceName: "Cube"))
        let paintObject = SelectionObject(title: "Paint", image: #imageLiteral(resourceName: "Palette"))
        
        placeholderArray.append(buildObject)
        placeholderArray.append(paintObject)
        
        return placeholderArray
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = objectArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ObjectCell
        
        cell.setObject(object: object)
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let storyBoard = UIStoryboard(name: "Start", bundle: nil)
            let vc = storyBoard.instantiateViewController(identifier: "Build") as! BuildViewController
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            
            let storyBoard = UIStoryboard(name: "Start", bundle: nil)
            let vc = storyBoard.instantiateViewController(identifier: "Paint") as! PaintViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
   }

}
