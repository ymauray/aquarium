//
//  SwitchTableViewCell.swift
//  Aquarium
//
//  Created by Yannick Mauray on 23.07.17.
//  Copyright © 2017 Yannick Mauray. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var switchSwitch: UISwitch!
    @IBOutlet weak var switchImage: UIImageView!
    
    var module = "dummy"
    var tableViewController: AquariumTableViewController?
    
    @IBAction func valueChangedAction(_ sender: UISwitch) {
        let url = NSURL(string: "http://aquarium.nanuq.loc/switch.php?module=" + self.module + "&on=" + String(sender.isOn))
        let task = URLSession.shared.dataTask(with: url! as URL) {(data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                print(json)
                self.tableViewController?.loadAquariumData()
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
