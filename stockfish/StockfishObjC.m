//
//  stockfish.m
//  stockfish
//
//  Created by Douglas Pedley on 12/27/20.
//

#import "StockfishObjC.h"
#import "FishWrap.h"


@interface Stockfish ()
@property (nonatomic, strong) FishWrap *fishWrap;
@end

@implementation Stockfish

-(instancetype)initWithAquaman:(NSObject <TalksToFish>*)aquaman {
    self = [super init];
    if (self) {
        self.fishWrap = [[FishWrap alloc] initWithAquaman:aquaman];
    }
    return self;
}

-(void)setPositionAndEvaluate:(NSString *)position time:(NSTimeInterval)timeInterval {
    NSString *go = @"go depth 16"; //[NSString stringWithFormat:@"go movetime %d", (int)(timeInterval * 1000)];
    [self.fishWrap sendUCICommand:position];
    [self.fishWrap sendUCICommand:go];
}


@end
