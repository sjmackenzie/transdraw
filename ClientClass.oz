%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                                      %%
%% TransDraw multi-user graphic editor                                  %%
%%                                                                      %%
%%  Copyright 1998 Walloon Region of Belgium.  All Rights Reserved.     %%
%%  The development of TransDraw is supported by the PIRATES project at %%
%%  the Université catholique de Louvain.  This file is subject to the  %%
%%  general TransDraw license.                                          %%
%%                                                                      %%
%%  Author: Donatien Grolaux                                            %%
%%                                                                      %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


functor

import System(show:Show)
   
export
   Get

define
   proc{Get Tk TkTools System Pickle Connection Open OS Remote DialogBox ToolBar StandardObj StandardTool LineObj LineTool ArrowObj ArrowTool TextObj TextTool FreezeTool ZoomTool BrowseTool NewLocalize NewLocalizeGifs Convert SelectTool StatusBar ConsistantState ResetFreeze BorderWidth ColorSelection ColorBar Debug SlowNet MenuEvent ToolBox Wand ChatRoom RubberFrame Objlistclass Objarrayclass NewAsynch NewRedir Actions DummyActions GroupObj ServerDialog ?P1}
      \insert 'clientclass.oz'
   in
      P1=ClientObject
   end
end

