//
//  AquariumViewController.swift
//  Aquarium
//
//  Created by Yannick Mauray on 09.08.17.
//  Copyright © 2017 Yannick Mauray. All rights reserved.
//

import UIKit

class AquariumViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var indicator: UIImageView!
    @IBOutlet weak var lightButton: UIImageView!
    @IBOutlet weak var waterButton: UIImageView!
    @IBOutlet weak var heatingButton: UIImageView!

    var temperature: Double?
    var light: Bool?
    var pump: Bool?
    var heating: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(AquariumViewController.refresh), name: NSNotification.Name(rawValue: "refresh"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AquariumViewController.invalidate), name: NSNotification.Name(rawValue: "invalidate"), object: nil)
    }
    
    @objc
    func refresh() {
        let url = NSURL(string: "http://aquarium.nanuq.loc/status.php")
        let task = URLSession.shared.dataTask(with: url! as URL) {(data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                self.temperature = Double(json["temperature"] as! String)!
                self.light = json["light"] as! String == "on"
                self.pump = json["pump"] as! String == "on"
                self.heating = json["heating"] as! String == "on"
                
                self.tick()
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    @objc
    func invalidate() {
        DispatchQueue.main.async() {
            self.label.text = "+--.-°"
            self.lightButton.image = #imageLiteral(resourceName: "light_white")
            self.waterButton.image = #imageLiteral(resourceName: "water_white")
            self.heatingButton.image = #imageLiteral(resourceName: "temperature_white")
        }
    }
    
    @objc
    func tick() {
        var temp = self.temperature!
        
        if 21 > temp { temp = 21 }
        if temp > 25 { temp = 25 }
        
        let pi_over_two = Double.pi / 2
        let pi_over_four = Double.pi / 4

        var angle: Double
        if 22.5 > temp {
            let factor = (temp - 22.5) / 1.5
            angle = -pi_over_two + (pi_over_four - 0.1) * factor
        }
        else if 23.5 >= temp {
            angle = (temp - 23) * Double.pi
        }
        else {
            let factor = (temp - 23.5) / 1.5
            angle = pi_over_two + (pi_over_four - 0.1) * factor
        }
        DispatchQueue.main.async() {
            self.label.text = String(format: "+%.1f°", temp)
            if (temp >= 22.5 && 23.5 >= temp) { self.label.textColor = UIColor.white }
            else if (22.5 > temp) {
                let hue = 30.0 / 255.0 * (0.75 - abs(temp - 21.75)) / 0.75
                let saturation = abs(temp - 22.5) / 1.5
                let brightness = 1.0
                self.label.textColor = UIColor(hue: CGFloat(hue), saturation: CGFloat(saturation), brightness: CGFloat(brightness), alpha: CGFloat(1.0))
            }
            else {
                let hue = 30.0 / 255.0 * (0.75 - abs(temp - 24.25)) / 0.75
                let saturation = abs(temp - 23.5) / 1.5
                let brightness = 1.0
                self.label.textColor = UIColor(hue: CGFloat(hue), saturation: CGFloat(saturation), brightness: CGFloat(brightness), alpha: CGFloat(1.0))
            }
            UIView.animate(withDuration: 1, animations: {
                self.indicator.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
            })
            if self.light! {
                self.lightButton.image = #imageLiteral(resourceName: "light_green")
            }
            else {
                self.lightButton.image = #imageLiteral(resourceName: "light_white")
            }
            
            if self.pump! {
                self.waterButton.image = #imageLiteral(resourceName: "water_green")
            }
            else {
                self.waterButton.image = #imageLiteral(resourceName: "water_white")
            }
            
            if self.heating! {
                self.heatingButton.image = #imageLiteral(resourceName: "temperature_green")
            }
            else {
                self.heatingButton.image = #imageLiteral(resourceName: "temperature_white")
            }
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count != 1 { return }
        let touch = touches.first!
        var module = "dummy"
        var isOn = "true"
        if touch.view! == self.lightButton {
            module = "lumiere"
            isOn = String(!(self.light!))
        }
        else if touch.view! == self.waterButton {
            module = "pompe"
            isOn = String(!(self.pump!))
        }
        else if touch.view! == self.heatingButton {
            module = "chauffage"
            isOn = String(!(self.heating!))
        }
        else {
            print("erreur: cible inconnue")
        }
        
        let url = NSURL(string: "http://aquarium.nanuq.loc/switch.php?module=" + module + "&on=" + isOn)
        let task = URLSession.shared.dataTask(with: url! as URL) {(data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                let module = json["module"] as! String
                let isOn = json["on"] as! String == "true"
                if module == "lumiere" {
                    self.light = isOn
                    DispatchQueue.main.async() {
                        self.lightButton.image = isOn ? #imageLiteral(resourceName: "light_green") : #imageLiteral(resourceName: "light_white")
                    }
                }
                else if (module == "pompe") {
                    self.pump = isOn
                    DispatchQueue.main.async() {
                        self.waterButton.image = isOn ? #imageLiteral(resourceName: "water_green") : #imageLiteral(resourceName: "water_white")
                    }
                }
                else if (module == "chauffage") {
                    self.heating = isOn
                    DispatchQueue.main.async() {
                        self.heatingButton.image = isOn ? #imageLiteral(resourceName: "temperature_green") : #imageLiteral(resourceName: "temperature_white")
                    }
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
