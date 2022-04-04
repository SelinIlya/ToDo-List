//
//  CategoryViewController.swift
//  ToDo-List
//
//  Created by Ilya Selin on 04.04.2022.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    
    var categories = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        loadCategories()
    }
    
    
    // Datasurse Metod
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    // Data Manipulation
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error save Category \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error  load Categories \(error)")
        }
        tableView.reloadData()
    }
    
    // Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destanationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destanationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    // add New Category
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Новая категория", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Добавить", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)

            if textField.text == "" {
                newCategory.name = "Без названия"
            } else {
                newCategory.name = textField.text
            }
          
            self.categories.append(newCategory )
            
            self.saveCategories()
        }
        
        alert.addAction(action)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Название категории"
        }
        
        present(alert, animated: true, completion: nil )
        
    }
}
