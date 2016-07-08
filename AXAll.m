//
//  AXAll.m
//  AXAll
//
//  Created by Sylvain Malacria on 02/02/16.
//  Copyright © 2016 Sylvain Malacria. All rights reserved.
//

#import "AXAll.h"
#import "UIElementUtilities.h"
#import "UIElementUtilitiesAdditions.h"
#import "XMLFileAccessMethods.h"
#import <AppKit/AppKit.h>

#include <sys/time.h>

@implementation AXAll{
    
    
 }

static AXUIElementRef systemWideElement;


-(id)initWithXMLFileAccess:(XMLFileAccessMethods*)xml{
    self = [super init];
    if(self){
        systemWideElement = AXUIElementCreateSystemWide();
        self.xmlFileAccess = xml;
        [self registerGlobalListener];

    }
    return self;
}



/**
 registers global listener for left/right mouse down/up events
 */
-(void)registerGlobalListener{
    NSEventMask mask = NSLeftMouseDownMask|NSLeftMouseUpMask|NSRightMouseDownMask|NSRightMouseUpMask;
    [NSEvent addGlobalMonitorForEventsMatchingMask:mask handler:^(NSEvent *event){
        [self handleEvent:event];
    }];
}

///**
// register a shared notification called when the frontmost app change and makes sure that the foremostAppActivated: method is called
// */
//
//-(void)registerAppTracker{
//    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(foremostAppActivated:) name:NSWorkspaceDidActivateApplicationNotification object:nil];
//}
//
//
//
// /** 
//  Called when the front app has changed
//  Retrieve the AXUIElementRef element corresponding to the novel frontmost app and 
//  calls handleAXElement(AXUIelementRef) to deal with it
//  @param notification the notification corresponding to the app change event
//  */
//- (void)foremostAppActivated:(NSNotification *)notification{
//   
//    NSRunningApplication *activatedApp = [[notification userInfo] objectForKey:NSWorkspaceApplicationKey];
//
//    //NSLog(@"changed app for %@",[activatedApp localizedName]);
//    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
//    pid_t pid = (pid_t)[activatedApp processIdentifier];
//    
//
// 
//    [self.xmlFileAccess writeChangeApp:[activatedApp localizedName] atTime:time];
//}




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

    [self.xmlFileAccess addXMLElementToFileForMouseType:(int)[event type] withModifiers:[event modifierFlags] andAXUIElements:array andChildren:children andSiblings:siblings atTime:time];
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





#pragma mark obsolete because handled using eventtaps

///**
// Handle a CGEvent event, retrieve its location to carbon coordinates and call handleEventInLocation:ofMouseType:withModifiers: for the corresponding event
// @warning this method is obsolete
// @param cgevent a CGEventRef
// @param type a CGEventType (should be mouse down or up)
// */
//-(void)handleEvent:(CGEventRef)cgevent ofType:(CGEventType)type{
//    CGPoint where = CGEventGetLocation(cgevent);
//    [self handleEventInLocation:where ofMouseType:type withModifiers:CGEventGetFlags(cgevent)];
//}
//


////THIS ONE IS OBSOLETE
//-(void)registerEventTap{
//
//    CGEventMask mask =NSLeftMouseDownMask|NSLeftMouseUpMask|NSRightMouseDownMask|NSRightMouseUpMask;
//
//
//    eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, mask, myCallback, (__bridge void *)(self));
//
//    if (!eventTap) {
//        NSLog(@"Couldn't create event tap!");
//        exit(1);
//    }
//
//    runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
//
//    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
//
//    CGEventTapEnable(eventTap, true);
//    CFRelease(eventTap);
//    CFRelease(runLoopSource);
//
//}




//-(CGEventRef)processEventTap:(CGEventRef)cgevent ofType:(CGEventType)type{
//    // Check the types
//    
//    if ((type==kCGEventTapDisabledByUserInput)||(type == kCGEventTapDisabledByTimeout)) {
//        // required in case of disabling
//        NSLog(@"eventTap Was Disabled So Reenable Now");
//        CGEventTapEnable(eventTap, true);
//        return cgevent;
//    }
//    else if((type==NSLeftMouseDown)||(type == NSLeftMouseUp)||(type == NSRightMouseDown)||(type == NSRightMouseUp)){
//        //Beware that origin is topleft for CGevents, bottomleft for NSEvents
//        NSLog(@"type is %d",type);
//        [self handleEvent:cgevent ofType:type];
//    }
//   
//    return cgevent;
//}



//CGEventRef myCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
//    AXAll* master = (__bridge AXAll*)refcon;
//    return [master processEventTap:event ofType:type];
//    
//    
//}



@end
