//
//  SQLiteCommands.swift
//  TodocPro
//
//  Created by Vasilis Voyiadjis on 19/8/22.
//

import Foundation
import SQLite

class SQLiteCommands {
	static var todos = Table("todos")
	struct todosExpressions {
		static let id = Expression<Int64>("id")
		static let shortText = Expression<String>("short_text")
		static let done = Expression<Bool>("done")
	}
	
	static func createTables() {
		guard let database = SQLiteDatabase.sharedInstance.database else {
			print("Database connection error")
			return
		}
		
		// Create todos table
		do {
			// try database.run(todos.drop(ifExists: true))
			try database.run(todos.create(ifNotExists: true, block: { table in
				table.column(todosExpressions.id, primaryKey: true)
				table.column(todosExpressions.shortText)
				table.column(todosExpressions.done, defaultValue: false)
			}))
		} catch {
			print("\"todo\" table already exist: \(error)")
		}
	}
}

// Todos Table Commands
extension SQLiteCommands {
	static func createTodo(withTodoModel todo: Todo) -> Todo? {
		guard let database = SQLiteDatabase.sharedInstance.database else {
			print("Database connection error")
			return nil
		}
		
		do {
			let todoId = try database.run(
				todos.insert(todosExpressions.shortText <- todo.shortText)
			)
			
			return Todo(id: todoId, shortText: todo.shortText, done: todo.done)
		} catch {
			print("Error creating todo: \(error)")
			return nil
		}
	}
	
	static func removeTodo(withId todoId: Int64) -> Bool? {
		guard let database = SQLiteDatabase.sharedInstance.database else {
			print("Database connection error")
			return nil
		}
		
		do {
			let todo = todos.filter(todosExpressions.id == todoId).limit(1)
			
			// check if a todo with this id exists
			if ((try database.scalar(todo.count)) <= 0) {
				return false
			}
				
			try database.run(todo.delete())
			return true
		} catch {
			print("Error removing todo: \(error)")
			return false
		}
	}
	
	static func updateTodo(withId todoId: Int64, newTodoValues: Todo) -> Todo? {
		guard let database = SQLiteDatabase.sharedInstance.database else {
			print("Database connection error")
			return nil
		}
		
		do {
			let todo = todos.filter(todosExpressions.id == todoId).limit(1)
			
			// check if a todo with this id exists
			if ((try database.scalar(todo.count)) <= 0) {
				return nil
			}
			
			try database.run(todo.update(
				todosExpressions.shortText <- newTodoValues.shortText,
				todosExpressions.done <- newTodoValues.done
			))
			
			return Todo(id: todoId, shortText: newTodoValues.shortText, done: newTodoValues.done)
		}
		catch {
			print("Error updating todo: \(error)")
			return nil
		}
	}
	
	static func getAllTodos() -> [Todo]? {
		guard let database = SQLiteDatabase.sharedInstance.database else {
			print("Database connection error")
			return nil
		}
		
		var todosArray = [Todo]()
		todos = todos.order(todosExpressions.id.asc)
		
		do {
			for todo in try database.prepare(todos) {
				let _todo = Todo(
					id: todo[todosExpressions.id],
					shortText: todo[todosExpressions.shortText],
					done: todo[todosExpressions.done]
				)
				
				todosArray.append(_todo)
			}
			
			return todosArray
		} catch {
			print("Error fetching todos: \(error)")
			return nil
		}
	}
}
