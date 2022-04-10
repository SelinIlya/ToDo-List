//
//  ViewController.swift
//  ToDo-List
//
//  Created by Ilya Selin on 17.03.2022.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var itemArray: Results<Item>?
    let realm = try! Realm()
    var selectedCategory : Category? {
        didSet {
            //            load Items()
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
        
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colorForBar = selectedCategory?.color {
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else {
                fatalError("Navigation controller does not exist")
            }
            if let navBarColor = UIColor(hexString: colorForBar){
                navBar.backgroundColor = navBarColor
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
                searchBar.barTintColor = navBarColor
            }
        }
    }
    //Создает необходимое кол-во строк в таблице
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    // Вставка ячейки в таблицу
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = itemArray?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: (CGFloat(indexPath.row) / CGFloat(itemArray!.count))) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
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
    
    // Delete item
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDelete = self.itemArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDelete)
                }
            } catch {
                print("Error delete item \(error)")
            }
        }
    }
    
    
    // Загрузка
    func loadItems() {
        
        itemArray = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: false)
        
        tableView.reloadData()
    }
}

// Поиск
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder() //Убирает клавиатуру
            }
        }
    }
}
