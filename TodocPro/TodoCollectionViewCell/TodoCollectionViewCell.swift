//
//  TodoCollectionViewCell.swift
//  TodocPro
//
//  Created by Vasilis Voyiadjis on 18/8/22.
//

import UIKit

class TodoCollectionViewCell: UICollectionViewCell {

	@IBOutlet weak var todoText: UILabel!
	@IBOutlet weak var deleteButton: UIButton!
	var todoId: Int!
	var deleteCallback: ((Int) -> Void)!
	
	static let identifier = "TodoCollectionViewCell"
	static func nib() -> UINib {
		return UINib(nibName: "TodoCollectionViewCell", bundle: nil)
	}
	
	override func awakeFromNib() {
        super.awakeFromNib()
    }
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.contentView.addConstraint(
			NSLayoutConstraint(item: deleteButton!, attribute: .leading, relatedBy: .equal, toItem: todoText, attribute: .trailing, multiplier: 1, constant: 10)
		)
	}
	
	func configure(withTodo todoText: String, todoId: Int, deleteCallback: @escaping (Int) -> Void) {
		self.todoText.text = todoText
		self.todoId = todoId
		self.deleteCallback = deleteCallback
	}
	
	@IBAction func didTapDeleteButton(_ sender: Any) {
		deleteCallback(self.todoId)
	}
}

extension TodoCollectionViewCell {
	// This makes sure the cell it's taking the full width of the screen.
	override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
		setNeedsLayout()
		layoutIfNeeded()
	   
		let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
		var frame = layoutAttributes.frame
		frame.size.height = ceil(size.height)
		layoutAttributes.frame = frame
	   
		return layoutAttributes
	}
}
