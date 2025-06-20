import Foundation
import UIKit

public class BackgroundView: UIView {
    private let config: AnimatedLaunchScreenConfiguration
    private var stackView: UIStackView!
    private var columnViews: [SlotColumnView] = []
    private var isBeingDeallocated = false
    
    // Single display link for all animations
    private var displayLink: CADisplayLink?
    
    public init(configuration: AnimatedLaunchScreenConfiguration) {
        self.config = configuration
        super.init(frame: .zero)
        setupStackView()
        createColumns()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupStackView() {
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func createColumns() {
        guard !isBeingDeallocated else { return }
        
        let columnCount = config.columns.count

        for index in 0..<columnCount {
            guard !isBeingDeallocated else { return }
            
            let isEvenColumn = index % 2 == 0
            let direction: SlotColumnView.ScrollDirection = isEvenColumn ? .down : .up
            let columnImages = config.columns[index]
            
            let columnView = SlotColumnView(images: columnImages, scrollDirection: direction)
            columnViews.append(columnView)
            stackView.addArrangedSubview(columnView)
        }
    }

    public func runPhaseOne() {
        guard !isBeingDeallocated else { return }
        
        // Prepare all columns for animation with their individual delays
        for (index, column) in columnViews.enumerated() {
            let delay = Double(index) * 0.05
            column.prepareForAnimation(delay: delay, duration: config.animationDurations.spinDuration)
        }
        
        // Create single display link to drive all animations
        displayLink = CADisplayLink(target: WeakProxy(target: self, selector: #selector(updateAllColumns)), selector: #selector(WeakProxy.forward(_:)))
        displayLink?.add(to: .main, forMode: .common)

    }
    @objc private func updateAllColumns() {
        // Exit early if cleanup has started
        if isBeingDeallocated {
            return
        }

        let currentTime = CACurrentMediaTime()

        // Copy columnViews to avoid mutation crash
        let columnsSnapshot = columnViews

        for column in columnsSnapshot {
            column.updateAnimation(currentTime: currentTime)
        }
    }

    public func stopAll() {
        displayLink?.invalidate()
        displayLink = nil
    }

    public func prepareForDeallocation() {
        stopAll() // 🛑 Make sure display link is stopped first
        isBeingDeallocated = true
        columnViews.removeAll() // Mutating array safely after stop
    }

}

final class WeakProxy {
    weak var target: AnyObject?
    let selector: Selector

    init(target: AnyObject, selector: Selector) {
        self.target = target
        self.selector = selector
    }

    @objc func forward(_ displayLink: CADisplayLink) {
        guard let target = target else {
            displayLink.invalidate()
            return
        }

        _ = target.perform(selector, with: displayLink)
    }
}
