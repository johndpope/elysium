//
//  ELPlayer.h
//  Elysium
//
//  Created by Matt Mower on 20/07/2008.
//  Copyright 2008 Matthew Mower.
//  See MIT-LICENSE for more information.
//

#import <Cocoa/Cocoa.h>

#import "Elysium.h"

#import "ELMIDITrigger.h"
#import "ELMIDIController.h"

@class ELNote;
@class ELLayer;
@class ELTimer;
@class ELHarmonicTable;
@class ELMIDIController;
@class ElysiumDocument;
@class ELScriptPackage;
@class ELEnvelopeProbabilityGenerator;

@interface ELPlayer : NSObject <ELXmlData,ELTaggable> {
  ElysiumDocument     *document;        // Cocoa NSDocument subclass hosting this player
  ELHarmonicTable     *harmonicTable;   // Represents the structure of notes to be played
  NSMutableArray      *layers;          // Each layer is an "instrument"
  ELLayer             *selectedLayer;
  BOOL                running;          // The player is active
  ELMIDIController    *midiController;  // Our interface to CoreMIDI
  int                 timerResolution;  
  UInt64              startTime;
  
  int                 nextLayerNumber;
  BOOL                showNotes;
  BOOL                showOctaves;
  BOOL                showKey;
  BOOL                performanceMode;
  
  NSString            *scriptingTag;
  NSMutableDictionary *scripts;
  NSMutableArray      *triggers;        // ELMIDITrigger objects
  NSThread            *triggerThread;
  
  ELScriptPackage     *pkg;
  
  ELIntegerKnob       *tempoKnob;
  ELIntegerKnob       *barLengthKnob;
  ELIntegerKnob       *timeToLiveKnob;
  ELIntegerKnob       *pulseCountKnob;
  ELIntegerKnob       *velocityKnob;
  ELIntegerKnob       *emphasisKnob;
  ELIntegerKnob       *durationKnob;
  ELIntegerKnob       *transposeKnob;
}

@property (readonly) UInt64 startTime;
@property (readonly) ELHarmonicTable *harmonicTable;
@property BOOL running;
@property BOOL showNotes;
@property BOOL showOctaves;
@property BOOL showKey;
@property BOOL performanceMode;

@property ELLayer *selectedLayer;

@property ElysiumDocument *document;
@property (readonly) NSMutableDictionary *scripts;
@property (readonly) NSMutableArray *triggers;
@property (readonly) ELScriptPackage *pkg;

@property (readonly) ELIntegerKnob *tempoKnob;
@property (readonly) ELIntegerKnob *barLengthKnob;
@property (readonly) ELIntegerKnob *timeToLiveKnob;
@property (readonly) ELIntegerKnob *pulseCountKnob;
@property (readonly) ELIntegerKnob *velocityKnob;
@property (readonly) ELIntegerKnob *emphasisKnob;
@property (readonly) ELIntegerKnob *durationKnob;
@property (readonly) ELIntegerKnob *transposeKnob;

- (id)initWithDocument:(ElysiumDocument *)document;
- (id)initWithDocument:(ElysiumDocument *)document createDefaultLayer:(BOOL)createDefaultLayer;

- (ELIntegerKnob *)defaultTempoKnob;
- (ELIntegerKnob *)defaultBarLengthKnob;
- (ELIntegerKnob *)defaultTimeToLiveKnob;
- (ELIntegerKnob *)defaultPulseCountKnob;
- (ELIntegerKnob *)defaultVelocityKnob;
- (ELIntegerKnob *)defaultEmphasisKnob;
- (ELIntegerKnob *)defaultDurationKnob;
- (ELIntegerKnob *)defaultTransposeKnob;

- (void)toggleNoteDisplay;

- (void)start:(id)_sender_;
- (void)start;
- (void)stop:(id)_sender_;
- (void)stop;
- (void)reset;

- (void)clearAll;

// Drawing support

- (void)needsDisplay;

// Layer management
- (ELLayer *)createLayer;
- (void)addLayer:(ELLayer *)layer;
- (int)layerCount;
- (void)removeLayers;
- (NSArray *)layers;
- (ELLayer *)layer:(int)index;

// MIDI Trigger support
- (void)processMIDIControlMessage:(ELMIDIControlMessage *)message;
- (void)handleMIDIControlMessage:(ELMIDIControlMessage *)message;

// Script support
- (void)runWillStartScript;
- (void)runDidStartScript;
- (void)runWillStopScript;
- (void)runDidStopScript;

@end
