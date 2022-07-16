//
//  ViewController.swift
//  basicListApp
//
//  Created by Umithan  on 16.07.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var alertController = UIAlertController()
    var data = [NSManagedObject]()
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetch()
    }
    
    @IBAction func didRemoveBarButtonTap(_ sender: UIBarButtonItem) {
        presentAlert(title: "warning!",
                     message: "this action will delete all the items from the list",
                     cancelButtonTitle: "cancel",
                     defaultButtonTitle: "delete") { _ in
            //self.data.removeAll()
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListItem")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
 
            
            try? managedObjectContext?.persistentStoreCoordinator?.execute(deleteRequest, with: managedObjectContext!)
            
            self.fetch()
            
        }
    }
    @IBAction func didAddBarButtonItemTap(_ sender: UIBarButtonItem) {
        presentAddAlert()
    }
    
    func presentAlert(title: String?,
                      message: String?,
                      preferredStyle: UIAlertController.Style = .alert,
                      cancelButtonTitle: String?,
                      defaultButtonTitle: String? = nil,
                      isTextFieldAvailable: Bool = false,
                      defaultButtonHandler: ((UIAlertAction)  -> Void)? = nil) {
        alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        let cancelButton = UIAlertAction(title: cancelButtonTitle, style: .cancel)
        if defaultButtonTitle != nil {
            let defaultButton = UIAlertAction(title: defaultButtonTitle, style: .default, handler: defaultButtonHandler)
            alertController.addAction(defaultButton)
        }
        
        if isTextFieldAvailable {
            alertController.addTextField()
        }
        
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
    }
    
    func presentAddAlert() {
        presentAlert(title: "add new item", message: nil, cancelButtonTitle: "cancel", defaultButtonTitle: "add", isTextFieldAvailable: true) { _ in
            let text = self.alertController.textFields?.first?.text
            if text != "" {
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                
                let managedObjectContext = appDelegate?.persistentContainer.viewContext
                
                let entity = NSEntityDescription.entity(forEntityName: "ListItem", in: managedObjectContext!)
                
                let listItem = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
                
                listItem.setValue(text, forKey: "title")
                
                try? managedObjectContext?.save()
                
                self.fetch()
            } else {
                self.presentWarningAlert()
            }
        }
        
    }
    
    func presentWarningAlert() {
        presentAlert(title: "Warning!", message: "list item cannot be empty", cancelButtonTitle: "Aye, sir!")
    }
    
    func fetch() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        
        data = try! managedObjectContext!.fetch(fetchRequest)
        
        tableView.reloadData()
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal, title: "delete") { _,_,_ in
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            
            managedObjectContext?.delete(self.data[indexPath.row])
            try? managedObjectContext?.save()
            
            self.fetch()
        }
        deleteAction.backgroundColor = .systemRed
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return config
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .normal, title: "edit") { _,_,_ in
            self.presentAlert(title: "edit",
                              message: nil,
                              cancelButtonTitle: "cancel",
                              defaultButtonTitle: "edit",
                              isTextFieldAvailable: true) { _ in
                let text = self.alertController.textFields?.first?.text
                if text != "" {
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    
                    let managedObjectContext = appDelegate?.persistentContainer.viewContext
                    
                    self.data[indexPath.row].setValue(text, forKey: "title")
                    
                    if managedObjectContext!.hasChanges {
                        try? managedObjectContext?.save()
                    }
                    
                    self.tableView.reloadData()
                } else {
                    self.presentWarningAlert()
                }
            }
        }
        
        editAction.backgroundColor = .systemBlue
        
        let config = UISwipeActionsConfiguration(actions: [editAction])
        
        return config
    }
    
}

