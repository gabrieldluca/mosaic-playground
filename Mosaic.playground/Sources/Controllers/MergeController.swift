import AVFoundation
import UIKit
import SceneKit

public class MergeController: UIViewController, LevelDelegate {
    
    // MARK: - Variables
    
    internal let scene:SCNScene = SCNScene()
    internal let sceneView:SCNView = SCNView()
    internal var progressPercentage:Double = 0
    internal var levelPieces:[MovableView] = []
    
    // MARK: - Assets
    
    internal let images:[UIImage?] = [
        UIImage(named: "Images/Pieces/Merge/piece-0.png"),
        UIImage(named: "Images/Pieces/Merge/piece-1.png")
    ]
    internal let coloredImages:[UIImage?] = [
        UIImage(named: "Images/Pieces/Merge/piece-0-colored.png"),
        UIImage(named: "Images/Pieces/Merge/piece-1-colored.png")
    ]
    internal let frames:[CGRect] = [
        CGRect(x: 50, y: 230.625, width: 68.29, height: 88.75),
        CGRect(x: 425, y: 230.625, width: 68.25, height: 88.66)
    ]
    
    // MARK: - Sound Effects
    
    internal var switchPlayer:AVAudioPlayer = AVAudioPlayer()
    internal var rotatePlayer:AVAudioPlayer = AVAudioPlayer()
    
    // MARK: - ViewController Lifecycle methods
    
    override public func viewDidLoad() {
        sceneView.scene = self.scene
        self.view.addSubview(self.sceneView)
        
        setupScene(self.scene, withView: self.sceneView)
        self.levelSetup()
        
        do {
            /*
             "Light Switch" by GOSFX; "Whip 01" by erkanozans
             
             Source(s): https://freesound.org/people/GOSFX/sounds/324334/ (CC BY 3.0) & https://freesound.org/people/erkanozan/sounds/51755/ (CC0 1.0)
             */
            let switchAudioPath = Bundle.main.path(forResource: "Sound/light-switch", ofType: "mp3")
            let rotateAudioPath = Bundle.main.path(forResource: "Sound/whip", ofType: "wav")
            
            try self.switchPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: switchAudioPath!) as URL)
            try self.rotatePlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: rotateAudioPath!) as URL)
        } catch {
            print("Couldn't find background music file.")
        }
        
        self.switchPlayer.volume = 1.5
        self.rotatePlayer.volume = 0.3
        self.switchPlayer.prepareToPlay()
        self.rotatePlayer.prepareToPlay()
        
        super.viewDidLoad()
    }
    
    // MARK: - Level Delegate methods
    
    internal func levelSetup() {
        // MARK: Adding objective description
        addHeader(toView: self.view)
        let _ = addDescription(toView: self.view, withText: "Combine or cause to form a single entity.")
        addLevelNumber(toView: self.view, withText: "1")
        
        // MARK: Adding objective shape
        let objective = UIImageView(image: UIImage(named:"Images/Pieces/Merge/objective.png"))
        objective.frame = CGRect(x: 225, y: 225, width: 91, height: 100)
        self.view.addSubview(objective)
        
        // MARK: Adding pieces
        for imageInfo in zip(self.images, self.frames) {
            let piece = MovableView(image: imageInfo.0!)
            piece.frame = imageInfo.1
            piece.center.y = objective.center.y
            
            piece.objectiveSize = 0
            piece.currentSize = 0
            
            // MARK: Configuring objective
            if imageInfo.0 == self.images[0] {
                piece.objectiveVertex = CGPoint(x: objective.frame.maxX, y: objective.frame.minY)
                piece.objectiveCenter = CGPoint(x: 281.73, y: 269.44)
                piece.objectiveAngle = 3
                piece.currentAngle = 1
                piece.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            } else {
                piece.objectiveVertex = CGPoint(x: objective.frame.minX, y: objective.frame.maxY)
                piece.objectiveCenter = CGPoint(x: 259.27, y: 280.57)
                piece.objectiveAngle = 3
                piece.currentAngle = 3
                piece.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
            }
            
            piece.levelDelegate = self
            self.levelPieces.append(piece)
            self.view.addSubview(piece)
        }
        
        let viewButton = addToolButton(withImageNamed: "Images/Icons/view.png", andInsets: UIEdgeInsets(top: 10, left: 11.21, bottom: 10, right: 11.21), toX: 160.0)
        //scaleButton.addTarget(self, action: #selector(self.didPressScale(_:)), for: .touchUpInside)
        self.view.addSubview(viewButton)
        
        let colorizeButton = addToolButton(withImageNamed: "Images/Icons/colorize.png", andInsets: UIEdgeInsets(top: 12, left: 13, bottom: 12, right: 13), toX: 220.0)
        colorizeButton.addTarget(self, action: #selector(self.didPressColorize(_:)), for: .touchUpInside)
        self.view.addSubview(colorizeButton)
        
        let rotateButton = addToolButton(withImageNamed: "Images/Icons/rotate.png", andInsets: UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10), toX: 280.0)
        rotateButton.addTarget(self, action: #selector(self.didPressRotate(_:)), for: .touchUpInside)
        self.view.addSubview(rotateButton)
        
        let scaleButton = addToolButton(withImageNamed: "Images/Icons/scale.png", andInsets: UIEdgeInsets(top: 14, left: 9, bottom: 14, right: 9), toX: 340.0)
        scaleButton.addTarget(self, action: #selector(self.didPressScale(_:)), for: .touchUpInside)
        self.view.addSubview(scaleButton)
    }
    
    internal func levelTeardown() {
        // MARK: Present next level
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            let connection = DepthController()
            connection.preferredContentSize = CGSize(width:550, height:450)
            self.present(connection, animated: true)
        })
    }
    
    internal func didFit(piece: MovableView) {
        self.updateProgress(withValue: (100.0/Double(self.images.count))/100.0)
    }
    
    // MARK: - Button interaction methods
    
    @objc private func didPressColorize(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        
        let imagesToColor:[UIImage?]
        if sender.tag == 0 {
            imagesToColor = self.coloredImages
            sender.tag = 1
            sender.setImage(UIImage(named: "Images/Icons/colorize-remove.png"), for: .normal)
        } else {
            imagesToColor = self.images
            sender.tag = 0
            sender.setImage(UIImage(named: "Images/Icons/colorize.png"), for: .normal)
        }
        
        self.switchPlayer.play()
        for piece in zip(self.levelPieces, imagesToColor) {
            UIView.animate(withDuration: 0.5, animations: {
                piece.0.alpha = 0
            })
            piece.0.image = piece.1
            UIView.animate(withDuration: 0.5, animations: {
                piece.0.alpha = 1
            }, completion: { (sucess: Bool) in
                sender.isUserInteractionEnabled = true
            })
        }
    }
    
    @objc private func didPressRotate(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        self.rotatePlayer.play()
        for piece in self.levelPieces {
            
            let nextAngle:Int
            if piece.currentAngle == 3 {
                nextAngle = 0
            } else {
                nextAngle = piece.currentAngle + 1
                
            }
            
            UIView.animate(withDuration: 0.25, animations: {
                if piece.isUserInteractionEnabled {
                    piece.transform = CGAffineTransform(rotationAngle: CGFloat(angleForNumber[nextAngle]!))
                }
            }, completion: { (sucess: Bool) in
                sender.isUserInteractionEnabled = true
                piece.currentAngle = nextAngle
            })
        }
    }
    
    @objc private func didPressScale(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        // PLAY SOUND EFFECT
        for piece in self.levelPieces {
            let nextSize:Int
            if piece.currentSize == 1 {
                nextSize = 0
            } else {
                nextSize = 1
            }
            
            UIView.animate(withDuration: 0.25, animations: {
                if piece.isUserInteractionEnabled {
                    if piece.currentSize == 0 {
                        piece.frame = CGRect(x: piece.frame.minX, y: piece.frame.minY, width: piece.frame.width/2.127, height: piece.frame.height/2.12855)
                    } else {
                        piece.frame = CGRect(x: piece.frame.minX, y: piece.frame.minY, width: piece.frame.width*2.127, height: piece.frame.height*2.12855)
                    }
                }
            }, completion: { (success: Bool) in
                sender.isUserInteractionEnabled = true
                piece.currentSize = nextSize
            })
        }
    }
    
    // MARK: - Progress update methods
    
    private func updateProgress(withValue: Double) {
        // MARK: Calculating radians
        self.progressPercentage += withValue
        let degrees = 360.0 * self.progressPercentage
        let radians = degrees * Double.pi / 180.0
        
        // MARK: Adding circular progress
        let progressView = CircularProgressView()
        progressView.endAngle = CGFloat(radians)
        progressView.frame = CGRect(x: 277.5, y: 147.5, width: 100.0, height: 100.0)
        progressView.alpha = 0
        self.view.addSubview(progressView)
        
        UIView.animate(withDuration: 0.25, animations: {
            progressView.alpha = 1
        })
        
        // MARK: Check for level ending
        if self.progressPercentage == 1.0 {
            self.levelTeardown()
        }
    }
}
