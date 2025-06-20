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
    private var isBeingDeallocated = false
    
    private var imageHeight: CGFloat = 60
    private var pixelsPerSecond: CGFloat = 0
    private var animationDelay: TimeInterval = 0
    private var animationStartTime: CFTimeInterval = 0
    
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
        guard !isBeingDeallocated else { return }
        
        imageViews.forEach { $0.removeFromSuperview() }
        imageViews.removeAll()
        
        var lastImageView: UIImageView?
        
        for image in images {
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
        
        guard !isBeingDeallocated, bounds.size.height > 0 else { return }
        
        let contentHeight = CGFloat(imageViews.count) * imageHeight
        scrollView.contentSize = CGSize(width: bounds.width, height: contentHeight)
        
        // Position at one third to allow seamless scrolling
        let oneThirdHeight = contentHeight / 3
        scrollView.contentOffset = CGPoint(x: 0, y: oneThirdHeight)
    }

    public func prepareForAnimation(delay: TimeInterval, duration: TimeInterval) {
        self.animationDelay = delay
        self.pixelsPerSecond = imageHeight / CGFloat(duration)
        self.animationStartTime = CACurrentMediaTime()
    }

    public func updateAnimation(currentTime: CFTimeInterval) {
        guard !isBeingDeallocated else { return }
        
        let elapsed = currentTime - animationStartTime
        guard elapsed >= animationDelay else { return }
        
        let distance = pixelsPerSecond * CGFloat(1.0/60.0) // 60fps
        let direction: CGFloat = scrollDirection == .down ? 1 : -1
        let newY = scrollView.contentOffset.y + (distance * direction)
        scrollView.contentOffset = CGPoint(x: 0, y: newY)
    }

    public func prepareForDeallocation() {
        isBeingDeallocated = true
    }
}
