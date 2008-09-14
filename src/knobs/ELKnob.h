//
//  ELKnob.h
//  Elysium
//
//  Created by Matt Mower on 10/09/2008.
//  Copyright 2008 LucidMac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ELData.h"

@class ELOscillator;

@interface ELKnob : NSObject {
  NSString        *name;            // name assigned to the knob
  
  ELKnob          *linkedKnob;      // a "parent" knob that may
  
  BOOL            enabled;          // whether this knob is enabled or not
  BOOL            hasEnabled;
  BOOL            linkEnabled;
  
  BOOL            hasValue;         // If a value is stored in this knob
  BOOL            linkValue;
  
  float           alpha;
  BOOL            hasAlpha;
  BOOL            linkAlpha;
  
  float           p;
  BOOL            hasP;
  BOOL            linkP;
  
  ELOscillator    *filter;          // an oscillator that can be linked to alpha
  BOOL            linkFilter;
  
  NSPredicate     *predicate;       // a predicate that be used to govern whether
  BOOL            linkPredicate;    // this knob is enabled or not
}

- (id)initWithName:(NSString *)name;

- (NSString *)name;

- (void)clearValue;

- (ELKnob *)linkedKnob;
- (void)setLinkedKnob:(ELKnob *)linkedKnob;

- (BOOL)enabled;
- (void)setEnabled:(BOOL)enabled;

- (BOOL)linkEnabled;
- (void)setLinkEnabled:(BOOL)linkEnabled;

- (BOOL)linkValue;
- (void)setLinkValue:(BOOL)linkValue;

- (float)alpha;
- (void)setAlpha:(float)alpha;

- (BOOL)linkAlpha;
- (void)setLinkAlpha:(BOOL)linkAlpha;

- (float)p;
- (void)setP:(float)p;

- (BOOL)linkP;
- (void)setLinkP:(BOOL)linkP;

- (ELOscillator *)filter;
- (void)setFilter:(ELOscillator *)filter;

- (BOOL)linkFilter;
- (void)setLinkFilter:(BOOL)linkFilter;

- (NSPredicate *)predicate;
- (void)setPredicate:(NSPredicate *)predicate;

- (BOOL)linkPredicate;
- (void)setLinkPredicate:(BOOL)linkPredicate;

@end
