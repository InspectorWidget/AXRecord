//
//  AXRecordController.m
//  AXRecord
//
//  Created by Christian Frisson on 05/02/17.
//  Copyright © 2017 Christian Frisson and Sylvain Malacria. All rights reserved.
//

#include "AXRecordController.h"
#import "AXElementTracker.h"
#import "AppTracker.h"
#import "WindowTracker.h"
#import "XMLFileAccessMethods.h"

@implementation AXRecordController{
    AXElementTracker* elementTracker;
    WindowTracker* windowTracker;
    AppTracker* appTracker;
    XMLFileAccessMethods* xmlFileAccess;
}

-(id)initWithFilename:(NSString *)filename andElementTrackDelay:(float)elementTrackDelay andWindowTrackDelay:(float)windowTrackDelay{
    self = [super init];
    if(self){
        xmlFileAccess = [[XMLFileAccessMethods alloc] initWithFilename:filename];
        elementTracker = [[AXElementTracker alloc] initWithDelay:elementTrackDelay andXMLFileAccess:xmlFileAccess];
        windowTracker = [[WindowTracker alloc] initWithDelay:windowTrackDelay andXMLFileAccess:xmlFileAccess];
        [windowTracker setWindowTrackerDelegate:self];
        appTracker= [[AppTracker alloc] initWithXMLFileAccess:xmlFileAccess];
    }
    return self;
}

-(id)stop {
    [appTracker stop];
    [windowTracker stop];
    [elementTracker stop];
    [xmlFileAccess close];

    appTracker = nil;
    windowTracker = nil;
    elementTracker = nil;
    xmlFileAccess = nil;
}

-(void)windowInfoEventHappened:(WindowInfoEvent*)windowEvent{
    NSLog(@"windowInfoEventHappened");
    if(xmlFileAccess){
        [xmlFileAccess addXMLElementToFileForWindowEvent:windowEvent];
    }
}

@end
