//
//  ViewController.swift
//  TodocPro
//
//  Created by Vasilis Voyiadjis on 18/8/22.
//

import UIKit

class ViewController: UIViewController {

	// Segues
	let AddTodoSegueIdentifier = "AddTodoSegue"
	let AboutTodocSegueIdentifier = "AboutTodocSegue"
	
	@IBOutlet weak var withTodosView: UIView!
	@IBOutlet weak var todosCollectionView: UICollectionView!
	var todosRefresherControl: UIRefreshControl!
	@IBOutlet weak var tasksLeftLabel: UILabel!
	
	@IBOutlet weak var removeDoneTodosBarButtonItem: UIBarButtonItem!
	
	@IBOutlet weak var noTodosStackView: UIStackView!
	
	var todos = [Todo]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		todosRefresherControl = UIRefreshControl()
		todosRefresherControl.attributedTitle = NSAttributedString(string: "Refreshing todos...")
		todosRefresherControl.addTarget(self, action: #selector(didPullTodoListToRefresh), for: .valueChanged)
		
		todosCollectionView.register(TodoCollectionViewCell.nib(), forCellWithReuseIdentifier: TodoCollectionViewCell.identifier)
		todosCollectionView.delegate = self
		todosCollectionView.dataSource = self
		todosCollectionView.addSubview(todosRefresherControl)
		
		// Configure database and fetch todos
		setupDatabase()
		getAllTodos()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		todosCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if (segue.identifier == AddTodoSegueIdentifier) {
			guard let addTodoVC = segue.destination as? AddTodoViewController else {
				return
			}
			
			addTodoVC.addTodoCallback = { [weak self] newTodo in
				guard let strongSelf = self else {
					return false
				}
				
				let ok = strongSelf.addTodo(withModel: newTodo)
				if (ok) {
					strongSelf.didTodoListUpdated()
				}
				
				return ok
			}
		}
	}
	
	private func didTodoListUpdated() {
		let totalTodosCount = todos.count
		let doneTodosCount = todos.filter { todo in
			todo.done == true
		}.count
		let leftTodosCount = totalTodosCount - doneTodosCount
		
		hideNoTodosView(totalTodosCount > 0)
		removeDoneTodosBarButtonItem.isEnabled = (doneTodosCount > 0)
		
		if (totalTodosCount > 0) {
			updateTodoEvents()
			todosCollectionView.reloadData()
			tasksLeftLabel.text = "\(leftTodosCount) task\(leftTodosCount == 1 ? "" : "s") left"
		}
	}
	
	private func updateTodoEvents() {
		todos = todos.map { [weak self] _todo in
			var todo = _todo
			
			todo.onDoneChanged = { [weak self] isDone in
				guard let strongSelf = self else { return }
				
				var updatedTodo = _todo
				updatedTodo.done = isDone
				
				strongSelf.updateTodo(withId: todo.id, newValues: updatedTodo)
				strongSelf.didDoneTodosChanged()
				strongSelf.didTodoListUpdated()
			}
			
			return todo
		}
	}
	
	// Perform haptic feedback when toggling a todo as "done".
	// If all todos are done, perform a haptic feedback that's heavier.
	// I'm having a different function for that and putting in inside didTodoListUpdated(),
	// so it responds as fast as possible and doesn't wait for the list to be refreshed.
	private func didDoneTodosChanged() {
		let totalTodosCount = todos.count
		let doneTodosCount = todos.filter { todo in
			todo.done == true
		}.count
		let leftTodosCount = totalTodosCount - doneTodosCount
		
		let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: leftTodosCount > 0 ? .light : .heavy)
		impactFeedbackGenerator.prepare()
		impactFeedbackGenerator.impactOccurred()
	}
	
	private func hideNoTodosView(_ hide: Bool) {
		noTodosStackView.isHidden = hide
		withTodosView.isHidden = !hide
	}
	
	@objc private func didPullTodoListToRefresh() {
		getAllTodos()
		todosRefresherControl.endRefreshing()
	}
	
	@IBAction  func didTapAddTodoButton(_ sender: Any) {
		self.performSegue(withIdentifier: AddTodoSegueIdentifier, sender: self)
	}
	
	@IBAction func didTapRemoveDoneTodosButton(_ sender: Any) {
		let alert = UIAlertController(title: "Remove Done Todos.", message: "Are you sure you want to remove all todos marked as done?", preferredStyle: .actionSheet)
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alert.addAction(UIAlertAction(title: "Remove All Done", style: .destructive, handler: { [weak self] (_) in
			guard let strongSelf = self else { return }
			
			let doneTodos = strongSelf.todos.filter { _todo in _todo.done == true }
			for todo in doneTodos {
				strongSelf.removeTodo(withId: todo.id)
			}
			
			strongSelf.didTodoListUpdated()
		}))
		
		self.present(alert, animated: true)
	}
	
	@IBAction private func didTapInfoButton(_ sender: Any) {
		self.performSegue(withIdentifier: AboutTodocSegueIdentifier, sender: self)
	}
	
	private func didTapRemoveTodoButton(forTodoAtIndex index: Int) {
		self.removeTodo(withId: self.todos[index].id)
		didTodoListUpdated()
	}
}

// Database
extension ViewController {
	private func setupDatabase() {
		let database = SQLiteDatabase.sharedInstance
		database.createTables()
	}
	
	private func getAllTodos() {
		let fetchedTodos = SQLiteCommands.getAllTodos()
		if (fetchedTodos == nil) {
			showError(withTitle: "Task Failed", message: "Todoc encountered an error trying to fetch todos.")
			return
		}
		
		todos = fetchedTodos!
		didTodoListUpdated()
	}
	
	private func addTodo(withModel todo: Todo) -> Bool {
		var newTodo = SQLiteCommands.createTodo(withTodoModel: todo)
		if (newTodo == nil) {
			showError(withTitle: "Task Failed", message: "Todoc encountered an error trying to create this todo.")
			return false
		}
		
		todos.append(newTodo!)
		
		// add notification
		if (newTodo!.notify) {
			TodoNotificationManager.addNotificationForTodo(todo: newTodo!) { [weak self] error in
				if (error != nil) {
					self?.showError(
						withTitle: "Task Failed",
						message: "Todoc encountered an error trying to schedule a local notification for the newly created todo.\nPlease, make sure you have given Todoc permission in Settings."
					)
					
					// if notification fails update todo in db to set notify to false
					newTodo!.notify = false
					self?.updateTodo(withId: newTodo!.id, newValues: newTodo!)
				}
			}
		}
		
		return true
	}
	
	private func removeTodo(withId todoId: String) {
		let removedTodo = SQLiteCommands.removeTodo(withId: todoId)
		if (removedTodo == nil || removedTodo == false) {
			showError(withTitle: "Task Failed", message: "Todoc encountered an error trying to remove this todo.")
			return
		}
		
		todos.removeAll { todo in todo.id == todoId }
	}
	
	private func updateTodo(withId todoId: String, newValues: Todo) {
		let updatedTodo = SQLiteCommands.updateTodo(withId: todoId, newTodoValues: newValues)
		if (updatedTodo == nil) {
			showError(withTitle: "Task Failed", message: "Todoc encountered an error trying to update this todo.")
			return
		}
		
		let todoIndex = todos.firstIndex { todo in todo.id == todoId }
		if (todoIndex == nil) {
		   print("Todo with id: \(todoId) not found in todos")
		   return
		}
		
		todos[todoIndex!] = updatedTodo!
	}
}

extension ViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] (action) -> UIMenu in
			let index = indexPath.item
			
			let deleteAction = UIAction(
				title: "Delete",
				image: .init(systemName: "trash"),
				identifier: nil,
				discoverabilityTitle: nil,
				attributes: .destructive,
				state: .off
			) { [weak self] _ in
				self?.didTapRemoveTodoButton(forTodoAtIndex: index)
			}
			
			return UIMenu(
				title: "What do you want to do with this todo?",
				image: nil,
				identifier: nil,
				options: .displayInline,
				children: [deleteAction]
			)
		}
	}
}

extension ViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return todos.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let index = indexPath.item
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodoCollectionViewCell.identifier, for: indexPath) as! TodoCollectionViewCell
		
		cell.configure(withTodo: todos[index])
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.frame.width, height: 50)
	}
}

extension ViewController: UICollectionViewDelegateFlowLayout {}
