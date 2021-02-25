/*: [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
# Bridge
- - - - - - - - - -
 ![Bridge Diagram](Bridge_Diagram.png)
 
 The bridge pattern is a design pattern used in software engineering that is meant to "decouple an abstraction from its implementation so that the two can vary independently", introduced by the Gang of Four. The bridge uses encapsulation, aggregation, and can use inheritance to separate responsibilities into different classes.
 ## Code Example
*/
import UIKit

// MARK: - Abstraction

protocol View {
    func drawOn(_ window: Window)
}

protocol Window {
    var imp: WindowImp { get }
    var contents: View { get }
    
    init(contents: View, imp: WindowImp)
    
    func drawContents()
    func open()
    func close()
    func iconify()
    func deiconify()
    
    func setSize(_ size: CGSize)
    func raise()
    func lower()
    
    func drawLine(from start: CGPoint, to finish: CGPoint)
    func drawRect(_ rect: CGRect)
    func drawPolygon(points: [CGPoint])
    func drawText(_ text: String, at point: CGPoint)
}

// MARK: - Implementator

protocol WindowImp {
    func impTop()
    func impBottom()
    func impSetSize(_ size: CGSize)
    
    func deviceRect(_ rect: CGRect)
    func deviceText(_ text: String, at point: CGPoint)
    func deviceBitmap(_ name: String, at point: CGPoint)
}

class WindowSystemFactory {
    static var instance: WindowSystemFactory = .init()
    init() { }
    
    func makeWindowImp() -> WindowImp { XWindowImp() }
    func makeIconWindowImp() -> WindowImp { IconWindowImp() }
}

// MARK: - Refined abstractions

class ApplicationWindow: Window {
    var imp: WindowImp
    var contents: View
    
    required init(contents: View,
                  imp: WindowImp = WindowSystemFactory.instance.makeWindowImp()) {
        self.contents = contents
        self.imp = imp
    }
    
    func drawContents() {
        contents.drawOn(self)
    }
    
    func open() { }
    func close() { }
    func iconify() { }
    func deiconify() { }
    
    func setSize(_ size: CGSize) { }
    func raise() { }
    func lower() { }
    
    func drawLine(from start: CGPoint, to finish: CGPoint) { }
    func drawRect(_ rect: CGRect) { }
    func drawPolygon(points: [CGPoint]) { }
    func drawText(_ text: String, at point: CGPoint) { }
}

class IconWindow: Window {
    private var bitmapName: String = ""
    
    var imp: WindowImp
    var contents: View
    
    convenience init(_ bitmapName: String, contents: View, imp: WindowImp = WindowSystemFactory.instance.makeIconWindowImp()) {
        self.init(contents: contents, imp: imp)
        self.bitmapName = bitmapName
    }
    
    required init(contents: View, imp: WindowImp) {
        self.contents = contents
        self.imp = imp
    }
    
    func drawContents() {
        imp.deviceBitmap(bitmapName, at: .zero)
    }
    
    func open() { }
    func close() { }
    func iconify() { }
    func deiconify() { }
    
    func setSize(_ size: CGSize) { }
    func raise() { }
    func lower() { }
    
    func drawLine(from start: CGPoint, to finish: CGPoint) { }
    
    func drawRect(_ rect: CGRect) {
        imp.deviceRect(rect)
    }
    
    func drawPolygon(points: [CGPoint]) { }
    func drawText(_ text: String, at point: CGPoint) { }
}

// MARK: - Concrete implementators

class XWindowImp: WindowImp {
    func impTop() { }
    func impBottom() { }
    func impSetSize(_ size: CGSize) { }
    func deviceRect(_ rect: CGRect) { }
    func deviceText(_ text: String, at point: CGPoint) { }
    func deviceBitmap(_ name: String, at point: CGPoint) { }
}

class PMWindowImp: WindowImp {
    func impTop() { }
    func impBottom() { }
    func impSetSize(_ size: CGSize) { }
    func deviceRect(_ rect: CGRect) { }
    func deviceText(_ text: String, at point: CGPoint) { }
    func deviceBitmap(_ name: String, at point: CGPoint) { }
}

class IconWindowImp: WindowImp {
    func impTop() { }
    func impBottom() { }
    func impSetSize(_ size: CGSize) { }
    func deviceRect(_ rect: CGRect) { }
    func deviceText(_ text: String, at point: CGPoint) { }
    func deviceBitmap(_ name: String, at point: CGPoint) { }
}
