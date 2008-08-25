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

@implementation ELTool

- (id)initWithType:(NSString *)_type {
  return [self initWithType:_type config:[[ELConfig alloc] init]];
}

- (id)initWithType:(NSString *)_type config:(ELConfig *)_config {
  if( self = [super init] ) {
    toolType = _type;
    config   = _config;
    enabled  = YES;
  }
  
  return self;
}

@synthesize enabled;
@synthesize toolType;
@synthesize config;
@synthesize layer;

- (void)useInheritedConfig:(NSString *)_key {
  [config removeValueForKey:_key];
}

- (void)addedToLayer:(ELLayer *)_layer atPosition:(ELHex *)_hex {
  [config setParent:[_layer config]];
  layer = _layer;
  hex   = _hex;
}

- (void)removedFromLayer:(ELLayer *)layer {
  // NOP
}

// Tool specific invocation goes here
- (void)run:(ELPlayhead *)playhead {
  NSLog( @"Tool of type %@ has been run at %@", toolType, hex );
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

- (void)loadToolConfig:(NSXMLElement *)_xml_ {
}

@end
