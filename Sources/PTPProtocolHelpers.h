//------------------------------------------------------------------------------------------------------------------------------
//
// File:       PTPProtocolHelpers.h
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

#import <Cocoa/Cocoa.h>

#import "PTPEnums.h"

short PTPReadShort( unsigned char** buf );
void PTPWriteShort( unsigned char** buf, short value );

unsigned short PTPReadUnsignedShort( unsigned char** buf );
void PTPWriteUnsignedShort( unsigned char** buf, unsigned short value );

int PTPReadInt( unsigned char** buf );
void PTPWriteInt( unsigned char** buf, int value );

unsigned int PTPReadUnsignedInt( unsigned char** buf );
void PTPWriteUnsignedInt( unsigned char** buf, unsigned int value );

long long PTPReadLongLong( unsigned char** buf );
void PTPWriteLongLong( unsigned char** buf, long long value );

unsigned long long PTPReadUnsignedLongLong( unsigned char** buf );
void PTPWriteUnsignedLongLong( unsigned char** buf, unsigned long long value );

//--------------------------------------------------------------------------------------------------------- PTPOperationResponse
/*! 
  @class PTPOperationResponse
  @abstract The OperationResponse object is returned by the device in response to a PTP operation request.
*/

@interface PTPOperationResponse : NSObject
{
@private
    id mPrivateData;
}

/*! 
  @property responseCode
  @abstract PTP response code.
*/
@property(readonly)     unsigned short    responseCode;

/*! 
  @property transactionID
  @abstract PTP transaction ID.
*/
@property(readonly)     unsigned int      transactionID;

/*! 
  @property numberOfParameters
  @abstract Number of parameters received from the device. This cannot be greater than 5.
*/
@property(readonly)     unsigned short    numberOfParameters;

/*! 
  @property parameter1
  @abstract Parameter 1.
*/
@property(readonly)     unsigned int      parameter1;

/*! 
  @property parameter2
  @abstract Parameter 2.
*/
@property(readonly)     unsigned int      parameter2;

/*! 
  @property parameter3
  @abstract Parameter 3.
*/
@property(readonly)     unsigned int      parameter3;

/*! 
  @property parameter4
  @abstract Parameter 4.
*/
@property(readonly)     unsigned int      parameter4;

/*! 
  @property parameter5
  @abstract Parameter 5.
*/
@property(readonly)     unsigned int      parameter5;

- (id)initWithData:(NSData*)data;

@end

//--------------------------------------------------------------------------------------------------------------------- PTPEvent
/*! 
  @class Event
  @abstract The PTPEvent object is sent by the device. The developer should refer to the PTP specification document, PIMA 15740:2000, for more information about when a device is likely to send PTP events.
*/

@interface PTPEvent : NSObject
{
@private
    id mPrivateData;
}

/*! 
  @property eventCode
  @abstract PTP event code.
*/
@property(readonly)     unsigned short    eventCode;

/*! 
  @property transactionID
  @abstract PTP transaction ID.
*/
@property(readonly)     unsigned int      transactionID;

/*! 
  @property numberOfParameters
  @abstract Number of parameters received from the device. This cannot be greater than 3.
*/
@property(readonly)     unsigned short    numberOfParameters;

/*! 
  @property parameter1
  @abstract Parameter 1.
*/
@property(readonly)     unsigned int      parameter1;

/*! 
  @property parameter2
  @abstract Parameter 2.
*/
@property(readonly)     unsigned int      parameter2;

/*! 
  @property parameter3
  @abstract Parameter 3.
*/
@property(readonly)     unsigned int      parameter3;

- (id)initWithData:(NSData*)data;

@end

//------------------------------------------------------------------------------------------------------------------------------
