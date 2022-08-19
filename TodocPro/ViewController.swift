//
//  ViewController.swift
//  TodocPro
//
//  Created by Vasilis Voyiadjis on 18/8/22.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet var todosCollectionView: UICollectionView!
	@IBOutlet weak var noTodosStackView: UIStackView!
	
	var todoList: [String] = [
		"Buy milk", "Feed the cat", "Buy Todoc Pro", "Rob a fucking bank",
		"Rate Todoc for being the greatest task-manager app for pros",
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Create "add todo button"
		self.navigationItem.rightBarButtonItems = [
			UIBarButtonItem(image: .init(systemName: "plus"), style: .plain, target: self, action: #selector(didTapAddTodoButton)),
			UIBarButtonItem(image: .init(systemName: "info.circle"), style: .plain, target: self, action: #selector(didTapInfoButton)),
		]
		
		todosCollectionView.register(TodoCollectionViewCell.nib(), forCellWithReuseIdentifier: TodoCollectionViewCell.identifier)
		todosCollectionView.delegate = self
		todosCollectionView.dataSource = self
		
		didTodoListChanged()
	}

	private func didTodoListChanged() {
		hideNoTodosView(todoList.count > 0)
		todosCollectionView.reloadData()
	}
	
	private func hideNoTodosView(_ hide: Bool) {
		noTodosStackView.isHidden = hide
		todosCollectionView.isHidden = !hide
	}
	
	@objc private func didTapInfoButton() {
		self.performSegue(withIdentifier: "AboutTodocSegue", sender: self)
	}
	
	@objc private func didTapAddTodoButton() {
		let alert = UIAlertController(title: "Add Todo", message: "Enter a brief description of the todo.", preferredStyle: .alert)

		alert.addTextField { textField in
			textField.placeholder = "Todo"
			textField.autocorrectionType = .yes
			textField.autocapitalizationType = .sentences
		}
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
			let todoTextField = alert!.textFields![0]
			let todoText = todoTextField.text!
			if (todoText.isEmpty) {
				return
			}
			
			self.addTodo(withText: todoText)
		}))
		
		self.present(alert, animated: true)
	}
	
	private func didTapRemoveTodoButton(forTodoAtIndex index: Int) {
		let alert = UIAlertController(title: "Delete \"\(todoList[index])\" todo?", message: "Are you sure you want to delete this todo? After tapping \"Delete\" there is no comeback.", preferredStyle: .actionSheet)
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
			self.removeTodo(withIndex: index)
		}))
		
		self.present(alert, animated: true)
	}
	
	private func addTodo(withText todoText: String) {
		todoList.append(todoText)
		didTodoListChanged()
	}
	
	private func removeTodo(withIndex todoId: Int) {
		todoList.remove(at: todoId)
		didTodoListChanged()
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
				title: "What do you want to do with this Todo?",
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
		return todoList.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let index = indexPath.item
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodoCollectionViewCell.identifier, for: indexPath) as! TodoCollectionViewCell
		
		cell.configure(withTodoId: index, todoText: todoList[index])
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.frame.width, height: 50)
	}
}

extension ViewController: UICollectionViewDelegateFlowLayout {}
