
//

import UIKit
import CoreData
import UserNotifications

class todoViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var taskCatSelectorButton: UIBarButtonItem!
    @IBOutlet weak var taskNameLabel: UITextField!
    @IBOutlet weak var taskDescriptionLabel: UITextView!
    @IBOutlet weak var taskDateLabel: UILabel!
    @IBOutlet weak var taskDatePicker: UIDatePicker!
    @IBOutlet weak var taskNotifySwitch: UISwitch!
    @IBOutlet weak var taskPrioritySegment: UISegmentedControl!
    @IBOutlet weak var taskAddButton: UIButton!
    @IBOutlet weak var taskCategoryLabel: UILabel!
    @IBOutlet weak var taskDoneSwitch: UISwitch!
    @IBOutlet weak var donelabel: UILabel!
    
    
    var tasksFetchedResultsController: NSFetchedResultsController<Task>!
    var tasks = [Task]()
    var task: Task?
    var isExsisting = false
    var indexPath: Int?
    
    var taskDateTime : String = ""
    let taskDate = Date()
    var taskUUID: UUID = UUID()
    var taskPriority : String = "Normal"
    var taskNotify : Bool = true
    var taskDone : Bool = false
    //    var datePicker : UIDatePicker?
    
    
    let formatter = DateFormatter()
    var currDateTime : Date?
    let currentDateTime = Date()
    var taskCatSelected: String = "Others"
    
    
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
        donelabel.isHidden = true
        taskDoneSwitch.isHidden=true
        hideKeyboardWhenTappedAround()
        registerLocal()
        
        // Load data from TableView
        if let task = task {
            taskNameLabel.text = task.taskName
            taskDescriptionLabel.text = task.taskDesc
            taskDateLabel.text = task.taskDate
            taskNotifySwitch.isOn = task.taskNotify
            taskCategoryLabel.text = task.taskCat
            donelabel.isHidden = false
            taskDoneSwitch.isHidden=false
            taskDoneSwitch.isOn = task.taskDone
            taskUUID = task.taskUUID ?? UUID()
            taskDateTime = task.taskDate!
            
            
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
            taskUUID = UUID()
            
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
        let taskCat = ["Work", "School","Shopping","Bucket List","Personal","Others"]
        defaults.set(taskCat,forKey: keys.taskCatList)
        print(taskCat)
        
        // retrieve Userdefaults
//        let defaults = UserDefaults.standard
//        let myarray = defaults.stringArray(forKey: keys.taskCatList) ?? [String]()
        

        // Do any additional setup after loading the view.
    }
    
    
    
    //Notification
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    

    func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = taskNameLabel.text ?? "task Name"
        content.body = taskDescriptionLabel.text ?? "Task Description"
        content.categoryIdentifier = "task"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default()
        
        var dateComponents = DateComponents()
        dateComponents.year = (getDue(dateString: taskDateTime)).year
        dateComponents.month = (getDue(dateString: taskDateTime)).month
        dateComponents.day = (getDue(dateString: taskDateTime)).day
        dateComponents.hour = (getDue(dateString: taskDateTime)).hour
        dateComponents.minute = (getDue(dateString: taskDateTime)).minute
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: taskUUID.uuidString, content: content, trigger: trigger)
        center.add(request)
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
    
    func getDue(dateString: String) -> (day: Int, month: Int, year: Int, hour: Int, minute: Int){
        
        let formatter = DateFormatter()
       
        
        formatter.dateFormat = "dd"
        let temp = formatter.date(from: dateString)!
        let timeInterval = temp.timeIntervalSince1970
        let day = Int(timeInterval) //?? 03
//        let day = 03
        
        
        formatter.dateFormat = "MM"
        let temp1 = formatter.date(from: dateString)!
        let timeInterval1 = temp1.timeIntervalSince1970
        let month = Int(timeInterval1)
        
        formatter.dateFormat = "yyyy"
        let temp2 = formatter.date(from: dateString)!
        let timeInterval2 = temp2.timeIntervalSince1970
        let year = Int(timeInterval2)
        
        
        formatter.dateFormat = "HH"
        let temp3 = formatter.date(from: dateString)!
        let timeInterval3 = temp3.timeIntervalSince1970
        let hour = Int(timeInterval3)
        
        formatter.dateFormat = "mm"
        let temp4 = formatter.date(from: dateString)!
        let timeInterval4 = temp4.timeIntervalSince1970
        let minute = Int(timeInterval4)
        
        return (day, month, year, hour, minute)
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
        print("taskNotify :", taskNotify)
    }
    
    @IBAction func taskDoneSwitchChanged(_ sender: UISwitch) {
        
        if sender.isOn{
            taskDone = true
        } else{
            taskDone = false
        }
        print("taskNotify :", taskNotify)
    }
    //notidy switch end
    
    
    
    
    //Category select
    
    @IBAction func taskSelCategoryButton(_ sender: UIBarButtonItem) {
        taskSelCat()
    }
    
     //retrieve Userdefaults
    func taskSelCat(){
        let taskCat  =  defaults.stringArray(forKey: keys.taskCatList)!
        let categoryController = UIAlertController(title: "Select Category", message: "", preferredStyle: .actionSheet)
        for var i in taskCat
        {   let action = UIAlertAction(title: "\(i)", style: .default) { (action) in
            self.taskCatSelect(taskCategory: action.title!)}
            categoryController.addAction(action)
            print(i)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        categoryController.addAction(cancelAction)
        present(categoryController, animated: true, completion: nil)
        /*
         let catPersonal = UIAlertAction(title: "Personal", style: .default) { (action) in
         self.taskCatSelect(taskCategory: "Personal")}
         let catWork = UIAlertAction(title: "Work", style: .default) { (action) in
         self.taskCatSelect(taskCategory: "Work")}
         let catShopping = UIAlertAction(title: "Shopping", style: .default) { (action) in
         self.taskCatSelect(taskCategory: "Shopping")}
         let catSchool = UIAlertAction(title: "School", style: .default) { (action) in
         self.taskCatSelect(taskCategory: "School")}
         let catBucketList = UIAlertAction(title: "BucketList", style: .default) { (action) in
         self.taskCatSelect(taskCategory: "Bucket List")}
         let catImportant = UIAlertAction(title: "Important", style: .default) { (action) in
         self.taskCatSelect(taskCategory: "Important")}
         let catOthers = UIAlertAction(title: "Others", style: .default) { (action) in
         self.taskCatSelect(taskCategory: "Others")}
         let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
         categoryController.addAction(catWork)
         categoryController.addAction(catSchool)
         categoryController.addAction(catShopping)
         categoryController.addAction(catBucketList)
         categoryController.addAction(catPersonal)
         categoryController.addAction(catImportant)
         categoryController.addAction(catOthers)
         categoryController.addAction(cancelAction)
         present(categoryController, animated: true, completion: nil)
 */
    }
    
    func taskCatSelect(taskCategory: String){
        taskCategoryLabel.text = taskCategory
        taskCatSelected = taskCategory
        print(taskCategory)
    }
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
                    task.taskCat        = taskCatSelected
                    task.taskUUID       = taskUUID
                    
                    if taskNotify{
//                        scheduleNotification()
                    }
                    
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
                managedObject!.setValue(taskCatSelected, forKey: "taskCat")
                managedObject!.setValue(taskDone, forKey: "taskDone")
                
                if taskNotify{
//                    scheduleNotification()
                    
                }
                
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
        
    }
    @objc func showPicker(){
        taskDatePicker.isHidden = false
        i+=1
        print("Tapped: ", i)
    }
    func gesture(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showPicker))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
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
