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
export
   Convert
   ConvertList
   GifList
define
   GifList=['net-new.gif' 'net-open.gif' 'net-save.gif' 'net-print.gif'
	    % Selection tool
	    'select_off.gif' 'select_on.gif'
	    'net-cut.gif' 'net-copy.gif' 'net-paste.gif' 'mini-cross.gif' 'net-duplicate.gif' 'net-group.gif' 'net-ungroup.gif'
	    % Freeze and steal tools
	    'freeze_off.gif' 'freeze_on.gif'
	    'steal_off.gif' 'steal_on.gif'
	    'mini-lock.gif'
	    % Zoom tool
	    'zoom_off.gif' 'zoom_on.gif'
	    'mini-zoom+.gif' 'mini-zoom-.gif' 'mini-doc.gif'
	    % Circle and rectangle tools
	    'circle_off.gif' 'circle_on.gif'
	    'rectangle_off.gif' 'rectangle_on.gif'
	    % Polygon tool
	    'polyline_off.gif' 'polyline_on.gif'
	    % Text tool
	    'text_off.gif' 'text_on.gif'
	    'justif_left.gif' 'justif_right.gif' 'justif_center.gif'
	    'net-bold.gif' 'net-underline.gif' 'net-italic.gif'
	    % Arrow tool
	    'arrow_off.gif' 'arrow_on.gif'
	    'mini-paint.gif' 'mini-line.gif' 'mini-noleft.gif' 'mini-noright.gif'
	    'mini-nodemove.gif' 'mini-nodedel.gif' 'mini-nodeadd.gif' 'mini-nodeunlnk.gif' 'mini-nodelink.gif'
	    % Browser tool
	    'browse_on.gif' 'browse_off.gif'
	    'mini-left.gif' 'mini-right.gif'
	    'mini-window.gif' 'mini-windows.gif' 'mini-underline.gif'
	    % Unused
	    'justif_both.gif' 'mini-font.gif' 'mini-manual.gif'
	    % Funnies
	    'trd00000.gif' 'trd00001.gif' 'trd00002.gif' 'trd00003.gif' 'trd00004.gif' 'mozart-powered-75.gif'
	   ]
   
   CArray={NewArray 0 63 0}
   {List.forAllInd "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    proc{$ I C}
       {Array.put CArray I-1 C}
    end}
       
   fun{Convert File}
      Handler Dump
   in
      Handler={New Open.file init(name:File
				  flags:[read])}
      local T in
	 T={Handler read(list:$ size:all)}
	 case ({Length T} mod 3)
	 of 0 then Dump=T
	 [] 1 then Dump={List.append T [255 255]}
	 [] 2 then Dump={List.append T [255]}
	 end
      end
      {Handler close}
      local
	 proc{ByteToBit B B0 B1 B2 B3 B4 B5 B6 B7}
	    fun {GetBit V B}
	       B=V mod 2
	       V div 2
	    end
	 in
	    _={GetBit {GetBit {GetBit {GetBit {GetBit {GetBit {GetBit {GetBit B B0} B1} B2} B3} B4} B5} B6} B7}
	 end
	 fun{TB A0 A1 A2 A3 A4 A5}
	    {Array.get CArray A5*32+A4*16+A3*8+A2*4+A1*2+A0}
	 end
	 fun{Loop X N}
	    case X of A|B|C|Xs then
	       local
		  A0 A1 A2 A3 A4 A5 A6 A7
		  B0 B1 B2 B3 B4 B5 B6 B7
		  C0 C1 C2 C3 C4 C5 C6 C7
	       in
		  {ByteToBit A A0 A1 A2 A3 A4 A5 A6 A7}
		  {ByteToBit B B0 B1 B2 B3 B4 B5 B6 B7}
		  {ByteToBit C C0 C1 C2 C3 C4 C5 C6 C7}
		  case N>=68 then
		     {TB A2 A3 A4 A5 A6 A7}|{TB B4 B5 B6 B7 A0 A1}|{TB C6 C7 B0 B1 B2 B3}|{TB C0 C1 C2 C3 C4 C5}|10|32|32|32|32|{Loop Xs 0}
		  else
		     {TB A2 A3 A4 A5 A6 A7}|{TB B4 B5 B6 B7 A0 A1}|{TB C6 C7 B0 B1 B2 B3}|{TB C0 C1 C2 C3 C4 C5}|{Loop Xs N+4}
		  end
	       end
	    else case N>0 then 10|nil else nil end
	    end
	 end
      in
	 32|32|32|32|{Loop Dump 0}
      end
   end

   fun{ConvertList L}
      D in
      D={NewDictionary}
      {ForAll L
       proc{$ I}
	  {Dictionary.put D I {Convert I}}
       end}
      {Dictionary.entries D}
   end
end

