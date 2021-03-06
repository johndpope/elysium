//
//  ELRangedOscillator.m
//  Elysium
//
//  Created by Matt Mower on 21/10/2008.
//  Copyright 2008 Matthew Mower.
//  See MIT-LICENSE for more information.
//

#import "ELRangedOscillator.h"

@implementation ELRangedOscillator

#pragma mark Object initialization

- (id)initEnabled:(BOOL)enabled minimum:(int)minimum hardMinimum:(int)hardMinimum maximum:(int)maximum hardMaximum:(int)hardMaximum {
  if( ( self = [super initEnabled:enabled] ) ) {
    [self setMinimum:minimum];
    [self setHardMinimum:hardMinimum];
    [self setMaximum:maximum];
    [self setHardMaximum:hardMaximum];
    [self setValue:minimum];
    
    // NSLog( @"%@ (ranged) value = %d, minimum = %d", self, [self value], minimum );
  }
  
  return self;
  
}


- (id)initEnabled:(BOOL)enabled minimum:(int)min maximum:(int)max {
  return [self initEnabled:enabled minimum:min hardMinimum:min maximum:max hardMaximum:max];
}


- (NSString *)description {
  return [NSString stringWithFormat:@"<ELRangedOscillator: %p> value:%d min:%d hard_min:%d max:%d hard_max:%d", self, [self value], [self minimum], [self hardMinimum], [self maximum], [self hardMaximum]];
}



#pragma mark Properties

@synthesize minimum = _minimum;

- (void)setMinimum:(int)newMinimum {
  _minimum = newMinimum;
  _range = [self maximum] - _minimum;
  
  if( [self value] < _minimum ) {
    [self setValue:_minimum];
  }
}


@synthesize hardMinimum = _hardMinimum;


@synthesize maximum = _maximum;

- (void)setMaximum:(int)newMaximum {
  _maximum = newMaximum;
  _range = _maximum - [self minimum];
  
  if( [self value] > _maximum ) {
    [self setValue:_maximum];
  }
}


@synthesize hardMaximum = _hardMaximum;


@synthesize range = _range;


#pragma mark Implements ELXmlData

- (id)initWithXmlRepresentation:(NSXMLElement *)representation parent:(id)parent player:(ELPlayer *)player error:(NSError **)error {
  if( ( self = [super initWithXmlRepresentation:representation parent:parent player:player error:error] ) ) {
    BOOL hasValue;
    
    int min_value = [representation attributeAsInteger:@"minimum" hasValue:&hasValue];
    if( !hasValue ) {
      if( error ) {
        *error = [[NSError alloc] initWithDomain:ELErrorDomain code:EL_ERR_OSCILLATOR_INVALID_ATTR userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Ranged oscillator has no or invalid minimum",NSLocalizedDescriptionKey,nil]];
      }
      return nil;
    }
    
    int max_value = [representation attributeAsInteger:@"maximum" hasValue:&hasValue];
    if( !hasValue ) {
      if( error ) {
        *error = [[NSError alloc] initWithDomain:ELErrorDomain code:EL_ERR_OSCILLATOR_INVALID_ATTR userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Ranged oscillator has no or invalid maximum",NSLocalizedDescriptionKey,nil]];
      }
      return nil;
    }
    
    [self setMinimum:min_value];
    [self setValue:[self minimum]];
    [self setMaximum:max_value];
  }
  
  return self;
}


- (void)storeAttributes:(NSMutableDictionary *)attributes {
  [super storeAttributes:attributes];
  
  [attributes setObject:[NSNumber numberWithInteger:[self minimum]] forKey:@"minimum"];
  [attributes setObject:[NSNumber numberWithInteger:[self maximum]] forKey:@"maximum"];
}


@end
