CMAKE_MINIMUM_REQUIRED(VERSION 2.8.12 FATAL_ERROR)
project(AXRecord)
set(LIBNAME "libAXRecord")
set(GUIAPPNAME "AXRecordGUI")
set(CLIAPPNAME "AXRecordCLI")

message("AXRecord")

## LIB

set(${LIBNAME}_HDRS 
	AXRecord.h
	AXRecordController.h
	AXElementTracker.h
	AXSelectedArray.h
	AppLogger.h
	AppTracker.h
	DisplayInfo.h
	DisplaysGrabber.h
	DisplaysInfoEvent.h
	DisplaysTracker.h
	UIElementUtilities.h
	UIElementUtilitiesAdditions.h
	VnrWindowInfo.h
	WindowGrabber.h
	WindowInfoEvent.h
	WindowTracker.h
	XMLFileAccessMethods.h
	platform.h
)

set(${LIBNAME}_SRCS 
	AXRecord.m
	AXRecordController.m
	AXElementTracker.m
	AXSelectedArray.m
	AppLogger.m
	AppTracker.m
	DisplayInfo.m
	DisplaysGrabber.m
	DisplaysInfoEvent.m
	DisplaysTracker.m
	UIElementUtilities.m
	UIElementUtilitiesAdditions.m
	VnrWindowInfo.m
	WindowGrabber.m
	WindowInfoEvent.m
	WindowTracker.m
	XMLFileAccessMethods.m
	platform-cocoa.m
)

# From vtk/Examples/GUI/Cocoa/CMakeLists.txt
# Build all Objective-C as ARC.
# Otherwise with Xcode 7.3: "error: cannot synthesize weak property in file using manual reference counting"
# Except: UIElementUtilities.m
# Otherwise:
# error: ARC forbids explicit message send of 'autorelease'
# + error: cast of an indirect pointer to an Objective-C pointer (...) is disallowed with ARC
# + error: 'autorelease' is unavailable: not available in automatic reference counting mode
set_source_files_properties( 
	AXRecord.m
	AXRecordController.m
	AXSelectedArray.m
	AppLogger.m
	AppTracker.m
	DisplayInfo.m
	DisplaysGrabber.m
	DisplaysInfoEvent.m
	DisplaysTracker.m
	UIElementUtilitiesAdditions.m
	VnrWindowInfo.m
	WindowGrabber.m
	WindowInfoEvent.m
	WindowTracker.m
	XMLFileAccessMethods.m
	platform-cocoa.m
PROPERTIES COMPILE_FLAGS "-fobjc-arc")

add_library(${LIBNAME} ${${LIBNAME}_HDRS} ${${LIBNAME}_SRCS})

## GUI APP
option(BUILD_GUI "Build GUI app" ON)
if(BUILD_GUI)
set(${GUIAPPNAME}_HDRS 
	AppDelegate.h
	TableController.h
)

set(${GUIAPPNAME}_SRCS 
	AppDelegate.m
	TableController.m
	main.m
)

# From vtk/Examples/GUI/Cocoa/CMakeLists.txt
# Build all Objective-C as ARC.
# Otherwise with Xcode 7.3: "error: cannot synthesize weak property in file using manual reference counting"
set_source_files_properties( 
	AppDelegate.m
	TableController.m
	main.m
PROPERTIES COMPILE_FLAGS "-fobjc-arc")

# From vtk/Examples/GUI/Cocoa/CMakeLists.txt 
set(MACOSX_BUNDLE_GUI_IDENTIFIER "fr.inria.lille.mjolnir.malacria.AXRecord")
set(MACOSX_BUNDLE_BUNDLE_NAME ${GUIAPPNAME})
set(MACOSX_BUNDLE_NSMAIN_NIB_FILE "MainMenu")
set(MACOSX_BUNDLE_NSPRINCIPAL_CLASS "NSApplication")
set(MACOSX_BUNDLE_COPYRIGHT "Copyright © 2016 Sylvain Malacria. All rights reserved.")

add_executable(${GUIAPPNAME} MACOSX_BUNDLE ${${GUIAPPNAME}_HDRS} ${${GUIAPPNAME}_SRCS})
target_link_libraries(${GUIAPPNAME} ${LIBNAME} "-framework Cocoa")

# From vtk/Examples/GUI/Cocoa/CMakeLists.txt 
# Set a custom plist file for the app bundle
set_target_properties(${GUIAPPNAME} PROPERTIES MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info-CMake.plist)

# Make sure we can find the 'ibtool' program. If we can NOT find it we
# skip generation of this project
find_program(IBTOOL ibtool HINTS "/usr/bin" "${OSX_DEVELOPER_ROOT}/usr/bin")
if (${IBTOOL} STREQUAL "IBTOOL-NOTFOUND")
  message(SEND_ERROR "ibtool can not be found and is needed to compile the .xib files. It should have been installed with the Apple developer tools. The default system paths were searched in addition to ${OSX_DEVELOPER_ROOT}/usr/bin")
endif()

# Make sure the 'Resources' Directory is correctly created before we build
add_custom_command (TARGET ${GUIAPPNAME} PRE_BUILD
                      COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/${GUIAPPNAME}.app/Contents/Resources)

# Compile the .xib files using the 'ibtool' program with the destination being the app package
add_custom_command (TARGET ${GUIAPPNAME} POST_BUILD
                      COMMAND ${IBTOOL} --errors --warnings --notices --output-format human-readable-text --compile ${CMAKE_CURRENT_BINARY_DIR}/${GUIAPPNAME}.app/Contents/Resources/${MACOSX_BUNDLE_NSMAIN_NIB_FILE}.nib ${CMAKE_CURRENT_SOURCE_DIR}/Base.lproj/${MACOSX_BUNDLE_NSMAIN_NIB_FILE}.xib
                      COMMENT "Compiling ${CMAKE_CURRENT_SOURCE_DIR}/Base.lproj/${MACOSX_BUNDLE_NSMAIN_NIB_FILE}.xib"
)

endif(BUILD_GUI)
## CLI
option(BUILD_CLI "Build GUI app" ON)
if(BUILD_CLI)

set(${CLIAPPNAME}_HDRS 
	ConsoleController.h
)

set(${CLIAPPNAME}_SRCS 
	ConsoleController.m
	ConsoleMain.m
)

# From vtk/Examples/GUI/Cocoa/CMakeLists.txt
# Build all Objective-C as ARC.
# Otherwise with Xcode 7.3: "error: cannot synthesize weak property in file using manual reference counting"
set_source_files_properties( 
	ConsoleController.m
PROPERTIES COMPILE_FLAGS "-fobjc-arc")

add_executable(${CLIAPPNAME} ${${CLIAPPNAME}_HDRS} ${${CLIAPPNAME}_SRCS})
target_link_libraries(${CLIAPPNAME} ${LIBNAME} "-framework Cocoa")
endif(BUILD_CLI)
