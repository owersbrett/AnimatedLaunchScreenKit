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
    
    private var imageHeight: CGFloat = 60
    private var pixelsPerSecond: CGFloat = 0
    
    // Add these new properties at the top with your other properties
    private var animationDelay: TimeInterval = 0
    private var animationStartTime: CFTimeInterval = 0

    
    
    // Add this flag to prevent operations after deallocation starts
    private var isBeingDeallocated = false
    
    public init(images: [UIImage], scrollDirection: ScrollDirection) {
        self.images = images
        self.scrollDirection = scrollDirection
        super.init(frame: .zero)
        setupScrollView()
        setupImageViews()
    }
    // Remove displayLink property and use external timing
    public func prepareForAnimation(delay: TimeInterval, duration: TimeInterval) {
        self.animationDelay = delay
        self.pixelsPerSecond = imageHeight / CGFloat(duration)
        self.animationStartTime = CACurrentMediaTime()
    }

    public func updateAnimation(currentTime: CFTimeInterval) {
        // Only animate if enough time has passed for this column's delay
        let elapsed = currentTime - animationStartTime
        guard elapsed >= animationDelay else { return }
        
        // Your existing scroll update logic here
        let distance = pixelsPerSecond * CGFloat(1.0/60.0) // 60fps
        let direction: CGFloat = scrollDirection == .down ? 1 : -1
        let newY = scrollView.contentOffset.y + (distance * direction)
        scrollView.contentOffset = CGPoint(x: 0, y: newY)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isUserInteractionEnabled = false
        
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
        // Safety check
        guard !isBeingDeallocated else { return }
        
        // Remove existing image views safely
        imageViews.forEach { imageView in
            imageView.removeFromSuperview()
        }
        imageViews.removeAll()
        
        let repeatedImages = images
        var lastImageView: UIImageView?
        
        for image in repeatedImages {
            guard !isBeingDeallocated else { return }
            
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                imageView.heightAnchor.constraint(equalToConstant: imageHeight)
            ])
            
            if let lastImageView = lastImageView {
                imageView.topAnchor.constraint(equalTo: lastImageView.bottomAnchor).isActive = true
            } else {
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            }
            
            lastImageView = imageView
            imageViews.append(imageView)
        }
        
        if let lastImageView = lastImageView {
            lastImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        // Safety checks
        guard !isBeingDeallocated, bounds.size.height > 0 else { return }
        
        let contentHeight = CGFloat(imageViews.count) * imageHeight
        scrollView.contentSize = CGSize(width: bounds.width, height: contentHeight)
        
        if !isScrolling {
            let oneThirdHeight = contentHeight / 3
            scrollView.contentOffset = CGPoint(x: 0, y: oneThirdHeight)
        }
    }

    public func startScrolling(delay: TimeInterval, duration: TimeInterval) {
        guard !isScrolling, !isBeingDeallocated else { return }
        
        pixelsPerSecond = imageHeight / CGFloat(duration)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self, !self.isBeingDeallocated else { return }
            
            self.isScrolling = true
            self.startTime = CACurrentMediaTime()
            self.lastTime = self.startTime
            
            self.displayLink = CADisplayLink(target: self, selector: #selector(self.updateScroll))
            self.displayLink?.add(to: .main, forMode: .common)
        }
    }
    
    @objc private func updateScroll(displayLink: CADisplayLink) {
        // Critical safety check
        guard !isBeingDeallocated, isScrolling else {
            stopScrolling()
            return
        }
        
        let currentTime = displayLink.timestamp
        let deltaTime = currentTime - lastTime
        lastTime = currentTime
        
        let distance = pixelsPerSecond * CGFloat(deltaTime)
        let direction: CGFloat = scrollDirection == .down ? 1 : -1
        
        let newY = scrollView.contentOffset.y + (distance * direction)
        scrollView.contentOffset = CGPoint(x: 0, y: newY)
    }

    public func stopScrolling() {
        isScrolling = false
        displayLink?.invalidate()
        displayLink = nil
    }
    
    // Add a main-actor version for when called from UI contexts
    @MainActor
    public func stopScrollingOnMainActor() {
        stopScrolling()
    }
    
    // Add this method to be called before view controller transitions
    public func prepareForDeallocation() {
        isBeingDeallocated = true
        stopScrolling()
    }
}
