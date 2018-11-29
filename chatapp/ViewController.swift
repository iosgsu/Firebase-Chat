//
//  ViewController.swift
//  chatapp
//
//  Created by Nate Thompson on 11/15/18.
//  Copyright © 2018 Nate Thompson. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


struct Message {
    var text: String
    var date = Date()
}

extension Date {
    func formattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd yyyy, h:mm a"
        
        return formatter.string(from: self)
    }
}

class ViewController: UIViewController {
    
    var root: DatabaseReference!
    
    var messages: [Message] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        root = Database.database().reference()
        
        observeMessages()
    }
    
    func observeMessages() {
        let messagesRef = root.child("messages")
        
        messagesRef.observe(.childAdded) { snapshot in
            if let value = snapshot.value as? [String : Any],
                let text = value["text"] as? String,
                let timeInterval = value["date"] as? TimeInterval {
                
                let date = Date(timeIntervalSince1970: timeInterval)
                
                let message = Message(text: text, date: date)
                
                self.messages.append(message)
                
                self.tableView.reloadData()
                
                let bottomIndex = IndexPath(row: self.messages.count - 1, section: 0)
                self.tableView.scrollToRow(at: bottomIndex, at: .bottom, animated: true)
            }
        }
    }

    @IBAction func sendPressed(_ sender: Any) {
        let childRef = root.child("messages").childByAutoId()
        
        let data: [String : Any] = [
            "text" : messageTextField.text ?? "nil",
            "date" : Date().timeIntervalSince1970
        ]
        
        childRef.setValue(data)
        
        messageTextField.text = nil
    }
    
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        
        let message = messages[indexPath.row]
        
        cell.textLabel?.text = message.text
        cell.detailTextLabel?.text = message.date.formattedString()
        
        return cell
    }
    
    
}

