//
//  EdgeBorder.swift
//  Cactus
//
//  Created by Neil Poulin on 7/24/20.
//  Copyright © 2020 Cactus. All rights reserved.
//

import SwiftUI


struct HorizontalLineShape: Shape {

    func path(in rect: CGRect) -> Path {
        let fill = CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height)
        var path = Path()
        path.addRoundedRect(in: fill, cornerSize: CGSize(width: 2, height: 2))

        return path
    }
}

struct RoundedCorners: Shape {
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.size.width
        let h = rect.size.height
        
        // Make sure we do not exceed the size of the rectangle
        let tr = min(min(self.tr, h/2), w/2)
        let tl = min(min(self.tl, h/2), w/2)
        let bl = min(min(self.bl, h/2), w/2)
        let br = min(min(self.br, h/2), w/2)
        
        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        
        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        
        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        
        return path
    }
}

extension Path {
    func roundedCorners(tl: CGFloat=0, tr: CGFloat=0, bl: CGFloat=0, br: CGFloat=0) -> Path {
        // Make sure we do not exceed the size of the rectangle
        let w = self.boundingRect.width
        let h = self.boundingRect.height
        
        let tr = min(min(tr, h/2), w/2)
        let tl = min(min(tl, h/2), w/2)
        let bl = min(min(bl, h/2), w/2)
        let br = min(min(br, h/2), w/2)
        var path = self
        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        
        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        
        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        
        return path
        
    }
}


struct EdgeBorder: Shape {
    
    var width: CGFloat
    var edge: Edge
    var cornerRadius: CGFloat=0
    
    var corners: [UIRectCorner] = []
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
    
    func path(in rect: CGRect) -> Path {
        var x: CGFloat {
            switch edge {
            case .top, .bottom, .leading: return rect.minX
            case .trailing: return rect.maxX - width
            }
        }
        
        var y: CGFloat {
            switch edge {
            case .top, .leading, .trailing: return rect.minY
            case .bottom: return rect.maxY - width
            }
        }
        
        var w: CGFloat {
            switch edge {
            case .top, .bottom: return rect.width
            case .leading, .trailing: return self.width
            }
        }
        
        var h: CGFloat {
            switch edge {
            case .top, .bottom: return self.width
            case .leading, .trailing: return rect.height
            }
        }
        
        let tr = corners.contains(.topRight) || corners.contains(.allCorners) ? self.cornerRadius : self.tr
        let tl = corners.contains(.topLeft) || corners.contains(.allCorners) ? self.cornerRadius : self.tl
        let br = corners.contains(.bottomRight) || corners.contains(.allCorners) ? self.cornerRadius : self.br
        let bl = corners.contains(.bottomLeft) || corners.contains(.allCorners) ? self.cornerRadius : self.bl
        
        var path = Path()
        
        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        
        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        
        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        
        
        return path
        //        if cornerRadius > 0 {
        //            return Path(roundedRect: CGRect(x: x, y: y, width: w, height: h), cornerRadius: cornerRadius )
        //        } else {
        //            return Path(CGRect(x: x, y: y, width: w, height: h) )
        //        }
    }
}

extension View {
    func border(width: CGFloat, edge: Edge, color: Color, alignment: Alignment = Alignment.leading, radius: CGFloat=0, corners: [UIRectCorner]=[.allCorners]) -> some View {
        ZStack(alignment: alignment) {
            self
            EdgeBorder(width: width, edge: edge, cornerRadius: radius, corners: corners)
                .foregroundColor(color)
        }
    }
}

struct EdgeBorder_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Text("This is some really awesome text")
                .padding(.leading, 10)
                .border(width: 10, edge: .leading, color: Color(CactusColor.green), radius: 20, corners: [.topRight, .bottomRight])
            
            Text("Fancy Link")
                .padding(.leading, 10)
                .border(width: 10, edge: .bottom, color: Color(CactusColor.green))
            
        }
        .previewLayout(.fixed(width: 400, height: 100))
    }
}
