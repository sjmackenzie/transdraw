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



class RemoteReaderClass
   attr fd
   meth init
      skip
   end
   meth open(FN)
      FD in
      {Wait FN}
      {NewAsynch Open.file init(url:FN) FD}
      fd <- FD
   end
   meth read(?L)
      XL in
      {@fd read(list:XL size:all)}
      {Wait XL}
      XL=L
   end
   meth close
      {@fd close}
   end
end

RemoteReader={NewAsynch RemoteReaderClass init}

proc {NewLocalize Open OS ?Localize ?CleanUp}
   class LocalizerClass
      attr
	 remotereader
	 filedict
      prop locking
      meth init(RR)
	 lock
	    remotereader<-RR
	    filedict<-{NewDictionary}
	 end
      end

      meth localize(FN ?LFN)
	 A={StringToAtom {VirtualString.toString 'gifs/'#FN}}
      in
	 lock
%	    LFN=A
	    case {Dictionary.member @filedict A} then
	       {Dictionary.get @filedict A LFN}
	    else FD LFD L in
	       LFN={StringToAtom {OS.tmpnam $}}
	       {Dictionary.put @filedict A LFN}
	       % lecture au serveur
	       {@remotereader open(A)}
	       {@remotereader read(L)}
	       {Wait L}
	       {@remotereader close}
	       % ecriture au client
	       LFD={New Open.file
		    init(name:LFN
			 flags:[write create]
			 mode:mode(owner:[read write]))}
	       {LFD write(vs:L)}
	       {LFD close}
	    end
	 end
      end

      meth cleanup
	 lock
	    {ForAll {Dictionary.items @filedict $}
	     proc {$ F}
		{OS.unlink F}
	     end}
	    filedict<-{NewDictionary}
	    skip
	 end
      end

   end % class LocalizerClass

   Localizer={New LocalizerClass init(RemoteReader)}

in
   proc {Localize FN LFN}
      {Localizer localize(FN LFN)}
   end
   proc {CleanUp}
      {Localizer cleanup}
   end
end

	       
