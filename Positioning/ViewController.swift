//
//  ViewController.swift
//  Positioning
//
//  Created by Morten Just on 5/20/21.
//

import SceneKit
import AVFoundation

class ViewController: UIViewController, AVAudio3DMixing {
    var sourceMode: AVAudio3DMixingSourceMode = .pointSource
    
    var pointSourceInHeadMode: AVAudio3DMixingPointSourceInHeadMode = .mono
    
    @IBOutlet weak var sceneView: SCNView!
    
    // YOU NEED MONO AUDIO !!!

    var renderingAlgorithm = AVAudio3DMixingRenderingAlgorithm.sphericalHead
    var rate: Float = 0.0
    var reverbBlend: Float = 0.5
    var obstruction: Float = -100.0
    var occlusion: Float = -100.0
    var position: AVAudio3DPoint = AVAudio3DPoint(x: 0, y: 0, z: -100)

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = SCNScene()

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 200
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 40)
        scene.rootNode.addChildNode(cameraNode)

//        let sceneView = self.view as! SCNView
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.black
        sceneView.autoenablesDefaultLighting = true

        let path = Bundle.main.path(forResource: "steve01", ofType: "wav")
        let url = URL(fileURLWithPath: path!)
        let source = SCNAudioSource(url: url)!
        source.loops = true
        source.shouldStream = false  // MUST BE FALSE
        source.isPositional = true
        source.load()

        let player = SCNAudioPlayer(source: source)
        let audioNode = SCNNode()

        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.2)
        let boxNode = SCNNode(geometry: box)

        boxNode.addChildNode(audioNode)
        scene.rootNode.addChildNode(boxNode)

        audioNode.addAudioPlayer(player)
        let avm = player.audioNode as? AVAudioEnvironmentNode
        avm?.reverbBlend = reverbBlend
        avm?.renderingAlgorithm = renderingAlgorithm
        avm?.occlusion = occlusion
        avm?.obstruction = obstruction

        sceneView.allowsCameraControl = true
        
        
        let up = SCNAction.moveBy(x: 0, y: 0, z: 70, duration: 5)
        let down = SCNAction.moveBy(x: 0, y: 0, z: -70 , duration: 5)
        let sequence = SCNAction.sequence([up, down])
        let loop = SCNAction.repeatForever(sequence)
        boxNode.runAction(loop)

        avm?.position = AVAudio3DPoint(
                 x: Float(boxNode.position.x),
                 y: Float(boxNode.position.y),
                 z: Float(boxNode.position.z))
    }
}
