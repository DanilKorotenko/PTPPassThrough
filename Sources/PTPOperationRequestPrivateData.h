//
//  PTPOperationRequestPrivateData.h
//  PTPPassThrough
//
//  Created by Danil Korotenko on 5/10/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//----------------------------------------------------------------------------------------------- PTPOperationRequestPrivateData

@interface PTPOperationRequestPrivateData : NSObject

@property(readwrite)   unsigned short  operationCode;
@property(readwrite)   unsigned int    transactionID;
@property(readwrite)   unsigned short  numberOfParameters;
@property(readwrite)   unsigned int*   parameters;
@end

NS_ASSUME_NONNULL_END
