//
//  File.swift
//  
//
//  Created by John Knowles on 7/13/24.
//

import Foundation

extension OMPaint {
    struct StrokePoint {
        let point: OMPaint.Point
        var vector: OMPaint.Point
        // velocity
        let distance: Double
        let runningLength: Double
    }
}
