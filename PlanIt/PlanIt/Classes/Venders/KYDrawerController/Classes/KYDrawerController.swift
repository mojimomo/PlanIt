/*
Copyright (c) 2015 Kyohei Yamaguchi. All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import UIKit

@objc public protocol KYDrawerControllerDelegate {
    @objc optional func drawerController(_ drawerController: KYDrawerController, stateChanged state: KYDrawerController.DrawerState)
}

open class KYDrawerController: UIViewController, UIGestureRecognizerDelegate {
    
    /**************************************************************************/
    // MARK: - Types
    /**************************************************************************/
    
    @objc public enum DrawerDirection: Int {
        case left, right
    }
    
    @objc public enum DrawerState: Int {
        case opened, closed
    }
    
    fileprivate let _kContainerViewMaxAlpha  : CGFloat        = 0.2
    
    fileprivate let _kDrawerAnimationDuration: TimeInterval = 0.25
    
    /**************************************************************************/
    // MARK: - Properties
    /**************************************************************************/
    
    @IBInspectable open var mainSegueIdentifier: String?
    
    @IBInspectable open var drawerSegueIdentifier: String?
    
    fileprivate var _drawerConstraint: NSLayoutConstraint!
    
    fileprivate var _drawerWidthConstraint: NSLayoutConstraint!
    
    fileprivate var _panStartLocation = CGPoint.zero
    
    fileprivate var _panDelta: CGFloat = 0
    
    lazy fileprivate var _containerView: UIView = {
        let view = UIView(frame: self.view.frame)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(KYDrawerController.didtapContainerView(_:)))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0.0, alpha: 0)
        view.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        return view
    }()
    
    open var screenEdgePanGestreEnabled = true
    
    lazy fileprivate(set) var screenEdgePanGesture: UIScreenEdgePanGestureRecognizer = {
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(KYDrawerController.handlePanGesture(_:)))
        switch self.drawerDirection {
        case .left:     gesture.edges = .left
        case .right:    gesture.edges = .right
        }
        gesture.delegate = self
        return gesture
    }()
    
    lazy fileprivate(set) var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(KYDrawerController.handlePanGesture(_:)))
        gesture.delegate = self
        return gesture
    }()
    
    open weak var delegate: KYDrawerControllerDelegate?
    
    open var drawerDirection: DrawerDirection = .left {
        didSet {
            switch drawerDirection {
            case .left:  screenEdgePanGesture.edges = .left
            case .right: screenEdgePanGesture.edges = .right
            }
            let tmp = drawerViewController
            drawerViewController = tmp
        }
    }
    
    open var drawerState: DrawerState {
        get { return _containerView.isHidden ? .closed : .opened }
        set { setDrawerState(drawerState, animated: false) }
    }
    
    @IBInspectable open var drawerWidth: CGFloat = 280 {
        didSet { _drawerWidthConstraint?.constant = drawerWidth }
    }
    
    open var mainViewController: UIViewController! {
        didSet {
            if let oldController = oldValue {
                oldController.willMove(toParentViewController: nil)
                oldController.view.removeFromSuperview()
                oldController.removeFromParentViewController()
            }
            guard let mainViewController = mainViewController else { return }
            let viewDictionary      = ["mainView" : mainViewController.view]
            mainViewController.view.translatesAutoresizingMaskIntoConstraints = false
            addChildViewController(mainViewController)
            view.insertSubview(mainViewController.view, at: 0)
            view.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|-0-[mainView]-0-|",
                    options: [],
                    metrics: nil,
                    views: viewDictionary
                )
            )
            view.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|-0-[mainView]-0-|",
                    options: [],
                    metrics: nil,
                    views: viewDictionary
                )
            )
            mainViewController.didMove(toParentViewController: self)
        }
    }
    
    open var drawerViewController : UIViewController? {
        didSet {
            if let oldController = oldValue {
                oldController.willMove(toParentViewController: nil)
                oldController.view.removeFromSuperview()
                oldController.removeFromParentViewController()
            }
            guard let drawerViewController = drawerViewController else { return }
            let viewDictionary      = ["drawerView" : drawerViewController.view]
            let itemAttribute: NSLayoutAttribute
            let toItemAttribute: NSLayoutAttribute
            switch drawerDirection {
            case .left:
                itemAttribute   = .right
                toItemAttribute = .left
            case .right:
                itemAttribute   = .left
                toItemAttribute = .right
            }
            
            drawerViewController.view.layer.shadowColor   = UIColor.black.cgColor
            drawerViewController.view.layer.shadowOpacity = 0.4
            drawerViewController.view.layer.shadowRadius  = 5.0
            drawerViewController.view.translatesAutoresizingMaskIntoConstraints = false
            addChildViewController(drawerViewController)
            _containerView.addSubview(drawerViewController.view)
            _drawerWidthConstraint = NSLayoutConstraint(
                item: drawerViewController.view,
                attribute: NSLayoutAttribute.width,
                relatedBy: NSLayoutRelation.equal,
                toItem: nil,
                attribute: NSLayoutAttribute.width,
                multiplier: 1,
                constant: drawerWidth
            )
            drawerViewController.view.addConstraint(_drawerWidthConstraint)
            
            _drawerConstraint = NSLayoutConstraint(
                item: drawerViewController.view,
                attribute: itemAttribute,
                relatedBy: NSLayoutRelation.equal,
                toItem: _containerView,
                attribute: toItemAttribute,
                multiplier: 1,
                constant: 0
            )
            _containerView.addConstraint(_drawerConstraint)
            _containerView.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|-0-[drawerView]-0-|",
                    options: [],
                    metrics: nil,
                    views: viewDictionary
                )
            )
            _containerView.updateConstraints()
            drawerViewController.updateViewConstraints()
            drawerViewController.didMove(toParentViewController: self)
        }
    }
    
    
    /**************************************************************************/
    // MARK: - initialize
    /**************************************************************************/
    
    public convenience init(drawerDirection: DrawerDirection, drawerWidth: CGFloat) {
        self.init()
        self.drawerDirection = drawerDirection
        self.drawerWidth     = drawerWidth
    }
    
    
    /**************************************************************************/
    // MARK: - Life Cycle
    /**************************************************************************/
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let viewDictionary = ["_containerView": _containerView]
        
        view.addGestureRecognizer(screenEdgePanGesture)
        view.addGestureRecognizer(panGesture)
        view.addSubview(_containerView)
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[_containerView]-0-|",
                options: [],
                metrics: nil,
                views: viewDictionary
            )
        )
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[_containerView]-0-|",
                options: [],
                metrics: nil,
                views: viewDictionary
            )
        )
        _containerView.isHidden = true
        
        if let mainSegueID = mainSegueIdentifier {
            performSegue(withIdentifier: mainSegueID, sender: self)
        }
        if let drawerSegueID = drawerSegueIdentifier {
            performSegue(withIdentifier: drawerSegueID, sender: self)
        }
    }
    
    /**************************************************************************/
    // MARK: - Public Method
    /**************************************************************************/
    
    open func setDrawerState(_ state: DrawerState, animated: Bool) {
        _containerView.isHidden = false
        let duration: TimeInterval = animated ? _kDrawerAnimationDuration : 0
        
        UIView.animate(withDuration: duration,
            delay: 0,
            options: .curveEaseOut,
            animations: { () -> Void in
                switch state {
                case .closed:
                    self._drawerConstraint.constant     = 0
                    self._containerView.backgroundColor = UIColor(white: 0, alpha: 0)
                case .opened:
                    let constant: CGFloat
                    switch self.drawerDirection {
                    case .left:
                        constant = self.drawerWidth
                    case .right:
                        constant = -self.drawerWidth
                    }
                    self._drawerConstraint.constant     = constant
                    self._containerView.backgroundColor = UIColor(
                        white: 0
                        , alpha: self._kContainerViewMaxAlpha
                    )
                }
                self._containerView.layoutIfNeeded()
            }) { (finished: Bool) -> Void in
                if state == .closed {
                    self._containerView.isHidden = true
                }
                self.delegate?.drawerController?(self, stateChanged: state)
        }
    }
    
    /**************************************************************************/
    // MARK: - Private Method
    /**************************************************************************/
    
    final func handlePanGesture(_ sender: UIGestureRecognizer) {
        _containerView.isHidden = false
        if sender.state == .began {
            _panStartLocation = sender.location(in: view)
        }
        
        let delta           = CGFloat(sender.location(in: view).x - _panStartLocation.x)
        let constant        : CGFloat
        let backGroundAlpha : CGFloat
        let drawerState     : DrawerState
        
        switch drawerDirection {
        case .left:
            drawerState     = _panDelta < 0 ? .closed : .opened
            constant        = min(_drawerConstraint.constant + delta, drawerWidth)
            backGroundAlpha = min(
                _kContainerViewMaxAlpha,
                _kContainerViewMaxAlpha*(abs(constant)/drawerWidth)
            )
        case .right:
            drawerState     = _panDelta > 0 ? .closed : .opened
            constant        = max(_drawerConstraint.constant + delta, -drawerWidth)
            backGroundAlpha = min(
                _kContainerViewMaxAlpha,
                _kContainerViewMaxAlpha*(abs(constant)/drawerWidth)
            )
        }
        
        _drawerConstraint.constant = constant
        _containerView.backgroundColor = UIColor(
            white: 0,
            alpha: backGroundAlpha
        )
        
        switch sender.state {
        case .changed:
            _panStartLocation = sender.location(in: view)
            _panDelta         = delta
        case .ended, .cancelled:
            setDrawerState(drawerState, animated: true)
        default:
            break
        }
    }
    
    final func didtapContainerView(_ gesture: UITapGestureRecognizer) {
        setDrawerState(.closed, animated: true)
    }
    
    
    /**************************************************************************/
    // MARK: - UIGestureRecognizerDelegate
    /**************************************************************************/
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        switch gestureRecognizer {
        case panGesture:
            return drawerState == .opened
        case screenEdgePanGesture:
            return screenEdgePanGestreEnabled ? drawerState == .closed : false
        default:
            return touch.view == gestureRecognizer.view
        }
   }

}

