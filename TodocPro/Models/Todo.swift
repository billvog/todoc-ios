//
//  Todo.swift
//  TodocPro
//
//  Created by Vasilis Voyiadjis on 19/8/22.
//

import Foundation

struct Todo {
	let id: Int64
	var shortText: String
	var done: Bool
	
	var onDoneChanged: ((Bool) -> Void)!
}
