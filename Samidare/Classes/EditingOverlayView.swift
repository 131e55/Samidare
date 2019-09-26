//
//  EditingOverlayView.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/10/27.
//

import UIKit

/// EditingOverlayView manages its own layout constraints by itself.
internal class EditingOverlayView: TouchPassedView {

    private static let nib: UINib = UINib(nibName: "EditingOverlayView", bundle: Bundle(for: EditingOverlayView.self))
    /// Apply the constraint after move to superview. Until then it is nil.
    private weak var topConstraint: NSLayoutConstraint!
    /// Apply the constraint after move to superview. Until then it is nil.
    private weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var cellWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var cellHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var cellOverlayView: UIView!
    @IBOutlet private weak var leftTimeArea: UIView!
    @IBOutlet private weak var rightTimeArea: UIView!
    private var timeRangeView: TimeRangeView = TimeRangeView()
    @IBOutlet private weak var topKnobContainerView: UIView!
    @IBOutlet private weak var topKnobView: UIView!
    @IBOutlet private weak var bottomKnobContainerView: UIView!
    @IBOutlet private weak var bottomKnobView: UIView!

    private var editingCell: EventCell!
    
    private var cellPanGestureRecognizer: UIPanGestureRecognizer!
    private var topKnobPanGestureRecognizer: UIPanGestureRecognizer!
    private var bottomKnobPanGestureRecognizer: UIPanGestureRecognizer!

    /// First touch location in referencing EventScrollView.
    /// It's reset each time any gesture recognized.
    private var firstTouchLocation: CGPoint?
    /// Last touch location in referencing EventScrollView.
    private var lastTouchLocation: CGPoint?
    
    /// Current PanningPoint (cell or topKnob or bottomKnob)
    private var currentPanningPoint: PanningPoint? {
        didSet {
            switch currentPanningPoint {
            case .none:
                cellPanGestureRecognizer.isEnabled = true
                topKnobPanGestureRecognizer.isEnabled = true
                bottomKnobPanGestureRecognizer.isEnabled = true
            case .some(.cell):
                topKnobPanGestureRecognizer.isEnabled = false
                bottomKnobPanGestureRecognizer.isEnabled = false
            case .some(.topKnob):
                cellPanGestureRecognizer.isEnabled = false
                bottomKnobPanGestureRecognizer.isEnabled = false
            case .some(.bottomKnob):
                cellPanGestureRecognizer.isEnabled = false
                topKnobPanGestureRecognizer.isEnabled = false
            }
        }
    }

    /// Tells that begin panning cell or top-bottom knobs.
    internal var willPanHandler: ((_ panningPoint: PanningPoint) -> Void)?
    /// Tells that cell scaled by top-bottom knobs.
    /// If length is positive, means bottom side.
    /// If length is negative, means top side.
    internal var didPanKnobHandler: ((_ panningPoint: PanningPoint, _ length: CGFloat) -> Void)?
    /// Tells that cell moved by cell panning.
    /// If length is positive, cell.frame will be move bottom side.
    /// If length is negative, cell.frame will be move top side.
    internal var didPanCellHandler: ((_ length: CGFloat) -> Void)?
    /// Tells that ended panning cell or top-bottom knobs.
    internal var didEndPanningHandler: ((_ panningPoint: PanningPoint) -> Void)?

    internal var timeInfoWidth: CGFloat {
        return timeRangeView.intrinsicContentSize.width + 8 * 2
    }
    
    /// - Parameter cell: Editing target EventCell
    init(cell: EventCell) {
        super.init(frame: .zero)
        
        editingCell = cell
        isUserInteractionEnabled = true
        translatesAutoresizingMaskIntoConstraints = false

        let view = type(of: self).nib.instantiate(withOwner: self, options: nil).first as! UIView
        addSubview(view)
        view.activateFitFrameConstarintsToSuperview()

        cellPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanCellOverlayView))
        cellOverlayView.addGestureRecognizer(cellPanGestureRecognizer)
        topKnobPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanKnobView))
        topKnobContainerView.addGestureRecognizer(topKnobPanGestureRecognizer)
        topKnobView.backgroundColor = .white
        topKnobView.layer.borderColor = cell.event.color.cgColor
        topKnobView.layer.borderWidth = 0.5
        bottomKnobPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanKnobView))
        bottomKnobContainerView.addGestureRecognizer(bottomKnobPanGestureRecognizer)
        bottomKnobView.backgroundColor = .white
        bottomKnobView.layer.borderColor = cell.event.color.cgColor
        bottomKnobView.layer.borderWidth = 0.5

        NotificationCenter.default.addObserver(self, selector: #selector(eventCellDidSetEvent),
                                               name: EventCell.didSetEventNotification, object: nil)
        setTimeRangeViewPosition(toRight: false)
        updateTimeLabels()
    }
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if superview != nil {
            setupLayoutConstraints()
        }
    }

    private func setupLayoutConstraints() {
        guard superview != nil else { fatalError("Call in didMoveToSuperview.") }

        topConstraint = topAnchor.constraint(equalTo: editingCell.topAnchor,
                                             constant: -topKnobContainerView.bounds.height / 2)
        bottomConstraint = bottomAnchor.constraint(equalTo: editingCell.bottomAnchor,
                                                   constant: bottomKnobContainerView.bounds.height / 2)
        // left and right timeRangeView width.
        let additionalWidth = timeInfoWidth * 2

        NSLayoutConstraint.activate([
            topConstraint,
            bottomConstraint,
            centerXAnchor.constraint(equalTo: editingCell.centerXAnchor),
            widthAnchor.constraint(equalTo: editingCell.widthAnchor, constant: additionalWidth),
            cellOverlayView.widthAnchor.constraint(equalTo: editingCell.widthAnchor),
            cellOverlayView.heightAnchor.constraint(equalTo: editingCell.heightAnchor)
        ])
    }
    
    internal func setTimeRangeViewPosition(toRight: Bool) {
        timeRangeView.color = editingCell.event.color
        if toRight && timeRangeView.superview != rightTimeArea {
            rightTimeArea.addSubview(timeRangeView)
            timeRangeView.activateFitFrameConstarintsToSuperview()
        } else if toRight == false && timeRangeView.superview != leftTimeArea {
            leftTimeArea.addSubview(timeRangeView)
            timeRangeView.activateFitFrameConstarintsToSuperview()
        }
    }
    
    private func updateTimeLabels() {
        guard let cell = editingCell else { return }
        timeRangeView.update(timeRange: cell.event.start ... cell.event.end)
    }
    
    private func endPanning() {
        guard let panningPoint = currentPanningPoint else { return }
        currentPanningPoint = nil
        firstTouchLocation = nil
        lastTouchLocation = nil
        didEndPanningHandler?(panningPoint)
    }

    @objc private func didPanCellOverlayView(_ sender: UIGestureRecognizer) {
        guard sender.view == cellOverlayView else { fatalError() }
        handleCellPanning(recognizer: sender)
    }
    
    private func handleCellPanning(recognizer: UIGestureRecognizer) {
        guard currentPanningPoint == nil || currentPanningPoint == .cell
            else { fatalError("Restrict (cell, top, bottom)PanGestureRecognizer.isEnabled") }

        let location = recognizer.location(in: nil)
        
        switch recognizer.state {
        case .began:
            currentPanningPoint = .cell
            firstTouchLocation = location
            lastTouchLocation = location
            willPanHandler?(currentPanningPoint!)
            
        case .changed:
            guard let firstTouchLocation = firstTouchLocation else { fatalError("Not passed .began") }
            lastTouchLocation = location
            let length = lastTouchLocation!.y - firstTouchLocation.y
            didPanCellHandler?(length)
            
        default:
            endPanning()
        }
    }

    @objc private func didPanKnobView(_ sender: UIPanGestureRecognizer) {
        guard sender.view == topKnobContainerView || sender.view == bottomKnobContainerView else { fatalError() }
        let panningPoint: PanningPoint = sender.view == topKnobContainerView ? .topKnob : .bottomKnob
        handleKnobPanning(panningPoint: panningPoint, recognizer: sender)
    }
    
    private func handleKnobPanning(panningPoint: PanningPoint, recognizer: UIGestureRecognizer) {
        guard currentPanningPoint == nil || currentPanningPoint == panningPoint
            else { fatalError("Restrict (cell, top, bottom)PanGestureRecognizer.isEnabled") }

        let location = recognizer.location(in: nil)
        
        switch recognizer.state {
        case .began:
            currentPanningPoint = panningPoint
            // top and bottom may overlap, so bring touched knob and timeView to front
            if panningPoint == .topKnob {
                timeRangeView.bringStartViewToFront()
                topKnobContainerView.superview!.insertSubview(topKnobContainerView, aboveSubview: bottomKnobContainerView)
            } else if panningPoint == .bottomKnob {
                timeRangeView.bringEndViewToFront()
                bottomKnobContainerView.superview!.insertSubview(bottomKnobContainerView, aboveSubview: topKnobContainerView)
            }
            
            firstTouchLocation = location
            lastTouchLocation = location
            willPanHandler?(currentPanningPoint!)
            
        case .changed:
            guard let firstTouchLocation = firstTouchLocation else { fatalError("Not passed .began") }
            lastTouchLocation = location
            let length = lastTouchLocation!.y - firstTouchLocation.y
            didPanKnobHandler?(panningPoint, length)
            
        default:
            endPanning()
        }
    }
    
    @objc private func eventCellDidSetEvent(_ notification: Notification) {
        guard let eventCell = notification.object as? EventCell, eventCell == editingCell else { return }
        updateTimeLabels()
    }
}

extension EditingOverlayView {
    enum PanningPoint {
        case cell
        case topKnob
        case bottomKnob
    }
}

extension EditingOverlayView {
    /// 🤔
    /// for EventScrollView.Editor.
    /// Editor wants to move cell by panning after detected long press cell.
    internal func simulateCellOverlayViewPanning(_ recognizer: UIGestureRecognizer) {
        handleCellPanning(recognizer: recognizer)
    }

    /// 🤔
    /// for EventScrollView.Editor.
    /// Editor supports editor.simulateBottomKnobPanning(_ recognizer: UIGestureRecognizer)
    internal func simulateBottomKnobPanning(_ recognizer: UIGestureRecognizer) {
        handleKnobPanning(panningPoint: .bottomKnob, recognizer: recognizer)
    }
}
