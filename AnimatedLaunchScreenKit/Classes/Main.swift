import UIKit

public class AnimatedLaunchScreenViewController: UIViewController {
    private let configuration: AnimatedLaunchScreenConfiguration
    private var backgroundView: BackgroundView!
    private var logoView: BounceLogoView!
    private var homeViewController: UIViewController!
    private var hasCompleted = false // Prevent multiple completions
    
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
        setupLogoView()
        setupBackgroundView()
        runLaunchSequence()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop all animations when view is about to disappear
        cleanup()
    }
    
    
    @MainActor
    private func cleanup() {
        backgroundView?.stopAll()
        backgroundView?.prepareForDeallocation()
    }
    
    private func setupLogoView() {
        logoView = BounceLogoView()
        logoView.layer.zPosition = 5
        logoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoView)
        
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
        backgroundView.runPhaseOne()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self, !self.hasCompleted else { return }
            self.logoView.animateBounceIn(delay: 0.1)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) { [weak self] in
            self?.complete()
        }
    }
    
    private func complete() {
        // Prevent multiple calls
        guard !hasCompleted else { return }
        hasCompleted = true
        
        // Stop all animations FIRST
        cleanup()
        
        // Small delay to ensure cleanup completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            
            // Get the window safely
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return
            }
            
            // Perform transition
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
