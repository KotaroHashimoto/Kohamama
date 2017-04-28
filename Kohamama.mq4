//+------------------------------------------------------------------+
//|                                                     Kohamama.mq4 |
//|                           Copyright 2017, Palawan Software, Ltd. |
//|                             https://coconala.com/services/204383 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Palawan Software, Ltd."
#property link      "https://coconala.com/services/204383"
#property description "Author: Kotaro Hashimoto <hasimoto.kotaro@gmail.com>"
#property version   "1.00"
#property strict

input int TP_pips = 20;
input int SL_pips = 20;
input double Entry_Lot = 0.1;
input int Martin_Times = 1;
input int Magic_Number = 1;

double tp;
double sl;
double lot;
string thisSymbol;

const string indName = "BO_main001_porinashi";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
  tp = TP_pips * Point * 10.0;
  sl = SL_pips * Point * 10.0;
  
  if(Entry_Lot < MarketInfo(Symbol(), MODE_MINLOT)) {
    lot = 0.0;
  }
  else if(MarketInfo(Symbol(), MODE_MAXLOT) < Entry_Lot) {
    lot = MarketInfo(Symbol(), MODE_MAXLOT);
  }
  
  thisSymbol = Symbol();
  
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
      
  }
  
int getSignal() {

  if(0 < iCustom(NULL, PERIOD_CURRENT, indName, 0, 1)) {
    return OP_BUY;
  }
  else if(0 < iCustom(NULL, PERIOD_CURRENT, indName, 1, 1)) {
    return OP_SELL;
  }
  else {
    return -1;
  }
}
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  int cap = Martin_Times + 1;

  for(int i = 0; i < OrdersTotal(); i++) {
    if(OrderSelect(i, SELECT_BY_POS)) {
      if(OrderMagicNumber() == Magic_Number && !StringCompare(OrderSymbol(), thisSymbol)) {
        cap --;
        
        if(cap <= 0) {
          return;
        }
        else if(TimeCurrent() - OrderOpenTime() < Period() * 60 + 10) {
          return;
        }
      }
    }
  }
  
  int signal = getSignal();
  
  if(signal == OP_BUY) {
    int ticket = OrderSend(Symbol(), OP_BUY, lot, NormalizeDouble(Ask, Digits), 3, NormalizeDouble(Ask - sl, Digits), NormalizeDouble(Ask + tp, Digits), NULL, Magic_Number);
  }
  else if(signal == OP_SELL) {
    int ticket = OrderSend(Symbol(), OP_SELL, lot, NormalizeDouble(Bid, Digits), 3, NormalizeDouble(Bid + sl, Digits), NormalizeDouble(Bid - tp, Digits), NULL, Magic_Number);
  }

}

