//
//  AXElementTracker.m
//  AXRecord
//
//  Created by Sylvain Malacria on 02/02/16.
//  Copyright © 2016 Sylvain Malacria. All rights reserved.
//

#import "AXElementTracker.h"
#import "UIElementUtilities.h"
#import "UIElementUtilitiesAdditions.h"
#import "XMLFileAccessMethods.h"
#import <AppKit/AppKit.h>

#include <sys/time.h>
#include "platform.h"

@implementation AXElementTracker{
    pid_t current_pid;
    
 }

static AXUIElementRef systemWideElement;


-(id)initWithDelay:(float)delay andXMLFileAccess:(XMLFileAccessMethods*)xml{
    self = [super init];
    if(self){
        current_pid=0;
        systemWideElement = AXUIElementCreateSystemWide();
        self.xmlFileAccess = xml;
        [self registerGlobalListener];
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(processTimerForAX) userInfo:nil repeats:YES];
        }
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
    
    
    pid_t pid = (pid_t)[activatedApp processIdentifier];
    
    current_pid=pid;
    
}

-(void)processTimerForAX{
    if(current_pid!=0){
        uint64 clock = os_gettime_ns();
        
        // Get the local system time in UTC.
        gettimeofday(&system_time, NULL);
        
        // Convert the local system time to a Unix epoch in MS.
        NSTimeInterval time = (system_time.tv_sec * 1000) + (system_time.tv_usec / 1000);

        AXUIElementRef app_element = AXUIElementCreateApplication(current_pid);
        NSXMLElement* children = [self getXMLDescriptionOfElementAndChildren:app_element];
        [self.xmlFileAccess addXMLElementToFileForApplication:children atTime:time atClock:clock];
    }
    //
}





/**
 registers global listener for left/right mouse down/up events
 */
-(void)registerGlobalListener{
    NSEventMask mask = NSLeftMouseDownMask|NSLeftMouseUpMask|NSRightMouseDownMask|NSRightMouseUpMask;
    _mouseEventHandler = [NSEvent addGlobalMonitorForEventsMatchingMask:mask handler:^(NSEvent *event){
        [self handleEvent:event];
    }];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(foremostAppActivated:) name:NSWorkspaceDidActivateApplicationNotification object:nil];

    
}



/**
 Static accessor to systemWideElement for accessibility based methods
 @return systemWideElement
 */
+(AXUIElementRef)systemWideElement{
    return systemWideElement;
}




/**
Return an array of AXUIElementRefs corresponding to a widget and all its parents
 @param element the element
 @return an array of all AXUIElementRef of GUI components until the graphical widget passed as a parameter
 */
-(NSArray*)getArrayOfAncestorsAndElement:(AXUIElementRef)element{
    
   // AXUIElementRef element = [UIElementUtilities elementAtCGPoint:point withSystemWideElement:systemWideElement];
    if(element){
        NSArray* array = [UIElementUtilitiesAdditions arrayOfAncestorsOfElement:element];
        return array;
    }
    return nil;
}

/**
 Return an array of array of AXUIElementRefs corresponding to all children of a widget
 @param element the element
 @return an array of array all AXUIElementRef of all children of a GUI */
-(NSXMLElement*)getXMLDescriptionOfElementAndChildren:(AXUIElementRef)element{
    
    // AXUIElementRef element = [UIElementUtilities elementAtCGPoint:point withSystemWideElement:systemWideElement];
    if(element){
        NSXMLElement* xmlElement = [self.xmlFileAccess xmlDescriptionOfChildrenOfElement:element beingSelected:YES];
        return xmlElement;
    }
    return nil;
}


// Structure for the current Unix epoch in milliseconds.
static struct timeval system_time;

/**
 Handle a NSEvent event, converts its location to carbon coordinates and call handleEventInLocation:ofMouseType:withModifiers: for the corresponding event
 @param event a NSEvent that should be of MouseDownEvent type (left or right button)
 */
//TODO: check how modifiers are handled
-(void)handleEvent:(NSEvent*)event{
    uint64 clock = os_gettime_ns();
    
    // Get the local system time in UTC.
    gettimeofday(&system_time, NULL);
    
    // Convert the local system time to a Unix epoch in MS.
    NSTimeInterval time = (system_time.tv_sec * 1000) + (system_time.tv_usec / 1000);
    //NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    
    CGPoint where = [UIElementUtilities carbonScreenPointFromCocoaScreenPoint:[event locationInWindow]];
    AXUIElementRef element = [UIElementUtilitiesAdditions elementAtCGPoint:where withSystemWideElement:systemWideElement];
    AXUIElementRef parent = [UIElementUtilities parentOfUIElement:element];
    NSArray* siblings = [UIElementUtilities siblingsOfUIElement:element];
    //Array contains parents of the selected element
    NSArray* array;
    if(parent){
        array = [self getArrayOfAncestorsAndElement:parent];
    }
    
    NSXMLElement* children = [self getXMLDescriptionOfElementAndChildren:element];

    [self.xmlFileAccess addXMLElementToFileForMouseType:(int)[event type] withModifiers:[event modifierFlags] andAXUIElements:array andChildren:children andSiblings:siblings atTime:time atClock:clock];
}






#pragma mark likely to be obsolete below
///**
// Handle a NSEvent event, converts its location to carbon coordinates and call handleEventInLocation:ofMouseType:withModifiers: for the corresponding event
// @param event a NSEvent that should be of MouseDownEvent type (left or right button)
// */
//-(void)OLDhandleEvent:(NSEvent*)event{
//    CGPoint where = [UIElementUtilities carbonScreenPointFromCocoaScreenPoint:[event locationInWindow]];
//   // NSString* xmlTree= [self handleEventInLocation:where ofMouseType:[event type] withModifiers:[event modifierFlags]];
//    NSString* complete = [NSString stringWithFormat:@"<mouse type=%d time=%f>\n%@\n</mouse>",(int)[event type],[event timestamp],[self handleEventInLocation:where ofMouseType:[event type] withModifiers:[event modifierFlags]]];
//    
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
//    
//    NSError *error;
//    BOOL succeed = [complete writeToFile:[documentsDirectory stringByAppendingPathComponent:@"myfile.txt"]
//                              atomically:YES encoding:NSUTF8StringEncoding error:&error];
//    if (!succeed){
//        // Handle error here
//    }
//    else {
//        NSLog(@"cool %f",[event timestamp]);
//    }
//}
//
//
//
///**
// Handle a mouse down/up event in a given location, with modifiers. It first calls getArrayOfElementsAtPoint:CGPoint to get all AXUIElementRef at this location
// and then create a NSString corresponding to a XML description of it
// @param location Carbon screen location
// @param mouseType (int) value corresponding to the event type
// @param modifiers modifiers flag
// @return a string corresponding to the XML description of a AXUIelementRef at a given location and all its parents
// */
//-(NSString*)handleEventInLocation:(CGPoint)location ofMouseType:(int)mouseType withModifiers:(unsigned long)modifiers{
//    
//    
//    
//    NSArray* array = [self getArrayOfElementsAtPoint:location];
//    NSMutableString* wholeString = [NSMutableString new];
//    
//    // First we get all relevant information from each element
//    for(int i=0; i<array.count;i++){
//        
//        NSObject* element = [array objectAtIndex:i];
//        
//        if(i==array.count-1){
//            //Case of last item. It should be self closed
//            [wholeString appendString:[UIElementUtilities XMLDescriptionOfElement:(__bridge AXUIElementRef)(element) beingSelfClosed:YES]];
//            
//        }
//        else {
//            [wholeString appendString:[UIElementUtilities XMLDescriptionOfElement:(__bridge AXUIElementRef)(element)]];
//        }
//        
//    }
//    
//    //We retrieve the id of the before last item in the array
//    int startID = (int)array.count-2;
//    
//    if(startID>=0){
//        //We close the xml objects
//        for(int i=startID; i>=0; i--){
//            NSObject* element = [array objectAtIndex:i];
//            NSString* closing = [NSString stringWithFormat:@"</%@>\n",[UIElementUtilities roleOfUIElement:(__bridge AXUIElementRef)(element)]];
//            [wholeString appendString:closing];
//        }
//    }
//    
//    //NSLog(@"%lu",[wholeString length]);
//    return wholeString;
//    
//}


- (void)stop{
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver: self];
    [NSEvent removeMonitor:_mouseEventHandler];
    if ([_timer isValid]) {
            [_timer invalidate];
    }
    _timer = nil;
}


@end
