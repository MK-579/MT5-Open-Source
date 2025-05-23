#property description "MACD & OSMA"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
#define RESET  0
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrMediumSeaGreen,clrDeepPink
#property indicator_label1  "MACD_Cloud"
#property indicator_type2 DRAW_COLOR_HISTOGRAM
#property indicator_color2 clrCrimson,clrDarkOrange,clrGray,clrMediumSpringGreen,clrDarkGreen
#property indicator_style2 STYLE_SOLID
#property indicator_width2 5
#property indicator_label2  "MACD"
input uint FastMACD     = 12;
input uint SlowMACD     = 26;
input uint SignalMACD   = 9;
input ENUM_APPLIED_PRICE   PriceMACD=PRICE_CLOSE;
int  min_rates_total;
double ExtABuffer[],ExtBBuffer[];
double IndBuffer[],ColorIndBuffer[];
int MACD_Handle;
int OnInit()
  {
   min_rates_total=int(SignalMACD+MathMax(FastMACD,SlowMACD));
   MACD_Handle=iMACD(NULL,0,FastMACD,SlowMACD,SignalMACD,PriceMACD);
   if(MACD_Handle==INVALID_HANDLE){Print(" Failed to get the handle of iMACD");return(INIT_FAILED);}
   SetIndexBuffer(0,ExtABuffer,INDICATOR_DATA);
   ArraySetAsSeries(ExtABuffer,true);
   SetIndexBuffer(1,ExtBBuffer,INDICATOR_DATA);
   ArraySetAsSeries(ExtBBuffer,true);
   SetIndexBuffer(2,IndBuffer,INDICATOR_DATA);
   ArraySetAsSeries(IndBuffer,true);
   SetIndexBuffer(3,ColorIndBuffer,INDICATOR_COLOR_INDEX);
   ArraySetAsSeries(ColorIndBuffer,true);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   IndicatorSetString(INDICATOR_SHORTNAME,"MACD-OSMA");
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   return(INIT_SUCCEEDED);
  }
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[])
  {
   if(BarsCalculated(MACD_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
   int to_copy,limit;
   limit=(prev_calculated>rates_total || prev_calculated<=0) ? rates_total-min_rates_total-1 : rates_total-prev_calculated ;
   to_copy=limit+1;
   if(CopyBuffer(MACD_Handle,MAIN_LINE,0,to_copy,ExtABuffer)<=0) return(RESET);
   if(CopyBuffer(MACD_Handle,SIGNAL_LINE,0,to_copy,ExtBBuffer)<=0) return(RESET);
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtABuffer[bar]/=_Point;
      ExtBBuffer[bar]/=_Point;
      IndBuffer[bar]=3*(ExtABuffer[bar]-ExtBBuffer[bar]);
     }
   if(prev_calculated>rates_total || prev_calculated<=0) limit--;
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      int clr=2;
      clr=IndBuffer[bar]>0?(IndBuffer[bar]>IndBuffer[bar+1]?4:3):(IndBuffer[bar]<IndBuffer[bar+1]?0:1);
      ColorIndBuffer[bar]=clr;
     }
   return(rates_total);
  }
