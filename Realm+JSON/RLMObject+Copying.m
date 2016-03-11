//
//  RLMObject+Copying.m
//  RealmJSONDemo
//
//  Created by Matthew Cheok on 26/8/14.
//  Copyright (c) 2014 Getting Real. All rights reserved.
//

#import "RLMObject+Copying.h"

#import <Realm/RLMProperty.h>
#import <Realm/RLMObjectSchema.h>

@interface RLMProperty (Copying_Internal)

@property (nonatomic, assign) BOOL isPrimary;

@end

@implementation RLMObject (Copying)

- (instancetype)shallowCopy {
    id object = [[NSClassFromString(self.objectSchema.className) alloc] init];
    [object mergePropertiesFromObject:self];
    
    return object;
}

- (void)mergePropertiesFromObject:(id)object {
    for (RLMProperty *property in self.objectSchema.properties) {
        // assume array
        if (property.type == RLMPropertyTypeArray) {
            RLMArray *thisArray = [self valueForKeyPath:property.name];
            RLMArray *thatArray = [object valueForKeyPath:property.name];
            [self setValue:thatArray forKey:property.name];
        }
        // assume data
        else if (!property.isPrimary) {
            id value = [object valueForKeyPath:property.name];
            if (value) {
                [self setValue:value forKeyPath:property.name];
            }
        }
    }
}

- (instancetype)deepCopy {
    RLMObject *object = [[NSClassFromString(self.objectSchema.className) alloc] init];
    
    for (RLMProperty *property in self.objectSchema.properties) {

        if (property.type == RLMPropertyTypeArray) {
            RLMArray *thisArray = [self valueForKeyPath:property.name];
            RLMArray *newArray = [[RLMArray alloc] initWithObjectClassName:property.objectClassName];
            
            for (RLMObject *currentObject in thisArray) {
                [newArray addObject:[currentObject deepCopy]];
            }
            [object setValue:newArray forKey:property.name];
            
        }
        else if (property.type == RLMPropertyTypeObject) {
            RLMObject *value = [self valueForKeyPath:property.name];
            [object setValue:[value deepCopy] forKeyPath:property.name];
        }
        else {
            id value = [self valueForKeyPath:property.name];
            [object setValue:value forKeyPath:property.name];
        }
    }
    
    return object;
}



@end
