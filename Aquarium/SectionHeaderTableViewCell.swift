//
//  SectionHeaderTableViewCell.swift
//  Aquarium
//
//  Created by Yannick Mauray on 23.07.17.
//  Copyright © 2017 Yannick Mauray. All rights reserved.
//

import UIKit

class SectionHeaderTableViewCell: UITableViewCell {

    //MARK: properties
    @IBOutlet weak var headerLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
