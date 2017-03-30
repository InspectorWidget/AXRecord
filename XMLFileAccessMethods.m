//
//  XMLFileAccessMethods.m
//  AXRecord
//
//  Created by Sylvain Malacria on 03/03/16.
//  Copyright © 2016 Sylvain Malacria. All rights reserved.
//

#import "XMLFileAccessMethods.h"
#import "UIElementUtilities.h"
#import "UIElementUtilitiesAdditions.h"

#include "platform.h"

@implementation XMLFileAccessMethods{
    NSXMLDocument* xmldoc;
    NSString* filePath;
}


-(id)init{
    self = [super init];
    if(self){
        [self createFilePath];
        [self initXMLDoc];
    }
    return self;
}

-(id)initWithFilename:(NSString *)filename
{
    self = [super init];
    if(self){
        if(filename==nil){
            [self createFilePath];
        }
        else{
            filePath = filename;
        }
        [self initXMLDoc];
    }
    return self;
}

-(void)initXMLDoc{
    if(xmldoc==nil){
        xmldoc = [[NSXMLDocument alloc] init];
    }

    NSXMLElement *root = [[NSXMLElement alloc] initWithName:@"root"];
    [xmldoc addChild:root];

}

/**
 Create a XML documetn from a file. File is meant to be a XML Document so it will the XMLDocument with the content of the file
 @param file NSString path to the filea
 */
+(NSXMLDocument*)createXMLDocumentFromFile:(NSString *)file
{
    NSError *err = nil;
    NSXMLDocument *document;
    NSURL *furl = [NSURL fileURLWithPath:file];
    if( !furl )
    {
        NSLog(@"Can't create an URL from file %@.", file );
        return nil;
    }
    // if( document )
    // [document release];
    document = [[NSXMLDocument alloc] initWithContentsOfURL:furl options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA) error:&err];
    if( document == nil )
    {
        // in previous attempt, it failed creating XMLDocument because it
        // was malformed.
        document = [[NSXMLDocument alloc] initWithContentsOfURL:furl options:NSXMLDocumentTidyXML error:&err];
        
    }
    if( document == nil)
    {
        NSLog( @"Error occurred while creating an XML document.");
        //        if(err)
        //            [self handleError:err];
    }
    else{
        NSLog(@"file exist");
    }
    return document;
    

}


/**
 create a sessionlog-d file if filePath does not exist yet
 @param timestamp is the time at which the file has been created
 */
-(void)createFilePathWithTimestamp:(NSTimeInterval)timestamp{
    if(filePath==nil){
        time_t    now = time(0);
        struct tm *cur_time;
        cur_time = localtime(&now);
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSMoviesDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [paths objectAtIndex:0];
        NSString* filename = [NSString stringWithFormat:@"%d-%02d-%02d-%02d-%02d-%02d",
                              cur_time->tm_year+1900,
                              cur_time->tm_mon+1,
                              cur_time->tm_mday,
                              cur_time->tm_hour,
                              cur_time->tm_min,
                              cur_time->tm_sec];
        filePath = [documentPath stringByAppendingPathComponent:filename];
        filePath = [NSString stringWithFormat:@"%@.xml",filePath];
    }
}


-(void)createFilePath{
    [self createFilePathWithTimestamp:[[NSDate date] timeIntervalSince1970]];
}


/**
 add a complete NSXMLElement to the root of the xmldoc file
 @param element an NSXMLElement describing a graphical widget and all its ancestors
 */
-(BOOL)addXMLElementToRoot:(NSXMLElement*)element{
    if(xmldoc){
        [[xmldoc rootElement] addChild:element];
        NSData *xmlData = [xmldoc XMLDataWithOptions:NSXMLNodePrettyPrint];
        if ([xmlData writeToFile:filePath atomically:YES]) {
           return YES;
        }
    }
    return NO;
}

/**
 write a node for changeapp event in the root
 @param appname the name of the app
 @time the date
 @return BOOL YES if all went well
 */

-(BOOL)writeChangeApp:(NSString*)appname
               atTime:(NSTimeInterval)time
              atClock:(uint64)clock{
    if(xmldoc){
        NSXMLElement *xmlElement = [[NSXMLElement alloc] initWithName:@"appchange"];
        [xmlElement addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:appname]];
        [xmlElement addAttribute:[NSXMLNode attributeWithName:@"time" stringValue:[NSString stringWithFormat:@"%f",time]]];
        [xmlElement addAttribute:[NSXMLNode attributeWithName:@"clock" stringValue:[NSString stringWithFormat:@"%" PRIu64,clock]]];
        uint64 _clock = os_gettime_ns();
        [xmlElement addAttribute:[NSXMLNode attributeWithName:@"took" stringValue:[NSString stringWithFormat:@"%" PRIu64,_clock-clock]]];
        [[xmldoc rootElement] addChild:xmlElement];
        NSData *xmlData = [xmldoc XMLDataWithOptions:NSXMLNodePrettyPrint];
        if ([xmlData writeToFile:filePath atomically:YES]) {
        return YES;
    }
}
return NO;
}



/**
 return an XMLElement describing the entire name and properties of the AXUIElementRef
 @param element is a AXUIElementRef
 */
+(NSXMLElement*)XMLElementforAXElement:(AXUIElementRef)element{
    NSXMLElement *xmlelement = [[NSXMLElement alloc] initWithName:[UIElementUtilities roleOfUIElement:element]];
    
    
    NSArray *		theNames;
    CFIndex			nameIndex;
    CFIndex			numOfNames;
    
    // display attributes
    theNames = [UIElementUtilities attributeNamesOfUIElement:element];
    if (theNames) {
        
        numOfNames = [theNames count];
        
        for( nameIndex = 0; nameIndex < numOfNames; nameIndex++ ) {
            
            NSString *	theName = NULL;
            NSString *	theDesc = NULL;
            
            // Grab name
            theName = [theNames objectAtIndex:nameIndex];
            theDesc = [UIElementUtilities descriptionForUIElement:element attribute:theName beingVerbose:false];

            if([theName length]!=0)
                [xmlelement addAttribute:[NSXMLNode attributeWithName:theName stringValue:theDesc]];
            
        }
        
    }
    
    // display actions
    theNames = [UIElementUtilities actionNamesOfUIElement:element];
    if (theNames) {
        
        numOfNames = [theNames count];
        
        for( nameIndex = 0; nameIndex < numOfNames; nameIndex++ ) {
            
            NSString *	theName 		= NULL;
           	NSString *	theDesc 		= NULL;
            
            // Grab name
            theName = [theNames objectAtIndex:nameIndex];
            
            // Grab description
            theDesc = [UIElementUtilities descriptionOfAction:theName ofUIElement:element];
            
            // Add string
            if([theName length]!=0)
                [xmlelement addAttribute:[NSXMLNode attributeWithName:theName stringValue:theDesc]];
        }
        
    }
    return xmlelement;
}




/**
 Create a  XMLElement for a mouse down/up  XML Element describing the AXUIElement at the event location, all its ancestors and all of its children
 @param mouseType (int) value corresponding to the event type
 @param modifiers modifiers flag
 @param time at which the event occured
 @param array NSArray of all the AXUIElementRef
 @param children NSXMLElement of the selected element and all its children
 @return a NSXMLElement corresponding to the XML description of a AXUIelementRef at a given location and all its parents
 */
-(NSXMLElement*)createXMLElementForMouseType:(int)mouseType
                               withModifiers:(unsigned long)modifiers
                             andAXUIElements:(NSArray*)array
                                 andChildren:(NSXMLElement*)children
                                 andSiblings:(NSArray*)siblings
                                      atTime:(NSTimeInterval)time
                                     atClock:(uint64)clock{
    
    NSXMLElement *xmlElement = [[NSXMLElement alloc] initWithName:@"mouse"];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"type" stringValue:[NSString stringWithFormat:@"%d",mouseType]]];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"mod" stringValue:[NSString stringWithFormat:@"%lu",modifiers]]];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"time" stringValue:[NSString stringWithFormat:@"%f",time]]];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"clock" stringValue:[NSString stringWithFormat:@"%" PRIu64,clock]]];
    NSXMLElement* lastchild=xmlElement;
    if(array){
        for(int i=0; i<array.count;i++){
            
            NSObject* element = [array objectAtIndex:i];
            NSXMLElement* newElement =[XMLFileAccessMethods XMLElementforAXElement:(__bridge AXUIElementRef)(element)];
            if(i==array.count-1){
                
                [newElement addChild:children];
                for(int j=0;j<siblings.count; j++){
                     NSObject* sibling = [siblings objectAtIndex:j];
                    [newElement addChild:[XMLFileAccessMethods XMLElementforAXElement:(__bridge AXUIElementRef)(sibling)]];
                }
            }
            [lastchild addChild:newElement];
            lastchild = newElement;
        }
    }
    uint64 _clock = os_gettime_ns();
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"took" stringValue:[NSString stringWithFormat:@"%" PRIu64,_clock-clock]]];
    return xmlElement;
    
}

/** Create a XML Element for a displaysEvent
 @param DisplaysInfoEvent a displays event info
 @return a NSXMLElement corresponding to the XML description of this displaysEvent
 */
-(BOOL)addXMLElementToFileForDisplaysEvent:(DisplaysInfoEvent*)event{
    NSXMLElement* element = [self createXMLElementForDisplaysInfoEvent:event];
    return [self addXMLElementToRoot:element];
}

/** Create a XML Element for a windowEvent
 @param WindowInfoEvent a window event info
 @return a NSXMLElement corresponding to the XML description of this windowEvent
 */


-(NSXMLElement*)createXMLElementForDisplaysInfoEvent:(DisplaysInfoEvent*)event{
    NSXMLElement *xmlElement = [[NSXMLElement alloc] initWithName:@"displaysEvent"];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"time" stringValue:[NSString stringWithFormat:@"%f",[event timestamp]]]];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"clock" stringValue:[NSString stringWithFormat:@"%" PRIu64,[event clock]]]];

    NSXMLElement *allDisplays = [[NSXMLElement alloc] initWithName:@"allDisplays"];
    for(DisplayInfo* display in [event displays]){
        NSXMLElement *displayXML = [[NSXMLElement alloc] initWithName:@"display"];
        [self addAttributeToXMLElement:displayXML forDisplay:display];
        [allDisplays addChild:displayXML];
    }
    [xmlElement addChild:allDisplays];
    uint64 _clock = os_gettime_ns();
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"took" stringValue:[NSString stringWithFormat:@"%" PRIu64,_clock-[event clock]]]];

    return xmlElement;
}

//[NSNumber numberWithUnsignedInt:_displayID]

-(void)addAttributeToXMLElement:(NSXMLElement*)element forDisplay:(DisplayInfo*)displayInfo{
    [element  addAttribute:[NSXMLNode attributeWithName:@"id" stringValue:[[displayInfo displayIDNumber] stringValue]]];
    [element  addAttribute:[NSXMLNode attributeWithName:@"screen" stringValue:[[displayInfo screenNumber] stringValue]]];
    [element  addAttribute:[NSXMLNode attributeWithName:@"active" stringValue:([displayInfo active] ? @"true" : @"false")]];
    [element  addAttribute:[NSXMLNode attributeWithName:@"main" stringValue:([displayInfo main] ? @"true" : @"false")]];
    NSXMLElement *displayBounds = [[NSXMLElement alloc] initWithName:@"bounds"];
    [displayBounds  addAttribute:[NSXMLNode attributeWithName:@"x" stringValue:[NSString stringWithFormat:@"%.0f",[displayInfo displayBounds].origin.x]]];
    [displayBounds  addAttribute:[NSXMLNode attributeWithName:@"y" stringValue:[NSString stringWithFormat:@"%.0f",[displayInfo displayBounds].origin.y]]];
    [displayBounds  addAttribute:[NSXMLNode attributeWithName:@"w" stringValue:[NSString stringWithFormat:@"%.0f",[displayInfo displayBounds].size.width]]];
    [displayBounds  addAttribute:[NSXMLNode attributeWithName:@"h" stringValue:[NSString stringWithFormat:@"%.0f",[displayInfo displayBounds].size.height]]];
    [element addChild:displayBounds];
    NSXMLElement *rotation = [[NSXMLElement alloc] initWithName:@"rotation"];
    [rotation  addAttribute:[NSXMLNode attributeWithName:@"deg" stringValue:[NSString stringWithFormat:@"%.0f",[displayInfo screenRotation]]]];
    [element addChild:rotation];
    NSXMLElement *size = [[NSXMLElement alloc] initWithName:@"size"];
    NSXMLElement *pixels = [[NSXMLElement alloc] initWithName:@"px"];
    [pixels  addAttribute:[NSXMLNode attributeWithName:@"w" stringValue:[NSString stringWithFormat:@"%ld",[displayInfo pixelsWide]]]];
    [pixels  addAttribute:[NSXMLNode attributeWithName:@"h" stringValue:[NSString stringWithFormat:@"%ld",[displayInfo pixelsHigh]]]];
    [size addChild:pixels];
    NSXMLElement *mm = [[NSXMLElement alloc] initWithName:@"mm"];
    [mm  addAttribute:[NSXMLNode attributeWithName:@"w" stringValue:[NSString stringWithFormat:@"%.0f",[displayInfo screenSize].width]]];
    [mm  addAttribute:[NSXMLNode attributeWithName:@"h" stringValue:[NSString stringWithFormat:@"%.0f",[displayInfo screenSize].height]]];
    [size addChild:mm];
    [element addChild:size];
}


/** Create a XML Element for a windowEvent
 @param WindowInfoEvent a window event info
 @return a NSXMLElement corresponding to the XML description of this windowEvent
 */
-(BOOL)addXMLElementToFileForWindowEvent:(WindowInfoEvent*)event{
    NSXMLElement* element = [self createXMLElementForWindowInfoEvent:event];
    return [self addXMLElementToRoot:element];
}



/** Create a XML Element for a windowEvent
 @param WindowInfoEvent a window event info
 @return a NSXMLElement corresponding to the XML description of this windowEvent
 */


-(NSXMLElement*)createXMLElementForWindowInfoEvent:(WindowInfoEvent*)event{
    NSXMLElement *xmlElement = [[NSXMLElement alloc] initWithName:@"windowEvent"];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"type" stringValue:[NSString stringWithFormat:@"%d",[event eventType]]]];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"time" stringValue:[NSString stringWithFormat:@"%f",[event timestamp]]]];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"clock" stringValue:[NSString stringWithFormat:@"%" PRIu64,[event clock]]]];
    NSXMLElement *eventWindow = [[NSXMLElement alloc] initWithName:@"target"];
    [self addAttributeToXMLElement:eventWindow forVnrWindow:[event windowInfo]];
    [xmlElement addChild:eventWindow];
    
    NSXMLElement *allWindows = [[NSXMLElement alloc] initWithName:@"allWindows"];
    for(VnrWindowInfo* window in [event windows]){
        NSXMLElement *windxml = [[NSXMLElement alloc] initWithName:@"window"];
        [self addAttributeToXMLElement:windxml forVnrWindow:window];
        [allWindows addChild:windxml];
    }
    [xmlElement addChild:allWindows];
    uint64 _clock = os_gettime_ns();
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"took" stringValue:[NSString stringWithFormat:@"%" PRIu64,_clock-[event clock]]]];
    return xmlElement;
}


-(void)addAttributeToXMLElement:(NSXMLElement*)element forVnrWindow:(VnrWindowInfo*)windowInfo{
    [element  addAttribute:[NSXMLNode attributeWithName:@"id" stringValue:[[windowInfo windowIDNumber] stringValue]]];
    [element  addAttribute:[NSXMLNode attributeWithName:@"app" stringValue:[windowInfo ownerName]]];
    [element  addAttribute:[NSXMLNode attributeWithName:@"title" stringValue:[windowInfo title]]];
    [element  addAttribute:[NSXMLNode attributeWithName:@"x" stringValue:[NSString stringWithFormat:@"%.0f",windowInfo.frame.origin.x]]];
    [element  addAttribute:[NSXMLNode attributeWithName:@"y" stringValue:[NSString stringWithFormat:@"%.0f",windowInfo.frame.origin.y]]];
    [element  addAttribute:[NSXMLNode attributeWithName:@"w" stringValue:[NSString stringWithFormat:@"%.0f",windowInfo.frame.size.width]]];
    [element  addAttribute:[NSXMLNode attributeWithName:@"h" stringValue:[NSString stringWithFormat:@"%.0f",windowInfo.frame.size.height]]];
}

-(BOOL)addXMLElementToFileForMouseType:(int)mouseType
                         withModifiers:(unsigned long)modifiers
                       andAXUIElements:(NSArray*)array
                                atTime:(NSTimeInterval)time
                               atClock:(uint64)clock
{
    NSXMLElement* element = [self createXMLElementForMouseType:mouseType withModifiers:modifiers andAXUIElements:array atTime:time atClock:clock];
    return [self addXMLElementToRoot:element];
}


/**
 call a method that creates a XMLElement for the ancestors contain in the array and the element+children contained in the childrenNSXMLELement
 and adds it to the  root of the XML FIle
 @param mouseType (int) value corresponding to the event type
 @param modifiers modifiers flag
 @param time at which the event occured
 @param array NSArray of all the AXUIElementRef
 @param children NSXMLElement of the selected element and all its children
 @return a YES if everything went ok
*/
-(BOOL)addXMLElementToFileForMouseType:(int)mouseType
                         withModifiers:(unsigned long)modifiers
                       andAXUIElements:(NSArray*)array
                           andChildren:(NSXMLElement*)children
                           andSiblings:(NSArray*)siblings
                                atTime:(NSTimeInterval)time
                               atClock:(uint64)clock
{
    NSXMLElement* element = [self createXMLElementForMouseType:mouseType withModifiers:modifiers andAXUIElements:array andChildren:children andSiblings:siblings atTime:time atClock:clock];
    return [self addXMLElementToRoot:element];
}

/**
 call a method that creates a XMLElement for the element+children contained in the application tree
 and adds it to the  root of the XML FIle
 @param time at which the event occured
 @param children NSXMLElement of the selected element and all its children
 @return a YES if everything went ok
 */
-(BOOL)addXMLElementToFileForApplication:(NSXMLElement*)children
                                  atTime:(NSTimeInterval)time
                                 atClock:(uint64)clock
{
    NSXMLElement* element = [self createXMLElementForApplication:children atTime:time atClock:clock];
    return [self addXMLElementToRoot:element];
}

/**
 Create an XML element for the application in focus
 @param time at which the event occured
 @param array NSArray of all the AXUIElementRef
 @return a NSXMLElement corresponding to the XML description of a AXUIelementRef at a given location and all its parents
 */
-(NSXMLElement*)createXMLElementForApplication:(NSXMLElement*)children
                                        atTime:(NSTimeInterval)time
                                       atClock:(uint64)clock
{
    NSXMLElement *xmlElement = [[NSXMLElement alloc] initWithName:@"application"];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"time" stringValue:[NSString stringWithFormat:@"%f",time]]];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"clock" stringValue:[NSString stringWithFormat:@"%" PRIu64,clock]]];
    NSXMLElement* lastchild=xmlElement;
    [lastchild addChild:children];
    uint64 _clock = os_gettime_ns();
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"took" stringValue:[NSString stringWithFormat:@"%" PRIu64,_clock-clock]]];
    return xmlElement;
    
}

/** Create a XML Element describing an element and all its children
 @param AXUIElementRef the focused element
 @return a XMLElement of all children of this element
 */
-(NSXMLElement*)xmlDescriptionOfChildrenOfElement:(AXUIElementRef)element
                                    beingSelected:(BOOL)select
{
    NSXMLElement* xmlElement = [XMLFileAccessMethods XMLElementforAXElement:element];
    if(select){
        [xmlElement addAttribute:[NSXMLNode attributeWithName:@"selected" stringValue:@"YES"]];
    }
    
    CFTypeRef visibleChildren = (__bridge CFTypeRef)([UIElementUtilities valueOfAttribute:NSAccessibilityVisibleChildrenAttribute ofUIElement:element]);
    CFTypeRef children = (__bridge AXUIElementRef)[UIElementUtilities valueOfAttribute:NSAccessibilityChildrenAttribute ofUIElement:element];
    CFTypeRef visibleRows = (__bridge CFTypeRef)([UIElementUtilities valueOfAttribute:NSAccessibilityVisibleRowsAttribute ofUIElement:element]);
    CFTypeRef rows = (__bridge CFTypeRef)([UIElementUtilities valueOfAttribute:NSAccessibilityRowsAttribute ofUIElement:element]);
    CFTypeRef visibleColumns = (__bridge CFTypeRef)([UIElementUtilities valueOfAttribute:NSAccessibilityVisibleColumnsAttribute ofUIElement:element]);
    CFTypeRef columns = (__bridge CFTypeRef)([UIElementUtilities valueOfAttribute:NSAccessibilityColumnsAttribute ofUIElement:element]);
    //todo for visiblecolumns
    
    CFTypeRef iterateOn=nil;
    
    // rows have precedence since they contain references to columns
    // if visibleChildren, it means there are non-visible children (that we don't care of)
    if(visibleRows){
        iterateOn = visibleRows;
    }
    else if(rows){
        iterateOn = rows;
    }
    else if(visibleColumns){
        iterateOn = visibleColumns;
    }
    else if(columns){
        iterateOn = columns;
    }
    else if(visibleChildren){
        iterateOn = visibleChildren;
    }
    else if(children){
        iterateOn = children;
    }
    
    if(iterateOn!=nil){
        if(CFGetTypeID(iterateOn)==CFArrayGetTypeID()){
            CFIndex count = CFArrayGetCount(iterateOn);
            if(count>0){
                for( CFIndex i = 0; i < count; i++ )
                {
                    AXUIElementRef child = (AXUIElementRef) CFArrayGetValueAtIndex(iterateOn,i);
                    [xmlElement addChild:[self xmlDescriptionOfChildrenOfElement:child beingSelected:NO]];
                }
            }
        }
    }
    return xmlElement;
}




/**
 Create an XML element for a mouse down/up  XML Element describing the AXUIElement at the event location
 @param mouseType (int) value corresponding to the event type
 @param modifiers modifiers flag
 @param time at which the event occured
 @param array NSArray of all the AXUIElementRef
 @return a NSXMLElement corresponding to the XML description of a AXUIelementRef at a given location and all its parents
 @warning likely to be obsolete
 */
-(NSXMLElement*)createXMLElementForMouseType:(int)mouseType
                               withModifiers:(unsigned long)modifiers
                             andAXUIElements:(NSArray*)array
                                      atTime:(NSTimeInterval)time
                                     atClock:(uint64)clock
{
    NSXMLElement *xmlElement = [[NSXMLElement alloc] initWithName:@"mouse"];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"type" stringValue:[NSString stringWithFormat:@"%d",mouseType]]];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"mod" stringValue:[NSString stringWithFormat:@"%lu",modifiers]]];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"time" stringValue:[NSString stringWithFormat:@"%f",time]]];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"clock" stringValue:[NSString stringWithFormat:@"%" PRIu64,clock]]];
    NSXMLElement* lastchild=xmlElement;
    if(array){
        for(int i=0; i<array.count;i++){
            
            NSObject* element = [array objectAtIndex:i];
            NSXMLElement* newElement =[XMLFileAccessMethods XMLElementforAXElement:(__bridge AXUIElementRef)(element)];
            [lastchild addChild:newElement];
            lastchild = newElement;
        }
    }
    uint64 _clock = os_gettime_ns();
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"took" stringValue:[NSString stringWithFormat:@"%" PRIu64,_clock-clock]]];
    return xmlElement;
    
}


#pragma mark log all for all windows



/**
 return an XMLElement describing the  name and relevant properties of the AXUIElementRef if the element itself is relevant
 return nil otherwise
 @param element is a AXUIElementRef
 */
+(NSXMLElement*)XMLElementOfRelevantInfoforAXElement:(AXUIElementRef)element{
    
    NSString* elementRole = [UIElementUtilities roleOfUIElement:element];
    NSXMLElement *xmlelement = [[NSXMLElement alloc] initWithName:elementRole];
    // todo test if role is relevant
    BOOL isRoleRelevant = YES;
    if(!isRoleRelevant){
        return xmlelement;
    }
   
    
    
    BOOL children = [UIElementUtilities valueOfAttribute:kAXVisibleChildrenAttribute ofUIElement:element];
    BOOL cells=YES;
    BOOL columns = YES;
    BOOL rows = YES;

    
    NSArray *		theNames;
    CFIndex			nameIndex;
    CFIndex			numOfNames;
    
    // display attributes
    theNames = [UIElementUtilities attributeNamesOfUIElement:element];
    if (theNames) {
        
        numOfNames = [theNames count];
        
        for( nameIndex = 0; nameIndex < numOfNames; nameIndex++ ) {
            
            
            // retrieve attribute name
            NSString *theName = [theNames objectAtIndex:nameIndex];
            
            
            
            
            
            [xmlelement addAttribute:[NSXMLNode attributeWithName:theName stringValue:[UIElementUtilities descriptionForUIElement:element attribute:theName beingVerbose:false]]];
            
        }
        
    }
    
    // display actions
    theNames = [UIElementUtilities actionNamesOfUIElement:element];
    if (theNames) {
        
        numOfNames = [theNames count];
        
        for( nameIndex = 0; nameIndex < numOfNames; nameIndex++ ) {
            
            NSString *	theName 		= NULL;
           	NSString *	theDesc 		= NULL;
            
            // Grab name
            theName = [theNames objectAtIndex:nameIndex];
            
            // Grab description
            theDesc = [UIElementUtilities descriptionOfAction:theName ofUIElement:element];
            
            // Add string
            [xmlelement addAttribute:[NSXMLNode attributeWithName:theName stringValue:theDesc]];
        }
        
    }
    return xmlelement;
}




// -------------------------------------------------------------------------------
//	stringDescriptionOfRelevantUIElementsBeingVerbose:
//
//	Return a descriptive string of attributes and actions of a given uiElement.
// and all his relevant children
// is consider relevant if interactive, big enough, visible, etc.
// -------------------------------------------------------------------------------
+ (NSXMLElement *)XMLDescriptionOfRelevantUIElementsBeingVerbose:(AXUIElementRef)element
{
  //  NSXMLElement *xmlElement = [[NSXMLElement alloc] initWithName:@"mouse"];
    
    // first, we check wether or not the element is "relevant"

    NSXMLElement *xmlElement = nil;
    NSString* elementRole = [UIElementUtilities roleOfUIElement:element];
    // todo test if role is relevant
    BOOL isRoleRelevant = YES;
    if(isRoleRelevant){
        xmlElement = [[NSXMLElement alloc] initWithName:@"elementRole"];
    }
    
    BOOL children = ![UIElementUtilitiesAdditions hasGivenElement:element attribute:NSAccessibilityVisibleChildrenAttribute];
    BOOL cells=  ![UIElementUtilitiesAdditions hasGivenElement:element attribute:NSAccessibilityVisibleCellsAttribute];
    BOOL columns = ![UIElementUtilitiesAdditions hasGivenElement:element attribute:NSAccessibilityVisibleColumnsAttribute];
    BOOL rows = ![UIElementUtilitiesAdditions hasGivenElement:element attribute:NSAccessibilityVisibleRowsAttribute];
    
    NSXMLElement *actions = [[NSXMLElement alloc] initWithName:@"actions"];
    
    NSArray *		theNames;
    CFIndex			nameIndex;
    CFIndex			numOfNames;
    
//## HEREHEREHEREHEREHERE
    
    
    
    
    
    // display actions
    theNames = [UIElementUtilities attributeNamesOfUIElement:element];
    if (theNames) {
        
        numOfNames = [theNames count];
        
        for( nameIndex = 0; nameIndex < numOfNames; nameIndex++ ) {
            
            NSString *	theName 		= NULL;
           	NSString *	theDesc 		= NULL;
            
            // Grab name
            theName = [theNames objectAtIndex:nameIndex];
            
            // Grab description
            theDesc = [UIElementUtilities descriptionOfAction:theName ofUIElement:element];
            
            // Add string
            [xmlElement addAttribute:[NSXMLNode attributeWithName:theName stringValue:theDesc]];
        }
        
    }

    
    
    return nil;
    
    
    
    
    
    
    
//    
//
//    NSArray *		theNames;
//    CFIndex			nameIndex;
//    CFIndex			numOfNames;
//    
//    
//    NSMutableArray* ignoreItems = [NSMutableArray new];
//    
//    // display actions
//    NSArray * theActions = [UIElementUtilities actionNamesOfUIElement:element];
//    // Actions should contain the name of action so check weither or not this is relevant
//    // and instantiate the value of isRelevant with correct value
//    
//    
//    BOOL isRelevant= [UIElementUtilitiesAdditions isRelevantActionContainedInArrayOfActions:theActions];
//    
//    
//    NSString* elementRole = [UIElementUtilities roleOfUIElement:element];
//    if(!isRelevant){
//        // element role is the role of current element
//        // test wether or not the role is relevant
//        // and update the value of isrelevant
//        isRelevant = [UIElementUtilitiesAdditions isRelevantRole:elementRole];
//    }
//    
//    
//    if(isRelevant){
//        //TODO: here we should do what we have to do.
//        // either store the interesting information in a string (this one is dummy)
//        NSString* dummyString = [NSString stringWithFormat:@"%@",elementRole];
//        
//        
//        
//        // and append it to the theDescriptionStr
//        [theDescriptionStr appendFormat:@"%@",elementRole];
//        
//        for(NSString* action in theActions){
//            [theDescriptionStr appendFormat:@"-%@",action];
//        }
//        // or write the log somewhere
//        [theDescriptionStr appendFormat:@"\n"];
//    }
//    
//    
//    
//    BOOL hasVisibleChildren = YES;
//    NSArray* visibleChildren = [UIElementUtilities valueOfAttribute:NSAccessibilityVisibleChildrenAttribute ofUIElement:element];
//    if(visibleChildren){
//        if([visibleChildren count]==0){
//            hasVisibleChildren=NO;
//        }
//    }
//    
//    
//    if(hasVisibleChildren){
//        
//        
//        CFTypeRef children = (__bridge AXUIElementRef)[UIElementUtilities valueOfAttribute:NSAccessibilityChildrenAttribute ofUIElement:element];
//        if(children){
//            if(CFGetTypeID(children)==CFArrayGetTypeID()){
//                CFIndex count = CFArrayGetCount(children);
//                if(count>0){
//                    
//                    for( CFIndex i = 0; i < count; i++ )
//                    {
//                        AXUIElementRef child = (AXUIElementRef) CFArrayGetValueAtIndex(children,i);
//                        [theDescriptionStr appendFormat:@"%@",[UIElementUtilitiesAdditions stringDescriptionOfRelevantUIElementsBeingVerbose:child]];
//                    }
//                }
//            }
//        }
//    }
    
    
    
    
    
    
    
    
    
    return xmlElement;
}





/**
 return an XMLElement describing the entire name and properties of the AXUIElementRef
 @param element is a AXUIElementRef
 */
+(NSXMLElement*)PREVIOUSXMLElementOfRelevantInfoforAXElement:(AXUIElementRef)element{
    NSXMLElement *xmlelement = [[NSXMLElement alloc] initWithName:[UIElementUtilities roleOfUIElement:element]];
    
    
    NSArray *		theNames;
    CFIndex			nameIndex;
    CFIndex			numOfNames;
    
    // display attributes
    theNames = [UIElementUtilities attributeNamesOfUIElement:element];
    if (theNames) {
        
        numOfNames = [theNames count];
        
        for( nameIndex = 0; nameIndex < numOfNames; nameIndex++ ) {
            
            NSString *	theName = NULL;
            
            // Grab name
            theName = [theNames objectAtIndex:nameIndex];
            
            [xmlelement addAttribute:[NSXMLNode attributeWithName:theName stringValue:[UIElementUtilities descriptionForUIElement:element attribute:theName beingVerbose:false]]];
            
        }
        
    }
    
    // display actions
    theNames = [UIElementUtilities actionNamesOfUIElement:element];
    if (theNames) {
        
        numOfNames = [theNames count];
        
        for( nameIndex = 0; nameIndex < numOfNames; nameIndex++ ) {
            
            NSString *	theName 		= NULL;
           	NSString *	theDesc 		= NULL;
            
            // Grab name
            theName = [theNames objectAtIndex:nameIndex];
            
            // Grab description
            theDesc = [UIElementUtilities descriptionOfAction:theName ofUIElement:element];
            
            // Add string
            [xmlelement addAttribute:[NSXMLNode attributeWithName:theName stringValue:theDesc]];
        }
        
    }
    return xmlelement;
}

- (void)close{
    xmldoc = nil;
}


@end
