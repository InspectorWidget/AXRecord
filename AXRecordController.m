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
#import "DisplaysTracker.h"
#import "WindowTracker.h"
#import "XMLFileAccessMethods.h"
#import "WindowInfoEvent.h"

@implementation AXRecordController{
    AXElementTracker* elementTracker;
    DisplaysTracker* displaysTracker;
    WindowTracker* windowTracker;
    AppTracker* appTracker;
    XMLFileAccessMethods* xmlFileAccess;
}

-(id)initWithFilename:(NSString *)filename
  andElementTrackDelay:(float)elementTrackDelay
  andWindowTrackDelay:(float)windowTrackDelay
{
    self = [super init];
    if(self){
        xmlFileAccess = [[XMLFileAccessMethods alloc] initWithFilename:filename];
        elementTracker = [[AXElementTracker alloc] initWithDelay:elementTrackDelay andXMLFileAccess:xmlFileAccess];
        displaysTracker = [[DisplaysTracker alloc] initWithXMLFileAccess:xmlFileAccess];
        [displaysTracker setDisplaysTrackerDelegate:self];
        [displaysTracker update];
        windowTracker = [[WindowTracker alloc] initWithDelay:windowTrackDelay andXMLFileAccess:xmlFileAccess];
        [windowTracker setWindowTrackerDelegate:self];
        [windowTracker update];
        appTracker= [[AppTracker alloc] initWithXMLFileAccess:xmlFileAccess];
    }
    return self;
}

-(id)stop {
    [appTracker stop];
    [displaysTracker stop];
    [windowTracker stop];
    [elementTracker stop];
    [xmlFileAccess close];

    appTracker = nil;
    displaysTracker = nil;
    windowTracker = nil;
    elementTracker = nil;
    xmlFileAccess = nil;
}

-(void)displaysInfoEventHappened:(DisplaysInfoEvent*)displaysEvent{
    NSLog(@"displaysInfoEventHappened");
    if(xmlFileAccess){
        [xmlFileAccess addXMLElementToFileForDisplaysEvent:displaysEvent];
    }
}

-(void)windowInfoEventHappened:(WindowInfoEvent*)windowEvent{
    NSLog(@"windowInfoEventHappened");
    if(xmlFileAccess){
        [xmlFileAccess addXMLElementToFileForWindowEvent:windowEvent];
    }
    if(windowEvent && [windowEvent eventType] == vnrWindowAppeared ){
        NSString* ownerName = [[windowEvent windowInfo] ownerName];
        pid_t ownerPID = [[windowEvent windowInfo] ownerPID];
        [elementTracker log:ownerPID];
    }
}

@end
