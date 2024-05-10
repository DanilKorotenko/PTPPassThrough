//
//  PTPOperationRequest.m
//  PTPPassThrough
//
//  Created by Danil Korotenko on 5/10/24.
//

#import "PTPOperationRequest.h"
#import "PTPOperationRequestPrivateData.h"
#import "PTPProtocolHelpers.h"

@interface PTPOperationRequest ()

@property(strong) PTPOperationRequestPrivateData *privateData;

@end

@implementation PTPOperationRequest

- (id)init
{
    if ( ( self = [super init] ) )
    {
        self.privateData = [[PTPOperationRequestPrivateData alloc] init];
    }

    return self;
}

- (unsigned short)operationCode                     { return self.privateData.operationCode; }
- (void)setOperationCode:(unsigned short)code       { self.privateData.operationCode = code; }

- (unsigned int)transactionID                       { return self.privateData.transactionID; }
- (void)setTransactionID:(unsigned int)transID      { self.privateData.transactionID = transID; }

- (unsigned short)numberOfParameters                { return self.privateData.numberOfParameters; }
- (void)setNumberOfParameters:(unsigned short)num   { self.privateData.numberOfParameters = num; }

- (unsigned int)parameter1                          { return self.privateData.parameters[0]; }
- (void)setParameter1:(unsigned int)param           { self.privateData.parameters[0] = param; }

- (unsigned int)parameter2                          { return self.privateData.parameters[1]; }
- (void)setParameter2:(unsigned int)param           { self.privateData.parameters[1] = param; }

- (unsigned int)parameter3                          { return self.privateData.parameters[2]; }
- (void)setParameter3:(unsigned int)param           { self.privateData.parameters[2] = param; }

- (unsigned int)parameter4                          { return self.privateData.parameters[3]; }
- (void)setParameter4:(unsigned int)param           { self.privateData.parameters[3] = param; }

- (unsigned int)parameter5                          { return self.privateData.parameters[4]; }
- (void)setParameter5:(unsigned int)param           { self.privateData.parameters[4] = param; }

- (NSData*)commandBuffer
{
    int             i;
    unsigned int    len     = 12 + 4 * self.privateData.numberOfParameters;
    unsigned char*  buffer  = (unsigned char*)calloc(len, 1);
    unsigned char*  buf     = buffer;

    PTPWriteUnsignedInt( &buf, len );
    PTPWriteUnsignedShort( &buf, 1 );    // command block code
    PTPWriteUnsignedShort( &buf, self.privateData.operationCode );
    PTPWriteUnsignedInt( &buf, self.privateData.transactionID );      // ignored by ImageCaptureCore framework

    for ( i = 0; i < self.privateData.numberOfParameters; ++i )
    {
        PTPWriteUnsignedInt( &buf, self.privateData.parameters[i] );
    }

    return [NSData dataWithBytesNoCopy:buffer length:len freeWhenDone:YES];
}

- (NSString*)description
{
    NSMutableString*  s = [NSMutableString stringWithFormat:@"\n%@ <%p>:\n", [self class], self];

    [s appendFormat:@"  operationCode       : 0x%04x\n", self.privateData.operationCode];
    [s appendFormat:@"  transactionID       : 0x%08x\n", self.privateData.transactionID];
    [s appendFormat:@"  numberOfParameters  : %d\n", self.privateData.numberOfParameters];
    if ( self.privateData.numberOfParameters )
    {
        int i = 1;

        [s appendFormat:@"  parameters          : 0x%08X\n", self.privateData.parameters[0]];
        while ( i < self.privateData.numberOfParameters )
        {
            [s appendFormat:@"  parameters          : 0x%08X\n", self.privateData.parameters[i]];
            ++i;
        }
    }

    [s appendFormat:@"\n"];
    return s;
}

@end
