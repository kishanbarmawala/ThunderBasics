//
//  NSArray+TSCArray.m
//  Roboto Lite
//
//  Created by Phillip Caudell on 24/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "NSArray+TSCArray.h"
#import "TSCObject.h"

@implementation NSArray (TSCArray)

- (NSArray *)serialisableRepresentation
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (id object in self){
        
        if ([TSCObject isSerialisable:object]) {
            [array addObject:object];
        }
        
        if ([object respondsToSelector:@selector(serialisableRepresentation)]) {
            TSCObject *tscObject = [(TSCObject *)object serialisableRepresentation];
        
            if (tscObject) {
                [array addObject:tscObject];
            } else {
                NSLog(@"failed to serialize object : %@. Some required data may not be being sent to the server.",object);
            }
            
        }
    }
    
    return array;
}

- (NSData *)JSONRepresentation
{
    NSData *json = [NSJSONSerialization dataWithJSONObject:[self serialisableRepresentation] options:NSJSONWritingPrettyPrinted error:nil];
    return json;
}

+ (NSArray *)arrayWithArrayOfDictionaries:(NSArray *)dictionaries rootInstanceType:(Class)classType
{
    if (![classType instancesRespondToSelector:@selector(initWithDictionary:)]) {
        return nil;
    }
    
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:dictionaries.count];

    for (NSDictionary *dictionary in dictionaries) {
        
        id object = [[classType alloc] initWithDictionary:dictionary];
        [objects addObject:object];
    }
    
    return objects;
}

@end