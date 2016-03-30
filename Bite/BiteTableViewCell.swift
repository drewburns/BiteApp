//
//  BiteTableViewCell.swift
//  Bite
//
//  Created by Andrew Burns on 1/16/16.
//  Copyright © 2016 Andrew Burns. All rights reserved.
//

import UIKit

class BiteTableViewCell: UITableViewCell {

    var textBite: TextBite?
    var soundBite: SoundBite?
    

    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
