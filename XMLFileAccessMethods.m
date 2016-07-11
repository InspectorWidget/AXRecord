//
//  XMLFileAccessMethods.m
//  AXAll
//
//  Created by Sylvain Malacria on 03/03/16.
//  Copyright © 2016 Sylvain Malacria. All rights reserved.
//

#import "XMLFileAccessMethods.h"
#import "UIElementUtilities.h"
#import "UIElementUtilitiesAdditions.h"

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

-(BOOL)writeChangeApp:(NSString*)appname atTime:(NSTimeInterval)time{
    if(xmldoc){
        NSXMLElement *xmlElement = [[NSXMLElement alloc] initWithName:@"appchange"];
        [xmlElement addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:appname]];
        [xmlElement addAttribute:[NSXMLNode attributeWithName:@"time" stringValue:[NSString stringWithFormat:@"%f",time]]];
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




/**
 Create a  XMLElement for a mouse down/up  XML Element describing the AXUIElement at the event location, all its ancestors and all of its children
 @param mouseType (int) value corresponding to the event type
 @param modifiers modifiers flag
 @param time at which the event occured
 @param array NSArray of all the AXUIElementRef
 @param children NSXMLElement of the selected element and all its children
 @return a NSXMLElement corresponding to the XML description of a AXUIelementRef at a given location and all its parents
 */
-(NSXMLElement*)createXMLElementForMouseType:(int)mouseType withModifiers:(unsigned long)modifiers andAXUIElements:(NSArray*)array andChildren:(NSXMLElement*)children andSiblings:(NSArray*)siblings atTime:(NSTimeInterval)time{
    
    NSXMLElement *xmlElement = [[NSXMLElement alloc] initWithName:@"mouse"];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"type" stringValue:[NSString stringWithFormat:@"%d",mouseType]]];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"mod" stringValue:[NSString stringWithFormat:@"%lu",modifiers]]];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"time" stringValue:[NSString stringWithFormat:@"%f",time]]];
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
    
    return xmlElement;
    
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

-(BOOL)addXMLElementToFileForMouseType:(int)mouseType withModifiers:(unsigned long)modifiers andAXUIElements:(NSArray*)array atTime:(NSTimeInterval)time{
    NSXMLElement* element = [self createXMLElementForMouseType:mouseType withModifiers:modifiers andAXUIElements:array atTime:time];
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
-(BOOL)addXMLElementToFileForMouseType:(int)mouseType withModifiers:(unsigned long)modifiers andAXUIElements:(NSArray*)array andChildren:(NSXMLElement*)children andSiblings:(NSArray*)siblings atTime:(NSTimeInterval)time{
    NSXMLElement* element = [self createXMLElementForMouseType:mouseType withModifiers:modifiers andAXUIElements:array andChildren:children andSiblings:siblings atTime:time];
    return [self addXMLElementToRoot:element];
}

/**
 call a method that creates a XMLElement for the element+children contained in the application tree
 and adds it to the  root of the XML FIle
 @param time at which the event occured
 @param children NSXMLElement of the selected element and all its children
 @return a YES if everything went ok
 */
-(BOOL)addXMLElementToFileForApplication:(NSXMLElement*)children atTime:(NSTimeInterval)time{
    NSXMLElement* element = [self createXMLElementForApplication:children atTime:time];
    return [self addXMLElementToRoot:element];
}

/**
 Create an XML element for the application in focus
 @param time at which the event occured
 @param array NSArray of all the AXUIElementRef
 @return a NSXMLElement corresponding to the XML description of a AXUIelementRef at a given location and all its parents
 */
-(NSXMLElement*)createXMLElementForApplication:(NSXMLElement*)children atTime:(NSTimeInterval)time{
    
    NSXMLElement *xmlElement = [[NSXMLElement alloc] initWithName:@"application"];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"time" stringValue:[NSString stringWithFormat:@"%f",time]]];
    NSXMLElement* lastchild=xmlElement;
    [lastchild addChild:children];
    return xmlElement;
    
}

/** Create a XML Element describing an element and all its children
 @param AXUIElementRef the focused element
 @return a XMLElement of all children of this element
 */
-(NSXMLElement*)xmlDescriptionOfChildrenOfElement:(AXUIElementRef)element beingSelected:(BOOL)select{
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
-(NSXMLElement*)createXMLElementForMouseType:(int)mouseType withModifiers:(unsigned long)modifiers andAXUIElements:(NSArray*)array atTime:(NSTimeInterval)time{
    
    NSXMLElement *xmlElement = [[NSXMLElement alloc] initWithName:@"mouse"];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"type" stringValue:[NSString stringWithFormat:@"%d",mouseType]]];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"mod" stringValue:[NSString stringWithFormat:@"%lu",modifiers]]];
    [xmlElement addAttribute:[NSXMLNode attributeWithName:@"time" stringValue:[NSString stringWithFormat:@"%f",time]]];
    NSXMLElement* lastchild=xmlElement;
    if(array){
        for(int i=0; i<array.count;i++){
            
            NSObject* element = [array objectAtIndex:i];
            NSXMLElement* newElement =[XMLFileAccessMethods XMLElementforAXElement:(__bridge AXUIElementRef)(element)];
            [lastchild addChild:newElement];
            lastchild = newElement;
        }
    }
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




@end
