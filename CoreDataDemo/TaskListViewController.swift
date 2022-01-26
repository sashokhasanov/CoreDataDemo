//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by brubru on 24.01.2022.
//  Contributed by Сашок
//

import UIKit

class TaskListViewController: UITableViewController {
    private let context = StorageManager.shared.persistentContainer.viewContext
    
    private let cellID = "task"
    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        tableView.reloadData()
    }
    
    private func fetchData() {
        let fetchRequest = Task.fetchRequest()
        
        do {
            taskList = try context.fetch(fetchRequest)
        } catch {
           print("Faild to fetch data", error)
        }
    }
}

extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { action, view, completion in
            let task = self.taskList[indexPath.row]
            
            self.showAlert(title: "Edit task", message: "What do you want to change?", initialText: task.name) { newTask in
                self.setNewTask(newTask, at: indexPath)
            }
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
            let task = self.taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            StorageManager.shared.persistentContainer.viewContext.delete(task)
            StorageManager.shared.saveContext()
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

extension TaskListViewController {
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearence = UINavigationBarAppearance()
        navBarAppearence.configureWithOpaqueBackground()
        navBarAppearence.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearence.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearence.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearence
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearence
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(title: "New task", message: "What do you want to do?") { task in
            self.addTask(task)
        }
    }
}

extension TaskListViewController {
    private func showAlert(title: String, message: String, initialText: String? = nil, saveAction: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            saveAction(task)
        }
        alert.addAction(saveAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(cancelAction)
        
        alert.addTextField { textField in
            textField.placeholder = "Task"
            textField.text = initialText
        }
        present(alert, animated: true)
    }
    
    private func addTask(_ taskName: String) {
        let task = Task(context: context)
        task.name = taskName
        taskList.append(task)
        
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
        StorageManager.shared.saveContext()
    }
    
    private func setNewTask(_ newTask: String, at indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        task.name = newTask
        tableView.reloadRows(at: [indexPath], with: .automatic)
        StorageManager.shared.saveContext()
    }
}
