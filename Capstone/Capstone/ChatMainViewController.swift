//
//  ChatMainViewController.swift
//  Capstone
//
//  Created by Christian John on 2019-03-18.
//  Copyright © 2019 Christian John. All rights reserved.
//

import UIKit

class ChatMainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var cars = ["BMW", "Range Rover", "Tesla", "Lamborghini", "Datsun", "Jeep", "Lada", "Spyker", "Roewe", "Audi", "Toyota", "Chrysler", "Ford", "McLaren Senna", "Aston Martin Vanquish", "Triumph Spitfire", "Volkswagen Beetle", "Studebaker Power Hawk", "Lamborghini Murciélago", "Plymouth Road Runner Superbird", "Studebaker Power Hawk", "Lamborghini Murciélago", "AMC Gremlin", "Plymouth Road Runner Superbird", "Bentley Mulsanne", "Ford Thunderbird", "Chervolet", "Lagonda", "Bentley", "Dodge", "Donkervoort", "Freightliner", "Hyundai", "General Motors", "Hindustan Motors", "Mitsubishi","Pierce-Arrow", "Prodrive", "Studebaker"]
    var friuts = ["Pear", "Apple", "Pineapple", "Oranges", "WaterMelon", "Cherry", "Strawberry", "Pomangranate", "Plum", "Rasberry", "Lemon", "Grapefruit", "Coconut", "Avocodo", "Nectarine", "Mango", "Kiwi", "Papaya", "Carambola(U.K) – starfruit (U.S)", "Blueberry","Pear", "Apricot", "Kiwano (horned melon)", "Pomelo", "White currant", "Eggplant", "Cucumber", "Tangerine", "Nance", "Fig", "Durian", "Elderberry", "Japanese plum", "Passionfruit", "Plantain", "Blackcurrant", "Dragonfruit (or Pitaya)", "Buddha's hand (fingered citron)", "Purple mangosteen", "White sapote"]
    
    struct SegmentedControl {
        static let subscribed = 0
        static let unsubscribed = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Rooms"
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentControl.selectedSegmentIndex {
        case SegmentedControl.subscribed:
            return cars.count
        case SegmentedControl.unsubscribed:
            return friuts.count
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath)
        switch segmentControl.selectedSegmentIndex {
        case SegmentedControl.subscribed:
            cell.textLabel?.text = cars[indexPath.row]
        case SegmentedControl.unsubscribed:
            cell.textLabel?.text = friuts[indexPath.row]
        default:
            break
        }
        return cell
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        self.tableView.reloadData()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
