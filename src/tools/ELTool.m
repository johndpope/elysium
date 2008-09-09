//
//  ELTool.m
//  Elysium
//
//  Created by Matt Mower on 20/07/2008.
//  Copyright 2008 LucidMac Software. All rights reserved.
//

#import "Elysium.h"

#import "ELTool.h"

#import "ELHex.h"
#import "ELLayer.h"
#import "ELConfig.h"
#import "ELPlayhead.h"

#import "ELBeatTool.h"
#import "ELStartTool.h"
#import "ELRicochetTool.h"
#import "ELSinkTool.h"
#import "ELSplitterTool.h"
#import "ELRotorTool.h"

NSMutableDictionary *toolMapping = nil;

@implementation ELTool

+ (NSDictionary *)toolMapping {
  if( toolMapping == nil ) {
    toolMapping = [[NSMutableDictionary alloc] init];
    
    [toolMapping setObject:[ELStartTool class] forKey:@"start"];
    [toolMapping setObject:[ELBeatTool class] forKey:@"beat"];
    [toolMapping setObject:[ELRicochetTool class] forKey:@"ricochet"];
    [toolMapping setObject:[ELSinkTool class] forKey:@"sink"];
    [toolMapping setObject:[ELSplitterTool class] forKey:@"splitter"];
    [toolMapping setObject:[ELRotorTool class] forKey:@"rotor"];
  }
  
  return toolMapping;
}

+ (ELTool *)fromXMLData:(NSXMLElement *)_xml_ {
  NSXMLNode *attribute = [_xml_ attributeForName:@"type"];
  if( !attribute ) {
    NSLog( @"Marker without type!" );
    return nil;
  }
  
  NSString *type = [attribute stringValue];
  
  ELTool *tool = [[[[ELTool toolMapping] objectForKey:type] alloc] init];
  if( !tool ) {
    NSLog( @"Unknown tool type:%@", type );
  }
  
  if( ![tool loadToolConfig:_xml_] ) {
    NSLog( @"Failed to load tool configuration!" );
    return nil;
  }
  
  return tool;
}

- (id)initWithType:(NSString *)_type {
  return [self initWithType:_type config:[[ELConfig alloc] init]];
}

- (id)initWithType:(NSString *)_type config:(ELConfig *)_config {
  if( ( self = [super init] ) ) {
    toolType       = _type;
    config         = _config;
    enabled        = YES;
    preferredOrder = 5;
  }
  
  return self;
}

// NSMutableCopying protocol

- (id)mutableCopyWithZone:(NSZone *)_zone_ {
  return [[[self class] allocWithZone:_zone_] initWithType:toolType config:[config mutableCopy]];
}


// Properties

@synthesize enabled;
@synthesize preferredOrder;
@synthesize toolType;
@synthesize config;
@synthesize layer;
@synthesize hex;

- (NSArray *)observableValues {
  return [NSArray arrayWithObject:@"enabled"];
}

- (void)useInheritedConfig:(NSString *)_key {
  [config removeValueForKey:_key];
}

- (void)addedToLayer:(ELLayer *)_layer atPosition:(ELHex *)_hex {
  [config setParent:[_layer config]];
  layer = _layer;
  hex   = _hex;
}

- (void)removedFromLayer:(ELLayer *)layer {
  [config setParent:nil];
}

// Tool specific invocation goes here
- (BOOL)run:(ELPlayhead *)playhead {
  return enabled;
}

// Drawing

- (void)drawWithAttributes:(NSDictionary *)_attributes_ {
  NSLog( @"Drawing has not been defined for tool class %@", [self className] );
}

// Implementing the ELData protocol

- (NSXMLElement *)asXMLData {
  NSXMLElement *markerElement = [NSXMLNode elementWithName:@"marker"];
  
  NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
  [attributes setObject:[self toolType] forKey:@"type"];
  [self saveToolConfig:attributes];
  [markerElement setAttributesAsDictionary:attributes];
  
  return markerElement;
}

- (BOOL)fromXMLData:(NSXMLElement *)data {
  return NO;
}

- (void)saveToolConfig:(NSMutableDictionary *)_attributes_ {
}

- (BOOL)loadToolConfig:(NSXMLElement *)_xml_ {
  return YES;
}

@end
