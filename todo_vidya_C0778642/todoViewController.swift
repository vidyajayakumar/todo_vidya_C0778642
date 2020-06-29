
//

import UIKit
import CoreData

class todoViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var taskCatSelectorButton: UIBarButtonItem!
    @IBOutlet weak var taskNameLabel: UITextField!
    @IBOutlet weak var taskDescriptionLabel: UITextView!
    @IBOutlet weak var taskDateLabel: UILabel!
    @IBOutlet weak var taskDatePicker: UIDatePicker!
    @IBOutlet weak var taskNotifySwitch: UISwitch!
    @IBOutlet weak var taskPrioritySegment: UISegmentedControl!
    @IBOutlet weak var taskAddButton: UIButton!
  
    
    var tasksFetchedResultsController: NSFetchedResultsController<Task>!
    var tasks = [Task]()
    var task: Task?
    var isExsisting = false
    var indexPath: Int?
    
    let taskDate = Date()
    var taskUUID: String = ""
    
    var managedObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Date: ", taskDate)
        hideKeyboardWhenTappedAround()
        
        // Load data from TableView
        if let task = task {
            taskNameLabel.text = task.taskName
            taskDescriptionLabel.text = task.taskDesc
//            taskDateLabel.text = String.init(task.taskDate?)
        }
        else{    // Creating new
            taskDateLabel.text = String(describing: taskDate)
            // TODO: load Map location
            taskUUID = UUID().uuidString
            print(taskUUID)
        }
        
        if taskNameLabel.text != "" {
            isExsisting = true
        }
        
        // Delegates
        taskNameLabel.delegate = self
        taskDescriptionLabel.delegate = self

        // Do any additional setup after loading the view.
    }
    
    // Core data
    func saveToCoreData(completion: @escaping ()->Void){
        managedObjectContext!.perform {
            do {
                try self.managedObjectContext?.save()
                completion()
                print("Task saved to CoreData.")
            }
                
            catch let error {
                print("Could not save task to CoreData: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func taskShowDatePicker(_ sender: Any) {
    }
    @IBAction func AddTaskButton(_ sender: Any) {
        if taskNameLabel.text == "" || taskNameLabel.text == "Task Name" || taskDescriptionLabel.text == "" || taskDescriptionLabel.text == "Task Description" {
            
            let alertController = UIAlertController(title: "Missing Information", message:"Please make sure that all fields are filled before attempting to save.", preferredStyle: UIAlertControllerStyle.alert)
            let OKAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil)
            
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else { //CREATE
            if (isExsisting == false) {
                let taskName = taskNameLabel.text
                let taskDescription = taskDescriptionLabel.text
                
                
                if let moc = managedObjectContext {
                    let task = Task(context: moc)
                    
                    task.taskName = taskName
                    task.taskDesc = taskDescription
                    task.taskDate = taskDate
//                    task.taskCategory = taskCatSelected
                    
                    saveToCoreData() {
                        
                        let isPresentingInAddFluidPatientMode = self.presentingViewController is UINavigationController
                        
                        if isPresentingInAddFluidPatientMode {
                            self.dismiss(animated: true, completion: nil)
                            
                        }
                            
                        else {
                            self.navigationController!.popViewController(animated: true)
                        }
                    }
                }
            }
            else if (isExsisting == true) { // UPDATE
                
                let task = self.task
                
                let managedObject = task
                managedObject!.setValue(taskNameLabel.text, forKey: "taskName")
                managedObject!.setValue(taskDescriptionLabel.text, forKey: "taskDesc")
                

                
                do {
                    try context.save()
                    
                    let isPresentingInAddFluidPatientMode = self.presentingViewController is UINavigationController
                    
                    if isPresentingInAddFluidPatientMode {
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                        
                    else {
                        self.navigationController!.popViewController(animated: true)
                    }
                }
                catch {
                    print("Failed to update existing task.")
                }
            }
            
        }
        
        
        
        
        
        
        
    } // Addtask Button ====
    
    
    
    @IBAction func cancelTaskButton(_ sender: Any) {
        let isPresentingInAddFluidPatientMode = presentingViewController is UINavigationController
        if isPresentingInAddFluidPatientMode {
            dismiss(animated: true, completion: nil)
        }
            
        else {
            navigationController!.popViewController(animated: true)
        }
    }
    
    

    

    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    // Dismiss keyboard =====
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // ======
    
    // Date
    func gettaskDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: date)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "EEEE, MMM d, yyyy, hh:mm:ss"
        let taskDate = formatter.string(from: yourDate!)
        print(taskDate)
        return taskDate
    }
}
extension Date {
    func toSeconds() -> Int64! {
        return Int64((self.timeIntervalSince1970).rounded())
    }
    
    init(seconds:Int64!) {
        self = Date(timeIntervalSince1970: TimeInterval(Double.init(seconds)))
    }
    
    
    func dateComponents() -> DateComponents {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return components
    }
    
    func dateComponentsToNotify() -> DateComponents {
        let calendar = Calendar.current
        let newDate = calendar.date(byAdding: .minute, value: -30, to: self)
        guard let date = newDate else {
            return calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        }
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return components
    }
    
    func isEqual(currentDate: Date) -> Bool {
        if self.dateComponents().day == currentDate.dateComponents().day {
            return true
        } else {
            return false
        }
    }
    
    func isPast(today currentDate: Date) -> Bool {
        if self > currentDate {
            return true
        } else {
            return false
        }
    }
    
    static func from(hour: Int, minutes: Int, year: Int, month: Int, day: Int) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minutes
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return calendar.date(from: dateComponents) ?? nil
    }
    
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func dateFormatterString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: self)
    }
}
