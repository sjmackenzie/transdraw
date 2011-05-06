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
% Cet objet est le serveur du tableau blanc reparti.
%
   
Objlistclass Objarrayclass NewRedir NewAsynch
{GList Objlistclass Objarrayclass NewAsynch NewRedir}
NewLocalize NewLocalizeGifs
{GNedLoc Open NewAsynch NewLocalize}
{GLoc Open NewLocalize NewLocalizeGifs _}

LocLock={NewCell unit}

proc{SetVal Var Value}
   Old New in
   {Exchange LocLock Old New}
   {Wait Old}
   case {IsFree Var} then Var=Value else skip end
   New=unit
end

class ServerObject

   feat server chatters wand ticket os quit
   
   attr clientset graphobjset locks temp lastlocks idset

   meth send(To Msg)
      try
	 {To Msg}
      catch X then
	 Synch in
	 {self.server closeclient(To Synch)}
      end
   end
      
   meth init(OS)
      clientset<-{New Objlistclass init()}
      graphobjset<-{New Objlistclass init()}
      locks<-{NewDictionary $}
      lastlocks<-{NewDictionary $}
      self.chatters={NewDictionary $}
      self.wand={NewDictionary $}
      self.os=OS
      idset<-nil
   end
   
   meth set(SERVER)
      self.server=SERVER
   end

   meth setticket(TICKET)
      self.ticket=TICKET
   end
   
   meth getclientclass(?C)
      %
      % c'est cette procedure qui va distribuer le whiteboard
      %
      % On est oblige de passer par une procedure complementaire pcq
      % pour le moment Oz ne supporte pas de distribuer Tk
      %
      try
	 proc {NewClient Tk TkTools Open OS Pickle System Remote Connection NAME ?Client Quit DebugMode SlowNetMode DelayInt SERVER}
	    DialogBox ToolBar StandardObj StandardTool
	    LineObj LineTool
	    ArrowObj ArrowTool
	    TextObj TextTool BrowseTool
	    FreezeTool ZoomTool NewLocalize NewLocalizeGifs Convert
	    SelectTool StatusBar ConsistantState
	    ResetFreeze BorderWidth ColorSelection ColorBar Debug SlowNet
	    MenuEvent ToolBox Wand ChatRoom RubberFrame Objlistclass
	    Objarrayclass NewAsynch NewRedir Actions DummyActions GroupObj ClientObject
	 in
	    {GList Objlistclass Objarrayclass NewAsynch NewRedir}
	    {GAct Actions DummyActions}
	    {GNedLoc Open NewAsynch NewLocalize}
	    {GLoc Open NewLocalize NewLocalizeGifs Convert}
	    {GNed Tk System Pickle OS Open DialogBox}
	    {GNTB Tk ToolBar}
	    {GStd Tk StandardObj StandardTool}
	    {GLine Tk StandardObj StandardTool Objlistclass LineObj LineTool}
	    {GArrow Tk StandardObj StandardTool Objlistclass ArrowObj ArrowTool}
	    {GTxt Tk StandardObj StandardTool TextObj TextTool}
	    {GFrz Tk StandardTool Objlistclass FreezeTool}
	    {GZoom Tk StandardTool Objlistclass ZoomTool}
	    {GBrowse Tk StandardTool Objlistclass BrowseTool}
	    {GSel Tk StandardTool Objlistclass SelectTool}
	    {GStat Tk Objlistclass StatusBar}
	    {GTB Tk TkTools Objarrayclass ConsistantState ResetFreeze BorderWidth ColorSelection ColorBar Debug SlowNet}
	    {GMenu Tk TkTools Open OS Pickle Objlistclass GroupObj ServerObject MenuEvent}
	    {GTools Tk ToolBox}
	    {GChat Tk OS DialogBox Wand ChatRoom RubberFrame}
	    {GGroup Tk StandardObj Objlistclass GroupObj}
	    {GClient Tk TkTools System Pickle Connection Open OS Remote DialogBox ToolBar StandardObj StandardTool LineObj LineTool ArrowObj ArrowTool TextObj TextTool FreezeTool ZoomTool BrowseTool NewLocalize NewLocalizeGifs Convert SelectTool StatusBar ConsistantState ResetFreeze BorderWidth ColorSelection ColorBar Debug SlowNet MenuEvent ToolBox Wand ChatRoom RubberFrame Objlistclass Objarrayclass NewAsynch NewRedir Actions DummyActions GroupObj ServerDialog ClientObject}
	    Client={New ClientObject init({StringToAtom {VirtualString.toString NAME}} SERVER DebugMode SlowNetMode Quit DelayInt)}
	 end
      in
	 C=NewClient
      catch X then skip end
   end      

   meth getstate(C)
      {self send(C curstate({@graphobjset getlist($)}))}
   end
   
   meth subscribe(C Name GL CH)
      try
	 ID in
         % on rajoute le client a la liste
	 {@clientset addobj(C)}
	 case Name\='' then
	    ID=ServerObject,getID(C $)
	    {ForAll {@clientset getlist($)}
	     proc{$ D}
		case D==C then % on n'envoie pas au modificateur la modif
		   skip
		else
		   {self send(D addChatter(ID Name))}
		end
	     end}
	 else skip end
	 local TEMP in
	    TEMP={@graphobjset getlist($)}
	    GL=TEMP
	 end
%	 NL=NewLocalizeGifs
	 CH={Dictionary.entries self.chatters}
	 case Name\='' then
	    {Dictionary.put self.chatters ID Name}
	 else skip end
	 {ForAll {@clientset getlist($)}
	  proc{$ D}
	     ID Wand in
	     ID=ServerObject,getID(D $)
	     Wand={Dictionary.condGet self.wand ID nil}
	     case Wand==nil then skip else
		{self send(C placeWand(ID Wand.1 Wand.2 Wand.3 Wand.4))}
	     end
	  end}
      catch X then skip end
   end

   meth getchatters(?CH)
      try
	 CH={Dictionary.entries self.chatters}
      catch X then skip end
   end
   
   meth getserver(C)
      {self send(C getserver(GetServer))}
   end
   
   meth closeclient(C Synch)
      ID in
      % on va virer tous les locks que possede ce client
      try % pas grave si cela plante dans cette partie du programme, on doit ignorer
	 {ForAll {Dictionary.entries @locks $}
	  proc {$ O}
	     case O of X#Z then % si X est locke par C
		case Z==C then
		   {Dictionary.remove @locks X}
		else skip end
	     else skip end
	  end}
      % on supprime sa baguette
	 {self deleteWand(C)}
      % et on le supprime de la chatlist
	 ID=ServerObject,getID(C $)
	 {ForAll {@clientset getlist($)}
	  proc{$ D}
	     case D==C then % on n'envoie pas au modificateur la modif
		skip
	     else
		{self send(D removechater(ID))}
	     end
	  end}
	 {Dictionary.remove self.chatters ID}
      % on supprime le client de la liste
	 {@clientset subtract(C)}
      % synchronisation avec le client pour qu'il acheve de se killer
	 Synch=unit
      catch X then skip end
   end
   
   meth createobj(C S)
      local S1 in
	 {Dictionary.put @locks S.id C} % on locke le client
	 {@graphobjset addobj(S)}
	 {Dictionary.put @lastlocks S.id C} % c'est le dernier a avoir modifie
	 case S.order=={@graphobjset length($)} then
	    S1=S % ordre est deja bon
	 else
	    % on va recalculer l'ordre
	    local TEMP in
	       TEMP={@graphobjset getlist($)}
	       graphobjset<-{New Objlistclass init}
	       {ForAll {Reverse TEMP}
		proc{$ T}
		   X in
		   case T.order<S.order then X=T else
		      case S==T then X=S else
			 X={AdjoinAt T order T.order+1}
		      end
		   end
		   {@graphobjset addobj(X)}
		end}
	    end
	    S1=S
	 end
	 {ForAll {@clientset getlist($)}
	  proc{$ D}
	     case D==C then % on n'envoie pas au createur la creation
		% mais bien la confirmation de l'ordre
		{self send(D commitorder(S1.id S1.order))}
	     else
		{self send(D createobj(S1))} % on envoie la creation aux autres
	     end
	  end}
      end
   end

   meth getlock(C ID)
      case {Dictionary.condGet @locks ID nil $}==nil then
	 % pas locke, donc on le lock
	 {Dictionary.put @locks ID C}
	 {self send(C lockok(ID))}
      else
	 % locke, on annule
	 case {Dictionary.get @locks ID $}==C then
	    {self send(C lockok(ID))} % meme client demande meme lock -> c'est ok
	 else
	    {self send(C lockko(ID))}
	 end
      end
   end

   meth regetlock(C ID)
      case {Dictionary.condGet @lastlocks ID nil $}==C then
	 % on peut tenter de recuperer le lock
	 {self getlock(C ID)}
      else {self send(C lockko(ID))} end
   end

   meth steallock(C ID)
      case {Dictionary.condGet @locks ID nil $}==nil then
	 % lock libre => on demande le lock normalement... apres 5 secondes
%	 {Dictionary.put @locks ID C}
%	 {C lockok(ID)}
	 % tant pis si le lock part entre temps... J'aime pas les voleurs !
	 thread
	    {Delay 5000}
	    {self.server getlock(C ID)}
	 end
      else
	 % locke...
	 case {Dictionary.get @locks ID $}==C then
	    {self send(C lockok(ID))} % meme client demande meme lock -> c'est ok
	 else
	    % client different demande lock => on lui demande de le rendre
	    {{Dictionary.get @locks ID $} droplock(ID C)}
	 end
      end
   end

   meth droplockok(C1 ID C2)
      % Client 1 accepte de relacher le lock ID
      % au benefice du client 2
      {self releaselock(C1 ID)}
      {self getlock(C2 ID)}
   end

   meth droplockko(C1 ID C2)
      % Client 1 refuse de relacher le lock
      % soit c'est un egoiste, soit il ne le possede deja plus
      {self getlock(C2 ID)}
   end
   
   meth delobj(C S)
      case {Dictionary.get @locks S.id $}\=C then
	 skip
      else
	 {Dictionary.put @lastlocks S.id C} % c'est le dernier a avoir modifie
	 {ForAll {@clientset getlist($)} % on dit a tout le monde l'effacement
	  proc{$ D}
	     {self send(D deleteobj(S))}
	  end}
	 local TEMP in % mise a jour de la liste
	    TEMP={Reverse {@graphobjset getlist($)}}
	    graphobjset<-{New Objlistclass init()}
	    {ForAll TEMP
	     proc {$ O}
		case O.id==S.id then
		   skip % on passe cet objet-ci
		else
		   local O2 in
		      case O.order>S.order then % on va diminuer de 1 l'ordre
			 O2={AdjoinAt O order O.order-1}
		      else O2=O end
		      {@graphobjset addobj(O2)}
		   end
		end
	     end}
	 end
      end
   end
	 
   
   meth modifyobj(C S)
      case {Dictionary.condGet @locks S.id nil $}\=C then
	 % pas le bon client qui demande
	 skip
      else TEMP in % mise a jour de la liste
	 case {Dictionary.condGet @lastlocks S.id nil $}\=nil then
	    % on le supprime
	    {Dictionary.remove @lastlocks S.id}
	 else skip end
	 {Dictionary.put @lastlocks S.id C} % c'est le dernier a avoir modifie
	 TEMP=@graphobjset
	 graphobjset<-{New Objlistclass init()}
	 {ForAll {TEMP getlist($)}
	  proc{$ O}
	     case O.id==S.id then
		{@graphobjset addobj(S)}
	     else
		{@graphobjset addobj(O)}
	     end
	  end}
	 {ForAll {@clientset getlist($)}
	  proc{$ D}
	     case D==C then % on envoie pas au modificateur la modif
		skip
	     else
		{self send(D modifyobj(S))}
	     end
	  end}
      end
   end

   meth modifyobjorder(C S1) % notification de modification
      % de l'ordre d'affichage
      % besoin de separer de la methode precedente pour des
      % besoins d'orthogonalite entre un commit local d'une modif
      % d'un objet, et un commit global de changement d'ordre
      % d'affichage.
      S in
      case {Dictionary.get @locks S1.id $}\=C then
	 % pas le bon client qui demande
	 skip % nota : ne devrait absolument jamais arriver
      else TEMP in % mise a jour de la liste
	 case {Dictionary.condGet @lastlocks S1.id nil $}\=nil then
	    % on le supprime
	    {Dictionary.remove @lastlocks S1.id}
	 else skip end
	 % on verifie que l'ordre demande est toujours possible
	 case S1.order=<{@graphobjset length($)} then
	    S=S1
	 else % ordre demande trop eleve -> on le diminue
	    {AdjoinAt S1 order {@graphobjset length($)} S}
	 end
	 {Dictionary.put @lastlocks S.id C} % c'est le dernier a avoir modifie
	 TEMP=@graphobjset
	 graphobjset<-{New Objlistclass init()}
	 local A in
	    {ForAll {TEMP getlist($)}
	     proc{$ O}
		case O.id==S.id then
		   A=O.order % retient l'ancien ordre
		   {@graphobjset addobj(S)}
		else
		   {@graphobjset addobj(O)}
		end
	     end}
	    case A==S.order then % meme ordre
	       skip % rien a changer
	    elsecase A<S.order then % on a augmente l'ordre
	       TEMP2 in
	       TEMP2=@graphobjset
	       graphobjset<-{New Objlistclass init()}
	       {ForAll {TEMP2 getlist($)}
		proc{$ O}
		   O2 in
		   case O.order>A andthen O.order=<S.order
		      andthen O.id\=S.id then
		      {AdjoinAt O order O.order-1 O2}
		   else O2=O end
		   {@graphobjset addobj(O2)}
		end}
	    else % on a diminue l'ordre
	       TEMP2 in
	       TEMP2=@graphobjset
	       graphobjset<-{New Objlistclass init()}
	       {ForAll {Reverse {TEMP2 getlist($)}}
		proc {$ O}
		   O2 in
		   case O.order<A andthen O.order>=S.order
		      andthen O.id\=S.id then
		      O2={AdjoinAt O order O.order+1}
		   else O2=O end
		   {@graphobjset addobj(O2)}
		end}
	    end
	 end	    
	 {ForAll {@clientset getlist($)}
	  proc{$ D}
	     case D==C then % on envoie pas au modificateur la modif
		skip
	     else
		{self send(D modifyobj(S))}
	     end
	  end}
	 {self send(C commitorder(S.id S.order))} % on commit la modif d'ordre
	 % chez l'initiateur -> cela ferme la barriere
      end
   end
   
   meth releaselock(C ID)
      case {Dictionary.condGet @locks ID nil $}==C then
	 {Dictionary.remove @locks ID}
      else
	 skip % pas le bon client
      end
   end

   meth quit
      {ForAll {@clientset getlist($)}
       proc{$ D}
	  {self send(D closeclient)}
       end}
      self.quit=unit
   end

   meth waitQuit
      {Wait self.quit}
   end
   
   meth getfullorder(C)
      local L in
	 L={New Objlistclass init()}
	 {ForAll {@graphobjset getlist($)}
	  proc {$ S}
	     {L addobj(tree(id:S.id order:S.order))}
	  end}
	 {self send(C fullorder({L getlist($)}))}
      end
   end

   % gestion de la baguette
   meth getID(C ID)
      {ForAll @idset
       proc{$ L}
	  case L of CL#IDL then
	     case CL==C then ID=IDL
	     else skip end
	  else skip end
       end}
      case {IsFree ID} then
%	 ID=nil
	 ID={NewName}
	 idset<-C#ID|@idset
      else skip end
   end
   
   meth placeWand(C X1 Y1 X2 Y2)
      ID in
      ID=ServerObject,getID(C $)
      {ForAll {@clientset getlist($)}
       proc{$ D}
	  case D==C then % on n'envoie pas au modificateur la modif
	     skip
	  else
	     {self send(D placeWand(ID X1 Y1 X2 Y2))}
	  end
       end}
      {Dictionary.put self.wand ID r(X1 Y1 X2 Y2)}
   end

   meth deleteWand(C)
      ID in
      ID=ServerObject,getID(C $)
      {ForAll {@clientset getlist($)}
       proc{$ D}
	  case D==C then % on n'envoie pas au modificateur la modif
	     skip
	  else
	     {self send(D deleteWand(ID))}
	  end
       end}
      {Dictionary.remove self.wand ID}
   end

   meth radar(C X Y)
      ID in
      ID=ServerObject,getID(C $)
      {ForAll {@clientset getlist($)}
       proc{$ D}
	  case D==C then % on n'envoie pas au modificateur la modif
	     skip
	  else
	     {self send(D radar(ID X Y))}
	  end
       end}
   end

   meth getinfo(C)
      TICKET in
      case {IsDet self.ticket} then
	 TICKET={AtomToString self.ticket}
      else
	 TICKET=nil
      end
      {self send(C receiveserverinfo(r(ticket:TICKET
				       clients:{Length {Dictionary.items self.chatters}}
				       objects:{@graphobjset length($)}
				       uname:{self.os.uName})))}
   end
   
   % gestion du chatroom

   meth sendMsg(C Msg To Mood)
      ID in
      ID=ServerObject,getID(C $)
      case To==nil then % broadcast
	 {ForAll {@clientset getlist($)}
	  proc{$ D}
	     case D==C then % on n'envoie pas au modificateur la modif
		skip
	     else
		{self send(D receivemsg(ID Msg false Mood))}
	     end
	  end}
      else
	 {ForAll @idset
	  proc{$ O}
	     case O of CL#IDL then
		case IDL==To then
		   {self send(CL receivemsg(ID Msg true Mood))}
		else skip
		end
	     else skip end
	  end}
      end
   end

   meth inviteto(ID Name Ticket Comment)
      {ForAll @idset
       proc{$ O}
	  case O of CL#IDL then
	     case IDL==ID then
		{self send(CL inviteto(Name Ticket Comment))}
	     else skip
	     end
	  else skip end
       end}
   end
   
end

class ServerDialog

   feat newclient server ticket tk tktools os dialogbox system open pickle remote connection quitserver debug parent mycon client menu windows synch

   attr clientlist
      
   meth init(SERVER Tk TkTools OS System Open Pickle Remote Connection DialogBox)
      self.tk=Tk
      self.tktools=TkTools
      self.os=OS
      self.system=System
      self.open=Open
      self.pickle=Pickle
      self.remote=Remote
      self.dialogbox=DialogBox
      self.connection=Connection
      SERVER={NewAsynch ServerObject init(OS) $}
      {SERVER set(SERVER)}
      self.server=SERVER
   end
      
   meth startgui(Quit debug:DebugMode<=false withdraw:WD<=false ticket:TICK<=nil windows:Windows<=false)
      TICKET NEWCLIENT
      Tk=self.tk
      TkTools=self.tktools
      Connection=self.connection
      T F1 F2 F3 M1 L1 L2 B1 B2 B3 B4 B5
      Show=self.system.show Z Read
   in
      self.windows=Windows
      Z={NewPort Read}
      thread
	 {ForAll Read
	  proc{$ Msg}
	     {self Msg}
	  end}
      end
      self.debug=DebugMode
      self.quitserver=Quit
      self.mycon={New Connection.gate init(self.server TICKET)} % cree le ticket
      {self.server setticket(TICKET)}
      {self.server getclientclass(NEWCLIENT)}
      self.newclient=NEWCLIENT
      self.ticket=TICKET
      case {IsFree TICK} then TICK=TICKET else skip end
      clientlist<-nil
      T={New Tk.toplevel tkInit(title:"TransDraw Drawing Server"
				delete:Z#quit
				withdraw:true)}
      self.parent=T
      F1={New Tk.frame tkInit(parent:T
			     borderwidth:2
			     relief:sunken)}
      L1={New Tk.label tkInit(parent:F1
			      text:"Ticket : "#TICKET
			      anchor:nw
			      justify:left)}
      B1={New Tk.button tkInit(parent:F1
			       text:"Copy to Clipboard"
			       action:Z#clipboard)}
      B2={New Tk.button tkInit(parent:F1
			       text:"Pickle to a file"
			       action:Z#pickleit)}
      L2={New Tk.label tkInit(parent:F1
			      text:"Zoom :"
			      anchor:nw
			      justify:left)}
      M1={TkTools.menubar F1 F1
	  [menubutton(text:"25 %"
		      feature:zoom
		      menu:[command(label:"25 %"
				    action:Z#zoom(0.25))
			    command(label:"33 %"
				    action:Z#zoom(0.33))
			    command(label:"50 %"
				    action:Z#zoom(0.50))
			    command(label:"75 %"
				    action:Z#zoom(0.75))
			    command(label:"100 %"
				    action:Z#zoom(1.0))
			    command(label:"150 %"
				    action:Z#zoom(1.50))
			    command(label:"200 %"
				    action:Z#zoom(2.00))
			    command(label:"300 %"
				    action:Z#zoom(3.00))
			    command(label:"400 %"
				    action:Z#zoom(4.00))])]
	  nil}
      self.menu=M1
      {self.menu.zoom.menu tk(configure tearoff:false)}
      {self.menu.zoom tk(configure relief:raised borderwidth:2)}
      F3={New Tk.frame tkInit(parent:T)}
      B3={New Tk.button tkInit(parent:F3
			       text:"Open an editor"
			       action:Z#openclient)}
      B4={New Tk.button tkInit(parent:F3
			       text:"Close drawing"
			       action:Z#quit)}
      B5={New Tk.button tkInit(parent:F3
			       text:"Help"
			       action:Z#help("server"))}
      F2={New Tk.frame tkInit(parent:T relief:sunken borderwidth:2)}
      local Quit CLIENT in
	 {self.newclient self.tk self.tktools self.open self.os self.pickle self.system self.remote self.connection
	  nil
	  CLIENT Quit 0 0 0 self.server}
	 clientlist<-Quit|@clientlist
	 {CLIENT displayer(F2 windows:self.windows)}
	 {CLIENT setscale(0.25)}
	 self.client=CLIENT
      end
      {Tk.batch [grid(F1 row:0 column:0 sticky:nswe)
		 grid(F2 row:1 column:0 sticky:nswe)
		 grid(F3 row:2 column:0 sticky:nswe)
		 grid(rowconfigure    T 1 weight:1)
		 grid(columnconfigure T 0 weight:1)
		 pack(L1 side:top fill:x padx:5 pady:5)
		 pack(B1 B2 L2 M1 side:left padx:5 pady:5 anchor:nw)
%		 pack(B1 B2 L2  side:left padx:5 pady:5 anchor:nw)
		 pack(B3 B4 side:left padx:5 pady:5)
%		 pack(B5 side:right padx:5 pady:5)
		]}
      case WD==false then
	 {Tk.send wm(deiconify self.parent)}
      else skip end
      {Tk.send wm(iconname self.parent "TransDraw Drawing Server")}
   end

   meth clipboard
      DialogBox=self.dialogbox in
      {self.tk.send clipboard(clear)}
      {self.tk.send clipboard(append self.ticket)}
      _={DialogBox message(title:"Clipboard"
			   text:"\nTicket was succesfully copied to the clipboard\n"
			   bitmap:info
			   buttons:ok)}
   end

   meth zoom(Val)
      {self.menu.zoom tk(configure text:{FloatToInt Val*100.0}#" %")}
      {self.client setscale(Val)}
   end
   
   meth openclient
      Tk=self.tk
      DialogBox=self.dialogbox
      Debug SlowNetwork Latency Nom
      T E2 F1 F2 F3 L2 E1 V1 V2 Cl B1 B2 B3
   in
      T={New Tk.toplevel tkInit(title:"Start a new editor"
				delete:proc{$} Cl=false end)}
      F1={New Tk.frame tkInit(parent:T relief:sunken borderwidth:2)}
      F2={New Tk.frame tkInit(parent:T relief:sunken borderwidth:2)}
      F3={New Tk.frame tkInit(parent:T)}
      E2={New Tk.entry tkInit(parent:F1
			      bg:white)}
      L2={New Tk.label tkInit(parent:F1
			      text:"Editor user's name :")}
      {Tk.send pack(L2 E2 side:left padx:5 pady:5)}
      {Tk.send pack(F1 side:top expand:yes fill:both padx:5 pady:5)}
      case self.debug then
	 {Tk.send pack(F2 side:top expand:yes fill:both padx:5 pady:5)}
      else skip end
      {Tk.send pack(F3 side:top expand:yes fill:x padx:5 pady:5)}
      B1={New Tk.button tkInit(parent:F3
			       text:"Ok"
			       action:proc{$} {SetVal Cl true} end)}
      B2={New Tk.button tkInit(parent:F3
			       text:"Cancel"
			       action:proc{$} {SetVal Cl false} end)}
      B3={New Tk.button tkInit(parent:F3
			       text:"Help"
			       action:self#help("newclient"))}
      {Tk.batch [pack(B1 B2 side:left padx:5)]}
%      {Tk.send pack(B3 side:right padx:5)}
      V1={New Tk.variable tkInit(0)}
      V2={New Tk.variable tkInit(0)}
      case self.debug then
	 C1 C2 L1 in
	 C1={New Tk.checkbutton tkInit(parent:F2
				       text:"Slow Network"
				       variable:V1)}
	 L1={New Tk.label tkInit(parent:F2
				 text:"Latency (ms) :")}
	 E1={New Tk.entry tkInit(parent:F2
				 bg:white)}
	 {E1 tk(insert 'end' 3000)}
	 C2={New Tk.checkbutton tkInit(parent:F2
				       text:"Debug Window"
				       variable:V2)}
	 {Tk.batch [pack(C2 C1 side:top anchor:nw expand:true)
		    pack(L1 E1 side:left anchor:nw fill:x)]}
      else skip end
      {T tkBind(event:"<Return>"
		action:proc{$} {SetVal Cl true} end)}
      {T tkBind(event:"<Escape>"
		action:proc{$} {SetVal Cl false} end)}
      {Tk.send focus(E2)}
      {Wait Cl}
      case self.debug then
	 Debug={V2 tkReturnInt($)}*7
	 SlowNetwork={V1 tkReturnInt($)}
	 Latency={E1 tkReturnInt(get $)}
      else
	 Debug=0
	 SlowNetwork=0
	 Latency=0
      end
      local N={E2 tkReturn(get $)} in
	 case N=="" then Nom="NoName" else
	    Nom=N
	 end
      end
      {T tkClose}
      case Cl then
	 thread Quit CLIENT in
	    {self.newclient self.tk self.tktools self.open self.os self.pickle self.system self.remote self.connection
	     Nom
	     CLIENT Quit Debug SlowNetwork Latency self.server}
	    clientlist<-Quit|@clientlist
	    {CLIENT subscribe(windows: self.windows)}
	 end
      else skip end
   end

   meth quit
      Tk=self.tk
      DialogBox=self.dialogbox
   in
      case {DialogBox message(title:"Close Drawing"
			      text:"\nWarning : this will close all editors.\n\nAre you sure ?"
			      bitmap:question
			      escape:1
			      buttons:okcancel)}==0 then
	 {Tk.send wm(withdraw self.parent)}
	 {self.client closeclient}
	 {self.server quit}
	 {ForAll @clientlist proc{$ C} {Wait C} end}
	 {self.mycon close}
	 self.quitserver=unit
	 {self.parent tkClose}
      else skip end
   end

   meth forceQuit
      {self.server quit}
      {ForAll @clientlist proc{$ C} {Wait C} end}
      self.quitserver=unit
      {self.parent tkClose}
   end
   
   meth pickleit
      Tk=self.tk
      DialogBox=self.dialogbox
      Pickle=self.pickle
      Name in
      Name={DialogBox getFile(type:save
			      defaultextension:''
			      filetypes:[['All Files' ['*' '.*']]]
			      title:"Save the ticket to the file")}
      case Name=='' then skip else
	 Error in
	 try
	    {Pickle.save self.ticket Name}
	 catch
	    error(...) then Error=unit
	 end
	 case {IsDet Error} then
	    _={DialogBox message(title:"Error"
				 text:"Unable to save the ticket to this file"
				 bitmap:error
				 buttons:ok)}
	 else
	    _={DialogBox message(title:"Success"
				 text:"The ticket is saved to the file "#Name
				 bitmap:info
				 buttons:ok)}
	 end
      end
   end

   meth help(PURL)
%      Tk=self.tk
%      DialogBox=self.dialogbox
%      OS=self.os
%      T Cl L in
%      T={New Tk.toplevel tkInit(title:"Help"
%				withdraw:true)}
%      {Tk.send wm(overrideredirect T true)}
%      L={New Tk.label tkInit(parent:T
%			     text:"\nPlease wait while netscape is searching for the help page.\n"
%			     anchor:nw
%			     borderwidth:2
%			     relief:sunken
%			     padx:5 pady:5
%			     justify:left)}
%      {Tk.send pack(L)}
%      {Tk.send wm(deiconify T)}
%      thread
%	 {Wait Cl}
%	 {T tkClose}
%      end
%      case {OS.system {VirtualString.toString "netscape -remote "#'"'#"openURL(http://www.info.ucl.ac.be/people/ned/transdrawhelp/"#PURL#".html)"#'"'} $}==0 then Cl=unit else
%	 Cl=unit
%	 _={self.dialogbox message(title:"Error"
%				   text:"Unable to access Netscape"
%				   bitmap:error
%				   buttons:ok)}
%      end
      skip
   end

   meth show
      {self.tk.send wm(deiconify self.parent)}
   end
   
end

