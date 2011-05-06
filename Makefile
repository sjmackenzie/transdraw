##########################################################################
##                                                                      ##
## TransDraw multi-user graphic editor                                  ##
##                                                                      ##
##  Copyright 1998 Walloon Region of Belgium.  All Rights Reserved.     ##
##  The development of TransDraw is supported by the PIRATES project at ##
##  the Université catholique de Louvain.  This file is subject to the  ##
##  general TransDraw license.                                          ##
##                                                                      ##
##  Author: Donatien Grolaux                                            ##
##                                                                      ##
##########################################################################


foo:Actions.ozf Lists.ozf TextTool.ozf Chat.ozf LocalizeNed.ozf Localize.ozf SelectTool.ozf ToolBar.ozf FreezeTool.ozf ZoomTool.ozf Menus.ozf Server.ozf Tools.ozf Group.ozf NedTB.ozf StandardTool.ozf LineTool.ozf ArrowTool.ozf BrowseTool.ozf NedTools.ozf StatusBar.ozf ClientClass.ozf ServerClass.ozf Editor Ned

Actions.ozf:Actions.oz actionsclass.oz
	ozc -c -z 1 Actions.oz

Lists.ozf:Lists.oz objlistclass.oz
	ozc -c -z 1 Lists.oz

TextTool.ozf:TextTool.oz texttoolv3.oz
	ozc -c -z 1 TextTool.oz

Chat.ozf:Chat.oz wand.oz
	ozc -c -z 1 Chat.oz

LocalizeNed.ozf:Localize.oz localizened.oz
	ozc -c -z 1 Localize.oz -o LocalizeNed.ozf

Localize.ozf:CFun.oz GifToBase64.ozf
	ozc -c -z 1 CFun.oz -o Localize.ozf

GifToBase64.ozf:GifToBase64.oz
	ozc -c -z 1 GifToBase64.oz

SelectTool.ozf:SelectTool.oz selecttool.oz
	ozc -c -z 1 SelectTool.oz

ToolBar.ozf:ToolBar.oz toolbar.oz textwindow.oz
	ozc -c -z 1 ToolBar.oz

FreezeTool.ozf:FreezeTool.oz freezetool.oz
	ozc -c -z 1 FreezeTool.oz

ZoomTool.ozf:ZoomTool.oz zoomtool.oz
	ozc -c -z 1 ZoomTool.oz

BrowseTool.ozf:BrowseTool.oz browsetool.oz
	ozc -c -z 1 BrowseTool.oz

Menus.ozf:Menus.oz menus.oz
	ozc -c -z 1 Menus.oz

ServerClass.ozf:ServerClass.oz serverclass.oz
	ozc -c -z 1 ServerClass.oz

Server.ozf:server.oz
	ozc -c -z 1 server.oz -o Server.ozf

Tools.ozf:Tools.oz tools.oz
	ozc -c -z 1 Tools.oz

Group.ozf:Group.oz groupobj.oz
	ozc -c -z 1 Group.oz

NedTB.ozf:NedTB.oz nedtools/toolbar.oz
	ozc -c -z 1 NedTB.oz

StandardTool.ozf:StandardTool.oz standardtool.oz
	ozc -c -z 1 StandardTool.oz

LineTool.ozf:LineTool.oz linetool.oz
	ozc -c -z 1 LineTool.oz

ArrowTool.ozf:ArrowTool.oz arrowtool.oz
	ozc -c -z 1 ArrowTool.oz

NedTools.ozf:NedTools.oz nedtools/nedtools.oz nedtools/stdfont.oz nedtools/linestyle.oz
	ozc -c -z 1 NedTools.oz

StatusBar.ozf:StatusBar.oz statbar.oz
	ozc -c -z 1 StatusBar.oz

ClientClass.ozf:ClientClass.oz clientclass.oz
	ozc -c -z 1 ClientClass.oz

Editor:Editor.oz
	ozc -x -z 9 Editor.oz -o Editor

Ned:Ned.oz
	ozc -x -z 1 Ned.oz -o Ned
