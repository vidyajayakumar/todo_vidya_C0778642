
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
    
    var taskDateTime : String = ""
    let taskDate = Date()
    var taskUUID: String = ""
    var taskPriority : String = "Normal"
    var taskNotify : Bool = true
    var taskDone : Bool = false
    //    var datePicker : UIDatePicker?
    
    
    let formatter = DateFormatter()
    var currDateTime : Date?
    let currentDateTime = Date()
    
    let defaults = UserDefaults.standard
    struct keys {
        static let taskCatList = "taskCatList"
    }
    
    var managedObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getdate()
        currentDate()
        taskDatePicker.isHidden = true
        hideKeyboardWhenTappedAround()
        
        // Load data from TableView
        if let task = task {
            taskNameLabel.text = task.taskName
            taskDescriptionLabel.text = task.taskDesc
            taskDateLabel.text = task.taskDate
            taskNotifySwitch.isOn = task.taskNotify
            
            if(task.taskPriority == "High")
            {   taskPrioritySegment.selectedSegmentIndex = 0
            } else if(task.taskPriority == "Normal"){
                taskPrioritySegment.selectedSegmentIndex = 1
            }else{
                taskPrioritySegment.selectedSegmentIndex = 2
            }
            let date: String = String(task.taskDate!)
            let temp = stringToDate(dateString: date)
            
            let timePicker = taskDatePicker
            timePicker?.setDate(temp, animated: true)

            print("TaskDate label: ", taskDateLabel.text as Any)
        }
        else{    // Creating new
            taskDateLabel.text = gettaskDate(date: currentDateTime)
            taskUUID = UUID().uuidString
            
            print("TaskDate label: ", taskDateLabel.text as Any)
            
        }
        // Load data end
        
        if taskNameLabel.text != "" {
            isExsisting = true
        }
        
        // Delegates
        taskNameLabel.delegate = self
        taskDescriptionLabel.delegate = self
        
        
        // Uderdefaults Category save array
        let taskCat = ["Work", "School","Shopping","Bucket List","Personal","Others","Archived"]
        defaults.set(taskCat,forKey: keys.taskCatList)
        
        // retrieve Userdefaults
//        let defaults = UserDefaults.standard
//        let myarray = defaults.stringArray(forKey: keys.taskCatList) ?? [String]()
        

        // Do any additional setup after loading the view.
    }
    
    
    // date and time
    func currentDate(){
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        formatter.dateFormat = "yyyy-MM-dd hh:mm a"
        let datetimestring = formatter.string(from: currentDateTime)
        currDateTime =  currentDateTime
        print("Current Date and time : ",datetimestring)
    }
    
    
    func getdate(){
        taskDatePicker?.datePickerMode = .dateAndTime
        taskDatePicker.minimumDate = currentDateTime
        taskDatePicker.maximumDate = Date.calculateDate(day: 31, month: 12, year: 2099, hour: 0, minute: 0)
    }
    
    // Date
    func gettaskDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: date)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "yyyy-MM-dd hh:mm a"
        let taskDate = formatter.string(from: yourDate!)
        print("datetimePicter: ",taskDate)
        return taskDate
    }
    
    func stringToDate(dateString : String) -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm a"
        return formatter.date(from: dateString)!
    }
    
    // date and time end ====
    

    @IBAction func taskValueChangedDatePicker(_ sender: UIDatePicker, forEvent event: UIEvent) {
//        print(sender.date.getDue().day)
        taskDateTime = gettaskDate(date: sender.date)
        taskDateLabel.text = taskDateTime
    }
    
    // Segmented Control
    @IBAction func taskSegChanged(_ sender: Any) {
        switch taskPrioritySegment.selectedSegmentIndex
        {
        case 0:
           taskPriority = "High"
        case 1:
            taskPriority = "Normal"
        case 2:
            taskPriority = "Low"
        default:
            break;
        }
        print("taskPriority",taskPriority )
    }
    // Segmented Control end
    
    // Notify switch
    @IBAction func taskNotifySwitchChanged(_ sender: UISwitch) {
        if sender.isOn{
            taskNotify = true
        } else{
            taskNotify = false
        }
        print("taskNotidy :", taskNotify)
    }
    
    //notidy switch end
    
    
    //Category select
    
//    for (let i=0; i<cat; <#increment#>) {
//    <#statements#>
//    }
    //Category Selected
    
    
    
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
    
    // Add data
    @IBAction func AddTaskButton(_ sender: Any) {
        if taskNameLabel.text == "" || taskNameLabel.text == "Task Name" || taskDescriptionLabel.text == "" || taskDescriptionLabel.text == "Task Description" {
            
            let alertController = UIAlertController(title: "Missing Information", message:"Please make sure that all fields are filled before attempting to save.", preferredStyle: UIAlertControllerStyle.alert)
            let OKAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil)
            
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        }
         //CREATE
        else {
            if (isExsisting == false) {
                let taskName = taskNameLabel.text
                let taskDescription = taskDescriptionLabel.text
                let taskDateTime = taskDateLabel.text
                
                
                if let moc = managedObjectContext {
                    let task = Task(context: moc)
                    
                    task.taskName       = taskName
                    task.taskDesc       = taskDescription
                    task.taskPriority   = taskPriority
                    task.taskDate       = taskDateTime
                    task.taskNotify     = taskNotify
                    task.taskDone       = taskDone
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
            // UPDATE
            else if (isExsisting == true) {
                
                let task = self.task
                
                let managedObject = task
                managedObject!.setValue(taskNameLabel.text, forKey: "taskName")
                managedObject!.setValue(taskDescriptionLabel.text, forKey: "taskDesc")
                managedObject!.setValue(taskDateTime, forKey: "taskDate")
                managedObject!.setValue(taskPriority, forKey: "taskPriority")
                managedObject!.setValue(taskNotify, forKey: "taskNotify")
                
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
    }
    // Addtask Button ====
    
    
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
    var i=0
    // Show DatePicker
    @IBAction func ShowDatePicker(_ sender: UITapGestureRecognizer) {
        taskDatePicker.isHidden = false
        i+=1
        print("Tapped: ", i)
    }
    
    // shown
    
    
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
    

    // TextView Begin
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == "Task Description") {
            textView.text = ""
        }
    }
}
