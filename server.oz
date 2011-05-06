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

import
   Open
   LocalizeNed(get:GNedLoc)
   Localize(get:GLoc)
   Lists(get:GList)
   Tools(get:GTools)
   Actions(get:GAct)
   StandardTool(get:GStd)
   SelectTool(get:GSel)
   FreezeTool(get:GFrz)
   ZoomTool(get:GZoom)
   BrowseTool(get:GBrowse)
   LineTool(get:GLine)
   ArrowTool(get:GArrow)
   TextTool(get:GTxt)
   NedTools(get:GNed)
   NedTB(get:GNTB)
   Menus(get:GMenu)
   StatusBar(get:GStat)
   ToolBar(get:GTB)
   Chat(get:GChat)
   Group(get:GGroup)
   ClientClass(get:GClient)
   ServerClass(getServer:GServer)
export
   ServerObject
   ServerDialog
   
define
   ServerDialog ServerObject
in
   {GServer Open GNedLoc GLoc GList GArrow GTools GAct GStd GSel GFrz GZoom GBrowse GLine GTxt GNed GNTB GMenu GStat GTB GChat GGroup GClient ServerObject ServerDialog}

end
