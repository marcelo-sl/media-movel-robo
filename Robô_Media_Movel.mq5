//+------------------------------------------------------------------+
//|                                             Robô_Media_Movel.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| INCLUDES                                                         |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>; // Biblioteca-padrão CTrade

//+------------------------------------------------------------------+
//| INPUTS                                                           |
//+------------------------------------------------------------------+
input int lote = 1;
input int periodoCurta = 10;
input int periodoLonga = 50;
//+------------------------------------------------------------------+
//| GLOBAIS                                                          |
//+------------------------------------------------------------------+

//--- Manipuladores dos indicadores de media móvel
int curtaHandle = INVALID_HANDLE;
int longaHandle = INVALID_HANDLE;

//--- Vetores de dados dos indicadores de média móvel
double mediaCurta[];
double mediaLonga[];

//--- Declarando váriavel trade
CTrade trade;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Invertendo os indexs
   ArraySetAsSeries(mediaCurta, true);
   ArraySetAsSeries(mediaLonga, true);
   
//--- Atribuir valores para os manipuladores de média móvel
   curtaHandle = iMA(_Symbol,_Period,periodoCurta,0,MODE_SMA,PRICE_CLOSE);
   longaHandle = iMA(_Symbol,_Period,periodoLonga,0,MODE_SMA,PRICE_CLOSE);
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(isNewBar())
     {
      //--- Lógica operacional do robô
      
      //+------------------------------------------------------------------+
      //| OBTENÇÃO DOS DADOS                                               |
      //+------------------------------------------------------------------+
      int copied1 = CopyBuffer(curtaHandle,0,0,3,mediaCurta);
      int copied2 = CopyBuffer(longaHandle,0,0,3,mediaLonga);
      //---
      bool sinalCompra = false;
      bool sinalVenda = false;
      //--- Se os dados tiverem sido copiados corretamente
      if(copied1==3 && copied2==3)
        {
         //--- Sinal de compra
         if(mediaCurta[1]>mediaLonga[1] && mediaCurta[2]<mediaLonga[2])
           {
            sinalCompra = true;
           }
         //--- Sinal de venda
         if(mediaCurta[1]<mediaLonga[1] && mediaCurta[2]>mediaLonga[2])
           {
            sinalVenda = true;
           }
        }
      //+------------------------------------------------------------------+
      //| VERIFICAR SE ESTOU POSICIONADO                                   |
      //+------------------------------------------------------------------+
      bool comprado = false;
      bool vendido = false;
      if(PositionSelect(_Symbol))
        {
         //--- Se a posição for comprada
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
           {
            comprado = true;
           }
        }
        //--- Se a posição for vendida
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
           {
            vendido = true;
           }
      
      //+------------------------------------------------------------------+
      //| LÓGICA DE ROTEAMENTO                                             |
      //+------------------------------------------------------------------+
      //--- ZERADO
      if(!comprado && !vendido)
        {
         //--- Sinal de compra
         if(sinalCompra)
           {
            trade.Buy(lote,_Symbol,0,0,0,"Compra a mercado");
           }
           
         //--- Sinal de venda
         if(sinalVenda)
           {
            trade.Sell(lote,_Symbol,0,0,0,"Venda a mercado");
           }
        }
      else
        {
         //--- Comprado ou Vendido
         if(comprado)
           {
            if(sinalVenda)
              {
               trade.Sell(lote*2,_Symbol,0,0,0,"Virada de mão (compra -> venda)");
              }
           }
         else if(vendido)
           {
            if(sinalCompra)
              {
               trade.Buy(lote*2,_Symbol,0,0,0,"Virada de mão (venda -> compra)");
              } 
           }
        }
      
     }
     
   }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  
bool isNewBar()
  {
    static datetime last_time = 0;
    
    datetime lastbar_time=(datetime)SeriesInfoInteger(Symbol(), Period(), SERIES_LASTBAR_DATE);
    
    if(last_time==0)
      {
       last_time = lastbar_time;
       return(false);
      }  
    
    if(last_time!=lastbar_time)
      {
       last_time=lastbar_time;
       return(true);
      }
    
    return(false);
   
  }
//+------------------------------------------------------------------+
