//
//  PTPOperationRequestPrivateData.m
//  PTPPassThrough
//
//  Created by Danil Korotenko on 5/10/24.
//

#import "PTPOperationRequestPrivateData.h"

@implementation PTPOperationRequestPrivateData
@synthesize operationCode       = mOperationCode;
@synthesize transactionID       = mTransactionID;
@synthesize numberOfParameters  = mNumberOfParameters;
@synthesize parameters          = mParameters;

- (id)init
{
    if ( ( self = [super init] ) )
    {
        mParameters = (unsigned int*)calloc( 5, sizeof( unsigned int ) );
    }
    
    return self;
}

- (void)dealloc
{
    free( mParameters );
}

@end
