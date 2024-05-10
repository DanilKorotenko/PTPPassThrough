//------------------------------------------------------------------------------------------------------------------------------
//
// File:       Controller.m
//
// Abstract:   Cocoa PTP pass-through test application.
//
// Version:    1.0
//
// Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc. ("Apple")
//             in consideration of your agreement to the following terms, and your use,
//             installation, modification or redistribution of this Apple software
//             constitutes acceptance of these terms.  If you do not agree with these
//             terms, please do not use, install, modify or redistribute this Apple
//             software.
//
//             In consideration of your agreement to abide by the following terms, and
//             subject to these terms, Apple grants you a personal, non - exclusive
//             license, under Apple's copyrights in this original Apple software ( the
//             "Apple Software" ), to use, reproduce, modify and redistribute the Apple
//             Software, with or without modifications, in source and / or binary forms;
//             provided that if you redistribute the Apple Software in its entirety and
//             without modifications, you must retain this notice and the following text
//             and disclaimers in all such redistributions of the Apple Software. Neither
//             the name, trademarks, service marks or logos of Apple Inc. may be used to
//             endorse or promote products derived from the Apple Software without specific
//             prior written permission from Apple.  Except as expressly stated in this
//             notice, no other rights or licenses, express or implied, are granted by
//             Apple herein, including but not limited to any patent rights that may be
//             infringed by your derivative works or by other works in which the Apple
//             Software may be incorporated.
//
//             The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
//             WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
//             WARRANTIES OF NON - INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
//             PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION
//             ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//
//             IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
//             CONSEQUENTIAL DAMAGES ( INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//             SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//             INTERRUPTION ) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION
//             AND / OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER
//             UNDER THEORY OF CONTRACT, TORT ( INCLUDING NEGLIGENCE ), STRICT LIABILITY OR
//             OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// Copyright ( C ) 2009 Apple Inc. All Rights Reserved.
//
//------------------------------------------------------------------------------------------------------------------------------

#import "PTPProtocolHelpers.h"
#import "PTPOperationRequest.h"
#import "Controller.h"

@interface Controller ()

@property(strong) IBOutlet NSTextView *logView;
@property(strong) IBOutlet NSTextField *dataSize;

@property(strong) ICCameraDevice *camera;
@property(strong) ICDeviceBrowser *deviceBrowser;

@property(readwrite) uint32_t storageID;
@property(readwrite) uint32_t numObjects;
@property(readwrite) uint32_t *objects;

@end

@implementation Controller

//-------------------------------------------------------------------------------------------------------------------------- log

- (void)log:(NSString*)str
{
    dispatch_async(dispatch_get_main_queue(),
    ^{
        self.logView.string = [self.logView.string stringByAppendingString:str];
        [self.logView display];
    });
}

//----------------------------------------------------------------------------------------------------- dumpData:length:comment:
// This method dumps a buffer in hexadecimal format

- (void)dumpData:(void*)data length:(int)length comment:(NSString*)comment
{
    UInt32 i;
    UInt32 j;
    UInt8*  p;
    char    fStr[80];
    char*   fStrP;
    NSMutableString*  s = [NSMutableString stringWithFormat:@"\n  %@ [%d bytes]:\n\n", comment, length];

    p = (UInt8*)data;

    for ( i = 0; i < length; i++ )
    {
        if ( (i % 16) == 0 )
        {
            fStrP = fStr;
            fStrP += snprintf( fStrP, 10, "    %4X:", (unsigned int)i );
        }

        if ( (i % 4) == 0 )
        {
            fStrP += snprintf( fStrP, 2, " " );
        }

        fStrP += snprintf( fStrP, 3, "%02X", (UInt8)(*(p+i)) );
        if ( (i % 16) == 15 )
        {
            fStrP += snprintf( fStrP, 2, " " );
            for ( j = i-15; j <= i; j++ )
            {
                if ( *(p+j) < 32 || *(p+j) > 126 )
                {
                    fStrP += snprintf( fStrP, 2, "." );
                }
                else
                {
                    fStrP += snprintf( fStrP, 2, "%c", *(p+j) );
                }
            }
            [s appendFormat:@"%s\n", fStr];
        }

        if ( (i % 256) == 255 )
        {
            [s appendString:@"\n"];
        }
    }

    if ( (i % 16) )
    {
        for ( j = (i % 16); j < 16; j ++ )
        {
            fStrP += snprintf( fStrP, 3, "  " );
            if ( (j % 4) == 0 )
            {
                fStrP += snprintf( fStrP, 2, " " );
            }
        }
        fStrP += snprintf( fStrP, 2, " " );
        for ( j = i - (i % 16 ); j < length; j++ )
        {
            if ( *(p+j) < 32 || *(p+j) > 126 )
            {
                fStrP += snprintf( fStrP, 2, "." );
            }
            else
            {
                fStrP += snprintf( fStrP, 2, "%c", *(p+j) );
            }
        }
        for ( j = (i % 16); j < 16; j ++ )
        {
            fStrP += snprintf( fStrP, 2, " " );
        }
        [s appendFormat:@"%s\n", fStr];
    }

      [s appendString:@"\n"];
      [self log:s];
}

#pragma mark -

- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
    [self.logView setFont:[NSFont userFixedPitchFontOfSize:10]];
    self.deviceBrowser = [[ICDeviceBrowser alloc] init];
    self.deviceBrowser.delegate = self;
    self.deviceBrowser.browsedDeviceTypeMask = ICDeviceTypeMaskCamera | ICDeviceLocationTypeMaskLocal;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)applicationWillTerminate: (NSNotification *)notification
{
    self.camera = nil;
    self.deviceBrowser = nil;
}

#pragma mark -
#pragma mark ICDeviceBrowser delegate methods

- (void)deviceBrowser:(ICDeviceBrowser*)browser didAddDevice:(ICDevice*)addedDevice moreComing:(BOOL)moreComing
{
    // use the first PTP camera
    if ( ( self.camera == NULL ) && ( (addedDevice.type & ICDeviceTypeMaskCamera) == ICDeviceTypeCamera ) )
    {
        if ( [addedDevice.capabilities containsObject:ICCameraDeviceCanAcceptPTPCommands] )
        {
            [self log:[NSString stringWithFormat:@"\nFound a PTP camera '%@'.\n", addedDevice.name]];

            self.camera           = (ICCameraDevice*)addedDevice;
            self.camera.delegate  = self;

            [self log:[NSString stringWithFormat:@"\nOpening a session on '%@'...\n", self.camera.name]];
            [self.camera requestOpenSession];
        }
    }
}

- (void)deviceBrowser:(ICDeviceBrowser*)browser didRemoveDevice:(ICDevice*)removedDevice moreGoing:(BOOL)moreGoing
{
    if ( self.camera == removedDevice )
    {
        [self log:[NSString stringWithFormat:@"\nPTP camera '%@' has been removed.\n", removedDevice.name]];
        self.camera = NULL;
    }
}

#pragma mark -
#pragma mark ICDevice & ICCameraDevice delegate methods

- (void)didRemoveDevice:(ICDevice*)removedDevice
{
    if ( self.camera == removedDevice )
    {
        [self log:[NSString stringWithFormat:@"\nPTP camera '%@' has been removed.\n", removedDevice.name]];
        self.camera = NULL;
    }
}

- (void)device:(ICDevice*)device didOpenSessionWithError:(NSError*)error
{
    if ( error )
    {
        [self log:[NSString stringWithFormat:@"\nFailed to open a session on '%@'.\nError: %@\n", device.name, error]];
    }
    else
    {
        [self log:[NSString stringWithFormat:@"\nSession opened on '%@'.\n", device.name]];
    }
}

- (void)deviceDidBecomeReady:(ICCameraDevice*)camera;
{
    [self log:[NSString stringWithFormat:@"\nPTP camera '%@' is ready.\n", camera.name]];
}

- (void)device:(ICDevice*)device didCloseSessionWithError:(NSError*)error
{
    if ( error )
    {
        [self log:[NSString stringWithFormat:@"\nFailed to close a session on '%@'.\nError: %@\n", device.name, error]];
    }
    else
    {
        [self log:[NSString stringWithFormat:@"\nSession closed on '%@'.\n", device.name]];
    }
}

- (void)device:(ICDevice*)device didEncounterError:(NSError*)error
{
    [self log:[NSString stringWithFormat:@"\nPTP camera '%@' encountered an error: \n%@\n", device.name, error]];
}

- (void)cameraDevice:(ICCameraDevice*)camera didReceivePTPEvent:(NSData*)eventData
{
    PTPEvent* event = [[PTPEvent alloc] initWithData:eventData];
    [self log:@"\nReceived a PTP event:"];
    [self log:[event description]];
}

- (void)cameraDevice:(nonnull ICCameraDevice *)camera didAddItems:(nonnull NSArray<ICCameraItem *> *)items
{
    [self log:[NSString stringWithFormat:@"\nPTP camera '%@' Did add items\n", camera.name]];
}

- (void)cameraDevice:(nonnull ICCameraDevice *)camera didReceiveMetadata:(NSDictionary * _Nullable)metadata
    forItem:(nonnull ICCameraItem *)item error:(NSError * _Nullable)error
{
    [self log:[NSString stringWithFormat:@"\nPTP camera '%@' didReceiveMetadata\n", camera.name]];
}

- (void)cameraDevice:(nonnull ICCameraDevice *)camera didReceiveThumbnail:(CGImageRef _Nullable)thumbnail
    forItem:(nonnull ICCameraItem *)item error:(NSError * _Nullable)error
{
    [self log:[NSString stringWithFormat:@"\nPTP camera '%@' didReceiveThumbnail\n", camera.name]];
}

- (void)cameraDevice:(nonnull ICCameraDevice *)camera didRemoveItems:(nonnull NSArray<ICCameraItem *> *)items
{
    [self log:[NSString stringWithFormat:@"\nPTP camera '%@' didRemoveItems\n", camera.name]];
}

- (void)cameraDevice:(nonnull ICCameraDevice *)camera didRenameItems:(nonnull NSArray<ICCameraItem *> *)items
{
    [self log:[NSString stringWithFormat:@"\nPTP camera '%@' didRenameItems\n", camera.name]];
}

- (void)cameraDeviceDidChangeCapability:(nonnull ICCameraDevice *)camera
{
    [self log:[NSString stringWithFormat:@"\nPTP camera '%@' cameraDeviceDidChangeCapability\n", camera.name]];
}

- (void)cameraDeviceDidEnableAccessRestriction:(nonnull ICDevice *)device
{
    [self log:[NSString stringWithFormat:@"\nPTP camera '%@' cameraDeviceDidEnableAccessRestriction\n", device.name]];
}

- (void)cameraDeviceDidRemoveAccessRestriction:(nonnull ICDevice *)device
{
    [self log:[NSString stringWithFormat:@"\nPTP camera '%@' cameraDeviceDidRemoveAccessRestriction\n", device.name]];
}

- (void)deviceDidBecomeReadyWithCompleteContentCatalog:(nonnull ICCameraDevice *)device
{
    [self log:[NSString stringWithFormat:@"\nPTP camera '%@' deviceDidBecomeReadyWithCompleteContentCatalog\n", device.name]];
}

// ------------------ didSendCommand:data:response:error:contextInfo:
// This delegate method is invoked when "requestSendPTPCommand:..." is completed. Please refer to ICCameraDevice.h file in ImageCaptureCore.framework for more information about how to use the "requestSendPTPCommand:..." method.

 - (void)didSendPTPCommand:(NSData*)command inData:(NSData*)data response:(NSData*)response error:(NSError*)error
    contextInfo:(void*)contextInfo
{
    PTPOperationRequest     *ptpRequest  = (PTPOperationRequest*)CFBridgingRelease(contextInfo);
    PTPOperationResponse    *ptpResponse = NULL;

    if ( ptpRequest )
    {
        [self log:@"\nCompleted request:"];
        [self log:[ptpRequest description]];
    }

    if ( data )
    {
        [self log:@"\nReceived data:"];
        [self dumpData:(void*)[data bytes] length:(int)[data length] comment:@"inData"];
    }

    if ( response )
    {
        ptpResponse = [[PTPOperationResponse alloc] initWithData:response];
        [self log:@"\nReceived response:"];
        [self log:[ptpResponse description]];
    }

    switch ( ptpRequest.operationCode )
    {
        case PTPOperationCodeGetStorageIDs:
        {
            if ( ptpResponse && (ptpResponse.responseCode == PTPResponseCodeOK) && data )
            {
                uint32_t* temp = (uint32_t*)[data bytes];

                self.storageID = *(++temp);
                [self log:[NSString stringWithFormat:@"\nstorageID: %d", self.storageID]];
            }
            break;
        }

        case PTPOperationCodeGetNumObjects:
        {
            if ( ptpResponse && (ptpResponse.responseCode == PTPResponseCodeOK) )
            {
                self.numObjects = ptpResponse.parameter1;
                [self log:[NSString stringWithFormat:@"\nnumObjects: %d", self.numObjects]];
            }
            break;
        }

        case PTPOperationCodeGetObjectHandles:
        {
            if ( ptpResponse && (ptpResponse.responseCode == PTPResponseCodeOK) && data )
            {
                uint32_t* temp = (uint32_t*)[data bytes];
                uint32_t  i;

                self.numObjects = *temp;

                if ( self.objects )
                {
                    free( self.objects );
                    self.objects = NULL;
                }

                self.objects = malloc( self.numObjects*sizeof(uint32_t) );
                memcpy( self.objects, ++temp, self.numObjects*sizeof(uint32_t) );

                [self log:[NSString stringWithFormat:@"\nnumObjects: %d", self.numObjects]];
                for ( i = 0; i < self.numObjects; ++i )
                {
                    [self log:[NSString stringWithFormat:@"\n  object %d: 0x%08X", i, self.objects[i]]];
                }
            }
            break;
        }
    }
}

#pragma mark -

- (IBAction)startStopBrowsing:(id)sender
{
    if ( self.deviceBrowser.browsing == NO )
    {
        [self.deviceBrowser start];
        [self log:@"Looking for a PTP camera...\n"];
        [sender setTitle:@"Stop Browsing"];
    }
    else
    {
        [self.deviceBrowser stop];
        [self log:@"Stopped looking for a PTP camera.\n"];
        [sender setTitle:@"Start Browsing"];
    }
}

- (IBAction)getStorageIDs:(id)sender;
{
    NSData*               commandBuffer = NULL;
    PTPOperationRequest*  request       = [[PTPOperationRequest alloc] init];

    request.operationCode       = PTPOperationCodeGetStorageIDs;
    request.numberOfParameters  = 0;
    commandBuffer               = request.commandBuffer;

    [self log:@"\nSending PTP request:"];
    [self log:[request description]];

    [self.camera requestSendPTPCommand:commandBuffer outData:NULL sendCommandDelegate:self
        didSendCommandSelector:@selector(didSendPTPCommand:inData:response:error:contextInfo:)
        contextInfo:(void *)CFBridgingRetain(request)];
}

- (IBAction)getNumObjects:(id)sender;
{
    if ( self.storageID )
    {
        NSData*               commandBuffer = NULL;
        PTPOperationRequest*  request       = [[PTPOperationRequest alloc] init];

        request.operationCode       = PTPOperationCodeGetNumObjects;
        request.numberOfParameters  = 3;
        request.parameter1          = self.storageID;
        request.parameter2          = 0;
        request.parameter3          = 0;
        commandBuffer               = request.commandBuffer;

        [self log:@"\nSending PTP request:"];
        [self log:[request description]];

        [self.camera requestSendPTPCommand:commandBuffer outData:NULL sendCommandDelegate:self
            didSendCommandSelector:@selector(didSendPTPCommand:inData:response:error:contextInfo:)
            contextInfo:(void *)CFBridgingRetain(request)];
    }
}

- (IBAction)getObjectHandles:(id)sender;
{
    if ( self.numObjects )
    {
        NSData*               commandBuffer = NULL;
        PTPOperationRequest*  request       = [[PTPOperationRequest alloc] init];

        request.operationCode       = PTPOperationCodeGetObjectHandles;
        request.numberOfParameters  = 3;
        request.parameter1          = self.storageID;
        request.parameter2          = 0;
        request.parameter3          = 0;
        commandBuffer               = request.commandBuffer;

        [self log:@"\nSending PTP request:"];
        [self log:[request description]];

        [self.camera requestSendPTPCommand:commandBuffer outData:NULL sendCommandDelegate:self
            didSendCommandSelector:@selector(didSendPTPCommand:inData:response:error:contextInfo:)
            contextInfo:(void *)CFBridgingRetain(request)];
    }
}

- (IBAction)getPartialObject:(id)sender;
{
    if ( self.numObjects && self.objects )
    {
        NSData*               commandBuffer = NULL;
        PTPOperationRequest*  request       = [[PTPOperationRequest alloc] init];

        request.operationCode       = PTPOperationCodeGetPartialObject;
        request.numberOfParameters  = 3;
        request.parameter1          = self.objects[self.numObjects-1];  // last object
        request.parameter2          = 0;
        request.parameter3          = [self.dataSize intValue];
        commandBuffer               = request.commandBuffer;

        [self log:@"\nSending PTP request:"];
        [self log:[request description]];

        [self.camera requestSendPTPCommand:commandBuffer outData:NULL sendCommandDelegate:self
            didSendCommandSelector:@selector(didSendPTPCommand:inData:response:error:contextInfo:)
            contextInfo:(void *)CFBridgingRetain(request)];
    }
}

@end
