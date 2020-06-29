

import UIKit
import CoreData

class todoTableViewController: UITableViewController {

    var tasks = [Task]()
    
    var managedObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveTasks()
        print("Count : ",tasks.count)
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        retrieveTasks()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoTableViewCell", for: indexPath) as! todoTableViewCell
        
        let task: Task = tasks[indexPath.row]
        cell.configureCell(task: task)
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let task = self.tasks[indexPath.row]
            //            let path = getDirectory().appendingPathComponent("Recording\(indexPath.row + 1).m4a")
            context.delete(task)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do {
                self.tasks = try context.fetch(Task.fetchRequest())
            }
                
            catch {
                print("Failed to delete task.")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            //            tableView.reloadData()
        }
        tableView.reloadData()
        
    }
    // Table Load end ===
    
    
    // MARK: NSCoding
    func retrieveTasks() {
        managedObjectContext?.perform {
            self.fetchTaskFromCoreData { (tasks) in
                if let tasks = tasks {
                    self.tasks = tasks
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func fetchTaskFromCoreData(completion: @escaping ([Task]?)->Void){
        managedObjectContext?.perform {
            var tasks = [Task]()
            let request: NSFetchRequest<Task> = Task.fetchRequest()
            
            do {
                tasks = try  self.managedObjectContext!.fetch(request)
                completion(tasks)
                
            }
                
            catch {
                print("Could not fetch notes from CoreData:\(error.localizedDescription)")
                
            }
            
        }
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showDetails" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let todoDetailsViewController = segue.destination as! todoViewController
                let selectedTask: Task = tasks[indexPath.row]
                
                todoDetailsViewController.indexPath = indexPath.row
                todoDetailsViewController.isExsisting = false
                todoDetailsViewController.task = selectedTask
            }
        }
            
        else if segue.identifier == "AddItems" {
            print("User added a new Task.")
        }
    }


}
