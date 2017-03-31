//
//  AXElementTracker.h
//  AXRecord
//
//  Created by Sylvain Malacria on 02/02/16.
//  Copyright © 2016 Sylvain Malacria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLFileAccessMethods.h"

@interface AXElementTracker : NSObject

@property NSTimer *timer;

@property id mouseEventHandler;

@property XMLFileAccessMethods* xmlFileAccess; // The xml document corresponding to all the events

-(id)initWithDelay:(float)delay andXMLFileAccess:(XMLFileAccessMethods*)xml;

+(AXUIElementRef)systemWideElement;

-(void)log:(pid_t)ownerPID;

-(void)stop;

@end
