

import UIKit

class todoTableViewCell: UITableViewCell {
    
    
    let currentDateTime = Date()
    
    
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var taskPriorityLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        shadowView.layer.shadowColor =  UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0).cgColor
//        shadowView.layer.shadowOffset = CGSize(width: 0.75, height: 0.75)
//        shadowView.layer.shadowRadius = 1.5
//        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.cornerRadius = 2
        taskPriorityLabel.layer.cornerRadius = 30
//        taskPriorityLabel.layer.backgroundColor = UIColor.red.cgColor
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // Date
    func gettaskDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: date)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "yyyy-MM-dd hh:mm a"
        let taskDate = formatter.string(from: yourDate!)
        print("datetimePicker: ",taskDate)
        return taskDate
    }
    
    func stringToDate(dateString : String) -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm a"
        return formatter.date(from: dateString)!
    }
    //Date end
    
    
    
    
    
    func configureCell(task: Task) {
        
        self.taskNameLabel.text = task.taskName
//        self.taskDoneButton.titleLabel?.text = String(task.taskDone)
//        self.taskPriorityLabel.text = task.taskPriority
        
        
        if(task.taskPriority == "High")
        {
            self.taskPriorityLabel.layer.backgroundColor = UIColor.red.cgColor
        } else if(task.taskPriority == "Normal"){
            self.taskPriorityLabel.layer.backgroundColor = UIColor.green.cgColor
        }else{
            self.taskPriorityLabel.layer.backgroundColor = UIColor.blue.cgColor
        }
        
        let due = stringToDate(dateString: task.taskDate!)
        let currDate = stringToDate(dateString: gettaskDate(date: currentDateTime))
        if due<currDate
        {
            shadowView.layer.backgroundColor = UIColor.red.cgColor
        }
        
    }
}
