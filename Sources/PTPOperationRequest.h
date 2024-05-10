//
//  PTPOperationRequest.h
//  PTPPassThrough
//
//  Created by Danil Korotenko on 5/10/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//---------------------------------------------------------------------------------------------------------- PTPOperationRequest
/*! 
  @class PTPOperationRequest
  @abstract The OperationRequest object is used to create a PTP operation request.
*/

@interface PTPOperationRequest : NSObject

/*! 
  @property operationCode
  @abstract PTP operation code.
*/
@property(assign)       unsigned short    operationCode;

/*! 
  @property transactionID
  @abstract PTP transaction ID. Image Capture Core framework ignores this value since the PTPCamera device module determines this value.
*/
@property(assign)       unsigned int      transactionID;

/*! 
  @property numberOfParameters
  @abstract Number of parameters to be sent to the device. This cannot be greater than 5.
*/
@property(assign)       unsigned short    numberOfParameters;

/*! 
  @property parameter1
  @abstract Parameter 1.
*/
@property(assign)       unsigned int      parameter1;

/*! 
  @property parameter2
  @abstract Parameter 2.
*/
@property(assign)       unsigned int      parameter2;

/*! 
  @property parameter3
  @abstract Parameter 3.
*/
@property(assign)       unsigned int      parameter3;

/*! 
  @property parameter4
  @abstract Parameter 4.
*/
@property(assign)       unsigned int      parameter4;

/*! 
  @property parameter5
  @abstract Parameter 5.
*/
@property(assign)       unsigned int      parameter5;

/*! 
  @property commandBuffer
  @abstract A serialized buffer intended to be used with -requestSendPTPCommand:... method of ICCameraDevice object.
*/
@property(readonly)     NSData*           commandBuffer;
@end

NS_ASSUME_NONNULL_END
