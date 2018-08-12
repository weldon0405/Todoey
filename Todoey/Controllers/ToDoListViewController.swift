//  Created by Weldon Malbrough on 7/31/18.
//  Copyright © 2018 Weldon Malbrough. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical or
// instructional purposes related to programming, coding, application development,
// or information technology.  Permission for such use, copying, modification,
// merger, publication, distribution, sublicensing, creation of derivative works,
// or sale is expressly withheld.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController {
    
  var todoItems: Results<Item>?
  let realm = try! Realm()
  
  var selectedCategory: Category? {
    didSet{
      self.loadItems()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
  }
  
  //MARK: - TableView DataSource Methods
  /***************************************************************/
  
  //TODO: Declare numberOfRowsInSection here:
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return todoItems?.count ?? 1
  }
  
  //TODO: Declare cellForRowAtIndexPath here:
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
    if let item = todoItems?[indexPath.row] {
      cell.textLabel?.text = item.title
      cell.accessoryType = item.done ? .checkmark : .none
    } else {
      cell.textLabel?.text = "No Items Added"
    }
    return cell
  }
  
  //MARK: - TableView Delegate Methods
  /***************************************************************/
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let item = todoItems?[indexPath.row] {
      do {
        try realm.write {
          realm.delete(item)
//          item.done = !item.done
        }
      } catch {
        print("Error saving done status => \(error)")
      }
    }
    
      tableView.reloadData()
      tableView.deselectRow(at: indexPath, animated: true)
  }
  
  //MARK: - Add New Items
  /***************************************************************/
  
  @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
      var textField = UITextField()
      let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
      let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
        if let currentCategory = self.selectedCategory {
          do {
            try self.realm.write {
              let newItem = Item()
              newItem.title = textField.text!
              newItem.dateCreated = Date()
              currentCategory.items.append(newItem)
            }
          } catch {
            print("Error saving context => \(error)")
          }
        }
          self.tableView.reloadData()
      }
    
      alert.addTextField { (alertTextField) in
        alertTextField.placeholder = "Create New Item"
        textField = alertTextField
      }
    
      alert.addAction(action)
      print(textField)
      present(alert, animated: true, completion: nil)
  }
  
  //MARK: - Model Manipulation Methods
  /***************************************************************/
  
  func loadItems() {
    todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
    tableView.reloadData()
  }
  
}

//MARK: - Search Bar methods
/***************************************************************/

extension ToDoListViewController: UISearchBarDelegate {

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
    tableView.reloadData()
  }

  func searchBar(_ searchBar: UISearchBar, textDidChange: String) {
    if searchBar.text?.count == 0 {
      loadItems()
      
      DispatchQueue.main.async {
        searchBar.resignFirstResponder()
      }
    }
  }
}
