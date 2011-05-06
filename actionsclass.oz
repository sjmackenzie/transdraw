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



%
% Cet objet sert a gerer les evenements tcl/tk
% - Tout passe par un meme port
% - On peut demander que les objets graphiques recoivent ou pas les evenements
% - On peut de plus demander qu'un evenement ne soit pas envoye au canvas
%   si c'est en fait sur un objet que l'on a clique
%

class Actions

   feat mport menus client

   attr skipcanvas acceptobj objreceiver temp threadid
      skipnext scale grid gridx gridy gridded doubleobj

   prop locking

   meth setscale(S)
      scale<-1.0/S
   end
      
   meth init(CANVAS MENUS CLIENT TOOLS NAME Wand MPORT INPORT)
      skipcanvas<-true
      acceptobj<-true
      skipnext<-false
      scale<-1.0
      grid<-false
      gridded<-true
      gridx<-1.0
      gridy<-1.0
      self.menus=MENUS
      self.client=CLIENT
      local
	 proc{CX X ?RX}
%	    LX={CANVAS tkReturnFloat(canvasx(X) $)}*@scale
            LX=(X + {CANVAS getorgx($)})*@scale
	 in
	    case @grid andthen @gridded then
	       RX={Floor (LX+@gridx/2.0)/@gridx}*@gridx
	    else
	       RX=LX
	    end
	 end
	 proc{CY Y ?RY}
%	    LY={CANVAS tkReturnFloat(canvasy(Y) $)}*@scale
            LY=(Y + {CANVAS getorgy($)})*@scale
	 in
	    case @grid andthen @gridded then
	       RY={Floor (LY+@gridy/2.0)/@gridy}*@gridy
	    else
	       RY=LY
	    end
	 end
	 proc{TX X ?RX}
%	    RX={CANVAS tkReturnFloat(canvasx(X) $)}*@scale
            RX=(X + {CANVAS getorgx($)})*@scale
	 end
	 proc{TY Y ?RY}
%	    RY={CANVAS tkReturnFloat(canvasy(Y) $)}*@scale
            RY=(Y + {CANVAS getorgy($)})*@scale
	 end
	 proc {Server Ps}
	    case Ps of Px|Pr then
	       P in
	       % on va remplacer les deux derniers
	       % parametres pour convertir les coordonnees ecrans
	       % en coordonnees canvas
	       lock
		  case @skipnext then
		     case Px % saute les messages adresses au canvas
		     of cclick(X Y) then
			skipnext<-false
			{Server Pr}
		     [] cmotion(X Y) then
			skipnext<-false
			{Server Pr}
		     [] crelease(X Y) then
			skipnext<-false
			{Server Pr}
		     [] csclick(X Y) then
			skipnext<-false
			{Server Pr}
		     [] cdclick(X Y) then
			case @doubleobj==nil then skip else
			   {@objreceiver odclick(@doubleobj {CX X $} {CY Y $})}
			end
			skipnext<-false
			{Server Pr}
		     else skip end
		  else skip end
		  case Px
		  of menu(Cmd) then
		     {self.menus Cmd}
		  [] client(Msg) then
		     {self.client Msg}
		  [] toolbut(Msg) then
		     {TOOLS settool(Msg)}
		  [] cclick(X Y) then
		     doubleobj<-nil
		     {@objreceiver cclick({CX X $} {CY Y $})}
		  [] csclick(X Y) then
		     {@objreceiver csclick({CX X $} {CY Y $})}
		  [] cdclick(X Y) then
		     {@objreceiver cdclick({CX X $} {CY Y $})}
		  [] cmotion(X Y) then % ne traite pas le msg si d'autres deja en attente
		     Skip in
		     case {IsDet Pr} then
			case Pr of Z|Zs then
			   case {Label Z}==cmotion then Skip=unit % ne traite pas ce message-ci
			   else skip end
			else skip end
		     else skip end
		     case {IsFree Skip} then 
			{@objreceiver cmotion({CX X $} {CY Y $})}
		     else skip end
		  [] omotion(X Y) then
		     Skip in
		     case {IsDet Pr} then
			case Pr of Z|Zs then
			   case {Label Z}==cmotion andthen {IsDet Zs} then
			      case Zs of N|Ns then
				 case {Label N}==omotion then
				    Skip=unit % ne traite pas ce message-ci
				    skipnext<-true % ni le suivant d'ailleurs
				 else skip end
			      else skip end
			   else skip end
			else skip end
		     else skip end
		     case {IsFree Skip} then 
			case @acceptobj then
			   case @skipcanvas then
			      skipnext<-true 
			   else skip end
			   {@objreceiver omotion({CX X $} {CY Y $})}
			else skip end
		     else skip end
		  [] crelease(X Y) then
		     {@objreceiver crelease({CX X $} {CY Y $})}
		  [] mclick(X Y) then
		     {Wand click({TX X} {TY Y})}
		  [] mdclick(X Y) then
		     {Wand dclick({TX X} {TY Y})}
		  [] mmotion(X Y) then
		     {Wand motion({TX X} {TY Y})}
		  [] msmotion(X Y) then
		     {Wand smotion({TX X} {TY Y})}
		  [] mrelease(X Y) then
		     {Wand release({TX X} {TY Y})}
		  [] radar(X Y) then
		     {Wand doRadar({TX X} {TY Y})}
		  [] stopserver then
		     skip
		  else
		     case @acceptobj then
			local W L in
			   {Width Px W}
			   L=[(W-1)#{CX Px.(W-1) $} W#{CY Px.W $}]
			   {AdjoinList Px L P}
			end
			case @skipcanvas then
			   skipnext<-true 
			else skip end
			{@objreceiver P} % click sur le canvas
			case {Label P}==oclick then
			   doubleobj<-P.1
			else skip end
		     else skip end
		  end	
	       end
	       case Px==stopserver then skip else
		  {Server Pr}
	       end
	    else skip end
	 end
      in
	 self.mport=MPORT
	 thread
	    threadid<-{Thread.this $}
	    {Server INPORT}
	 end
      end
      {self clearactions}
      {CANVAS tkBind(event:'<1>'
		     args:[float(x) float(y)]
		     action:MPORT#cclick)}
      {CANVAS tkBind(event:'<Shift-1>'
		     args:[float(x) float(y)]
		     action:MPORT#csclick)}
      {CANVAS tkBind(event:'<Double-1>'
		     args:[float(x) float(y)]
		     action:MPORT#cdclick)}
      {CANVAS tkBind(event:'<B1-Motion>'
		     args:[float(x) float(y)]
		     action:MPORT#cmotion)}
      {CANVAS tkBind(event:'<B1-ButtonRelease>'
		     args:[float(x) float(y)]
		     action:MPORT#crelease)}
      {CANVAS tkBind(event:'<2>'
		     args:[float(x) float(y)]
		     action:MPORT#mclick)}
      {CANVAS tkBind(event:'<Double-2>'
		     args:[float(x) float(y)]
		     action:MPORT#mdclick)}
      {CANVAS tkBind(event:'<Triple-2>'
		     args:[float(x) float(y)]
		     action:MPORT#radar)}
      {CANVAS tkBind(event:'<B2-Motion>'
		     args:[float(x) float(y)]
		     action:MPORT#mmotion)}
      {CANVAS tkBind(event:'<Shift-B2-Motion>'
		     args:[float(x) float(y)]
		     action:MPORT#msmotion)}
      {CANVAS tkBind(event:'<B2-ButtonRelease>'
		     args:[float(x) float(y)]
		     action:MPORT#mrelease)}

   end

   meth bindtag(T O) % bind le tag donne
      {T tkBind(event:'<1>'
		args:[float(x) float(y)]
		action:self.mport#oclick(O))}
      {T tkBind(event:'<Shift-1>'
		args:[float(x) float(y)]
		action:self.mport#osclick(O))}
      {T tkBind(event:'<Double-1>'
		args:[float(x) float(y)]
		action:self.mport#odclick(O))}
      {T tkBind(event:'<B1-Motion>'
		args:[float(x) float(y)]
		action:self.mport#omotion(O))}
      {T tkBind(event:'<B1-ButtonRelease>'
		args:[float(x) float(y)]
		action:self.mport#orelease(O))}
   end
      
   meth setactions(T SKIP ACCEPT gridded:B<=true)
      lock
	 acceptobj<-ACCEPT
	 skipcanvas<-SKIP
	 objreceiver<-T
	 gridded<-B
	 doubleobj<-nil
      end
   end

   meth setgridded(B)
      gridded<-B
   end
   
   meth clearactions
      local
	 class Dummy

	    meth init()
	       skip
	    end
	    
	    meth cclick(X Y)
	       skip
	    end

	    meth cmotion(X Y)
	       skip
	    end

	    meth crelease(X Y)
	       skip
	    end

	 end
	 T
      in
	 {self setactions({New Dummy init()} false false)}
      end
   end

   meth stopactionserver
%      case @threadid==nil then skip else
%	 {Thread.terminate @threadid}
%	 threadid<-nil
%      end
      {Send self.mport stopserver}
   end

   meth switchgrid(B)
      grid<-B
   end

   meth setgrid(X Y)
      gridx<-X
      gridy<-Y
   end

   meth gridcoord(X Y ?RX ?RY)
      case @grid then
	 RX={Floor (X+@gridx/2.0)/@gridx}*@gridx
	 RY={Floor (Y+@gridy/2.0)/@gridy}*@gridy
      else
	 RX=X
	 RY=Y
      end
   end
   
end

class DummyActions

   feat mport menus client

   attr skipcanvas acceptobj objreceiver temp threadid
      skipnext

   prop locking
      
   meth init(Client MPORT INPORT browser:Browser<=false)
      proc{Server Ps}
	 case Ps of Px|Pr then
	    case Px
	    of client(Msg) then
	       case {Label Msg}
	       of createobj then {Client Msg}
	       [] deleteobj then {Client Msg}
	       [] modifyobj then {Client Msg}
	       else skip end
	       {Server Pr}
	    [] stopserver then
	       skip
	    end
	 else skip end
      end
   in
      self.mport=MPORT
      thread
	 {Server INPORT}
      end
   end

   meth bindtag(T O) % bind le tag donne
      skip
   end
      
   meth setscale(S)
      skip
   end
      
   meth stopactionserver
      {Send self.mport stopserver}
   end 
end

