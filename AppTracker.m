//
//  AppTracker.m
//  TrackpadLogger
//
//  Created by Sylvain Malacria on 22/04/2014.
//  Copyright (c) 2014 Sylvain Malacria. All rights reserved.
//

// This class (or not too far) should also register the global command listener as it requires AX
// How should we do?
// refactoring ...


#import "AppTracker.h"
#import <AppKit/AppKit.h>



@implementation AppTracker


-(id)initWithXMLFileAccess:(XMLFileAccessMethods*)xml{
    self =[super init];
    if(self){
        self.xmlFileAccess = xml;
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(foremostAppActivated:) name:NSWorkspaceDidActivateApplicationNotification object:nil];
    }
    return self;
    }


/**
 Called when the front app has changed
 Retrieve the AXUIElementRef element corresponding to the novel frontmost app and
 calls handleAXElement(AXUIelementRef) to deal with it
 @param notification the notification corresponding to the app change event
 */
- (void)foremostAppActivated:(NSNotification *)notification{
    
    NSRunningApplication *activatedApp = [[notification userInfo] objectForKey:NSWorkspaceApplicationKey];
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    pid_t pid = (pid_t)[activatedApp processIdentifier];
    
    
    [self.xmlFileAccess writeChangeApp:[activatedApp localizedName] atTime:time];
}




@end
