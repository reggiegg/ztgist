//
//  ViewController.swift
//  ztg.ist
//
//  Created by Reggie Gillett on 2018-02-01.
//  Copyright © 2018 ztg.ist. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var drawButton: UIButton!
    var colorPicker: ChromaColorPicker!
    var previousPoint: SCNVector3?
    var lineColours = [UIColor.magenta, UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.cyan, UIColor.blue, UIColor.purple]
    var colourIndex = 0
    
    var currentColour : UIColor = UIColor.magenta
    
    var maxCylinderDiameter : CGFloat = 0.01
    var touchForce : CGFloat = 1
    var sceneTouched = false
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/world.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        /* Calculate relative size and origin in bounds */
        let pickerSize = CGSize(width: view.bounds.width*0.5, height: view.bounds.width*0.5)
        let pickerOrigin = CGPoint(x: view.bounds.minX, y: view.bounds.minY+22)
        
        /* Create Color Picker */
        colorPicker = ChromaColorPicker(frame: CGRect(origin: pickerOrigin, size: pickerSize))
        colorPicker.delegate = self
        
        /* Customize the view (optional) */
        colorPicker.padding = 10
        colorPicker.stroke = 10 //stroke of the rainbow circle
        colorPicker.currentAngle = Float.pi
        
        
        /* Customize for grayscale (optional) */
        colorPicker.supportsShadesOfGray = true // false by default
        //colorPicker.colorToggleButton.grayColorGradientLayer.colors = [UIColor.lightGray.cgColor, UIColor.gray.cgColor] // You can also override gradient colors
        
        
        colorPicker.hexLabel.textColor = UIColor.white
        colorPicker.addButton.isHidden = true
        /* Don't want an element like the shade slider? Just hide it: */
        //colorPicker.shadeSlider.hidden = true
        
        self.view.addSubview(colorPicker)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    
    // MARK: - ARSCNViewDelegate
//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        DispatchQueue.main.async {
//            self.buttonHighlighted = self.drawButton.isHighlighted
//
//        }
//    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        super.touchesMoved(touches, with: event)
        
        let touch: UITouch = touches.first as UITouch!
        
        if (touch.view == sceneView){
            self.touchForce = touch.force / touch.maximumPossibleForce
            self.sceneTouched = true
        }else{
            print("touchesMoved | This is not an ARSCNView")
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        self.sceneTouched = false

    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        guard let pointOfView = sceneView.pointOfView else { return }
        
        let mat = pointOfView.transform
        let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
        let currentPosition = pointOfView.position + (dir * 0.1)
        
        if sceneTouched {
            if colourIndex < lineColours.count - 1 {
                self.colourIndex += 1
            } else {
                colourIndex = 0
            }
            if let previousPoint = previousPoint {
                let radius = self.touchForce * self.maxCylinderDiameter
                let lineNode = cylinderLineFrom(vector: previousPoint, toVector: currentPosition, radius : radius)
//                let lineNode = SCNNode(geometry: line)
//                lineNode.geometry?.firstMaterial?.diffuse.contents = lineColor
                sceneView.scene.rootNode.addChildNode(lineNode)
            }
        }
        previousPoint = currentPosition
        glLineWidth(20)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func cylinderLineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3, radius : CGFloat) -> SCNNode {
      
//        let element = SCNNode().buildLineInTwoPointsWithRotation(from: vector1, to: vector2, radius: radius, color: self.lineColours[self.colourIndex])
        
        let element = SCNNode().buildLineInTwoPointsWithRotation(from: vector1, to: vector2, radius: radius, color: colorPicker.currentColor)
        
        return element
        
    }
}
extension ViewController: ChromaColorPickerDelegate{
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        print(color)
        currentColour = color
    }
}
