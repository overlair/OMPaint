//
//  File.swift
//  
//
//  Created by John Knowles on 7/13/24.
//

import Foundation
//import SpriteKit
import CoreGraphics
import UIKit

extension Array where Element == OMPaint.Point {}

extension Array where Element == CGPoint {
    
    func getFreehandPath(for stroke: OMPaint.Stroke = .init()) -> CGPath {
        var points:  [OMPaint.Point] = []
        for point in self {
            points.append(OMPaint.Point(x: point.x, y: point.y))
        }
//        return points.getStrokePath(stroke: stroke)
        return points.getBezierPath()
    }
    
    func getLinePath() -> CGPath {
        let path = CGMutablePath()
        path.addLines(between: self)
        return path
    }
    
    func getBezierPath() -> CGPath {
        guard self.count > 0 else { return CGPath.init(rect: .zero, transform: nil) }
        guard self.count > 20 else { return getLinePath() }
        let path = UIBezierPath()
                
        var first = true
        var prevPoint: CGPoint = self[0]
        path.move(to: .zero)
        
        for point in self {
            let midPoint = CGPoint(
                x: (point.x + prevPoint.x) / 2,
                y: (point.y + prevPoint.y) / 2
            )
            
            if first {
                first = false
                path.addLine(to: midPoint)
            } else {
                path.addQuadCurve(to: midPoint, controlPoint: prevPoint)

            }
            prevPoint = point
        }

        if let last = self.last {
            path.addLine(to: last)
        }
        return path.cgPath
    }
    
}
extension Array where Element == OMPaint.Point {
    func getFreehandPath() -> CGPath {
        let path = CGMutablePath()
        let points = self.map { CGPoint(x: $0.x, y: $0.y)}
        path.addLines(between: points)
        return path
    }
    
    
    func getBezierPath() -> CGPath {
        guard self.count > 0 else { return CGPath.init(rect: .zero, transform: nil) }
        let path = UIBezierPath()
        
        let points = self.map { CGPoint(x: $0.x, y: $0.y)}
        
        var first = true
        var prevPoint: CGPoint = points[0]
        path.move(to: .zero)
        for point in points {
            let midPoint = CGPoint(
                x: (point.x + prevPoint.x) / 2,
                y: (point.y + prevPoint.y) / 2
            )
            
            if first {
                first = false
                path.addLine(to: midPoint)
            } else {
                path.addQuadCurve(to: midPoint, controlPoint: prevPoint)

            }
            prevPoint = point
        }

        if let last = points.last {
            path.addLine(to: last)
        }
        return path.cgPath
    }
    
    func getBezierPath2() -> CGPath {
        guard self.count > 0 else { return CGPath.init(rect: .zero, transform: nil) }
        let path = UIBezierPath()
        
        let points = self.map { CGPoint(x: $0.x, y: $0.y)}
        
        var first = true
        var prevPoint: CGPoint = points[0]
        var prevPoints: [CGPoint] = [prevPoint]
        path.move(to: .zero)
        for point in points {
            let midPoint = (point + prevPoint) / 2.0
            
            if first {
                first = false
                path.addLine(to: midPoint)
            } else {
                
                
                let cp1 =  midPoint + (2.0/3.0) * (prevPoint - midPoint)
                let cp2 = point + (2.0/3.0) * (prevPoint - point)
                path.addCurve(to: midPoint, controlPoint1: cp1, controlPoint2: cp2)

            }
            
            
            
            prevPoints.append(point)
            prevPoint = point
            
            while prevPoints.count > 3 {
                _ = prevPoints.removeFirst()
            }
        }

        if let last = points.last {
            path.addLine(to: last)
        }
        return path.cgPath
    }
    
    
    func createPathFromStroke() -> CGPath? {
        guard !self.isEmpty, let first = self.first else { return nil }
        let path = CGMutablePath()
        let _path = UIBezierPath()
        let points = self.map { CGPoint(x: $0.x, y: $0.y)}
        //var points: [CGPoint] = []
        
//        var prev = first
//        for point in self {
//            let step = 1.0 / 10
//            for t in stride(from: 0.0, through: 1.0, by: step) {
//                let tmp = prev.lrp(point, t: t)
//                points.append(CGPoint(x: tmp.x, y: tmp.y))
//            }
//            prev = point
//        }
        //path.move(to: CGPoint(x:first.x, y: first.y))
        _path.move(to: CGPoint(x:first.x, y: first.y))

//
//        var p1 = CGPoint(x:first.x, y: first.y)
//        var p2: CGPoint
//        for i in 0..<self.count - 2 {
//            p2 = points[i+1]
//            let midPoint = CGPoint(x: (p1.x + p2.x)/2.0, y: (p1.y + p2.y)/2.0)
//            path.addQuadCurve(to: p1, control: midPoint)
//            p1 = p2
//        }
//
        for p in points {
            _path.addLine(to: p)
        }
        //path.addLines(between: points)
    
       // path.closeSubpath()
        _path.lineJoinStyle = .round
        return _path.cgPath
    }
}



extension Array where Element == CGPoint {
    func avg() -> CGPoint {
        var temp: CGPoint = .zero
        for point in self {
            temp = temp + point
        }
        return temp / self.count
    }
    
    func getBezierPath2() -> CGPath {
        guard self.count > 0 else { return CGPath.init(rect: .zero, transform: nil) }
//        let path = UIBezierPath()
        
        let path2 = CGMutablePath()
        
        var first = true
        var prevPoint: CGPoint = self[0]
        var prevPoints: [CGPoint] = [prevPoint]
        //        path.move(to: .zero)
        path2.move(to: prevPoint)
        for point in self {
            let midPoint = (point + prevPoint) / 2.0
            if first {
                first = false
                path2.addLine(to: midPoint)
            } else {
                let cp1 =  midPoint + (2.0/3.0) * (prevPoint - midPoint)
                let cp2 = point + (2.0/3.0) * (prevPoint - point)
                //                path.addCurve(to: midPoint, controlPoint1: cp1, controlPoint2: cp2)
                path2.addCurve(to: midPoint, control1: cp1, control2: cp2)
            }
            prevPoint = point
        }
        
        for point in self.reversed() {
            let midPoint = (point + prevPoint) / 2.0
            if first {
                first = false
                path2.addLine(to: midPoint)
            } else {
                let cp1 =  midPoint + (2.0/3.0) * (prevPoint - midPoint)
                let cp2 = point + (2.0/3.0) * (prevPoint - point)
                //                path.addCurve(to: midPoint, controlPoint1: cp1, controlPoint2: cp2)
                path2.addCurve(to: midPoint, control1: cp1, control2: cp2)
            }
            prevPoint = point
        }
        
        if let last = self.last {
            path2.addLine(to: last)
        }
        return path2
    }
}

extension CGPoint {
//    static func +(_ lhs: CGPoint, rhs: CGPoint) -> CGPoint {
//        CGPoint(x: lhs.x + rhs.x , y: lhs.y + rhs.y)
//    }
//
//
    static func /(_ lhs: CGPoint, rhs: Int) -> CGPoint {
        let rhs =  CGFloat(rhs)
        return CGPoint(x: lhs.x / rhs , y: lhs.y / rhs)
    }
}
