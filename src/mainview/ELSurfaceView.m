//
//  ELSurfaceView.m
//  Elysium
//
//  Created by Matt Mower on 29/08/2008.
//  Copyright 2008 Matthew Mower.
//  See MIT-LICENSE for more information.
//

#import "ELSurfaceView.h"

#import "ELHex.h"
#import "ELToolView.h"

#import "ELNoteTool.h"
#import "ELAbsorbTool.h"
#import "ELSpinTool.h"
#import "ELGenerateTool.h"
#import "ELReboundTool.h"
#import "ELSplitTool.h"

NSString *HexPBoardType = @"HexPBoardType";

NSString * const ELDefaultCellBackgroundColor = @"cell.background.color";
NSString * const ELDefaultCellBorderColor = @"cell.border.color";
NSString * const ELDefaultSelectedCellBackgroundColor = @"selected.cell.background.color";
NSString * const ELDefaultSelectedCellBorderColor = @"selected.cell.border.color";
NSString * const ELDefaultToolColor = @"tool.color";
NSString * const ELDisabledToolColor = @"tool.disabled.color";
NSString * const ELDefaultActivePlayheadColor = @"active.playhead.color";
NSString * const ELTonicNoteColor = @"tonic.note.color";
NSString * const ELScaleNoteColor = @"scale.note.color";

@implementation ELSurfaceView

- (id)initWithFrame:(NSRect)_frame_ {
  if( ( self = [super initWithFrame:_frame_] ) ) {
    octaveColors = [[NSMutableArray alloc] init];
    [octaveColors addObject:[NSColor grayColor]]; // We don't see Octave#0 anyway
    [octaveColors addObject:[NSColor colorWithDeviceRed:(234.0/255) green:(174.0/255) blue:(145.0/255) alpha:0.9]];
    [octaveColors addObject:[NSColor colorWithDeviceRed:(231.0/255) green:(214.0/255) blue:(148.0/255) alpha:0.9]];
    [octaveColors addObject:[NSColor colorWithDeviceRed:(212.0/255) green:(228.0/255) blue:(150.0/255) alpha:0.9]];
    [octaveColors addObject:[NSColor colorWithDeviceRed:(176.0/255) green:(225.0/255) blue:(152.0/255) alpha:0.9]];
    [octaveColors addObject:[NSColor colorWithDeviceRed:(155.0/255) green:(222.0/255) blue:(165.0/255) alpha:0.9]];
    [octaveColors addObject:[NSColor colorWithDeviceRed:(158.0/255) green:(218.0/255) blue:(203.0/255) alpha:0.9]];
    [octaveColors addObject:[NSColor colorWithDeviceRed:(165.0/255) green:(172.0/255) blue:(210.0/255) alpha:0.9]];
    [octaveColors addObject:[NSColor colorWithDeviceRed:(192.0/255) green:(169.0/255) blue:(205.0/255) alpha:0.9]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self setDefaultColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:ELDefaultCellBackgroundColor]]];
    [self setBorderColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:ELDefaultCellBorderColor]]];
    [self setSelectedColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:ELDefaultSelectedCellBackgroundColor]]];
    [self setSelectedBorderColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:ELDefaultSelectedCellBorderColor]]];
    [self setToolColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:ELDefaultToolColor]]];
    [self setActivePlayheadColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:ELDefaultActivePlayheadColor]]];
    [self setTonicNoteColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:ELTonicNoteColor]]];
    [self setScaleNoteColor:[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:ELScaleNoteColor]]];
    
    [self registerForDraggedTypes:[NSArray arrayWithObjects:ToolPBoardType,HexPBoardType,nil]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cellWasUpdated:)
                                                 name:ELNotifyCellWasUpdated
                                               object:nil];
  }
  
  return self;
}

@dynamic toolColor;

- (void)setToolColor:(NSColor *)_color_ {
  [[self drawingAttributes] setObject:_color_ forKey:ELDefaultToolColor];
}

- (NSColor *)toolColor {
  return [[self drawingAttributes] objectForKey:ELDefaultToolColor];
}

- (void)setActivePlayheadColor:(NSColor *)_color_ {
  [[self drawingAttributes] setObject:_color_ forKey:ELDefaultActivePlayheadColor];
}

- (NSColor *)activePlayheadColor {
  return [[self drawingAttributes] objectForKey:ELDefaultActivePlayheadColor];
}

- (void)setTonicNoteColor:(NSColor *)_color_ {
  [[self drawingAttributes] setObject:_color_ forKey:ELTonicNoteColor];
}

- (NSColor *)tonicNoteColor {
  return [[self drawingAttributes] objectForKey:ELTonicNoteColor];
}

- (void)setScaleNoteColor:(NSColor *)_color_ {
  [[self drawingAttributes] setObject:_color_ forKey:ELScaleNoteColor];
}

- (NSColor *)scaleNoteColor {
  return [[self drawingAttributes] objectForKey:ELScaleNoteColor];
}

- (NSColor *)octaveColor:(int)_octave_ {
  return [octaveColors objectAtIndex:_octave_];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)_event_ {
  return YES;
}

// General view support

- (ELHex *)cellUnderMouseLocation:(NSPoint)_point_ {
  return (ELHex *)[self findCellAtPoint:[self convertPoint:_point_ fromView:nil]];
}

- (ELHex *)selectedHex {
  return (ELHex *)[self selected];
}

// Tool management

- (void)dragFromHex:(ELHex *)_sourceHex_ to:(ELHex *)_targetHex_ with:(NSDragOperation)_modifiers_ {
  [_targetHex_ removeAllTools];
  [_targetHex_ copyToolsFrom:_sourceHex_];
  if( !_modifiers_ & NSDragOperationCopy ) {
    [_sourceHex_ removeAllTools];
  }
  [self setNeedsDisplay:YES];
}

// Hex-to-Hex drag support

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)_isLocal_ {
  if( _isLocal_ ) {
    return NSDragOperationCopy;
  } else {
    return NSDragOperationNone;
  }
}

- (void)mouseDown:(NSEvent *)_event_ {
  [super mouseDown:_event_];
  savedEvent = _event_;
}

- (void)mouseDragged:(NSEvent *)_event_ {
  NSPoint down = [savedEvent locationInWindow];
  NSPoint drag = [_event_ locationInWindow];
  
  float distance = hypot( down.x - drag.x, down.y - drag.y );
  if( distance < 3 ) {
    return;
  }
  
  NSPoint p = [self convertPoint:down fromView:nil];
  
  NSImage *image = [NSImage imageNamed:@"hexdrag"];
  
  p.x = p.x - [image size].width / 2;
  p.y = p.y - [image size].height / 2;
  
  NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
  [pasteboard declareTypes:[NSArray arrayWithObject:HexPBoardType] owner:self];
  
  [pasteboard setString:@"foo" forType:HexPBoardType]; // Dummy, we'll just work of [self selected] anyway
  
  [self dragImage:image
               at:p
           offset:NSMakeSize(0,0)
            event:savedEvent
       pasteboard:pasteboard
           source:self
        slideBack:YES];
}

// Drag & Drop tool adding support

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)_sender_ {
  ELHex *cell = [self cellUnderMouseLocation:[_sender_ draggingLocation]];
  if( cell ) {
    return NSDragOperationCopy;
  } else {
    return NSDragOperationNone;
  }
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)_sender_ {
  ELHex *cell = [self cellUnderMouseLocation:[_sender_ draggingLocation]];
  if( cell ) {
    return NSDragOperationCopy;
  } else {
    return NSDragOperationNone;
  }
}

- (void)draggingExited:(id <NSDraggingInfo>)_sender_ {
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)_sender_ {
  NSPasteboard *pasteboard = [_sender_ draggingPasteboard];
  NSArray *types = [pasteboard types];
  
  ELHex *droppedCell = [self cellUnderMouseLocation:[_sender_ draggingLocation]];
  if( [types containsObject:HexPBoardType] ) {
    if( [self selectedHex] != droppedCell ) {
      [self dragFromHex:[self selectedHex] to:droppedCell with:[_sender_ draggingSourceOperationMask]];
    }
  }
  
  return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)_sender_ {
}

- (void)cellWasUpdated:(NSNotification*)_notification_
{
  [self setNeedsDisplay:YES];
}

@end
