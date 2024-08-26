// The Swift Programming Language
// https://docs.swift.org/swift-book



/*
 Audio
     record
     play (

     waveform
 
     buffer (read, write, copy, segment)
 
 
 Video
    play (pause, seek, step)
 
 
 Paint
 */

import SwiftUI


public enum OMPaintTool: Hashable {
    case freehand(Color, CGFloat)
    case rectangle(Color, CGFloat)
    case circle(Color, CGFloat)
    case line(Color, CGFloat)
    case eraser
    
//    case custom(OMPaintTool)
}



enum OMPaint {}

public class OMPaintManager {
    
    private var undoManager = UndoManager()
    private var tool = OMPaintTool.freehand(.blue, 12)
    
    
    public func undo() {
        if undoManager.canUndo {
            undoManager.undo()
        }
    }
    
    public func redo() {
        if undoManager.canRedo {
            undoManager.redo()
        }
    }
    
    public func changeTool(to tool: OMPaintTool) {
        
    }
 
    
}
