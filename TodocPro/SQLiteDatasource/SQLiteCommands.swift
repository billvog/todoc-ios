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
		static let id = Expression<String>("id")
		static let shortText = Expression<String>("short_text")
		static let done = Expression<Bool>("done")
		static let createdAt = Expression<Date>("created_at")
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
				table.column(todosExpressions.createdAt)
			}))
		} catch {
			print("\"todo\" table already exist: \(error)")
		}
	}
}

// Todos Table Commands
extension SQLiteCommands {
	// A utility to help myself convert the result of database.prepare() fast to a Todo struct
	static func databaseRowToTodo(_ row: Row) -> Todo {
		return Todo(
			id: row[todosExpressions.id],
			shortText: row[todosExpressions.shortText],
			done: row[todosExpressions.done],
			createdAt: row[todosExpressions.createdAt]
		)
	}
	
	static func findTodo(withId todoId: String) -> Todo? {
		guard let database = SQLiteDatabase.sharedInstance.database else {
			print("Database connection error")
			return nil
		}
		
		do {
			let todo = todos.filter(todosExpressions.id == todoId).limit(1)
			
			var foundTodo: Todo?
			for _todo in try database.prepare(todo) {
				foundTodo = databaseRowToTodo(_todo)
				break
			}
			
			return foundTodo
		}
		catch {
			print("Error finding todo with id: \(todoId): \(error)")
			return nil
		}
	}
	
	static func createTodo(withTodoModel todo: Todo) -> Todo? {
		guard let database = SQLiteDatabase.sharedInstance.database else {
			print("Database connection error")
			return nil
		}
		
		do {
			let todoId = UUID().uuidString
			try database.run(
				todos.insert(
					todosExpressions.id <- todoId,
					todosExpressions.shortText <- todo.shortText,
					todosExpressions.createdAt <- Date.now
				)
			)
			
			guard let newTodo = findTodo(withId: todoId) else {
				return nil
			}
			
			return newTodo
		} catch {
			print("Error creating todo: \(error)")
			return nil
		}
	}
	
	static func removeTodo(withId todoId: String) -> Bool? {
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
	
	static func updateTodo(withId todoId: String, newTodoValues: Todo) -> Todo? {
		guard let database = SQLiteDatabase.sharedInstance.database else {
			print("Database connection error")
			return nil
		}
		
		do {
			let todo = todos.filter(todosExpressions.id == todoId).limit(1)
			
			guard let oldTodo = findTodo(withId: todoId) else {
				return nil
			}
			
			try database.run(todo.update(
				todosExpressions.shortText <- newTodoValues.shortText,
				todosExpressions.done <- newTodoValues.done
			))
			
			return Todo(
				id: todoId,
				shortText: newTodoValues.shortText,
				done: newTodoValues.done,
				createdAt: oldTodo.createdAt
			)
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
		todos = todos.order(todosExpressions.createdAt.asc)
		
		do {
			for todo in try database.prepare(todos) {
				let _todo = databaseRowToTodo(todo)
				todosArray.append(_todo)
			}
			
			return todosArray
		} catch {
			print("Error fetching todos: \(error)")
			return nil
		}
	}
}
