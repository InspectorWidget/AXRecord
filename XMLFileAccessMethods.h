//
//  XMLFileAccessMethods.h
//  AXRecord
//
//  Created by Sylvain Malacria on 03/03/16.
//  Copyright © 2016 Sylvain Malacria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DisplaysInfoEvent.h"
#import "WindowInfoEvent.h"

@interface XMLFileAccessMethods : NSObject

-(id)initWithFilename:(NSString *)filename;

-(BOOL)addXMLElementToFileForMouseType:(int)mouseType
                         withModifiers:(unsigned long)modifiers
                       andAXUIElements:(NSArray*)array
                           andChildren:(NSXMLElement*)children
                           andSiblings:(NSArray*)siblings
                                atTime:(NSTimeInterval)time
                               atClock:(uint64)clock;

-(BOOL)addXMLElementToFileForDisplaysEvent:(DisplaysInfoEvent*)event;

-(BOOL)addXMLElementToFileForWindowEvent:(WindowInfoEvent*)event;

-(BOOL)addXMLElementToFileForApplication:(NSXMLElement*)children
                                  atTime:(NSTimeInterval)time
                                  atClock:(uint64)clock;

-(NSXMLElement*)xmlDescriptionOfChildrenOfElement:(AXUIElementRef)element
                                    beingSelected:(BOOL)select;

-(BOOL)writeChangeApp:(NSString*)appname
               atTime:(NSTimeInterval)time
              atClock:(uint64)clock;

-(void)close;

@end
