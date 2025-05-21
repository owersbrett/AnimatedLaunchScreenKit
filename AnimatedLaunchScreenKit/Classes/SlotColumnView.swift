import UIKit

@MainActor
public class SlotColumnView: UIView {

    public enum ScrollDirection {
        case up
        case down
    }

    private var images: [UIImage]
    private var scrollDirection: ScrollDirection
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var imageViews: [UIImageView] = []
    private var isScrolling = false
    private var scrollTimer: Timer?
    
    private var imageHeight: CGFloat = 60

    public init(images: [UIImage], scrollDirection: ScrollDirection) {
        self.images = images
        self.scrollDirection = scrollDirection
        super.init(frame: .zero)
        setupScrollView()
        setupImageViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupImageViews() {
        // Remove existing image views
        imageViews.forEach { $0.removeFromSuperview() }
        imageViews.removeAll()
        
        // Create twice as many images as needed by repeating the array
        let repeatedImages = images + images
        
        // Set up a vertical stack of images
        var lastImageView: UIImageView?
        var totalHeight: CGFloat = 0
        
        for image in repeatedImages {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(imageView)
            
            // Constrain width to fill container
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                imageView.heightAnchor.constraint(equalToConstant: imageHeight)
            ])
            
            // Position vertically
            if let lastImageView = lastImageView {
                imageView.topAnchor.constraint(equalTo: lastImageView.bottomAnchor).isActive = true
            } else {
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            }
            
            lastImageView = imageView
            imageViews.append(imageView)
            totalHeight += imageHeight
        }
        
        // Set the bottom constraint for the content view
        if let lastImageView = lastImageView {
            lastImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        }
        
        // Set content size
        let contentHeight = CGFloat(repeatedImages.count) * imageHeight
        
        // Update content size
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentHeight)
        
        // Initially position in the middle to allow seamless scrolling
        let initialOffset = (contentHeight - scrollView.frame.height) / 2
        scrollView.contentOffset = CGPoint(x: 0, y: initialOffset)
    }

    public func startScrolling(delay: TimeInterval, duration: TimeInterval) {
        guard !isScrolling else { return }
        isScrolling = true
        
        // Adjust layout if needed first
        layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            // Calculate scroll speed (pixels per second)
            let pixelsPerSecond: CGFloat = self.imageHeight / CGFloat(duration)
            
            // Create a timer for smooth scrolling
            self.scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] timer in
                guard let self = self else { timer.invalidate(); return }

                Task { @MainActor in
                    let distance = pixelsPerSecond * 0.016
                    let direction: CGFloat = self.scrollDirection == .down ? 1 : -1
                    let newY = self.scrollView.contentOffset.y + (distance * direction)

                    self.scrollView.contentOffset.y = newY
                    self.checkAndResetScrollPosition()
                }
            }

            
            // Make sure the timer runs on the main run loop
            RunLoop.main.add(self.scrollTimer!, forMode: .common)
        }
    }
    
    private func checkAndResetScrollPosition() {
        let contentHeight = scrollView.contentSize.height
        let halfContentHeight = contentHeight / 2
        
        // If we've scrolled past the halfway point of the duplicate content
        if scrollView.contentOffset.y < imageHeight {
            // Jump to the duplicate section seamlessly
            scrollView.contentOffset.y += halfContentHeight
        } else if scrollView.contentOffset.y > halfContentHeight + imageHeight {
            // Jump back to the original section seamlessly
            scrollView.contentOffset.y -= halfContentHeight
        }
    }

    public func stopScrolling() {
        isScrolling = false
        scrollTimer?.invalidate()
        scrollTimer = nil
    }
}
