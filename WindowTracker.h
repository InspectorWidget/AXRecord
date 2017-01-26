//
//  WindowTracker.h
//  TrackingFramework
//
//  Created by Sylvain Malacria on 10/07/15.
//  Copyright (c) 2015 Sylvain Malacria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLFileAccessMethods.h"
#import "WindowInfoEvent.h"

@protocol WindowTrackerDelegate <NSObject>
@required

-(void)windowInfoEventHappened:(WindowInfoEvent*)windowEvent;

@end




@interface WindowTracker : NSObject

@property NSTimer *timer;

@property XMLFileAccessMethods* xmlFileAccess; // The xml document corresponding to all the events
@property(nonatomic,assign)id<WindowTrackerDelegate> windowTrackerDelegate;

-(id)initWithDelay:(float)delay andXMLFileAccess:(XMLFileAccessMethods*)xml;
// retrieve an array of current window snapshots
+(NSArray*)getCurrentWindowsInfo;

-(void)printWindows;

-(void)stop;

@end
