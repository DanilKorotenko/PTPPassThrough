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
{
    unsigned short    mOperationCode;
    unsigned int      mTransactionID;
    unsigned short    mNumberOfParameters;
    unsigned int*     mParameters;
}

@property   unsigned short  operationCode;
@property   unsigned int    transactionID;
@property   unsigned short  numberOfParameters;
@property   unsigned int*   parameters;
@end

NS_ASSUME_NONNULL_END
