import Foundation
import UIKit

public class BackgroundView: UIView {
    private let config: AnimatedLaunchScreenConfiguration
    private var stackView: UIStackView!
    private var columnViews: [SlotColumnView] = []
    private var isBeingDeallocated = false
    
    // Single display link for all animations
    private var displayLink: CADisplayLink?
    private var animationStartTime: CFTimeInterval = 0
    
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
        
        // Start all columns with their delays, but don't let them create their own display links
        for (index, column) in columnViews.enumerated() {
            let delay = Double(index) * 0.05
            column.prepareForAnimation(delay: delay, duration: config.animationDurations.spinDuration)
        }
        
        // Create single display link
        animationStartTime = CACurrentMediaTime()
        displayLink = CADisplayLink(target: self, selector: #selector(updateAllColumns))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func getScrollViews() -> [UIScrollView]? {
        return []
    }

    public func stopAll() {
        // Stop all column animations safely
        for column in columnViews {
            column.stopScrolling()
        }
    }
    
    // Add this method to prepare for deallocation
    public func prepareForDeallocation() {
        isBeingDeallocated = true
        
        // Stop all columns - since stopScrolling is now nonisolated, this is safe
        for column in columnViews {
            column.stopScrolling()
            column.prepareForDeallocation()
        }
    }
    
    @objc private func updateAllColumns() {
        let currentTime = CACurrentMediaTime()
        
        for column in columnViews {
            column.updateAnimation(currentTime: currentTime)
        }
    }

}
