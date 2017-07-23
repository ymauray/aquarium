//
//  AquariumTableViewController.swift
//  Aquarium
//
//  Created by Yannick Mauray on 22.07.17.
//  Copyright © 2017 Yannick Mauray. All rights reserved.
//

import UIKit

class AquariumTableViewController: UITableViewController {
    
    //MARK: Properties
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var switchSwitch: UISwitch!
    @IBOutlet weak var switchImage: UIImageView!
    
    var temperature: Float = 0.0
    var light = false
    var pump = false
    var heating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAquariumData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /*
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "La pataugeoire enchantée"
    }
    */
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderTableViewCell") as? SectionHeaderTableViewCell else {
            fatalError("The dequeud cell is not an instance of SectionHeaderTableViewCell.")
        }
        cell.headerLabel.text = "La pataugeoire enchantée"
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt: " + String(indexPath.row))
        if (indexPath.row == 0) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClockTableViewCell", for: indexPath) as? ClockTableViewCell else {
                fatalError("The dequeud cell is not an instance of ClockTableViewCell.")
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            cell.clockLabel.text = dateFormatter.string(from: Date())
            let clockIcon = UIImage(named: "clock")
            cell.iconImageView.image = clockIcon
            return cell
        }
        else if (indexPath.row == 1) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClockTableViewCell", for: indexPath) as? ClockTableViewCell else {
                fatalError("The dequeud cell is not an instance of ClockTableViewCell.")
            }
            cell.clockLabel.text = String(format: "%.1f", self.temperature) + "°"
            let temperatureIcon = UIImage(named: "temperature")
            cell.iconImageView.image = temperatureIcon
            return cell
        }
        else {
            let cellIdentifier = "SwitchTableViewCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SwitchTableViewCell else {
                fatalError("The dequeud cell is not an instance of SwitchTableViewCell.")
            }
            cell.tableViewController = self
            switch indexPath.row {
            case 2:
                cell.switchLabel.text = "La lumière est " + (self.light ? "allumée" : "éteinte") + "."
                cell.switchSwitch.isOn = self.light
                cell.switchImage.image = UIImage(named: "light")
                cell.module = "lumiere"
            case 3:
                cell.switchLabel.text = "Le filtre est " + (self.pump ? "en fonction" : "arrété") + "."
                cell.switchSwitch.isOn = self.pump
                cell.switchImage.image = UIImage(named: "water")
                cell.module = "pompe"
            case 4:
                cell.switchLabel.text = "Le chauffage est " + (self.heating ? "en fonction" : "eteint") + "."
                cell.switchSwitch.isOn = self.heating
                cell.switchImage.image = UIImage(named: "heating")
                cell.module = "chauffage"
            default:
                cell.switchLabel.text = "Oups..."
                cell.switchSwitch.isOn = true
                cell.switchImage.image = UIImage(named: "light")
            }
            return cell
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    public func loadAquariumData() {
        let url = NSURL(string: "http://aquarium.nanuq.loc/status.php")
        let task = URLSession.shared.dataTask(with: url! as URL) {(data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                self.temperature = Float(json["temperature"] as! String)!
                self.light = json["light"] as! String == "on"
                self.pump = json["pump"] as! String == "on"
                self.heating = json["heating"] as! String == "on"
                DispatchQueue.main.async() {
                    self.tableView.reloadData()
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}
