//
//  XMLFileAccessMethods.h
//  AXAll
//
//  Created by Sylvain Malacria on 03/03/16.
//  Copyright © 2016 Sylvain Malacria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WindowInfoEvent.h"

@interface XMLFileAccessMethods : NSObject



-(BOOL)addXMLElementToFileForMouseType:(int)mouseType withModifiers:(unsigned long)modifiers andAXUIElements:(NSArray*)array andChildren:(NSXMLElement*)children andSiblings:(NSArray*)siblings  atTime:(NSTimeInterval)time;
-(BOOL)addXMLElementToFileForWindowEvent:(WindowInfoEvent*)event;
-(BOOL)addXMLElementToFileForApplication:(NSXMLElement*)children atTime:(NSTimeInterval)time;

-(NSXMLElement*)xmlDescriptionOfChildrenOfElement:(AXUIElementRef)element beingSelected:(BOOL)select;

-(BOOL)writeChangeApp:(NSString*)appname atTime:(NSTimeInterval)time;



@end
