//
//  ELStartTool.m
//  Elysium
//
//  Created by Matt Mower on 20/07/2008.
//  Copyright 2008 LucidMac Software. All rights reserved.
//

#import "ELStartTool.h"

#import "ELHex.h"
#import "ELLayer.h"
#import "ELPlayhead.h"

static NSString * const toolType = @"start";

@implementation ELStartTool

+ (void)initialize {
  [ELTool addToolMapping:[ELStartTool class] forKey:toolType];
}

- (id)initWithDirectionKnob:(ELIntegerKnob *)_directionKnob_ timeToLiveKnob:(ELIntegerKnob *)_timeToLiveKnob_ pulseCountKnob:(ELIntegerKnob *)_pulseCountKnob_ {
  if( ( self = [self initWithType:toolType] ) ) {
    directionKnob = _directionKnob_;
    timeToLiveKnob = _timeToLiveKnob_;
    pulseCountKnob = _pulseCountKnob_;
  }
  
  return self;
}

- (id)init {
  if( ( self = [super initWithType:toolType] ) ) {
    directionKnob = [[ELIntegerKnob alloc] initWithName:@"direction" integerValue:N];
    timeToLiveKnob = [[ELIntegerKnob alloc] initWithName:@"timeToLive"];
    pulseCountKnob = [[ELIntegerKnob alloc] initWithName:@"pulseCount"];
    
    [self setPreferredOrder:1];
  }
  return self;
}

@synthesize directionKnob;
@synthesize timeToLiveKnob;
@synthesize pulseCountKnob;

- (void)addedToLayer:(ELLayer *)_layer_ atPosition:(ELHex *)_hex_ {
  [super addedToLayer:_layer_ atPosition:_hex_];
  
  [timeToLiveKnob setLinkedKnob:[_layer_ timeToLiveKnob]];
  [timeToLiveKnob setLinkValue:YES];
  
  [pulseCountKnob setLinkedKnob:[_layer_ pulseCountKnob]];
  [pulseCountKnob setLinkValue:YES];
  
  [_layer_ addGenerator:self];
}

- (void)removedFromLayer:(ELLayer *)_layer_ {
  [_layer_ removeGenerator:self];
  
  [timeToLiveKnob setLinkedKnob:nil];
  
  [super removedFromLayer:_layer_];
}

- (NSArray *)observableValues {
  NSMutableArray *keys = [[NSMutableArray alloc] init];
  [keys addObjectsFromArray:[super observableValues]];
  [keys addObjectsFromArray:[NSArray arrayWithObjects:@"directionKnob.value",@"timeToLiveKnob.value",nil]];
  return keys;
}

// Tool runner

- (BOOL)shouldPulseOnBeat:(int)_beat_ {
  return ( _beat_ % [pulseCountKnob value] ) == 0;
}

- (BOOL)run:(ELPlayhead *)_playhead {
  if( [super run:_playhead] ) {
    [layer addPlayhead:[[ELPlayhead alloc] initWithPosition:hex
                                                  direction:[directionKnob value]
                                                        TTL:[timeToLiveKnob value]]];
    return YES;
  } else {
    return NO;
  }
}

// Drawing

- (void)drawWithAttributes:(NSDictionary *)_attributes_ {
  NSPoint centre = [[self hex] centre];
  float radius = [[self hex] radius];
  
  NSBezierPath *symbolPath;
  symbolPath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect( centre.x - radius/3, centre.y - radius/3, 2*radius/3, 2*radius/3 )];
  [symbolPath setLineWidth:2.0];

  [[_attributes_ objectForKey:ELDefaultToolColor] set];
  [symbolPath stroke];
  
  [[self hex] drawTriangleInDirection:[directionKnob value] withAttributes:_attributes_];
}

// Implement the ELXmlData protocol

- (NSXMLElement *)xmlRepresentation {
  NSXMLElement *generatorElement = [NSXMLNode elementWithName:toolType];
  
  NSXMLElement *controlsElement = [NSXMLNode elementWithName:@"controls"];
  [controlsElement addChild:[directionKnob xmlRepresentation]];
  [controlsElement addChild:[timeToLiveKnob xmlRepresentation]];
  [controlsElement addChild:[pulseCountKnob xmlRepresentation]];
  [generatorElement addChild:controlsElement];
  
  return generatorElement;
}

- (id)initWithXmlRepresentation:(NSXMLElement *)_representation_ {
  if( ( self = [self initWithType:toolType] ) ) {
    NSXMLElement *element;
    NSArray *nodes;
    
    nodes = [_representation_ nodesForXPath:@"controls/knob[@name='direction']" error:nil];
    element = (NSXMLElement *)[nodes objectAtIndex:0];
    directionKnob = [[ELIntegerKnob alloc] initWithXmlRepresentation:element];
    
    nodes = [_representation_ nodesForXPath:@"controls/knob[@name='timeToLive']" error:nil];
    element = (NSXMLElement *)[nodes objectAtIndex:0];
    timeToLiveKnob = [[ELIntegerKnob alloc] initWithXmlRepresentation:element];

    nodes = [_representation_ nodesForXPath:@"controls/knob[@name='pulseCount']" error:nil];
    element = (NSXMLElement *)[nodes objectAtIndex:0];
    pulseCountKnob = [[ELIntegerKnob alloc] initWithXmlRepresentation:element];
  }
  
  return self;
}

// NSMutableCopying protocol

- (id)mutableCopyWithZone:(NSZone *)_zone_ {
  return [[[self class] allocWithZone:_zone_] initWithDirectionKnob:[directionKnob mutableCopy]
                                                     timeToLiveKnob:[timeToLiveKnob mutableCopy]
                                                     pulseCountKnob:[pulseCountKnob mutableCopy]];
}

@end
