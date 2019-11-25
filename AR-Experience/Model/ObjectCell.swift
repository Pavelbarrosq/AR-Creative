//
//  ObjectCell.swift
//  AR-Experience
//
//  Created by Pavel Barros Quintanilla on 2019-11-25.
//  Copyright © 2019 Pavel Barros Quintanilla. All rights reserved.
//

import UIKit

class ObjectCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var objectImage: UIImageView!
    
    
    func setObject(object: SelectionObject) {
        titleLabel.text = object.title
        objectImage.image = object.image
    }

}
