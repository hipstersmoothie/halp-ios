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
    var loggedIn:User!
    
    override func viewWillAppear(animated: Bool) {
        if pinMode == "student" {
            self.navigationItem.title = "Chats with Tutors"
//            if chatType != "student" || loggedInUser != loggedIn {
//                getConversations()
//            }
        } else {
            self.navigationItem.title = "Chats with Students"
//            if chatType != "tutor" || loggedInUser != loggedIn {
//                getConversations()
//            }
        }
        getConversations()
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
        loggedIn = loggedInUser
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //getConversations()
        
        tableView.rowHeight = chatCellHeight
        tableView.registerClass(ChatCell.self, forCellReuseIdentifier: NSStringFromClass(ChatCell))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("gotNotifications:"), name: "GetNewMessages", object: nil)
    }
    
    func gotNotifications(notification: NSNotification) {
        getConversations()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "notificationsRecieved", object: nil)
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
        
        NSNotificationCenter.defaultCenter().postNotificationName("MessageClicked", object: nil, userInfo: [
                "decrementValue": chat.unreadMessageCount
            ])
        chat.unreadMessageCount = 0
        chats[indexPath.row] = chat
        
        
        let chatViewController = ConversationViewController(chat: chat)
        navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ChatCell), forIndexPath: indexPath) as ChatCell
        
        cell.configureWithChat(chats[indexPath.row])
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return chatCellHeight
    }
}