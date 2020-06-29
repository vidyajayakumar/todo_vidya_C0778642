

import UIKit

class todoTableViewCell: UITableViewCell {
    
    
//    @IBOutlet weak var taskNamelabel: UILabel!
//    @IBOutlet weak var taskPriorityLabel: UILabel!
//    @IBOutlet weak var taskDoneButton: UIButton!
//    @IBOutlet weak var shadowView: UIView!
    
    
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var taskPriorityLabel: UILabel!
    @IBOutlet weak var taskDoneButton: UIButton!
    @IBOutlet weak var shadowView: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        shadowView.layer.shadowColor =  UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0).cgColor
//        shadowView.layer.shadowOffset = CGSize(width: 0.75, height: 0.75)
//        shadowView.layer.shadowRadius = 1.5
//        shadowView.layer.shadowOpacity = 0.2
//        shadowView.layer.cornerRadius = 2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(task: Task) {
        
        self.taskNameLabel.text = task.taskName
        //        self.taskDescriptionLabel.text = task.noteDescription
        //        self.noteImageView.image = UIImage(data: note.noteImage! as Data)
        self.taskDoneButton.titleLabel?.text = String(task.taskDone)
        self.taskPriorityLabel.text = task.taskPriority
        
        
        //TODO: add a notification On button
        
        
        if(task.taskPriority == "High")
        {
            self.taskPriorityLabel.textColor = UIColor.red
        } else if(task.taskPriority == "Normal"){
            self.taskPriorityLabel.textColor = UIColor.green
        }else{
            self.taskPriorityLabel.textColor = UIColor.blue
        }
        
    }
}
