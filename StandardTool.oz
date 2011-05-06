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
   proc{Get Tk ?P1 ?P2}
      \insert 'standardtool.oz'
   in
      P1=StandardObj
      P2=StandardTool
   end
end

