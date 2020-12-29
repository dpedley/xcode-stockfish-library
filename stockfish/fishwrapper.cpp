/*
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

using namespace std;

const char* StartFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

struct StockfishState {
    Position *pos;
    StateListPtr states;
    string token;
};

StockfishState *initializeStockfish() {
    StockfishState *state = new StockfishState();
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
    state->states = StateListPtr(new std::deque<StateInfo>(1));
    
    state->pos->set(StartFEN, false, &state->states->back(), Threads.main());
    return state;
}

void uci(StockfishState *state, char *cmd) {
    UCI::processCommand(state->token, cmd, *(state->pos), state->states);
}

void tearDownStockfish() {
    Threads.stop = true;
    Threads.set(0);
}
*/
