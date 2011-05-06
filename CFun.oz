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
   
require
   GifToBase64(convert:Convert
	       convertList:ConvertList
	       gifList:GifList)

export
   Get

prepare
   CL = {ConvertList {List.map GifList fun{$ I} {StringToAtom {VirtualString.toString 'gifs/'#I}} end}}

define

   proc{Get Open NewLocalize ?P1 ?P2}
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
   
      proc{NewLocalizeGifs Open OS ?Localize ?CleanUp}
	 MyObj
	 CodedList={NewDictionary}
	 {ForAll CL
	  proc{$ O}
	     case O of LI#X then {Dictionary.put CodedList LI X}
	     end
	  end}
      
	 class GifLocalizer
	    feat loc clean
	    meth init
	       {NewLocalize Open OS self.loc self.clean}
	    end
	    meth localize(FN LFN)
	       Name in Name={StringToAtom {VirtualString.toString 'gifs/'#FN}}
	       case {Dictionary.member CodedList Name} then
		  LFN={Dictionary.get CodedList Name}
	       else
		  LFN={StringToAtom {self.loc FN $}}
	       end
	    end
	    meth cleanup
	       {self.clean}
	    end
	 end
	 MyObj={New GifLocalizer init}
      in
	 Localize=proc {$ FN LFN}
		     {MyObj localize(FN LFN)}
		  end
	 CleanUp=proc {$}
		    {MyObj cleanup}
		 end

      end
   in
      P1=NewLocalizeGifs
      P2=Convert
   end
end
 
   
