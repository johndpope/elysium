//
//  ELConfig.h
//  Elysium
//
//  Created by Matt Mower on 20/07/2008.
//  Copyright 2008 LucidMac Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ELData.h"

@interface NSString ( StringValue )
- (NSString *)stringValue;
@end

@interface ELConfig : NSObject <ELData,NSMutableCopying> {
  ELConfig              *parent;
  NSMutableDictionary   *data;
  NSMutableDictionary   *snapshot;
  NSMutableArray        *children;
}

- (id)init;
- (id)initWithParent:(ELConfig *)parent;
- (id)initWithParent:(ELConfig *)parent data:(NSMutableDictionary *)data children:(NSMutableArray *)children;

- (void)addChild:(ELConfig *)child;
- (void)removeChild:(ELConfig *)child;

@property ELConfig *parent;

- (void)removeValueForKey:(NSString *)key;
- (BOOL)hasValueForKey:(NSString *)key;
- (BOOL)definesValueForKey:(NSString *)key;
- (BOOL)inheritsValueForKey:(NSString *)key;

- (id)valueForKey:(NSString *)key;
- (void)setValue:(id)value forKey:(NSString *)key;

- (int)integerForKey:(NSString *)key;
- (void)setInteger:(int)value forKey:(NSString *)key;

- (float)floatForKey:(NSString *)key;
- (void)setFloat:(float)value forKey:(NSString *)key;

- (void)setBoolean:(BOOL)value forKey:(NSString *)key;
- (BOOL)booleanForKey:(NSString *)key;

- (void)setString:(NSString *)value forKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;

- (void)snapshot;
- (void)restore;

@end
