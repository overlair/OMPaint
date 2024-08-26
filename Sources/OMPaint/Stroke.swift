//
//  File.swift
//  
//
//  Created by John Knowles on 7/13/24.
//

import Foundation


extension OMPaint {
    struct Stroke: Equatable {
        var size: Double = 12
        var thinning: Double = 0.3
        var smoothing: Double = 0.8
        var streamline: Double = 0.2
        var taperStart: Double = 0.3
        var taperEnd: Double = 0.3
        var capStart: Bool = true
        var capEnd: Bool = true
        var simulatePressure: Bool = true
    }
}
