//
//  ConsoleController.m
//  AXRecord
//
//  Created by Christian Frisson on 24/01/17.
//  Forked from TableController.m
//  Copyright © 2017 Christian Frisson and Sylvain Malacria. All rights reserved.
//

#import "ConsoleController.h"
#import "AXElementTracker.h"
#import "AppTracker.h"
#import "WindowGrabber.h"

@implementation ConsoleController{
    AXElementTracker* elementTracker;
    WindowTracker* windowTracker;
    AppTracker* appTracker;
    XMLFileAccessMethods* xmlFileAccess;
}


// main function

-(id)init{
    self = [super init];
    if(self){
        xmlFileAccess = [XMLFileAccessMethods new];
        
        elementTracker = [[AXElementTracker alloc] initWithXMLFileAccess:xmlFileAccess];
        
        windowTracker = [[WindowTracker alloc] initWithDelay:0.2 andXMLFileAccess:xmlFileAccess];
        [windowTracker setWindowTrackerDelegate:self];
       
        appTracker= [[AppTracker alloc] initWithXMLFileAccess:xmlFileAccess];
        
        }
    return self;
}

-(void)windowInfoEventHappened:(WindowInfoEvent*)windowEvent{
	NSLog(@"windowInfoEventHappened");
    [xmlFileAccess addXMLElementToFileForWindowEvent:windowEvent];
}

@end
