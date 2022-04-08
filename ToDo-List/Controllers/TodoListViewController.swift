//
//  ViewController.swift
//  ToDo-List
//
//  Created by Ilya Selin on 17.03.2022.
//

import UIKit
import RealmSwift


class TodoListViewController: UITableViewController {
    
    var itemArray: Results<Item>?
    let realm = try! Realm()
    var selectedCategory : Category? {
        didSet {
            //            load Items()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //Alternative change bar tint color
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        loadItems()
        
        
    }
    
    //Создает необходимое кол-во строк в таблице
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    // Вставка ячейки в таблицу
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        if let item = itemArray?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            // Установка чекмарка
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "Нет записей"
        }
        
        return cell
        
    }
    
    //Delegate Methods
    //Действие при на жатие на строку
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = itemArray?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done //
                }
            } catch {
                print("Error save done status \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true) //Отмена выделения ячейки
        
    }
    
    // Добавление новых элементов
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        
        var textField  = UITextField()
        
        
        let alert = UIAlertController(title: "Добавление задачи", message: "", preferredStyle: .alert )
        
        let action = UIAlertAction(title: "Добавить", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem )
                    }
                } catch {
                    print("Error save new Item \(error)")
                }
            }
            self.tableView.reloadData()
        }
        self.tableView.reloadData()
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Название задачи"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    // Загрузка
    func loadItems() {
        
        itemArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
}

// Поиск
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
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
