//
//  StockfishObjC.h
//  stockfish
//
//  Created by Douglas Pedley on 12/27/20.
//

#import <Foundation/Foundation.h>

// These came from the Makefile.
#define NNUE_EMBEDDING_OFF
#define IS_64BIT
#define USE_PTHREADS
@protocol TalksToFish <NSObject>
-(void)stockfishBestMove:(NSString *)message;
-(void)stockfishInfo:(NSString *)infoMessage;
-(void)stockfishError:(NSString *)errorMessage;
@end

@interface Stockfish : NSObject
-(void)setPositionAndEvaluate:(NSString *)position time:(NSTimeInterval)timeInterval;
-(instancetype)initWithTalksTo:(NSObject<TalksToFish> *)talksTo;
@end
