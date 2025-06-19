import Foundation
import UIKit

public class BackgroundView: UIView {
    private let config: AnimatedLaunchScreenConfiguration
    private var stackView: UIStackView!
    private var columnViews: [SlotColumnView] = []
    private var isBeingDeallocated = false

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
        
        // Use enumerated().forEach safely
        for (index, column) in columnViews.enumerated() {
            guard !isBeingDeallocated else { break }
            
            let delay = Double(index) * 0.05
            column.startScrolling(delay: delay, duration: config.animationDurations.spinDuration)
        }
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
}
