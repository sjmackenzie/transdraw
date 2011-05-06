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
   GetServer

define

   proc{GetServer Open GNedLoc GLoc GList GArrow GTools GAct GStd GSel GFrz GZoom GBrowse GLine GTxt GNed GNTB GMenu GStat GTB GChat GGroup GClient ?P1 ?P2}
      \insert 'serverclass.oz'
   in
      P1=ServerObject
      P2=ServerDialog
   end
end

