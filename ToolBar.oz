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

export
   Get

define
   proc{Get Tk TkTools Objarrayclass ?P1 ?P2 ?P3 ?P4 ?P5 ?P6 ?P7}
      \insert 'toolbar.oz'
   in
      P1=ConsistantState
      P2=ResetFreeze
      P3=BorderWidth
      P4=ColorSelection
      P5=ColorBar
      P6=Debug
      P7=SlowNet
   end
end

