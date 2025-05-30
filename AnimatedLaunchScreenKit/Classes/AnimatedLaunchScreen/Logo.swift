import UIKit

class BounceLogoView: UIView {
    // MARK: - Configuration Constants
    
    /// Final size of the logo as a fraction of the container view's width (0.0-1.0)
    var finalSizeMultiplier: CGFloat = 0.7
    
    /// Initial size of the logo as a fraction of the final size (0.0-1.0)
    var initialSizeScale: CGFloat = 0.15
    
    /// Maximum size during overshoot as a multiplier of final size (e.g., 1.25 = 125%)
    var overshotSizeMultiplier: CGFloat = 1.25
    
    /// Duration for the initial growth animation in seconds
    var growthDuration: TimeInterval = 0.6
    
    /// Duration for the settling animation in seconds
    var settlingDuration: TimeInterval = 0.3
    
    /// Spring damping for growth (0.0-1.0, lower = more bouncy)
    var growthDamping: CGFloat = 0.5
    
    /// Spring damping for settling (0.0-1.0, lower = more bouncy)
    var settlingDamping: CGFloat = 0.6
    
    /// Initial velocity for growth animation (higher = more energetic)
    var growthVelocity: CGFloat = 0.8
    
    // MARK: - Private Properties
    
    private var logoImageView: UIImageView!
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLogoView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLogoView()
    }
    
    // MARK: - Setup
    
    private func setupLogoView() {
        // Get logo using your assets system
        if let logoImage = HPGAssets.image(for: .logo) {
            logoImageView = UIImageView(image: logoImage)
            logoImageView.contentMode = .scaleAspectFit
            logoImageView.translatesAutoresizingMaskIntoConstraints = false
            
            // Add to view
            addSubview(logoImageView)
            
            // Center logo with final size constraints
            NSLayoutConstraint.activate([
                logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                logoImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: finalSizeMultiplier),
                logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor)
            ])
            
            // Set initial transform to tiny (will be reset in animation)
            logoImageView.transform = CGAffineTransform(scaleX: initialSizeScale, y: initialSizeScale)
        }
    }
    
    // MARK: - Animation
    
    func animateBounceIn(delay: TimeInterval = 0.5, completion: (() -> Void)? = nil) {
        // Ensure we're laid out
        layoutIfNeeded()
        
        // Reset to initial size
        logoImageView.transform = CGAffineTransform(scaleX: initialSizeScale, y: initialSizeScale)
        
        // First bounce animation
        UIView.animate(withDuration: growthDuration,
                       delay: delay,
                       usingSpringWithDamping: growthDamping,
                       initialSpringVelocity: growthVelocity,
                       options: [],
                       animations: {
            // Overshoot to larger size
            self.logoImageView.transform = CGAffineTransform(scaleX: self.overshotSizeMultiplier,
                                                          y: self.overshotSizeMultiplier)
        }, completion: { _ in
            // First settle back to final size
            UIView.animate(withDuration: self.settlingDuration,
                           delay: 0,
                           usingSpringWithDamping: self.settlingDamping,
                           initialSpringVelocity: 0,
                           options: [],
                           animations: {
                // Final size (100%)
                self.logoImageView.transform = .identity
            }, completion: { _ in
                // Second bounce after 1 second delay
                UIView.animate(withDuration: self.growthDuration,
                               delay: 1.5, // 1 second delay
                               usingSpringWithDamping: self.growthDamping,
                               initialSpringVelocity: self.growthVelocity,
                               options: [],
                               animations: {
                    // Second overshoot
                    self.logoImageView.transform = CGAffineTransform(scaleX: self.overshotSizeMultiplier,
                                                                  y: self.overshotSizeMultiplier)
                }, completion: { _ in
                    // Final settle
                    UIView.animate(withDuration: self.settlingDuration,
                                   delay: 0,
                                   usingSpringWithDamping: self.settlingDamping,
                                   initialSpringVelocity: 0,
                                   options: [],
                                   animations: {
                        // Back to final size
                        self.logoImageView.transform = .identity
                    }, completion: { _ in
                        completion?()
                    })
                })
            })
        })
    }
}
