import Foundation
import Display
import SwiftSignalKit

private let impactTime: Double = 0.4

final class PeachHaptic: EmojiHaptic {
    private var hapticFeedback = HapticFeedback()
    private var timer: SwiftSignalKit.Timer?
    private var time: Double = 0.0
    var enabled: Bool = false {
        didSet {
            if !self.enabled {
                self.reset()
            }
        }
    }
    
    var active: Bool {
        return self.timer != nil
    }
    
    private func reset() {
        if let timer = self.timer {
            self.time = 0.0
            timer.invalidate()
            self.timer = nil
        }
    }
    
    private func beat(time: Double) {
        let epsilon = 0.1
        if fabs(impactTime - time) < epsilon {
            self.hapticFeedback.impact(.heavy)
        }
    }
    
    func start(time: Double) {
        self.hapticFeedback.prepareImpact()
        
        if time > impactTime {
            return
        }

        let startTime: Double = 0.0
        
        let block = { [weak self] in
            guard let strongSelf = self, strongSelf.enabled else {
                return
            }
            
            strongSelf.time = startTime
            strongSelf.beat(time: startTime)
            strongSelf.timer = SwiftSignalKit.Timer(timeout: 0.2, repeat: true, completion: { [weak self] in
                guard let strongSelf = self, strongSelf.enabled else {
                    return
                }
                strongSelf.time += 0.2
                strongSelf.beat(time: strongSelf.time)
                
                if strongSelf.time > impactTime {
                    strongSelf.reset()
                    strongSelf.time = 0.0
                    strongSelf.timer?.invalidate()
                    strongSelf.timer = nil
                }
            }, queue: Queue.mainQueue())
            strongSelf.timer?.start()
        }
        
        block()
    }
}
