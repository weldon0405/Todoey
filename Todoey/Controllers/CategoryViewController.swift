//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Weldon Malbrough on 8/8/18.
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

class CategoryViewController: SwipeTableViewController {
  let realm = try! Realm()
  var categories: Results<Category>?

  override func viewDidLoad() {
    super.viewDidLoad()
    loadCategories()
  }
    
  //MARK: - TableView Data Source methods
  /***************************************************************/
  
  //TODO: numberOfRowsInSection
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories?.count ?? 1
  }
  
  //TODO: cellForRowAtPath
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    cell.textLabel?.text = categories?[indexPath.row].name ?? "Add a category to begin"
    return cell
  }
  
  //MARK: - Data Manipulation methods
  /***************************************************************/
  
  func save(category: Category) {
    do {
      try realm.write {
          realm.add(category)
      }
    } catch {
      print("Error saving context: \(error)")
    }
    tableView.reloadData()
  }
  
  func loadCategories() {
      categories = realm.objects(Category.self)
      tableView.reloadData()
  }
  
  //MARK: - Delete Data From Swipe
  /***************************************************************/
  
  override func updateModel(at indexPath: IndexPath) {
    if let categoryForDeletion = self.categories?[indexPath.row] {
      do {
        try self.realm.write {
          self.realm.delete(categoryForDeletion)
        }
      } catch {
        print("Error deleting category => \(error)")
      }
    }
  }
    
  //MARK: - Add New Categories
  /***************************************************************/
  
  @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    
    var textField = UITextField()
    let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
    let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
        let newCategory = Category()
        newCategory.name = textField.text!
        self.save(category: newCategory)
    }
  
    alert.addTextField { (alertTextField) in
        alertTextField.placeholder = "Create New Category"
        textField = alertTextField
    }
  
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
  
  //MARK: - TableView Delegate methods
  /***************************************************************/
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "goToItems", sender: self)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destinationVC = segue.destination as! ToDoListViewController
    if let indexPath = tableView.indexPathForSelectedRow {
      destinationVC.selectedCategory = categories?[indexPath.row]
    }
  }
}
