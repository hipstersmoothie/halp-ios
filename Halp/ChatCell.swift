import UIKit

let chatCellHeight: CGFloat = 75
let chatCellInsetLeft = chatCellHeight + 24

class ChatCell: UITableViewCell {
    let unreadNotification:UIImageView
    let userPictureImageView: UIImageView
    let userNameLabel: UILabel
    let lastMessageTextLabel: UILabel
    let lastMessageSentDateLabel: UILabel
    let userNameInitialsLabel: UILabel
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        let pictureSize: CGFloat = 64
        
        unreadNotification = UIImageView(frame: CGRectMake(0, 0, 20, 20))
        unreadNotification.image = UIImage(named: "unreadDot.png")
        unreadNotification.layer.borderWidth = 1.0
        unreadNotification.layer.masksToBounds = false
        unreadNotification.layer.borderColor = UIColor.whiteColor().CGColor
        unreadNotification.layer.cornerRadius = unreadNotification.frame.size.height/2
        unreadNotification.clipsToBounds = true
        unreadNotification.hidden = true

        userPictureImageView = UIImageView(frame: CGRect(x: 26, y: 6, width: pictureSize, height: pictureSize))
        userPictureImageView.backgroundColor = UIColor(red: 199/255.0, green: 199/255.0, blue: 204/255.0, alpha: 1)
        userPictureImageView.layer.cornerRadius = pictureSize/2
        userPictureImageView.layer.masksToBounds = true
        
        userNameLabel = UILabel(frame: CGRectZero)
        userNameLabel.backgroundColor = UIColor.whiteColor()
        userNameLabel.font = UIFont.systemFontOfSize(17)
        
        lastMessageTextLabel = UILabel(frame: CGRectZero)
        lastMessageTextLabel.backgroundColor = UIColor.whiteColor()
        lastMessageTextLabel.font = UIFont.systemFontOfSize(15)
        lastMessageTextLabel.numberOfLines = 2
        lastMessageTextLabel.textColor = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1)
        
        lastMessageSentDateLabel = UILabel(frame: CGRectZero)
        lastMessageSentDateLabel.autoresizingMask = .FlexibleLeftMargin
        lastMessageSentDateLabel.backgroundColor = UIColor.whiteColor()
        lastMessageSentDateLabel.font = UIFont.systemFontOfSize(15)
        lastMessageSentDateLabel.textColor = lastMessageTextLabel.textColor
        
        userNameInitialsLabel = UILabel(frame: CGRectZero)
        userNameInitialsLabel.font = UIFont.systemFontOfSize(33)
        userNameInitialsLabel.textAlignment = .Center
        userNameInitialsLabel.textColor = UIColor.whiteColor()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(unreadNotification)
        contentView.addSubview(userPictureImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(lastMessageTextLabel)
        contentView.addSubview(lastMessageSentDateLabel)
        userPictureImageView.addSubview(userNameInitialsLabel)
        
        userNameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addConstraint(NSLayoutConstraint(item: userNameLabel, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: chatCellInsetLeft))
        contentView.addConstraint(NSLayoutConstraint(item: userNameLabel, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 6))
        
        lastMessageTextLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addConstraint(NSLayoutConstraint(item: lastMessageTextLabel, attribute: .Left, relatedBy: .Equal, toItem: userNameLabel, attribute: .Left, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: lastMessageTextLabel, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 28))
        contentView.addConstraint(NSLayoutConstraint(item: lastMessageTextLabel, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: -7))
        contentView.addConstraint(NSLayoutConstraint(item: lastMessageTextLabel, attribute: .Bottom, relatedBy: .LessThanOrEqual, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: -4))
        
        lastMessageSentDateLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addConstraint(NSLayoutConstraint(item: lastMessageSentDateLabel, attribute: .Left, relatedBy: .Equal, toItem: userNameLabel, attribute: .Right, multiplier: 1, constant: 2))
        contentView.addConstraint(NSLayoutConstraint(item: lastMessageSentDateLabel, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: -7))
        contentView.addConstraint(NSLayoutConstraint(item: lastMessageSentDateLabel, attribute: .Baseline, relatedBy: .Equal, toItem: userNameLabel, attribute: .Baseline, multiplier: 1, constant: 0))
        
        userNameInitialsLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        userPictureImageView.addConstraint(NSLayoutConstraint(item: userNameInitialsLabel, attribute: .CenterX, relatedBy: .Equal, toItem: userPictureImageView, attribute: .CenterX, multiplier: 1, constant: 0))
        userPictureImageView.addConstraint(NSLayoutConstraint(item: userNameInitialsLabel, attribute: .CenterY, relatedBy: .Equal, toItem: userPictureImageView, attribute: .CenterY, multiplier: 1, constant: -1))
        
        unreadNotification.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addConstraint(NSLayoutConstraint(item: unreadNotification, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 3))
        contentView.addConstraint(NSLayoutConstraint(item: unreadNotification, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 29))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWithChat(chat: Chat) {
        let user:Dictionary<String, AnyObject> = chat.otherUser
        userPictureImageView.image = UIImage(named: "tutor.jpeg")
        if userPictureImageView.image == nil {
            let initials = user["firstname"] as String
            userNameInitialsLabel.text = initials[0]
            userNameInitialsLabel.hidden = false
        } else {
            userNameInitialsLabel.hidden = true
        }
        
        if chat.unreadMessageCount > 0 {
            unreadNotification.hidden = false
        }
        
        userNameLabel.text = user["firstname"] as? String
        lastMessageTextLabel.text = chat.lastMessageText
        lastMessageSentDateLabel.text = chat.lastMessageSentDateString
    }
}
