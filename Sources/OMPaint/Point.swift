//
//  File.swift
//  
//
//  Created by John Knowles on 7/13/24.
//

import Foundation

extension OMPaint {
    struct Point: Equatable, Codable {
        // horizontal coordinate
        let x: Double
        // vertical coordinate
        let y: Double
        // pressure component
        let p: Double
        
        enum CodingKeys: String, CodingKey {
            case x
            case y
            case p
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(x, forKey: .x)
            try container.encode(y, forKey: .y)
            try container.encode(p, forKey: .p)
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            x = try container.decode(Double.self, forKey: .x)
            y = try container.decode(Double.self, forKey: .y)
            p = try container.decode(Double.self, forKey: .p)
        }
        
        
        init(x: Double, y: Double, p: Double = 0.5) {
            self.x = x
            self.y = y
            self.p = p
        }
    }


}
extension OMPaint.Point {
    static prefix func -(_ rhs: OMPaint.Point) -> OMPaint.Point {
        OMPaint.Point(x: -rhs.x, y: -rhs.y)
    }
    
    func neg() -> OMPaint.Point  {
        OMPaint.Point (x: -self.x, y: -self.y, p: self.p)
    }
    
    func add(_ this: OMPaint.Point) -> OMPaint.Point  {
        OMPaint.Point (x: self.x + this.x, y: self.y + this.y, p: this.p)
    }
    
    func sub(_ this: OMPaint.Point ) -> OMPaint.Point  {
        OMPaint.Point (x: self.x - this.x, y: self.y - this.y, p: this.p)
    }
    
    func mulV(_ this: OMPaint.Point ) -> OMPaint.Point  {
        OMPaint.Point (x: self.x * this.x, y: self.y * this.y, p: this.p)
    }

    func mul(_ this: Double) -> OMPaint.Point  {
        OMPaint.Point (x: self.x * this, y: self.y * this, p: self.p)
    }
    
    func divV(_ this: OMPaint.Point ) -> OMPaint.Point  {
        OMPaint.Point (x: self.x / this.x, y: self.y / this.y, p: this.p)
    }
    
    func div(_ this: Double) -> OMPaint.Point  {
        OMPaint.Point (x: self.x / this, y: self.y / this, p: self.p)
    }
    
    func per() -> OMPaint.Point  {
        OMPaint.Point (x: self.y, y: -self.x, p: self.p)
    }

    func uni() -> OMPaint.Point  {
        self.div(self.len())

    }

    func lrp(_ this: OMPaint.Point , t: Double) -> OMPaint.Point  {
        self.add(this.sub(self).mul(t))
    }
    
    func med(_ this: OMPaint.Point ) -> OMPaint.Point  {
        self.lrp(this, t: 0.5)
    }
    
    func len() -> Double {
        sqrt(self.len2())
    }
    
    func len2() -> Double {
        self.x * self.x + self.y * self.y
    }
    
    
    func isEqual(_ this: OMPaint.Point ) -> Bool {
        self.x == this.x && self.y == this.y
     }
    
    func dist2(_ this: OMPaint.Point ) -> Double {
        self.sub(this).len2()
    }
    
    func dist(_ this: OMPaint.Point ) -> Double {
        self.sub(this).len()
    }
    
    func dpr(_ this: OMPaint.Point ) -> Double {
        self.x * this.x + self.y * this.y
    }

    func prj(_ this: OMPaint.Point , d: Double) -> OMPaint.Point  {
       self.add(this.mul(d))
    }
    
    func rotAround(_ this: OMPaint.Point , r: Double) -> OMPaint.Point  {
        let s = sin(r)
        let c = cos(r)
        let px = self.x - this.x
        let py = self.y - this.y
        let nx = px * c - px * s
        let ny = py * s + py * c
        return OMPaint.Point (x: nx + this.x, y: ny + this.y, p: this.p)
    }
}

