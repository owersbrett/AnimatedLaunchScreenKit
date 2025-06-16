import UIKit

public class AnimatedLaunchScreenViewController: UIViewController {
    private let configuration: AnimatedLaunchScreenConfiguration
    private var backgroundView: BackgroundView!
    private var logoView: BounceLogoView!
    private var homeViewController: UIViewController!
    

    private var totalDuration: TimeInterval {
        configuration.animationDurations.totalDuration
    }

    public init(configuration: AnimatedLaunchScreenConfiguration, homeViewController: UIViewController) {
        self.homeViewController = homeViewController
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = configuration.backgroundColor
        setupLogoView() // Create the logo view first (will be behind background)
        setupBackgroundView() // Add background view on top
        runLaunchSequence() // Start the animations
    }
    
    private func setupLogoView() {
        // Create the logo view
        logoView = BounceLogoView()
        logoView.layer.zPosition = 5
        logoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoView)
        
        // Position the logo - adjust constraints as needed for your design
        NSLayoutConstraint.activate([
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoView.widthAnchor.constraint(equalToConstant: 300),
            logoView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupBackgroundView() {
        backgroundView = BackgroundView(configuration: configuration)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func runLaunchSequence() {
        // Start the background scrolling immediately
        backgroundView.runPhaseOne()
        
        // Add the logo bounce animation after a slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.logoView.animateBounceIn(delay: 0.1)
        }
        
        // Set up the completion to run after the total duration
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            // Take a snapshot to freeze the animation state
            let snapshot = self.view.snapshotView(afterScreenUpdates: true)
            if let snapshot = snapshot {
                snapshot.frame = self.view.frame
                self.view.addSubview(snapshot)
                self.complete()

            } else {
                self.complete()
            }
        }
    }
    
    private func complete(){
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let snapshot = self.view.snapshotView(afterScreenUpdates: true)
            if let snapshot = snapshot {
                snapshot.frame = self.view.frame
                self.view.addSubview(snapshot)
            }

            // Transition rootViewController
            guard let window = UIApplication.shared.delegate?.window ?? nil else { return }

            UIView.transition(with: window,
                              duration: 0.4,
                              options: [.transitionCrossDissolve],
                              animations: {
                                  window.rootViewController = self.homeViewController
                              })
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
