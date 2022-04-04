 //
//  ViewController.swift
//  ToDo-List
//
//  Created by Ilya Selin on 17.03.2022.
//

import UIKit
import CoreData


class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //Alternative change bar tint color
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        
        
        
    }
     
    //Создает необходимое кол-во строк в таблице
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    // Вставка ячейки в таблицу
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        // Установка чекмарка
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    //Delegate Methods
    //Действие при на жатие на строку
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true) //Отмена выделения ячейки
    }
    
    // Добавление новых элементов
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        
        var textField  = UITextField()
        
        
        let alert = UIAlertController(title: "Добавление задачи", message: "", preferredStyle: .alert )
        
        let action = UIAlertAction(title: "Добавить", style: .default) { (action) in
                        
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
             
            self.saveItems()
        
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Название задачи"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // Сохраниние
    func saveItems() {
        
        do {
            try context.save()
        } catch{
            print("Error save context \(error )")
        }
        self.tableView.reloadData()
    }
        // Загрузка
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate?  = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data \(error)")
        }
        
        tableView.reloadData()
    }
    
}

// Поиск
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()

        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data \(error)")
        }
        
        loadItems(with: request)
        
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder() //Убирает клавиатуру
            }
            
        }
    }
}
