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
    private var displayLink: CADisplayLink?
    
    private var imageHeight: CGFloat = 60
    private var pixelsPerSecond: CGFloat = 0
    private var startTime: CFTimeInterval = 0
    private var lastTime: CFTimeInterval = 0
    
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
    
    deinit {
        stopScrolling()
    }

    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isUserInteractionEnabled = false // Prevent user interaction during animation
        
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
        
        // Create three sets of images for smoother looping
        let repeatedImages = images + images + images
        
        // Set up a vertical stack of images
        var lastImageView: UIImageView?
        
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
        }
        
        // Set the bottom constraint for the content view
        if let lastImageView = lastImageView {
            lastImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        // Only update if we have valid bounds
        guard bounds.size.height > 0 else { return }
        
        // Update content size after layout
        let contentHeight = CGFloat(imageViews.count) * imageHeight
        scrollView.contentSize = CGSize(width: bounds.width, height: contentHeight)
        
        // Position in the middle third to allow seamless scrolling
        if !isScrolling {
            let oneThirdHeight = contentHeight / 3
            scrollView.contentOffset = CGPoint(x: 0, y: oneThirdHeight)
        }
    }

    public func startScrolling(delay: TimeInterval, duration: TimeInterval) {
        guard !isScrolling else { return }
        
        // Calculate scroll speed (pixels per second)
        pixelsPerSecond = imageHeight / CGFloat(duration)
        
        // Delay the start
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            
            self.isScrolling = true
            self.startTime = CACurrentMediaTime()
            self.lastTime = self.startTime
            
            // Create and start display link
            self.displayLink = CADisplayLink(target: self, selector: #selector(self.updateScroll))
            self.displayLink?.add(to: .main, forMode: .common)
        }
    }
    
    @objc private func updateScroll(displayLink: CADisplayLink) {
        let currentTime = displayLink.timestamp
        let deltaTime = currentTime - lastTime
        lastTime = currentTime
        
        // Calculate distance to move
        let distance = pixelsPerSecond * CGFloat(deltaTime)
        let direction: CGFloat = scrollDirection == .down ? 1 : -1
        
        // Update scroll position
        let newY = scrollView.contentOffset.y + (distance * direction)
        scrollView.contentOffset = CGPoint(x: 0, y: newY)
        
        // Check if we need to reset position for infinite scroll
        checkAndResetScrollPosition()
    }
    
    private func checkAndResetScrollPosition() {
        let contentHeight = scrollView.contentSize.height
        let oneThirdHeight = contentHeight / 3
        
        // If we've scrolled past the bounds, reset to maintain infinite scroll
        if scrollDirection == .up {
            if scrollView.contentOffset.y <= 0 {
                // Jump forward by one third
                scrollView.contentOffset.y += oneThirdHeight
            }
        } else {
            if scrollView.contentOffset.y >= contentHeight - scrollView.bounds.height {
                // Jump back by one third
                scrollView.contentOffset.y -= oneThirdHeight
            }
        }
        
        // Additional check for the middle position
        if scrollView.contentOffset.y < oneThirdHeight * 0.5 {
            scrollView.contentOffset.y += oneThirdHeight
        } else if scrollView.contentOffset.y > oneThirdHeight * 2.5 {
            scrollView.contentOffset.y -= oneThirdHeight
        }
    }

    public func stopScrolling() {
        isScrolling = false
        displayLink?.invalidate()
        displayLink = nil
    }
}
