#include <Trade/Trade.mqh>
CTrade S_TRADE;
void OnTick()
  {
    double
      ISpread = MathCeil((SymbolInfoDouble(_Symbol,SYMBOL_ASK)-SymbolInfoDouble(_Symbol,SYMBOL_BID))/_Point),
      HigCT,LowCT;
    for(int i = 1; i <= 7; i++)
      {
        HigCT+=iHigh(_Symbol,PERIOD_CURRENT,i); 
        LowCT+=iLow(_Symbol,PERIOD_CURRENT,i);
      }
    BodyHeightTrailingStop = MathCeil(((HigCT-LowCT)/7)/_Point);
    if(PositionSelect(_Symbol) == true)
      {
        double
          BuyRange = iLow(_Symbol,PERIOD_CURRENT,0) + (0.85 * (iHigh(_Symbol,PERIOD_CURRENT,0) - iLow(_Symbol,PERIOD_CURRENT,0))),
          SellRange = iHigh(_Symbol,PERIOD_CURRENT,0) - (0.85 * (iHigh(_Symbol,PERIOD_CURRENT,0) - iLow(_Symbol,PERIOD_CURRENT,0))),
          InstantStopLoss = (BodyHeightTrailingStop * 1.85)* _Point;
        //---Buy
        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
          {
            double 
              SL = NormalizeDouble((PositionGetDouble(POSITION_PRICE_OPEN) - (ISpread * _Point) - (BodyHeightTrailingStop * _Point)), _Digits),
              NSL = NormalizeDouble((iHigh(_Symbol,PERIOD_CURRENT,0) - (BodyHeightTrailingStop * _Point) - (ISpread * _Point)), _Digits);
            // Stoploss
            if(PositionGetDouble(POSITION_SL) == 0)
              {S_TRADE.PositionModify(_Symbol, SL, NULL);}
            else {}
            // TrailingStop
            if(NSL > PositionGetDouble(POSITION_SL) && SymbolInfoDouble(_Symbol,SYMBOL_ASK) < BuyRange)
              {S_TRADE.PositionModify(_Symbol, NSL, NULL);}
            else {}
          }
        else {}
        //---SELL
        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
          {
            double 
              SL = NormalizeDouble((PositionGetDouble(POSITION_PRICE_OPEN) + (ISpread * _Point) + (BodyHeightTrailingStop * _Point)), _Digits),
              NSL = NormalizeDouble((iLow(_Symbol,PERIOD_CURRENT,0) + (BodyHeightTrailingStop * _Point) + (ISpread * _Point)), _Digits);
            // Stoploss
            if(PositionGetDouble(POSITION_SL) == 0)
              {S_TRADE.PositionModify(_Symbol, SL, NULL);}
            else {}
            // TrailingStop
            if(NSL < PositionGetDouble(POSITION_SL) && SymbolInfoDouble(_Symbol,SYMBOL_BID) > SellRange)
              {S_TRADE.PositionModify(_Symbol, NSL, NULL);}
            else {}
          }
        else {}
      }
  }
