//
//  Messages.swift
//  Halp
//
//  Created by Andrew Lisowski on 3/8/15.
//  Copyright (c) 2015 Andrew Lisowski. All rights reserved.
//

import UIKit

class Messages: UITableViewController {
    var chats: [Chat]!
    var chatType:String!
    let halpApi = HalpAPI()
    
    override func viewWillAppear(animated: Bool) {
        if pinMode == "student" {
            self.navigationItem.title = "Chats with Tutors"
            if chatType != "student" {
                getConversations()
            }
        } else {
            self.navigationItem.title = "Chats with Students"
            if chatType != "tutor" {
                getConversations()
            }
        }
    }
    
    func getConversations() {
        pause(self.view)
        chats = []
        halpApi.getConversations() { sucess, json in
            if sucess == true {
                let conversations = json["conversations"].arrayValue
                
                for conversation in conversations {
                    self.chats.append(Chat(rootMessage: conversation))
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                    start(self.view)
                }
            } else {
                println(json)
            }
        }
        
        chatType = pinMode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getConversations()
        
        tableView.rowHeight = chatCellHeight
        tableView.registerClass(ChatCell.self, forCellReuseIdentifier: NSStringFromClass(ChatCell))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var chat = chats[indexPath.row]
        let chatViewController = ConversationViewController(chat: chat)
        navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ChatCell), forIndexPath: indexPath) as ChatCell
        
        cell.configureWithChat(chats[indexPath.row])
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }
}
