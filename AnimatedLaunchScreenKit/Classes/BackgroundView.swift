import Foundation
import UIKit

public class BackgroundView: UIView {
    private let config: AnimatedLaunchScreenConfiguration
    private var stackView: UIStackView!
    private var columnViews: [SlotColumnView] = []

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
        let columnCount = config.columns.count

        for index in 0..<columnCount {
            let isEvenColumn = index % 2 == 0
            let direction: SlotColumnView.ScrollDirection = isEvenColumn ? .down : .up
            
            // Get the images for this column directly from the configuration
            let columnImages = config.columns[index]
            
            let columnView = SlotColumnView(images: columnImages, scrollDirection: direction)
            columnViews.append(columnView)
            stackView.addArrangedSubview(columnView)
            
            print("Column \(index) asset count: \(columnImages.count)")
            for (i, image) in columnImages.enumerated() {
                print("  - Image \(i): size = \(image.size)")
            }
        }
    }

    // Public control for animations
    public func runPhaseOne() {
        columnViews.enumerated().forEach { index, column in
            let delay = Double(index) * 0.05
            column.startScrolling(delay: delay, duration: config.animationDurations.spinDuration)
        }
    }
    func getScrollViews() -> [UIScrollView]? {
        // Return array of scroll views used in your animations
        return []
    }

    public func stopAll() {
//        getScrollViews()?.forEach { $0.stopScrolling() }
    }
}
