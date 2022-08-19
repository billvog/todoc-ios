//
//  SQLiteDatabase.swift
//  TodocPro
//
//  Created by Vasilis Voyiadjis on 19/8/22.
//

import Foundation
import SQLite

class SQLiteDatabase {
	static let sharedInstance = SQLiteDatabase()
	var database: Connection?
	
	private init() {
		do {
			let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
			let fileUrl = documentDirectory.appendingPathComponent("TodocProDB").appendingPathExtension("sqlite")
			database = try Connection(fileUrl.path)
		}
		catch {
			print("Creating connection to database error: \(error)")
		}
	}
	
	func createTables() {
		SQLiteCommands.createTables()
	}
}
