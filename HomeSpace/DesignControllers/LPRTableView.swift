//
//  LPRTableView.swift
//  LPRTableView
//
//  Objective-C code Copyright (c) 2013 Ben Vogelzang. All rights reserved.
//  Swift adaptation Copyright (c) 2014 Nicolas Gomollon. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

/** The delegate of a LPRTableView object can adopt the LPRTableViewDelegate protocol. Optional methods of the protocol allow the delegate to modify a cell visually before dragging occurs, or to be notified when a cell is about to be dragged or about to be dropped. */
@objc
public protocol LPRTableViewDelegate: NSObjectProtocol {
	
	/** Provides the delegate a chance to modify the cell visually before dragging occurs. Defaults to using the cell as-is if not implemented. */
	@objc optional func tableView(_ tableView: UITableView, draggingCell cell: UITableViewCell, at indexPath: IndexPath) -> UITableViewCell
	
	/** Called within an animation block when the dragging view is about to show. */
	@objc optional func tableView(_ tableView: UITableView, showDraggingView view: UIView, at indexPath: IndexPath)
	
	/** Called within an animation block when the dragging view is about to hide. */
	@objc optional func tableView(_ tableView: UITableView, hideDraggingView view: UIView, at indexPath: IndexPath)

	/** Called when the dragging gesture's vertical location changes. */
	@objc optional func tableView(_ tableView: UITableView, draggingGestureChanged gesture: UILongPressGestureRecognizer)
	
}

open class LPRTableView: UITableView {
	
	/** The object that acts as the delegate of the receiving table view. */
	weak open var longPressReorderDelegate: LPRTableViewDelegate?
	
	fileprivate var longPressGestureRecognizer: UILongPressGestureRecognizer!
	
	fileprivate var initialIndexPath: IndexPath?
	
	fileprivate var currentLocationIndexPath: IndexPath?
	
	fileprivate var draggingView: UIView?
	
	fileprivate var scrollRate = 0.0
	
	fileprivate var scrollDisplayLink: CADisplayLink?
	
	fileprivate var feedbackGenerator: AnyObject?

	fileprivate var previousGestureVerticalPosition: CGFloat?
	
	/** A Bool property that indicates whether long press to reorder is enabled. */
	open var longPressReorderEnabled: Bool {
		get {
			return longPressGestureRecognizer.isEnabled
		}
		set {
			longPressGestureRecognizer.isEnabled = newValue
		}
	}
	
	/**
	The minimum period a finger must press on a cell for the reordering to begin.
	
	The time interval is in seconds. The default duration is is 0.5 seconds.
	*/
	open var minimumPressDuration: CFTimeInterval {
		get {
			return longPressGestureRecognizer.minimumPressDuration
		}
		set {
			longPressGestureRecognizer.minimumPressDuration = newValue
		}
	}
	
	public convenience init()  {
		self.init(frame: CGRect.zero)
	}
	
    public override init(frame: CGRect, style: UITableView.Style) {
		super.init(frame: frame, style: style)
		initialize()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}
	
	fileprivate func initialize() {
		longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(LPRTableView._longPress(_:)))
		addGestureRecognizer(longPressGestureRecognizer)
		
		self.estimatedRowHeight = 0
		self.estimatedSectionHeaderHeight = 0
		self.estimatedSectionFooterHeight = 0
	}
	
}

extension LPRTableView {
	
	fileprivate func canMoveRowAt(indexPath: IndexPath) -> Bool {
		return (dataSource?.responds(to: #selector(UITableViewDataSource.tableView(_:canMoveRowAt:))) == false) || (dataSource?.tableView?(self, canMoveRowAt: indexPath) == true)
	}
	
	fileprivate func cancelGesture() {
		longPressGestureRecognizer.isEnabled = false
		longPressGestureRecognizer.isEnabled = true
	}
	
	@objc internal func _longPress(_ gesture: UILongPressGestureRecognizer) {
		
		let location = gesture.location(in: self)
		let indexPath = indexPathForRow(at: location)
		
		let sections = numberOfSections
		var rows = 0
		for i in 0..<sections {
			rows += numberOfRows(inSection: i)
		}
		
		// Get out of here if the long press was not on a valid row or our table is empty
		// or the dataSource tableView:canMoveRowAtIndexPath: doesn't allow moving the row.
		if (rows == 0) ||
            ((gesture.state == UIGestureRecognizer.State.began) && (indexPath == nil)) ||
            ((gesture.state == UIGestureRecognizer.State.ended) && (currentLocationIndexPath == nil)) ||
			((gesture.state == UIGestureRecognizer.State.began) && !canMoveRowAt(indexPath: indexPath!)) {
				cancelGesture()
				return
		}
		
		// Started.
		if gesture.state == .began {
			self.hapticFeedbackSetup()
			self.hapticFeedbackSelectionChanged()
			self.previousGestureVerticalPosition = location.y
			
			if let indexPath = indexPath {
				if var cell = cellForRow(at: indexPath) {
					
					cell.setSelected(false, animated: false)
					cell.setHighlighted(false, animated: false)
					
					// Create the view that will be dragged around the screen.
					if (draggingView == nil) {
						if let draggingCell = longPressReorderDelegate?.tableView?(self, draggingCell: cell, at: indexPath) {
							cell = draggingCell
						}
						
						// Make an image from the pressed table view cell.
						UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0.0)
						cell.layer.render(in: UIGraphicsGetCurrentContext()!)
						let cellImage = UIGraphicsGetImageFromCurrentImageContext()
						UIGraphicsEndImageContext()
						
						draggingView = UIImageView(image: cellImage)
						
						if let draggingView = draggingView {
							addSubview(draggingView)
							let rect = rectForRow(at: indexPath)
							draggingView.frame = draggingView.bounds.offsetBy(dx: rect.origin.x, dy: rect.origin.y)
							
							UIView.beginAnimations("LongPressReorder-ShowDraggingView", context: nil)
							longPressReorderDelegate?.tableView?(self, showDraggingView: draggingView, at: indexPath)
							UIView.commitAnimations()
							
							// Add drop shadow to image and lower opacity.
							draggingView.layer.masksToBounds = false
							draggingView.layer.shadowColor = UIColor.black.cgColor
							draggingView.layer.shadowOffset = CGSize.zero
							draggingView.layer.shadowRadius = 4.0
							draggingView.layer.shadowOpacity = 0.7
							draggingView.layer.opacity = 0.85
							
							// Zoom image towards user.
							UIView.beginAnimations("LongPressReorder-Zoom", context: nil)
							draggingView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
							draggingView.center = CGPoint(x: center.x, y: newYCenter(for: draggingView, with: location))
							UIView.commitAnimations()
						}
					}
					
					cell.isHidden = true
					currentLocationIndexPath = indexPath
					initialIndexPath = indexPath
					
					// Enable scrolling for cell.
					scrollDisplayLink = CADisplayLink(target: self, selector: #selector(LPRTableView._scrollTableWithCell(_:)))
                    scrollDisplayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
				}
			}
		}
		// Dragging.
		else if gesture.state == .changed {
			
			if let draggingView = draggingView {
				// Update position of the drag view
				draggingView.center = CGPoint(x: center.x, y: newYCenter(for: draggingView, with: location))
				if let previousGestureVerticalPosition = self.previousGestureVerticalPosition {
					if location.y != previousGestureVerticalPosition {
						longPressReorderDelegate?.tableView?(self, draggingGestureChanged: gesture)
						self.previousGestureVerticalPosition = location.y
					}
				} else {
					longPressReorderDelegate?.tableView?(self, draggingGestureChanged: gesture)
					self.previousGestureVerticalPosition = location.y
				}
			}
			
			let inset: UIEdgeInsets
			if #available(iOS 11.0, *) {
				inset = adjustedContentInset
			} else {
				inset = contentInset
			}
			
			var rect = bounds
			// Adjust rect for content inset, as we will use it below for calculating scroll zones.
			rect.size.height -= inset.top
			
			updateCurrentLocation(gesture)
			
			// Tell us if we should scroll, and in which direction.
			let scrollZoneHeight = rect.size.height / 6.0
			let bottomScrollBeginning = contentOffset.y + inset.top + rect.size.height - scrollZoneHeight
			let topScrollBeginning = contentOffset.y + inset.top  + scrollZoneHeight
			
			// We're in the bottom zone.
			if location.y >= bottomScrollBeginning {
				scrollRate = Double(location.y - bottomScrollBeginning) / Double(scrollZoneHeight)
			}
			// We're in the top zone.
			else if location.y <= topScrollBeginning {
				scrollRate = Double(location.y - topScrollBeginning) / Double(scrollZoneHeight)
			}
			else {
				scrollRate = 0.0
			}
		}
		// Dropped.
		else if (gesture.state == .ended) || (gesture.state == .cancelled) || (gesture.state == .failed) {

			// Remove previously cached Gesture location
			self.previousGestureVerticalPosition = nil
			
			// Remove scrolling CADisplayLink.
			scrollDisplayLink?.invalidate()
			scrollDisplayLink = nil
			scrollRate = 0.0
			
			// Animate the drag view to the newly hovered cell.
			UIView.animate(withDuration: 0.3,
				animations: { [unowned self] () -> Void in
					if let draggingView = self.draggingView {
						if let currentLocationIndexPath = self.currentLocationIndexPath {
							UIView.beginAnimations("LongPressReorder-HideDraggingView", context: nil)
							self.longPressReorderDelegate?.tableView?(self, hideDraggingView: draggingView, at: currentLocationIndexPath)
							UIView.commitAnimations()
							let rect = self.rectForRow(at: currentLocationIndexPath)
							draggingView.transform = CGAffineTransform.identity
							draggingView.frame = draggingView.bounds.offsetBy(dx: rect.origin.x, dy: rect.origin.y)
						}
					}
				},
				completion: { [unowned self] (Bool) -> Void in
					if let draggingView = self.draggingView {
						draggingView.removeFromSuperview()
					}
					
					// Reload the rows that were affected just to be safe.
					if let visibleRows = self.indexPathsForVisibleRows {
						self.reloadRows(at: visibleRows, with: .none)
					}
					
					self.currentLocationIndexPath = nil
					self.draggingView = nil
					
					self.hapticFeedbackSelectionChanged()
					self.hapticFeedbackFinalize()
				})
		}
	}
	
	fileprivate func updateCurrentLocation(_ gesture: UILongPressGestureRecognizer) {
		let location = gesture.location(in: self)
		guard var indexPath = indexPathForRow(at: location) else { return }
		
		if let iIndexPath = initialIndexPath,
			let ip = delegate?.tableView?(self, targetIndexPathForMoveFromRowAt: iIndexPath, toProposedIndexPath: indexPath) {
				indexPath = ip
		}
		
		guard let clIndexPath = currentLocationIndexPath else { return }
		let oldHeight = rectForRow(at: clIndexPath).size.height
		let newHeight = rectForRow(at: indexPath).size.height
		
		if let cell = cellForRow(at: clIndexPath) {
			cell.setSelected(false, animated: false)
			cell.setHighlighted(false, animated: false)
			cell.isHidden = true
		}
		
		if ((indexPath != clIndexPath) &&
			(gesture.location(in: cellForRow(at: indexPath)).y > (newHeight - oldHeight))) &&
			canMoveRowAt(indexPath: indexPath) {
				beginUpdates()
				moveRow(at: clIndexPath, to: indexPath)
				dataSource?.tableView?(self, moveRowAt: clIndexPath, to: indexPath)
				currentLocationIndexPath = indexPath
				endUpdates()
			
				self.hapticFeedbackSelectionChanged()
		}
	}
	
	@objc internal func _scrollTableWithCell(_ sender: CADisplayLink) {
		guard let gesture = longPressGestureRecognizer else { return }
		
		let location = gesture.location(in: self)
		guard !(location.y.isNaN || location.x.isNaN) else { return } // Explicitly check for out-of-bound touch.
		
		let yOffset = Double(contentOffset.y) + scrollRate * 10.0
		var newOffset = CGPoint(x: contentOffset.x, y: CGFloat(yOffset))
		
		let inset: UIEdgeInsets
		if #available(iOS 11.0, *) {
			inset = adjustedContentInset
		} else {
			inset = contentInset
		}
		
		if newOffset.y < -inset.top {
			newOffset.y = -inset.top
		} else if (contentSize.height + inset.bottom) < frame.size.height {
			newOffset = contentOffset
		} else if newOffset.y > ((contentSize.height + inset.bottom) - frame.size.height) {
			newOffset.y = (contentSize.height + inset.bottom) - frame.size.height
		}
		
		contentOffset = newOffset
		
		if let draggingView = draggingView {
			draggingView.center = CGPoint(x: center.x, y: newYCenter(for: draggingView, with: location))
		}
		
		updateCurrentLocation(gesture)
	}
	
	fileprivate func newYCenter(for draggingView: UIView, with location: CGPoint) -> CGFloat {
		let cellCenter = draggingView.frame.height / 2
		let bottomBound = contentSize.height - cellCenter
		
		if location.y < cellCenter {
			return cellCenter
		} else if location.y > bottomBound {
			return bottomBound
		}
		return location.y
	}
	
}

extension LPRTableView {
	
	fileprivate func hapticFeedbackSetup() {
		guard #available(iOS 10.0, *) else { return }
		let feedbackGenerator = UISelectionFeedbackGenerator()
		feedbackGenerator.prepare()
		
		self.feedbackGenerator = feedbackGenerator
	}
	
	fileprivate func hapticFeedbackSelectionChanged() {
		guard #available(iOS 10.0, *),
			let feedbackGenerator = self.feedbackGenerator as? UISelectionFeedbackGenerator else { return }
		feedbackGenerator.selectionChanged()
		feedbackGenerator.prepare()
	}
	
	fileprivate func hapticFeedbackFinalize() {
		guard #available(iOS 10.0, *) else { return }
		self.feedbackGenerator = nil
	}
	
}

open class LPRTableViewController: UITableViewController, LPRTableViewDelegate {
	
	/** Returns the long press to reorder table view managed by the controller object. */
	open var lprTableView: LPRTableView! { return (tableView as? LPRTableView)! }
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		initialize()
	}
	
    public override init(style: UITableView.Style) {
		super.init(style: style)
		initialize()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}
	
	fileprivate func initialize() {
		tableView = LPRTableView()
		tableView.dataSource = self
		tableView.delegate = self
		registerClasses()
		lprTableView.longPressReorderDelegate = self
	}
	
	/** Override this method to register custom UITableViewCell subclass(es). DO NOT call `super` within this method. */
	open func registerClasses() {
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
	}
	
	/** Provides the delegate a chance to modify the cell visually before dragging occurs. Defaults to using the cell as-is if not implemented. The default implementation of this method is empty—no need to call `super`. */
	open func tableView(_ tableView: UITableView, draggingCell cell: UITableViewCell, at indexPath: IndexPath) -> UITableViewCell {
		// Empty implementation, just to simplify overriding (and to show up in code completion).
		return cell
	}
	
	/** Called within an animation block when the dragging view is about to show. The default implementation of this method is empty—no need to call `super`. */
	open func tableView(_ tableView: UITableView, showDraggingView view: UIView, at indexPath: IndexPath) {
		// Empty implementation, just to simplify overriding (and to show up in code completion).
	}
	
	/** Called within an animation block when the dragging view is about to hide. The default implementation of this method is empty—no need to call `super`. */
	open func tableView(_ tableView: UITableView, hideDraggingView view: UIView, at indexPath: IndexPath) {
		// Empty implementation, just to simplify overriding (and to show up in code completion).
	}
	
	/** Called when the dragging gesture's vertical location changes. The default implementation of this method is empty—no need to call `super`. */
	open func tableView(_ tableView: UITableView, draggingGestureChanged gesture: UILongPressGestureRecognizer) {
		// Empty implementation, just to simplify overriding (and to show up in code completion).
	}
	
}
