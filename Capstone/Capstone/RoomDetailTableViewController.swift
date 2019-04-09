//
//  RoomDetailTableViewController.swift
//  Capstone
//
//  Created by Christian John on 2019-03-28.
//  Copyright © 2019 Christian John. All rights reserved.
//

import UIKit
import PusherChatkit

class RoomDetailTableViewController: UITableViewController {
    var room: PCRoom? = nil
    var usersInRoom: [PCUser]? = nil
    var index = 0
    var numberOfRows = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.usersInRoom = self.room?.users
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        print("self.room?.users: \(String(describing: self.room?.users.count))")
        self.navigationItem.title = "Details"
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let temp = usersInRoom {
            self.numberOfRows = temp.count
        }
        self.numberOfRows = self.numberOfRows + 5 - 1
        return self.numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RoomNameCell", for: indexPath) as! RoomNameTableViewCell
            cell.roomName.text = self.room?.name
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            return cell
        } else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MuteMessagesCell", for: indexPath) as! MuteMessagesTableViewCell
            if (cell.mute.isOn) {
                self.room?.unsubscribe()
            }
            return cell
        } else if (indexPath.row == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MembersCell", for: indexPath) as! MembersTableViewCell
            cell.add.addTarget(self, action: #selector(addUser), for: .touchUpInside)
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            return cell
        } else if (indexPath.row == self.numberOfRows - 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LeaveRoomCell", for: indexPath) as! LeaveRoomTableViewCell
            cell.leaveRoom.addTarget(self, action: #selector(leaveRoom), for: .touchUpInside)
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListOfMembersCell", for: indexPath) as! ListOfMembersTableViewCell
            let user = self.usersInRoom![index]
            getCustomImage(imageDisplayName: user.displayName, imageView: cell.imagePlaceholder)
            cell.user.text = user.displayName
            if (self.index != usersInRoom!.count - 1) {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            }
            self.index += 1

            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return UITableView.automaticDimension
        case 1:
            return 44
        case 2:
            return UITableView.automaticDimension
        case self.numberOfRows - 1:
            return 93
        default:
            return 60
        }
    }
    func getCustomImage(imageDisplayName: String?, imageView: UIImageView!){
        if let name = imageDisplayName, !name.isEmpty {
            imageView.setImage(string:name, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), circular: true, stroke: false)
        } else {
            imageView.setImage(string:"Display Picture", color: UIColor.colorHash(name: "Display Picture"), circular: true, stroke: false)
        }
    }
    
    @objc
    func addUser() {
        let ac = UIAlertController(title: "Add User", message: "Enter the username of the user", preferredStyle: .alert)
        ac.addTextField()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let submitAction = UIAlertAction(title: "Add", style: .default) { [unowned ac] _ in
            guard let answer = ac.textFields![0].text else { return }
            if (ChatMainViewController.chat.AddUser(anotherUserID: answer, room_id: self.room!.id) == false) {
                let ac = UIAlertController(title: "Error", message: "You don't have the right to add user to this room. Only the room admin can add a user", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
                self.present(ac, animated: true, completion: nil)
            }
            self.usersInRoom = self.room?.users
            self.index = 0
            self.tableView.reloadData()
        }
        
        ac.addAction(submitAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
        print("adding user to room \(String(describing: self.room))")
    }
    
    @objc
    func leaveRoom() {
        if (ChatMainViewController.chat.LeaveRoom(room: self.room!)) {
            let ac = UIAlertController(title: "😢", message: "You have left \(self.room!.name)", preferredStyle: .alert)
            let closure: (UIAlertAction) -> Void = { _ in
                if let index = ChatMainViewController.ChatSubscribedRooms.index(where: { $0.room.id == self.room!.id }) {
                    let sub = ChatMainViewController.ChatSubscribedRooms[index]
                    ChatMainViewController.ChatUnsubscribedRooms.append(sub)
                    ChatMainViewController.ChatSubscribedRooms.remove(at: index)
                }
                _ = self.navigationController?.popToViewController(self.navigationController!.viewControllers[1] as! ChatMainViewController, animated: true) }
            let ok = UIAlertAction(title: "Ok", style: .cancel, handler: closure)
            ac.addAction(ok)
            self.present(ac, animated: true, completion: nil)
        }
        
        print("leaving room: \(String(describing: self.room))")
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


class RoomNameTableViewCell: UITableViewCell {
    @IBOutlet weak var roomName: UILabel!
}

class MuteMessagesTableViewCell: UITableViewCell {
    @IBOutlet weak var mute: UISwitch!
}

class MembersTableViewCell: UITableViewCell {
    @IBOutlet weak var add: UIButton!
}

class ListOfMembersTableViewCell: UITableViewCell {
    @IBOutlet weak var imagePlaceholder: UIImageView!
    @IBOutlet weak var user: UILabel!
}

class LeaveRoomTableViewCell: UITableViewCell {
    @IBOutlet weak var leaveRoom: UIButton!
}
