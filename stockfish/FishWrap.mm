//
//  FishWrap.m
//  stockfish
//
//  Created by Douglas Pedley on 12/28/20.
//

#import <Foundation/Foundation.h>
#import "FishWrap.h"
#include <iostream>
#include "bitboard.h"
#include "endgame.h"
#include "position.h"
#include "search.h"
#include "thread.h"
#include "tt.h"
#include "uci.h"
#include "syzygy/tbprobe.h"
#include <sstream>

namespace PSQT {
  void init();
}
const char* StartFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

@interface FishLoop : NSOperation
@property (nonatomic, strong) NSMutableArray *commands;
@end

@implementation FishLoop

- (instancetype)init {
    self = [super init];
    if (self) {
        self.commands = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)appendCommand:(NSString *)command {
    @synchronized (self.commands) {
        [self.commands addObject:command];
    }
}

- (void)main {
    Position pos;
    std::string token;
    StateListPtr states(new std::deque<StateInfo>(1));

    // Initialize Stockfish classes
    UCI::init(Options);
    Tune::init();
    PSQT::init();
    Bitboards::init();
    Position::init();
    Bitbases::init();
    Endgames::init();
    Threads.set(size_t(Options["Threads"]));
    Search::clear(); // After threads are up
    Eval::NNUE::init();    
    pos.set(StartFEN, false, &states->back(), Threads.main());

    do {
        NSString *command = [self.commands firstObject];
        if (command != nil) {
            @synchronized (self.commands) {
                [self.commands removeObjectAtIndex:0];
            }
            // Call UCI
            std::string cmd = std::string([command UTF8String]);
            UCI::processCommand(token, cmd, pos, states);
        } else {
            [NSThread sleepForTimeInterval:0.05];
        }
    } while (!self.cancelled);
}

@end

@interface FishWrap()
@property (nonatomic, strong) FishLoop *fishLoop;
@end

@implementation FishWrap
- (NSString *)sendUCICommand:(NSString *)uci {
    [self.fishLoop appendCommand:uci];
    return @"";
}

-(instancetype)init {
    self = [super init];
    if (self) {
        self.fishLoop = [[FishLoop alloc] init];
    }
    return self;
}
@end
