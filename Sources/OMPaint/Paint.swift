//
//  File.swift
//  
//
//  Created by John Knowles on 7/13/24.
//

import Foundation
import SwiftUI
public extension [CGPoint] {

    func getAngle(start: CGPoint, end: CGPoint) -> Angle {
        
        
        let originX = end.x - start.x
        let originY = end.y - start.y
        
        var radian = atan2(originY, originX)
//
        return .radians(radian)
    }
    
 
    public func getPath(with size: CGFloat = 5) -> CGPath {
        func getSegments(_ points: [CGPoint])  -> [LineSegment] {
            var segments: [LineSegment] = []
            var current: CGPoint? = nil

            for point in points {
                if let current = current {
                    var angle = Angle(from: current, to: point)
                    angle = angle.clamp()
                    segments.append(LineSegment(start: current,
                                                end: point,
                                                angle: angle))

                    
                }
                
                current = point
            }
            return segments
        }
        
        
        func getPerpendiculars(_ segments: [LineSegment], size: CGFloat)  -> [LineSegment] {
            var perpendiculars: [LineSegment] = []
            
            for segment in segments {
                perpendiculars.append(segment.getPerpendicular(size: size))
            }
            return perpendiculars
        }
        
        func getLerps(_ points: [CGPoint])  -> [CGPoint] {
            var newPoints: [CGPoint] = []
            var previousPoint: CGPoint? = nil
            
            for point in points {
                if let previousPoint = previousPoint {
                    let distance = previousPoint.distance(to: point)
                    print(distance)
//                    let lerpPoint = previousPoint.point.lerping(to: point.point, at: 0.9)
//                    let lerpVelocity = previousPoint.velocity.lerping(to: point.velocity, at: 0.9)
//                    newPoints.append(.init(point: lerpPoint, velocity: lerpVelocity))
                }
                
                newPoints.append(point)

                previousPoint = point
            }
            return newPoints
        }
        
        func getSegments_v2(_ points: [CGPoint], with radius: CGFloat)  -> [LineSegment] {
            var segments: [LineSegment] = []
            
            var previousAngle: Angle? = nil
            var previousPoint: CGPoint? = nil
            var previousRadius: CGFloat? = nil
            
//            let scalar: CGFloat = 5.0

            for point in points {
//                let adjustedVelocity =  tanh(point.velocity * 0.001) - 0.5

//                var point = point.point
                
                if let previous = previousPoint {
//                    point = previous.lerping(to: point, at: 0.025)
                    let angle = Angle(from: previous, to: point)
                    
                    var perpindicular = angle.perpendicular()
//                    if let previous = previousAngle {
//                        perpindicular = previous.lerping(to: perpindicular, at: 0.98)
//                    }
                    previousAngle = perpindicular
                    
                    
                    
//                    var radius: CGFloat = 2 //- (0.1 * brush.size  * adjustedVelocity)
                   
//                    if let previous = previousRadius {
//                        radius = lerp(previous, radius, 0.2)
//                    }
                    
                    previousRadius = radius
                    
                    
                    let start = point.getPointOnCircle(radius: -radius, radian: perpindicular.radians)
                    let end = point.getPointOnCircle(radius: radius, radian: perpindicular.radians)
                    
                    segments.append(LineSegment(start: start,
                                                end: end,
                                                angle: perpindicular))
                }
                
                previousPoint = point
            }
            return segments
        }
        
        
        
        
        
//        let segments = getSegments(points)
//        let perps = getPerpendiculars(segments,
//                                      size: 80)
//
        
        var potential: [CGPoint] = []
//        if let potentialPoints = potentialPoints {
//            potential = potentialPoints
//        }
//        let completePoints = points + potential
//        let lerps = getLerps(completePoints)
        let perps = getSegments_v2(self, with: size)
        
        let path = CGMutablePath()
        
        
        
        
        guard let first = perps.first else { return path }
       
        var prevPoint: CGPoint? = nil
        path.move(to: first.end)
        
        for segment in perps {
            if let prevPoint = prevPoint {
                let midPoint = CGPoint(
                    x: (segment.start.x + prevPoint.x) / 2.0,
                    y: (segment.start.y + prevPoint.y ) / 2.0
                )
                path.addQuadCurve(to: midPoint,
                                  control: prevPoint)
            }
            prevPoint = segment.start
            
        }
        
        for segment in perps.reversed() {
            if let prevPoint = prevPoint {
                let midPoint = CGPoint(
                    x: (segment.end.x + prevPoint.x) / 2.0,
                    y: (segment.end.y + prevPoint.y) / 2.0
                )
                
                path.addQuadCurve(to: midPoint,
                                  control: prevPoint)
            }
            
            prevPoint = segment.end
            
        }
        
        path.closeSubpath()
        
        return path
    }
    
}

extension Angle {
    init(from p1: CGPoint, to p2: CGPoint) {
        let originX = p2.x - p1.x
        let originY = p2.y - p1.y
        self.init(radians: atan2(originY, originX))
    }
    
    func clamp() -> Angle {
        var radian = self.radians
        while radian < 0 {
            radian += CGFloat(2 * Double.pi)
        }

        while radian > CGFloat(2 * Double.pi) {
            radian -= CGFloat(2 * Double.pi)
        }
        return .radians(radian)

    }
    
    
    func perpendicular() -> Angle {
        return Angle(radians: self.radians + (Double.pi / 2.0))

//        if self.radians > Double.pi {
//            return Angle(radians: self.radians - (Double.pi / 2.0))
//        } else {
//            return Angle(radians: self.radians + (Double.pi / 2.0))
//        }
    }
    
    func lerping(to angle: Angle, at rate: CGFloat) -> Angle{
        
        let lerped = self.radians + short_angle_dist(from: self.radians, to: angle.radians) * rate
//        let lerped =  short_angle_dist(from: self.radians, to: angle.radians) * rate
        return Angle(radians: lerped)
//        var a = self.radians
//        var b = angle.radians
//        if abs(b - a) >= Double.pi {
//            if a > b {
//                a = normalize_angle(a) - 2.0 * Double.pi
//
//            } else {
//                b = normalize_angle(b) - 2.0 * Double.pi
//            }
//        }
//
//        let lerped = lerp(a, b, rate)
//
//        return Angle(radians: lerped)
//
//        func normalize_angle(_ x: Double) -> Double {
//            return fmod(x + Double.pi, 2.0 * Double.pi) - Double.pi
//        }
//
//        func lerp_angle(from, to, weight):
//            return from + short_angle_dist(from, to) * weight

        func short_angle_dist(from start: Double, to end: Double) -> Double {
            let twoPi = Double.pi * 2
            let threePi = Double.pi * 3
            let difference = end - start
            let differencePrime = difference.truncatingRemainder(dividingBy: twoPi) + threePi
            
            let shortest_angle = differencePrime.truncatingRemainder(dividingBy: twoPi)
             return shortest_angle  - Double.pi // * amount
//            var max_angle = Double.pi * 2
//            var difference = fmod(to - from, max_angle)
//            return fmod(2 * difference, max_angle) - difference
        }
    }
}
struct LineSegment: Equatable {
    let id = UUID()
    let start: CGPoint
    let end: CGPoint
    let angle: Angle
    
    func getPerpendicular(size: CGFloat,
                          velocity: CGFloat = 1) -> LineSegment {
        let scalar: CGFloat = 3.0
        
        var perpAngle = angle.radians - (Double.pi / 2.0)
        var startAngle = Angle(radians: perpAngle).clamp().radians
        var endAngle = Angle(radians: startAngle + Double.pi).clamp().radians
  
        let radius = size
        let midPoint = CGPoint(x: (start.x + end.x) / 2.0,
                               y:  (start.y + end.y) / 2.0)
        
        let start = midPoint.getPointOnCircle(radius:  radius, radian: startAngle)
        let end = midPoint.getPointOnCircle(radius: -radius, radian: startAngle)
        
        return LineSegment(start: start,
                           end: end,
                           angle: .radians(startAngle))
    }
    
}




private let places: Int = 6
private let maxIters: Int = 500

public struct CGLine: Equatable {
    let a: CGFloat
    let b: CGFloat
    let c: CGFloat
    let start: CGPoint
    let end: CGPoint
    init(start: CGPoint, end: CGPoint) {
        var a = start.y - end.y
        var b = end.x - start.x
        var c = start.x * end.y - end.x * start.y
        let distance = sqrt(a * a + b * b)
        if distance != 0 {
            a /= distance
            b /= distance
            c /= distance
        }
        else {
            a = 0
            b = 0
            c = 0
        }
        self.a = a
        self.b = b
        self.c = c
        self.start = start
        self.end = end
    }

    func distance(to point: CGPoint) -> CGFloat {
        return a * point.x + b * point.y + c
    }
}

public struct CGSpline: Equatable {
    enum Kind: Int {
        case segment
        case quad
        case cubic
    }

    struct Collinearity: Equatable {
        enum Kind: Int {
            case point
            case horizontal
            case vertical
            case slope
            case curve
        }
        let kind: Kind
        let m: Double
        let b: Double
        init(kind: Kind, m: Double = 0, b: Double = 0) {
            self.kind = kind
            self.m = m
            self.b = b
        }
    }

    let points: [CGPoint]
    let kind: Kind
    let collinearity: Collinearity
    init(kind: Kind, points: [CGPoint]) {
        let count: Int
        switch kind {
        case .segment:
            count = 2
        case .quad:
            count = 3
        case .cubic:
            count = 4
        }
        assert(points.count == count)
        assert(points.count > 0)

        self.kind = kind
        self.points = Array(points.prefix(count))

        let horizontal = points.reduce(true, {$0 && $1.y == points[0].y})
        let vertical = points.reduce(true, {$0 && $1.x == points[0].x})

        if points.count < 2 {
            self.collinearity = Collinearity(kind: .point)
        }
        else if horizontal && vertical {
            self.collinearity = Collinearity(kind: .point)
        }
        else if horizontal {
            self.collinearity = Collinearity(kind: .horizontal)
        }
        else if vertical {
            self.collinearity = Collinearity(kind: .vertical)
        }
        else {
            if points[0].x != points[points.count - 1].x {
                let m = Double((points[0].y - points[points.count - 1].y)/(points[0].x - points[points.count - 1].x))
                let b = Double(points[0].y) - m * Double(points[0].x)
                let tolerance = pow(10.0, -CGFloat(places))
                for point in points {
                    if !point.y.isAlmostEqual(to: CGFloat(m * Double(point.x) + b), tolerance: tolerance) {
                        self.collinearity = Collinearity(kind: .curve)
                        return
                    }
                }
                self.collinearity = Collinearity(kind: .slope, m: m, b: b)
            }
            else {
                self.collinearity = Collinearity(kind: .curve)
            }
        }
    }

    func fatLine() -> (CGLine, CGFloat, CGFloat)? {
        if points.count < 2 {
            return nil
        }
        let line = CGLine(start: points[0], end: points[points.count - 1])
        var minimum: CGFloat = 0
        var maximum: CGFloat = 0

        for point in points.dropFirst().dropLast()  {
            let distance = line.distance(to: point)
            minimum = min(distance, minimum)
            maximum = max(distance, maximum)
        }

        return (line, minimum, maximum)
    }

    func clip(around line: CGLine, minimum: CGFloat, maximum: CGFloat) -> (CGSpline, CGFloat, CGFloat)? {
        if points.count < 3 || line.start == line.end {
            return nil
        }

        let totalLength = zip(points, points.dropFirst()).reduce(0, {$0 + $1.0.distance(to: $1.1)})
        var length: CGFloat = 0
        var distances: [CGPoint] = []
        for i in 0..<points.count {
            if i != 0 {
                length += points[i - 1].distance(to: points[i])
            }
            distances.append(CGPoint(x: length/totalLength, y: line.distance(to: points[i])))

        }

        let distanceSpline = CGSpline(kind: kind, points: distances)
        let minSpline = CGSpline(kind: .segment, points: [
            .init(x: 0, y: minimum),
            .init(x: 1, y: minimum)
        ])
        let maxSpline = CGSpline(kind: .segment, points: [
            .init(x: 0, y: maximum),
            .init(x: 1, y: maximum)
        ])

        let crossPointsMin = distanceSpline.intersections(with: minSpline).map({$0.points[0]}).dropFirst()
        let crossPointsMax = distanceSpline.intersections(with: maxSpline).map({$0.points[0]}).dropFirst()
        let crossPoints = crossPointsMin + crossPointsMax

        guard crossPoints.count > 0 else {
            let hull = convexHull(of: distances)
            if hull.allSatisfy({ $0.y < maximum && $0.y > minimum}) {
                return (self, 0, 1)
            }
            else {
                return nil
            }
        }

        var minX: CGFloat = 1
        var maxX: CGFloat = 0
        for point in crossPoints {
            minX = min(point.x, minX)
            maxX = max(point.x, maxX)
        }


        if minX > 0 {
            if maxX < 1 {
                guard let result = split(at: [minX, maxX])[safe: 1] else {assertionFailure();return nil}
                return (result, minX, maxX)
            }
            else {
                guard let (_, result) = split(at: minX) else {assertionFailure();return nil}
                return (result, minX, 1)
            }
        }
        else {
            if maxX < 1 {
                guard let (result, _) = split(at: maxX) else {assertionFailure();return nil}
                return (result, 0, maxX)
            }
            else {
                return nil
            }
        }
    }
    public func split(at ratios: [CGFloat]) -> [CGSpline] {
        if ratios.count == 0 {
            return []
        }
        if ratios.count == 1 {
            guard let (head, tail) = split(at: ratios[0]) else {return []}
            return [head, tail]
        }

        var spline = self
        var result = [CGSpline]()
        var prevRatio: CGFloat? = nil
        for ratio in ratios {
            if let prevRatio = prevRatio {
                assert(prevRatio <= ratio)

                if prevRatio < ratio {
                    if let (head, tail) = spline.split(at: (ratio - prevRatio) / (1.0 - prevRatio)) {
                        result.append(head)
                        spline = tail
                    }
                }
            }
            else {
                if let (head, tail) = spline.split(at: ratio) {
                    result.append(head)
                    spline = tail
                }
            }
            prevRatio = ratio
        }
        result.append(spline)
        return result
    }
    public func split(at ratio: CGFloat) -> (CGSpline, CGSpline)? {
        guard ratio > 0 && ratio < 1 else {assertionFailure();return nil}

        var result: (CGSpline, CGSpline)?
        switch collinearity.kind {
        case .point:
            result = nil
        case .horizontal:
            fallthrough
        case .vertical:
            fallthrough
        case .slope:
            let p = lerp(
                points[0],
                points[points.count - 1],
                CGFloat(ratio)
            )
            result = (
                CGSpline(kind: .segment, points: [points[0], p]),
                CGSpline(kind: .segment, points: [p, points[points.count - 1]])
            )
        case .curve:
            var localPoints = self.points
            var firstPoints: [CGPoint] = []
            var lastPoints: [CGPoint] = []
            for k in 1..<localPoints.count {
                for i in 0..<(localPoints.count - k) {
                    localPoints[i].x = (1.0 - ratio) * localPoints[i].x + ratio * localPoints[i + 1].x;
                    localPoints[i].y = (1.0 - ratio) * localPoints[i].y + ratio * localPoints[i + 1].y;
                }
                firstPoints.append(localPoints[0])
                lastPoints.append(localPoints[localPoints.count - k - 1])
            }
            result = (
                CGSpline(kind: kind, points: [points[0]] + firstPoints),
                CGSpline(kind: kind, points: lastPoints.reversed() + [points[points.count - 1]])
            )
        }
        return result
    }

    public func intersections(with spline: CGSpline) -> [CGSpline] {
        if points.count < 2 || spline.points.count < 2 {
            return []
        }

        if self == spline {
            return []
        }

        let group = [self, spline].sorted(by: {$0.collinearity.kind.rawValue < $1.collinearity.kind.rawValue})

        if (group[0].collinearity.kind == .point)
            || (group[0].collinearity.kind == .horizontal && group[1].collinearity.kind == .horizontal)
            || (group[0].collinearity.kind == .vertical && group[1].collinearity.kind == .vertical) {
            return []
        }
        else {
            var intersectionPoint: CGPoint? = nil
            if (group[0].collinearity.kind == .horizontal && group[1].collinearity.kind == .vertical) {
                intersectionPoint = CGPoint(x: group[1].points[0].x, y: group[0].points[0].y)
            }
            else if (group[0].collinearity.kind == .horizontal && group[1].collinearity.kind == .slope) {
                let y = Double(group[0].points[0].y)
                let c = group[1].collinearity
                let x = (y - c.b)/c.m
                intersectionPoint = CGPoint(x: x, y: y)
            }
            else if (group[0].collinearity.kind == .vertical && group[1].collinearity.kind == .slope) {
                let x = Double(group[0].points[0].x)
                let c = group[1].collinearity
                let y = x * c.m + c.b
                intersectionPoint = CGPoint(x: x, y: y)
            }
            else if (group[0].collinearity.kind == .slope || group[1].collinearity.kind == .slope) {
                let c = group[0].collinearity
                let oc = group[1].collinearity
                if c.m != oc.m || c.b != oc.b {
                    let x = (oc.b - c.b)/(c.m - oc.m)
                    let y = x * c.m + c.b
                    intersectionPoint = CGPoint(x: x, y: y)
                }
            }

            if let intersectionPoint = intersectionPoint {
                var isOnBothSplines = true

                for s in group {
                    let ad = s.points[0].distance(to: intersectionPoint)
                    let bd = s.points[0].distance(to: s.points[s.points.count - 1])
                    let cd = s.points[s.points.count - 1].distance(to: intersectionPoint)

                    if pow(ad, 2) + pow(bd, 2) < pow(cd, 2) || pow(ad, 2) + pow(cd, 2) > pow(bd, 2) {
                        isOnBothSplines = false
                        break
                    }
                }

                if isOnBothSplines {
                    return [
                        CGSpline(kind: .segment, points: [points[0], intersectionPoint]),
                        CGSpline(kind: .segment, points: [intersectionPoint, points[points.count - 1]])
                    ]
                }
                else {
                    return []
                }
            }
            else {
                if (group[0].collinearity.kind == .horizontal || group[0].collinearity.kind == .vertical && group[1].collinearity.kind == .curve) {
                    let roots: [Double]
                    let l = CGLine(start: group[0].points[0], end: group[0].points[1])
                    let p = group[1].points
                    let ap0 = Double(l.a * p[0].x + l.b * p[0].y + l.c)
                    let ap1 = Double(l.a * p[1].x + l.b * p[1].y + l.c)
                    let ap2 = Double(l.a * p[2].x + l.b * p[2].y + l.c)

                    switch  group[1].kind {
                    case .quad:
                        let a = ap0 - 2.0 * ap1 + ap2
                        let b = -2.0 * ap0 + 2.0 * ap1
                        let c = ap0

                        roots = quadraticSolve(a: a, b: b, c: c)
                    case .cubic:
                        let ap3 = Double(l.a * p[3].x + l.b * p[3].y + l.c)
                        let a = -ap0 + 3.0*ap1 - 3.0*ap2 + ap3
                        let b = 3.0*ap0 - 6.0*ap1 + 3.0*ap2
                        let c = -3.0*ap0 + 3.0*ap1
                        let d = ap0

                        roots = cubicSolve(a: a, b: b, c: c, d: d)
                    case .segment:
                        assertionFailure()
                        return []
                    }

                    var result: [CGSpline] = []
                    let validRoots = roots.filter({$0 >= 0 && $0 <= 1}).sorted()

                    for i in 0..<validRoots.count {
                        guard let (a, c) = group[1].split(at: CGFloat(validRoots[i])) else { assertionFailure();return [] }

                        if i == 0 {
                            result.append(a)
                        }
                        if i == validRoots.count - 1 {
                            result.append(c)
                        }
                        if i < validRoots.count - 1 {
                            guard let b = group[1].split(at: [CGFloat(validRoots[i]), CGFloat(validRoots[i+1])])[safe: 1] else { assertionFailure();return [] }
                            result.append(b)
                        }
                    }

                    // if we are the line
                    if collinearity.kind == .horizontal || collinearity.kind == .vertical {
                        let crossings = [points[0]] + result.map({$0.points[0]}).dropFirst() + [points[1]]
                        return zip(crossings, crossings.dropFirst()).map({a, b in
                            CGSpline(kind: .segment, points: [a, b])
                        })
                    }
                    else {
                        return result
                    }
                }
                else if group[0].collinearity.kind == .curve {
                    let points = crossings(with: spline)
                    return group[0].split(at: points)
                }
                else {
                    assertionFailure()
                    return []
                }
            }
        }
    }

    public func crossings(with spline: CGSpline) -> [CGFloat] {
        return _crossings(with: spline)
    }

    private func _crossings(with spline: CGSpline, count: Int = 0) -> [CGFloat] {
        let length = zip(points, points.dropFirst()).reduce(0, {$0 + $1.0.distance(to: $1.1)})
        if length <= pow(10.0, CGFloat(-places)) {
            return [0]
        }
        if count > 100 {
            return [0]
        }
        guard let (line, minimum, maximum) = spline.fatLine() else {
            return [0]
        }
        guard let (section, minX, maxX) = clip(around: line, minimum: minimum, maximum: maximum) else {
            return [0]
        }
        let result = spline._crossings(with: section, count: count + 1)
        let ratio = maxX - minX
        return result.map { r in
            return minX + r * ratio
        }
    }
}

public extension CGMutablePath {
    func addSpline(spline: CGSpline) {
        let points = spline.points
        move(to: points[0])
        switch spline.kind {
        case .cubic:
            addCurve(to: points[3], control1: points[1], control2: points[2])
        case .quad:
            addQuadCurve(to: points[2], control: points[1])
        case .segment:
            addLine(to: points[1])
        }
    }
}

public extension CGPath {
    var splines: [CGSpline] {
        var origin: CGPoint = .zero
        var prev: CGPoint = .zero
        var result: [CGSpline] = []
        applyWithBlock {
            let elem = $0.pointee
            var elemPointsCount: Int? = nil
            var splineKind: CGSpline.Kind? = nil
            switch elem.type {
            case .moveToPoint:
                origin = elem.points[0]
                prev = origin
            case .addLineToPoint:
                elemPointsCount = 1
                splineKind = .segment
            case .addQuadCurveToPoint:
                elemPointsCount = 2
                splineKind = .quad
            case .addCurveToPoint:
                elemPointsCount = 3
                splineKind = .cubic
            case .closeSubpath:
                let spline = CGSpline(kind: .segment, points: [prev, origin])
                result.append(spline)
                prev = origin
            @unknown default:
                break
            }

            if let kind = splineKind, let count = elemPointsCount {
                let points = Array(UnsafeBufferPointer(start: elem.points, count: count))
                let spline = CGSpline(kind: kind, points: [prev] + points)
                result.append(spline)
            }

            if let count = elemPointsCount {
                prev = elem.points[count - 1]
            }
        }
        return result
    }

    func intersects(with path: CGPath) -> Bool {
        for spline in splines {
            for otherSpline in path.splines {
                var intersections = spline.crossings(with: otherSpline)
                if intersections.count > 1  { return true }
            }
        }
        return false
    }
    
    
    func intersect(with path: CGPath) -> [CGPath] {
        var result = [CGMutablePath()]
        for spline in splines {
            var hasIntersections = false
            for otherSpline in path.splines {
                var intersections = spline.intersections(with: otherSpline)
                if intersections.count > 1 {
                    let first = intersections.removeFirst()
                    result[result.count - 1].addSpline(spline: first)
                    for intersection in intersections {
                        let newPath = CGMutablePath()
                        newPath.addSpline(spline: intersection)
                        result.append(newPath)
                    }
                    hasIntersections = true
                }
            }
            if hasIntersections {
                result[result.count - 1].addSpline(spline: spline)
            }
        }

        return result
    }
}

extension FloatingPoint {
    public func isAlmostEqual(to other: Self, tolerance: Self = Self.ulpOfOne.squareRoot()) -> Bool {
      assert(tolerance >= .ulpOfOne && tolerance < 1)
      guard self.isFinite && other.isFinite else { return rescaledAlmostEqual(to: other, tolerance: tolerance)}
      let scale = max(abs(self), abs(other), .leastNormalMagnitude)
      return abs(self - other) < scale*tolerance
    }

    private func rescaledAlmostEqual(to other: Self, tolerance: Self) -> Bool {
      if self.isNaN || other.isNaN { return false }
      if self.isInfinite {
        if other.isInfinite { return self == other }
        let scaledSelf = Self(sign: self.sign,
                              exponent: Self.greatestFiniteMagnitude.exponent,
                              significand: 1)
        let scaledOther = Self(sign: .plus,
                               exponent: -1,
                               significand: other)
         return scaledSelf.isAlmostEqual(to: scaledOther, tolerance: tolerance)
      }
      return other.rescaledAlmostEqual(to: self, tolerance: tolerance)
    }
}

public func cross(_ o: CGPoint, _ a: CGPoint, _ b: CGPoint) -> CGFloat {
    let lhs = (a.x - o.x) * (b.y - o.y)
    let rhs = (a.y - o.y) * (b.x - o.x)
    return lhs - rhs
}

/// Calculate and return the convex hull of a given sequence of points.
///
/// - Remark: Implements Andrew’s monotone chain convex hull algorithm.
///
/// - Complexity: O(*n* log *n*), where *n* is the count of `points`.
///
/// - Parameter points: A sequence of `CGPoint` elements.
///
/// - Returns: An array containing the convex hull of `points`, ordered
///   lexicographically from the smallest coordinates to the largest,
///   turning counterclockwise.
///
public func convexHull<Source>(of points: Source) -> [CGPoint] where Source : Collection, Source.Element == CGPoint
{
    // Exit early if there aren’t enough points to work with.
    guard points.count > 1 else { return Array(points) }

    // Create storage for the lower and upper hulls.
    var lower = [CGPoint]()
    var upper = [CGPoint]()

    // Sort points in lexicographical order.
    let points = points.sorted { a, b in
        a.x < b.x || a.x == b.x && a.y < b.y
    }

    // Construct the lower hull.
    for point in points {
        while lower.count >= 2 {
            let a = lower[lower.count - 2]
            let b = lower[lower.count - 1]
            if cross(a, b, point) > 0 { break }
            lower.removeLast()
        }
        lower.append(point)
    }

    // Construct the upper hull.
    for point in points.lazy.reversed() {
        while upper.count >= 2 {
            let a = upper[upper.count - 2]
            let b = upper[upper.count - 1]
            if cross(a, b, point) > 0 { break }
            upper.removeLast()
        }
        upper.append(point)
    }

    // Remove each array’s last point, as it’s the same as the first point
    // in the opposite array, respectively.
    lower.removeLast()
    upper.removeLast()

    // Join the arrays to form the convex hull.
    return lower + upper
}

func linearSolve(a: Double, b: Double) -> [Double] {
    if a == 0 {
        return []
    }
    else {
        return [-b/a]
    }
}

func quadraticSolve(a: Double, b: Double, c: Double) -> [Double] {
    if a == 0 { return linearSolve(a: b, b: c) }

    let d = b*b - 4*a*c

    if d > 0 {
        let x1 = (-b + sqrt(d))/(2*a)
        let x2 = (-b - sqrt(d))/(2*a)
        return [x1, x2]
    }
    else if d == 0 {
        let x = -b/(2*a)
        return [x, x]
    }
    else {
        return []
    }
}

func cubicSolve(a: Double, b: Double, c: Double, d: Double) -> [Double] {
    if a == 0 { return quadraticSolve(a: b, b: c, c: d) }

    let p = b/a
    let q = c/a
    let r = d/a
    let u = q - pow(p, 2)/3
    let v = r - p*q/3 + 2*pow(p, 3)/27

    let M = Double.greatestFiniteMagnitude
    if abs(p) > 27 * pow(M, 1/3) {
        return [-p]
    }
    else if abs(v) > pow(M, 1/2) {
        return [pow(v, 1/3)]
    }
    else if abs(u) > 3 * pow(M, 1/3) {
        return [pow(4, 1/3) * u / 3]
    }

    let j = 4*pow(u/3, 3) + pow(v, 2)

    if j >= 0 {
        let w = pow(j, 1/2)
        let y = (u/3) * pow(2/(w + v), 1/3) - pow((w + v)/2, 1/3) - p/3
        return [y]
    }
    else {
        let s = pow((-u/3), 1/2)
        let t = -v/(2 * pow(s, 3))
        let k = acos(t)/3

        let y1 = 2 * s * cos(k) - p/3
        let y2 = s * (-cos(k) + pow(3, 1/2) * sin(k)) - p/3
        let y3 = s * (-cos(k) - pow(3, 1/2) * sin(k)) - p/3
        return [y1, y2, y3]
    }
}


extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}










//
//  File.swift
//
//
//  Created by John Knowles on 7/28/24.
//

import CoreGraphics
import Accelerate
import  SwiftUI

@inline(__always)
func lerp<V: BinaryFloatingPoint, T: BinaryFloatingPoint>(_ v0: V, _ v1: V, _ t: T) -> V {
    return v0 + V(t) * (v1 - v0)
}

@inline(__always)
func lerp<T: BinaryFloatingPoint>(_ v0: CGSize, _ v1: CGSize, _ t: T) -> CGSize {
    return CGSize(
        width: lerp(v0.width, v1.width, t),
        height: lerp(v0.height, v1.height, t)
    )
}


@inline(__always)
func lerp<T: BinaryFloatingPoint>(_ v0: CGPoint, _ v1: CGPoint, _ t: T) -> CGPoint {
    return CGPoint(
        x: lerp(v0.x, v1.x, t),
        y: lerp(v0.y, v1.y, t)
    )
}

extension CGFloat {
    var formatted: String {
        let size = NSNumber(value: Float(self))
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter.string(from: size) ?? "\(Int(truncating: size))"
    }
    
    func lerping(to point: CGFloat, at rate: CGFloat) -> CGFloat {
       lerp(self, point, rate)
    }
}


extension CGPoint {
    func translatedBy(_ size: CGSize) -> CGPoint {
        return CGPoint(x: self.x + size.width,
                       y: self.y + size.height)
    }
    
      func translatedBy(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x,
                       y: self.y + y)
      }
    
    func lerping(to point: CGPoint, at rate: CGFloat) -> CGPoint {
        let x = lerp(point.x, self.x, rate)
        let y = lerp(point.y, self.y, rate)
        return CGPoint(x: x, y: y)
    }

}

extension CGPoint {
    func vector() -> CGVector {
        .init(dx: self.x, dy: self.y)
    }
    
    func rect(of size: CGSize) -> CGRect {
        let origin = self.translatedBy(x: -size.width / 2.0,
                                       y: -size.height / 2.0)
        return CGRect(origin: origin, size: size)
    }
    
    func transformCoordinates(_ canvas: CGSize, _ offset: CGSize, _ scale: CGFloat) -> CGPoint {
        self
            .alignCenterInCanvas(canvas)
            .scaledFrom(scale)
            .translatedBy(offset * -1)
    }
    
   func alignCenterInParent(_ parent: CGSize) -> CGPoint {
       let dx = parent.width / 2.0
       let dy = parent.height / 2.0
       return self.applying(.init(translationX: dx, y: dy))
   }
    
    func alignCenterInCanvas(_ parent: CGSize) -> CGPoint {
        let dx = -(parent.width / 2.0)
        let dy = -(parent.height / 2.0)
        return self.applying(.init(translationX: dx, y: dy))
    }
    

    
    
    func alignCenterInCanvas(_ parent: CGRect) -> CGPoint {
        let dx = -(parent.width / 2.0)
        let dy = -(parent.height / 2.0)
        return self.applying(.init(translationX: dx, y: dy))
    }
    
    func alignToScreen(_ parent: CGSize) -> CGPoint {
        let dx = (parent.width / 2.0)
        let dy = (parent.height / 2.0)
        return self.applying(.init(translationX: dx, y: dy))
    }


    
    
    func getAsUnit(_ canvas: CGSize) -> CGPoint {
        let x = self.x / canvas.width
        let y = self.y / canvas.height
        return CGPoint(x: x, y: y)
    }
    
  func scaledFrom(_ factor: CGFloat) -> CGPoint {
      return self.applying(.init(scaleX: factor, y: factor))
  }
    

 }

extension CGRect {
    func scaledFrom(_ factor: CGFloat) -> CGRect {
        self.applying(.init(scaleX: factor, y: factor))
    }
    
  
    func centerScale(by factor: CGFloat) -> CGRect {
        let newWidth = self.width * factor
        let newHeight = self.height * factor
        let newRect = self.translatedBy(x: -(newWidth - self.width) / 2.0,
                                        y: -(newHeight - self.height) / 2.0)
        return newRect.scaledFrom(factor)
    }
    
    func translatedBy(x: CGFloat, y: CGFloat) -> CGRect {
        self.applying(.init(translationX: x, y: y))
    }
    
    func alignCenterInCanvas(_ canvas: CGSize) -> CGRect {
        self.translatedBy(x:  -canvas.width / 2.0, y:  -canvas.height / 2.0)
    }
    
}

public extension CGPoint {
    
    internal static func +(_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    internal static func +(_ lhs: CGPoint, _ rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }
    
    internal static func -(_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    internal static func -(_ lhs: CGPoint, _ rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
    }
    
    internal static func *(_ lhs: CGPoint, _ rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    internal static func *(_ lhs: CGFloat, _ rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs * rhs.x, y: lhs * rhs.y)
    }
    
    internal static func *(_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y )
    }
    
    internal static func /(_ lhs: CGPoint, _ rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow((point.x - x), 2) + pow((point.y - y), 2))
    }
    
    
    func translation(from point: CGPoint) -> CGSize {
        return CGSize(width: self.x - point.x, height: self.y - point.y)
    }
    
    
    func magnitude() -> CGFloat {
        return sqrt(pow(x, 2) + pow(y, 2))
    }
    
    func getPointOnCircle(radius: CGFloat, radian: CGFloat) -> CGPoint {
        let x = self.x + radius * cos(radian)
        let y = self.y + radius * sin(radian)
        
        return CGPoint(x: x, y: y)
    }
    
    func getRadianFromCenter(container: CGRect) -> CGFloat {
        self.getRadian(pointOnCircle: CGPoint(x: container.midX, y: container.midY))
    }
    
    func getRadian(pointOnCircle: CGPoint) -> CGFloat {
        let originX = pointOnCircle.x - self.x
        let originY = pointOnCircle.y - self.y
        var radian = atan2(originY, originX)
        while radian < 0 {
            radian += CGFloat(2 * Double.pi)
        }
        return radian
    }
    
//    func getPolarPoint(from origin: CGPoint = CGPoint.zero) -> PolarPoint {
//        let deltaX = self.x - origin.x
//        let deltaY = self.y - origin.y
//        let radians = -1 * atan2(deltaY, deltaX)
//        let degrees = radians * (180.0 / CGFloat.pi)
//        let distance = self.distance(to: origin)
//
//        guard degrees < 0 else {
//            return PolarPoint(degrees: degrees, distance: distance)
//        }
//        return PolarPoint(degrees: degrees + 360.0, distance: distance)
//    }
}

extension CGPoint {
    func offsetFrom(_ point: CGPoint) -> CGSize {
        CGSize(width: self.x - point.x, height: self.y - point.y)
    }
    
    func size() -> CGSize {
        CGSize(width: self.x, height: self.y)

    }
}


extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

extension CGSize {
    func max(_ size: CGSize) -> CGSize {
        CGSize(width: Swift.max(self.width,  size.width),
               height: Swift.max(self.height,  size.height))
    }
    func point() -> CGPoint {
        CGPoint(x: self.width, y: self.height)
    }
    
   func scaledDownTo(_ factor: CGFloat) -> CGSize {
     return CGSize(width: width/factor, height: height/factor)
   }

  var length: CGFloat {
    return sqrt(pow(width, 2) + pow(height, 2))
  }

  var inverted: CGSize {
    return CGSize(width: -width, height: -height)
  }

    internal static func +(_ lhs: CGSize, _ rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
        
    }
    
    internal static func +(_ lhs: CGSize, _ rhs: CGPoint) -> CGSize {
        return CGSize(width: lhs.width + rhs.x, height: lhs.height + rhs.y)
        
    }
    
    internal static func -(_ lhs: CGSize, _ rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
        
    }
    internal static func *(_ lhs: CGSize, _ rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
        
    }
}

extension CGSize {
    func distance(_ size: CGSize) -> CGFloat {
        sqrt(pow(self.width - size.width, 2) + pow(self.height - size.height, 2))
    }
    
    
    internal static func +(_ lhs: CGSize, _ rhs: CGRect) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
        
    }
    
    internal static func /(_ lhs: CGSize, _ rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width / rhs, height: lhs.height / rhs )
    }
    
    func positive() -> CGSize {
        CGSize(width: abs(self.width),
               height: abs(self.height))
    }
    
}


extension CGSize {
    mutating func lerp(to value: CGSize, at rate: CGFloat = 0.7) {
        self = self * rate + value * (1 - rate)
    }
    
    func lerping(_ value: CGSize, at rate: CGFloat = 0.7) -> CGSize {
         self * rate + value * (1 - rate)
    }
    
    var zeroWidth: CGSize {
        CGSize(width:  0, height: self.height)
    }
    
    var zeroHeight: CGSize {
        CGSize(width:  self.width, height: 0)
    }
    
    func scaledX(_ scale: Double) -> CGSize {
        CGSize(width:  self.width * scale, height: self.height)
    }
    
    func scaledY(_ scale: Double) -> CGSize {
        CGSize(width:  self.width,
               height: self.height * scale)
    }
    
    func power(_ power: CGFloat) -> CGSize {
        CGSize(width: pow(self.width, power),
               height: pow(self.height, power))

    }
}


extension CGPoint {
    func distance(from point: CGPoint) -> CGFloat {
        return sqrt(pow((point.x - x), 2) + pow((point.y - y), 2))
    }
    

}


extension CGSize {
  
    
    internal static func *(_ lhs: CGFloat, _ rhs: CGSize) -> CGSize {
        return CGSize(width: lhs * rhs.width ,
                      height: lhs * rhs.height)
        
    }
    internal static func /(_ lhs: CGSize, _ rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width / rhs.width,
                      height: lhs.height / rhs.height)
        
    }

    
    func min(_ min: CGSize) -> CGSize {
        CGSize(width: Swift.min(self.width, min.width),
               height: Swift.min(self.height, min.height))
    }
    
    
    func magnitude() -> CGFloat {
        sqrt(pow(self.width, 2) + pow(self.height, 2))
    }
}

