/**
 * MIT License
 *
 * Copyright (c) 2017 Dimitris Bouzikas
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

import UIKit

class KeyboardViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
	
	// MARK: - Properties
	
	/// Store initial Y point of main view
	private final var frameInitialY: CGFloat!
	
	/// Field which the user is typing in
	private final var activeField: Any?
	
	// MARK: - ViewController lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		/// Prepare gestures, as tap for dismissing keyboard
		setupGestures()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		/// Register notification observers
		addObservers()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		/// Capture initial Y value of main view
		frameInitialY = self.view.frame.origin.y
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		/// Remove registered observers
		removeObservers()
	}
	
	// MARK: - Initialization methods
	
	/// Initialize gesture recognizers required
	/// to manipulate the behaviour of keyboard.
	public func setupGestures() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		tap.delegate = self
		view.isUserInteractionEnabled = true
		view.addGestureRecognizer(tap)
	}
	
	/// Initializes notification observers for keyboard show/hide action
	public func addObservers() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillChange(_:)),
			name: .UIKeyboardWillShow,
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillBeHidden(_:)),
			name: .UIKeyboardWillHide,
			object: nil
		)
	}
	
	/// Removes registered notification observers
	public func removeObservers() {
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
	}
	
	// MARK: - Notification observer methods
	
	/// Method called when keyboard is about to change
	/// This includes if keyboard is shown or if it's height changed
	///
	/// - Parameter notification:	Information broadcast to observers via a `NotificationCenter`
	@objc private func keyboardWillChange(_ notification: Notification) {
		let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]
		let keyboardRect = self.view.convert(keyboardFrame as! CGRect, to: nil)
		let keyboardSize = keyboardRect.size
		
		let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
		let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt
		
		let field = activeField as! UITextField?
		let point = field?.convert((field?.frame.origin)!, to: self.view)

		let frame = self.view.frame
		let visibleArea = frame.height - keyboardSize.height
		let fieldHeight = (field?.frame.size.height)!
		
		let newY = frameInitialY - ((point?.y)! - visibleArea + fieldHeight)
		let newFrame = CGRect.init(x: frame.origin.x, y: newY, width: frame.size.width, height: frame.size.height)
		
		UIView.animateKeyframes(
			withDuration: duration,
			delay: 0.0,
			options: UIViewKeyframeAnimationOptions(rawValue: curve),
			animations: {
				self.view.frame = newFrame
			},
			completion: nil
		)
	}
	
	/// Method called when keyboard is about to hide
	@objc private func keyboardWillBeHidden(_ notification: Notification) {
		let frame = self.view.frame
		let newY = frameInitialY ?? 0
		
		let newFrame = CGRect.init(
			x: frame.origin.x,
			y: newY,
			width: frame.size.width,
			height: frame.size.height
		)
		
		UIView.animate(withDuration: 0.4, animations: {
			self.view.frame = newFrame
			self.view.layoutIfNeeded()
		})
	}
	
	// MARK: - UITextFieldDelegate methods
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		activeField = textField
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		activeField = nil
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	// MARK: - Helper methods
	
	public func setDelegates(_ fields: AnyObject...) {
		for item in fields {
			if let textField = item as? UITextField {
				textField.delegate = self
			}
		}
	}
	
	private func dismissKeyboard() {
		view.endEditing(true)
		activeField = nil
	}
	
	// MARK: - IBAction methods
	
	@IBAction func handleTap(_ sender: UITapGestureRecognizer? = nil) {
		dismissKeyboard()
	}
}
