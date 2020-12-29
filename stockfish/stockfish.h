//
//  stockfish.h
//  stockfish
//
//  Created by Douglas Pedley on 12/27/20.
//

#import <Foundation/Foundation.h>

// These came from the Makefile.
#define NNUE_EMBEDDING_OFF
#define IS_64BIT
#define USE_PTHREADS

@interface stockfish : NSObject
-(void)evaluateFEN:(NSString *)fen;
@end
