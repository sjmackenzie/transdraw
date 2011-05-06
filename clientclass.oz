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


%\define STUDENT
%\define NOCMAP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Ce fichier s'occupe de gerer l'objet ClientClass, qui represente la
% partie utilisateur du whiteboard
%
% Par Donatien Grolaux, 1998
%

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cette classe permet de creer un canvas d'une taille arbitraire,
% automatiquement gere par des scrollbars ET partiellement zoomable
%

class ScrollCanvas
   from Tk.canvas

   feat tag1 tag2 tag3
      
   attr
      height: 1.0
      width: 1.0
      orgx: 0.0
      orgy: 0.0
      orgok: false

   meth recalcorg
      try
	 orgx<-{self tkReturnFloat(canvasx(0.0) $)}
	 orgy<-{self tkReturnFloat(canvasy(0.0) $)}
      catch X then skip end
      orgok<-true
   end
      
   meth init(Parent ScrX ScrY)
      {self tkInit(parent:Parent
		   bg:white
%		   width:400
%		   height:300
		   scrollregion:'0 0 1000 1000'
		   highlightthickness:0)}
%      {Tk.addYScrollbar self ScrY}
%      {Tk.addXScrollbar self ScrX}
      local In Out A1 A2 in
	 In={NewPort Out}
	 A1={New Tk.action tkInit(parent:self
				  action:In#sety)}
	 A2={New Tk.action tkInit(parent:self
				  action:In#setx)}
	 {self tk(configure yscrollcommand:A1)}
	 {self tk(configure xscrollcommand:A2)}
	 {ScrY tkAction(%args:[integer(dummy) float(y)]
			action:In#yview
		       )}
	 {ScrX tkAction(%args:[integer(dummy) float(x)]
			action:In#xview
		       )}
	 thread
	    proc{Server X}
	       case X of Msg|Xs then
		  TODO in
		  case {IsDet Xs} then
		     case Xs of Y|Ys then
			case {Label Y}=={Label Msg} then
			   TODO=false
			else skip end
		     else skip end
		  else skip end
		  case {IsFree TODO} then
		     case {Label Msg}==sety then
			{ScrY tk(set b({Record.toList Msg}))}
		     elsecase {Label Msg}==setx then
			{ScrX tk(set b({Record.toList Msg}))}
		     else
			{self tk({Label Msg} b({Record.toList Msg}))}
		     end
		     orgok<-false
		  else skip end
		  {Server Xs}
	       else skip end
	    end
	 in
	    {Server Out}
	 end
      end
      {self tkBind(event:'<Configure>'
		   action:self#Resized
		   args: [float(h) float(w)]
		   append:true)}
      self.tag1={New Tk.canvasTag tkInit(parent:self)}
      self.tag2={New Tk.canvasTag tkInit(parent:self)}
      self.tag3={New Tk.canvasTag tkInit(parent:self)}
      {self tk(crea rect
	       0 1001
	       100000 100000
	       fill:grey
	       outline:grey
	       tags:self.tag1)}
      {self tk(crea rect
	       1001 0
	       100000 1001
	       fill:grey
	       outline:grey
	       tags:self.tag2)}
      {self tk(crea rect
	       ~100000 ~100000
	       ~1      1000000
	       fill:grey
	       outline:grey
	       tags:self.tag3)}
      {self tk(crea rect
	       0 ~100000
	       100000 ~1
	       fill:grey
	       outline:grey
	       tags:self.tag3)}
   end
   
   meth Resized(H W)
      width<-W
      height<-H
      {self tk(configure width:W)}
      {self tk(configure height:H)}
      {self recalcorg}
   end

   meth zoom(Val)
      {self tk(coords self.tag1 0 1000.0*Val+1.0 10000000 10000000)}
      {self tk(coords self.tag2 1000.0*Val+1.0 0 10000000 1000.0*Val+1.0)}
      {self recalcorg}
   end

   meth hideborders
      {self tk(delete self.tag1)}
      {self tk(delete self.tag2)}
      {self tk(delete self.tag3)}
   end

   meth getorgx(X)
      case @orgok then skip else {self recalcorg} end
      X=@orgx
   end

   meth getorgy(Y)
      case @orgok then skip else {self recalcorg} end
      Y=@orgy
   end
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation du reseau lent
%
%

proc {SlowNetwork D Obj ?SlowObj}
   C={NewCell unit}
in
   proc {SlowObj Msg}
      Xold Xnew in
      {Exchange C Xold Xnew}
      thread
	 {Delay {Access D $}}
	 {Wait Xold}
	 {Obj Msg}
	 Xnew=unit
      end
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cette classe gere le client proprement dit.
%
%

class ClientObject

   feat client dc toolbar actions actport window seltool objmap consistant
      border color freezer colorbar localize cleanuptemp debug netdelay
      freezetool zoomtool slownet tmpclient name selicon texticon status cursynch mylock
      iconbar dialogbox texttool wand chat dbg slownetwork quit delay
      myport listener dummy windows helpserverdict
   
   attr
      server
      objlist            % liste des objets geres par ce client
      lockset            % liste des locks que possede ce client
      selset             % liste des objets selectionnes par l'outil selection
      freezeset          % liste des objets selectionnes par l'outil freeze
      savestate          % liste des etats sauvegardes pour rollup
      commitlist         % liste des commandes a effectuer si commit
      virtualorder       % liste des ordres que le serveur connait
      waitingorder       % liste des ordres que le serveur doit encore confirmer
      waitingobject      % liste des objets en attente de creation
      ordersent          % liste les changements d'ordre envoye au serveur
      temp i             % variables temporaires
      sellocktoget       % nombre de locks encore a obtenir pour la selection
      undodata           % retient comment faire un undo
      thid               % idem
      stealset
      serverinfo
      ender
      scale
      helpwindow
      helpback
      
      
   prop locking
	 
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Methodes d'utilisation generale du client 
   %

   meth init(NAME SERVER DEBUG SLOWNET Quit Delay)
      self.dbg=DEBUG
      self.slownetwork=SLOWNET
      self.quit=Quit
      self.delay=Delay
      ender<-nil
      objlist<-{New Objlistclass init()}
      lockset<-{New Objlistclass init()}
      selset<-{New Objlistclass init()}
      freezeset<-{New Objlistclass init()}
      savestate<-{New Objlistclass init()}
      commitlist<-{New Objlistclass init()}
      virtualorder<-{New Objlistclass init()}
      waitingorder<-{New Objlistclass init()}
      waitingobject<-{New Objlistclass init()}
      undodata<-{New Objlistclass init()}
      {NewCell 0 self.netdelay}
      server<-{SlowNetwork self.netdelay SERVER $}
%      server<-SERVER
      self.objmap={NewDictionary $}
      self.helpserverdict={NewDictionary}
      helpwindow<-nil
      helpback<-nil
      sellocktoget<-0
      self.name=NAME
      ordersent<-{New Objlistclass init()}
      thread
	 thid<-{Thread.this $}
      end
      {NewCell unit self.cursynch}
      {NewCell unit self.mylock}
      stealset<-{New Objlistclass init()}
      scale<-1.0
   end
   
   meth subscribe(windows:Windows<=false)
      self.windows=Windows
         % Pour le moment, CLIENT est une reference synchrone au client via un port
         % On va creer le port qui va servir de dispatcher
      P1 P2 P3 Port Server Client
   in
      Port={NewPort self.myport}
      Server=@server
      Client=self.client
      self.client=proc{$ Msg}
%		     try
			{Send Port Msg}
%		     catch error(...) then
%			Synch in
%			% force quit
%			{Server closeclient(Client Synch)}
%			{Wait Synch}
%		     end
		  end
      {@server subscribe(self.client self.name P1 P3)}
      {self subsok(P1 NewLocalizeGifs P3)}
   end
   
   meth subscribetop(Window)
      self.window=Window
      {self subscont}
   end
   
   meth rebuildwhiteboard(W)
         % cette methode enleve tous les elements presents dans le whiteboard
      {ForAll {@objlist getlist($)}
       proc{$ O}
	  {O kill()}
	  {Dictionary.remove self.objmap {O getstate($)}.id}
       end}
         %
      objlist<-{New Objlistclass init}
         % et reconstruit tout en fonction de ce qui est contenu dans W
         % tout d'abord, on va construire la liste dans l'ordre
      {ForAll {List.sort W fun{$ A B} A.order<B.order end}
       proc{$ S}
	  TEMP in
	  {self statetoobj(S TEMP)}
	  {@objlist addobj(TEMP)}
	  {@virtualorder addobj(S.id)} % on construit l'ordre en meme temps
	  {Dictionary.put self.objmap S.id TEMP}
       end}
   end      

   meth getlast(?N) % pour un nouvel objet -> au dessus du reste
      proc {PROC I}
	 case I>0 andthen {{@objlist getmember(I $)}
			   isvisible($)}==false then
	    {PROC I-1}
	 else
	    N=I
	 end
      end
   in
      {PROC {@objlist length($)}}
   end

   meth setlocalorder(O N)
      S in
      S={@objlist getindex(O $)}
      case N==S then % ordre ok
	    % si c'est a la fin, on va quand meme reafficher
	 case N=={@objlist length($)} then
	    case N==1 then % il est tout seul
	       {O lower} % on le met tout en bas
	    else
	       % on le place apres le precedent
	       {O raiseafter({{@objlist getmember({@objlist length($)}-1
						  $)} toptag($)})}
	    end
	 else skip end % deja correct, rien a faire
      else
	 % ordre pas ok on replace au bon endroit
	 {@objlist movemember(S N)}
	 % on va changer tous les numeros
	 {List.forAllInd {Reverse {@objlist getlist($)}}
	  proc{$ I O}
	     {O setorder(I)}
	  end}
	     % si c'est a la fin, on va le placer correctement
	 case N=={@objlist length($)} then
	    case N==1 then % il est tout seul
	       {O lower} % on le met tout en bas
	    else		     
		  % on le place apres le precedent
	       {O raiseafter({{@objlist getmember({@objlist length($)}-1
						  $)} toptag($)})}
	    end
	 else
	    {O lowerbefore({{@objlist getmember(N+1 $)} belowtag($)})}
	 end
      end
      {O setorder(N)}
   end
      
   meth getfulltrans(?L)
      L={New Objlistclass init}
      {ForAll {@commitlist getlist($)}
       proc {$ T}
	  {L appendlist({T.obj getlist($)})}
       end}
   end
      
   meth resolvetrans
         % cette methode va voir s'il y a moyen de resoudre les transactions
      case {@commitlist length($)}==0 then
	    % plus de transactions en cours
	 sellocktoget<-0 % on le remet a zero au cas ou...
	 {self.consistant yes}
	 {{self.toolbar getcurtool($)} updsel}
	 case {@savestate length($)}==0 then skip
	 else
	    savestate<-{New Objlistclass init}
	 end
      else
	 FirsT in
	 FirsT={@commitlist getfirst($)} % prend la premiere transaction
	 case {List.all {FirsT.obj getlist($)} fun{$ O}
						  {@lockset member(O $)}
					       end}
	 then
               % supression de la commitlist
	    {@commitlist removefirst}
	       % on peut commiter cette transaction
	    {ForAll {Reverse {FirsT.commit getlist($)}}
	     proc {$ Cmd}
		{@server Cmd}
		case Cmd
		of modifyobjorder(C S) then
		   {@ordersent addobj(S.id)}
		[] createobj(C S) then
		   O in
		   {Dictionary.get self.objmap S.id O}
		   {@waitingobject subtract(O)} % l'objet est maintenant cree
		   {@virtualorder addobj(S.id)} % on le met a la fin du virtual order
		   case {{self getfulltrans($)} member(O $)} then
			 % si on a encore besoin de ce lock, lockok va
			 % decrementer sellocktoget => on l'incremente
			 % anticipativement.
		      sellocktoget<-@sellocktoget+1
		   else skip end
		   {self lockok(S.id)} % prend le lock d'une maniere implicite
		   {@ordersent addobj(S.id)}
		[] delobj(C S) then
		   {@ordersent addobj(S.id)}
		else skip end
	     end}
	       % on met a jour savestate
	       % deux etapes : d'abord suppression des anciens etats
	    {ForAll {FirsT.obj getlist($)}
	     proc {$ S}
		{ForAll {@savestate getlist($)}
		 proc {$ Q}
		    case Q.id=={S getid($)} then
		       {@savestate subtract(Q)}
		    else skip end
		 end}
	     end}
	       % ensuite ajout de nouveaux anciens etats (sic)
	    case {@commitlist length($)}==0 then
		  % si on est maintenant dans un etat consistant -> prend les
		  % valeurs en cours
	       {ForAll {FirsT.obj getlist($)}
		proc{$ S}
		   {@savestate addobj({S getstate($)})}
		end}
	    else
		  % prend les valeurs sauvees a cet effet
	       {@savestate appendlist({FirsT.savestate getlist($)})}
	    end
	       % on regarde s'il y a des locks a abandonner
	    local L in
	       L={self getfulltrans($)}
%		  {L appendlist({@freezeset getlist($)})}
	       {ForAll {FirsT.obj getlist($)}
		proc {$ O}
		   case {L member(O $)} then
		      skip % on en a donc toujours besoin
		   else
		      case {@selset member(O $)} then
		            % s'il est dans savestate, on le supprime aussi
			 local I in
			    I={O getstate($)}
			    {ForAll {@savestate getlist($)}
			     proc {$ S}
				case S.id==I.id then
				   {@savestate subtract(S)}
				else skip end
			     end}
			 end			    
		      else case {@freezeset member(O $)} then
			      skip
			   else
		                 % le lock n'est plus demande donc plus necessaire
			      {@lockset subtract(O)}
			      {@server releaselock(self.client {O getid($)})}
			   end
		            % s'il est dans savestate, on le supprime aussi
			 local I in
			    I={O getstate($)}
			    {ForAll {@savestate getlist($)}
			     proc {$ S}
				case S.id==I.id then
				   {@savestate subtract(S)}
				else skip end
			     end}
			 end
		      end
		   end
		end}
	    end
	       % on itere
	    {self resolvetrans}
	 else
	    {self.consistant count(@sellocktoget)}
	    {self.consistant no} % pas dans un etat consistant
	 end
      end
   end

   meth orderedsavestate(L)
      local M N in
	 M={New Objlistclass init}
	 N=@savestate
	 {ForAll {@savestate getlist($)} % pour le faire le bon nbr de fois
	  proc {$ I}
	     % determine le savestate d'ordre le plus bas
	     temp<-{N getfirst($)}
	     {ForAll {N getlist($)}
	      proc {$ O}
		 case O.order<@temp.order then
		    temp<-O
		 else skip end
	      end}
	     {M addobj(@temp)} % c'est le plus bas, on le rajoute
	     {N subtract(@temp)} % on ne doit plus le traiter
	  end}
	 L={M getlist($)}
      end
   end
   
   meth rollup
         % on va annuler
         % on restaure d'abord l'ordre d'affichage correct
      {ForAll {@savestate getlist($)} % on prend toutes les sauvegardes
       proc {$ S}
	  local O in
	     O={Dictionary.get self.objmap S.id}
	     {O setstate(S)}
	     case {@freezeset member(O $)} then
		skip
	     else
		{O settag(none)}
	     end
	  end
       end}
	 % regarde si on est en attente de creation d'objet
      {ForAll {@waitingobject getlist($)}
       proc {$ O}
	  {Dictionary.remove self.objmap {O getid($)}}
	  {O settag(none)}
	  {O kill}
	  case {@freezeset member(O $)} then
	     {@freezeset subtract(O)}
	     {self.freezetool subtract(O)}
	     {self.freezer count({@freezeset length($)})}
	  else skip end
	  {@waitingobject subtract(O)}
	  {@objlist subtract(O)}
       end}
	 % on va supprimer de la liste waitingorder les demandes non
	 % reellement envoyees
      local OLDWAIT in
	 OLDWAIT={New Objlistclass init()}
	    % OLDWAIT=l'ancienne liste waitingorder
	 {OLDWAIT appendlist({@waitingorder getlist($)})}
	 waitingorder<-{New Objlistclass init()}
	 {ForAll {@ordersent getlist($)}
	  proc {$ T}
	     TT in
	     temp<-false
	     {ForAll {@OLDWAIT getlist($)}
	      proc {$ W}
		 case W.id==T andthen @temp==false then
		    temp<-true % prend le premier uniquement
		    TT=W
		 else skip end
	      end}
	     case @temp then
		   % l'ordre a ete envoye, on le retient donc
		{@waitingorder addobj(TT)}
		   % on le supprime de l'autre liste
		{@OLDWAIT subtract(TT)}
	     else skip end
	  end}
      end
      {ForAll {@lockset getlist($)} % on relache les locks dont on n'a plus besoin
       proc{$ O}
	  case {@freezeset member(O $)} then
	     {O settag(black)} % on restaure le tag
	  else
	     {@lockset subtract(O)}
	     {@server releaselock(self.client {O getid($)})}
	  end
       end}
      selset<-{New Objlistclass init} % MAZ de la liste
      savestate<-{New Objlistclass init} % mise a zero des etats sauvegardes
      commitlist<-{New Objlistclass init} % maz du commit
      undodata<-{New Objlistclass init} % empeche de pouvoir faire un undo.
         % l'etat est de nouveau consistant
      sellocktoget<-0
      {self recalcorder}
      {self.consistant yes}
         % si on est en train de faire quelque chose avec l'outil
         % de selection, on annule.
%      {self.seltool abort}
      {{self.toolbar getcurtool($)} abort}
   end
   
   meth addsavestate(S)
      case {self.consistant get($)} then skip else
	 {@savestate addobj(S)}
      end
   end
   
   meth startundolog
      undodata<-{New Objlistclass init}
      % cree une nouvelle transaction
      case {@commitlist length($)}==0 then skip else
	 NewT in
	 NewT=tree(obj:{New Objlistclass init}
		   commit:{New Objlistclass init}
		   savestate:{New Objlistclass init})
	 {NewT.obj appendlist({{@commitlist getlast($)}.obj getlist($)})}
	 {ForAll {NewT.obj getlist($)}
	  proc{$ O}
	     {{@commitlist getlast($)}.savestate addobj({O getstate($)})}
	  end}
	 {@commitlist addobj(NewT)}
      end
   end

   meth addundo(O C)
      {@undodata addobj(tree(obj:O cmd:C))}
   end

   meth maxorder(N ?R)
      case N>{self getlast($)} then
	 R={self getlast($)}+1
      else
	 R=N
      end
   end
   
%   meth undo % undo : ressemble a getsellock pcq on fait aussi transaction
%      lock
%	 TEMP
%	 OBJLIST
%	 RELEASE
%      in
%	 {self releasesellock({@selset getlist($)})}
%	 {self.seltool resetsellist}
%	 TEMP={@undodata getlist($)}
%	 undodata<-{New Objlistclass init}
%	 OBJLIST={New Objlistclass init}
%	 case {@commitlist length($)}==0 then
%	    % on doit faire la transaction
%	    {ForAll TEMP
%	     proc{$ U}
%		case U.obj==nil then skip else
%		   case {Dictionary.condGet self.objmap {U.obj getid($)} nil $}==nil then
%		      skip % on ne demande pas un lock d'un objet inexistant.
%		   else
%		      case {OBJLIST member(U.obj $)} then skip else
%			 {OBJLIST addobj(U.obj)}
%		      end
%		   end
%		end
%	     end}
%	     % on demande les locks necessaires pour la transaction
%	    {self regetlock({OBJLIST getlist($)})}
%	    RELEASE=true
%	 else
%	    RELEASE=false
%	 end
%	 {Show RELEASE}
%	 % on va maintenant undoer
%	 {ForAll {Reverse TEMP}
%	  proc{$ U}
%	     case U.cmd
%	     of setorder(Obj Nu) then
%		{self setorder(Obj {self maxorder(Nu $)})}
%	     [] delete(L) then
%		{Show {@commitlist length($)}}
%		{Show RELEASE}
%		{Show {@waitingorder length($)}}
%		{Show {@commitlist getlist($)}}
%		case RELEASE then
%		   {self delete(L)}
%		else
%		   {self undodelete({List.last L})}
%		end
%	     else
%		{self U.cmd} % effectue l'undo
%	     end
%	  end}
%	 case RELEASE then
%	    % relache les locks
%	    {self releasesellock({@selset getlist($)})}
%	 else
   %%	    % mise a jour en cas de suppression d'une creation
   %%	    {self debug}
   %%	    local TEMP in
   %%	       TEMP={@commitlist getlast($)}.commit
   %%	       {ForAll {TEMP getlist($)}
   %%		proc{$ Cmd}
   %%		   case Cmd
   %%		   of createobj(C S) then
   %%		      local O in
   %%			 {Dictionary.get self.objmap S.id O}
   %%			 {@waitingobject subtract(O)}
   %%			 {@objlist subtract(O)}
   %%			 {ForAll {@waitingorder getlist($)}
   %%			  proc {$ T}
   %%			     case T.id==S.id then
   %%				{@waitingorder subtract(T)}
   %%			     else skip end
   %%			  end}
   %%			 {@freezeset subtract(O)}
   %%			 {ForAll {@savestate getlist($)}
   %%			  proc{$ T}
   %%			     case T.id==S.id then
   %%				{@savestate subtract(T)}
   %%			     else skip end
   %%			  end}
   %%			 {Dictionary.remove self.objmap S.id}
   %%		      end
   %%		   else skip end
   %%		end}
   %%	    end
%	    % efface la derniere commande du commitlist
%	    {@commitlist drop(1)}
%	    case {@commitlist length($)}==0 then
%	       {self.consistant yes}
%	    else
%	       % recompte le nombre de locks en attente
%	       temp<-0
%	       local TL in
%		  TL={self getfulltrans($)}
%		  {ForAll {@freezeset getlist($)}
%		   proc{$ O}
%		      case {TL member(O $)} then
%			 skip
%		      else
%			 {TL addobj(O)}
%		      end
%		   end}		  
%		  {ForAll {TL getlist($)}
%		   proc{$ O}
%		      case {@lockset member(O $)} then
%			 temp<-@temp+1
%		      else skip end
%		   end}
%		  {self.consistant count(@temp)}
%	       end
%	    end	    
%	 end
%      end
%      {self recalcorder}
%      {self resolvetrans}
%      {{self.toolbar getcurtool($)} justundone}
%   end

   
   meth undo % undo : ressemble a getsellock pcq on fait aussi transaction
      TEMP
      OBJLIST
   in
      {self releasesellock({@selset getlist($)})}
      {self.seltool resetsellist}
      TEMP={@undodata getlist($)}
      undodata<-{New Objlistclass init}
      OBJLIST={New Objlistclass init}
      temp<-true
      {ForAll TEMP
       proc{$ U}
	  case U.obj==nil then skip else
	     case {Dictionary.condGet self.objmap {U.obj getid($)} nil $}==nil then
		   % on ne demande pas un lock d'un objet inexistant.
		   % mais alors, l'undo echoue.
		temp<-false
	     else
		case {OBJLIST member(U.obj $)} then skip else
		   {OBJLIST addobj(U.obj)}
		end
	     end
	  end
       end}
      case @temp then
	     % on demande les locks necessaires pour la transaction
	 {self regetlock({OBJLIST getlist($)})}
	 % on va effectuer l'undo
	 {ForAll TEMP
	  proc{$ U}
	     case U.cmd
	     of setorder(Obj Nu) then
		{self setorder(Obj {self maxorder(Nu $)})}
		{self recalcorder}
	     else
		{self U.cmd} % effectue l'undo
		{self recalcorder}
	     end
	  end}
	     % relache les locks
	 {self releasesellock({@selset getlist($)})}
	 {self.seltool resetsellist}
      else skip end
      {self resolvetrans}
      {self recalcorder}
      {{self.toolbar getcurtool($)} justundone}
   end
   
   meth getlastcommit(?C)
      C={@commitlist getlast($)}
   end
   
   meth recalcorder
      % on connait la virtualorder qui liste les objets dans l'ordre que l'on
      % sait etre connu par le serveur.
      % on connait aussi la waitingorder qui liste les demandes en suspend
      % et la waitingobject
%      TDic={NewDictionary}
%      TDic2={NewDictionary}
%      proc{ForI I To Proc}
%	 case I=<To then
%	    {Proc I}
%	    {ForI I+1 To Proc}
%	 else skip end
%      end
%      proc{ForDownI I To Proc}
%	 case I>=To then
%	    {Proc I}
%	    {ForDownI I-1 To Proc}
%	 else skip end
%      end
%      proc{Loop1 I Xs}
%	 case Xs of X|Xr then
%	    {Dictionary.put TDic I X}
%	    {Dictionary.put TDic2 X I}
%	    {Loop1 I+1 Xr}
%	 else skip end
%      end
%      {Loop1 1 {Reverse {@virtualorder getlist($)}}} % les objets sont maintenant places dans le dictionnaire
%      MAX={self getlast($)}+{@waitingobject length($)}+1
%      {Loop1 {@virtualorder length($)}+1 {Map {Reverse {@waitingobject getlist($)}}
%					  fun{$ O} {O getid($)} end}}
%      End={NewCell {@virtualorder length($)}+{@waitingobject length($)}}
%      proc{MoveTo ID Order1}
%	 Old Order in
%	 case Order1<MAX then Order=Order1 else Order=MAX end
%	 {Dictionary.get TDic2 ID Old}
%	 case Old<Order then
%	    {ForI Old Order-1
%	     proc{$ I}
%		Old in
%		Old={Dictionary.get TDic I+1}
%		{Dictionary.put TDic I Old}
%		{Dictionary.put TDic2 Old I}
%	     end}
%	    {Dictionary.put TDic Order ID}
%	    {Dictionary.put TDic2 ID Order}
%	 elsecase Old>Order then
%	    {ForDownI Old Order+1
%	     proc{$ I}
%		Old in
%		Old={Dictionary.get TDic I-1}
%		{Dictionary.put TDic I Old}
%		{Dictionary.put TDic2 Old I}
%	     end}
%	    {Dictionary.put TDic Order ID}
%	    {Dictionary.put TDic2 ID Order}	    
%	 else skip end
%      end
%      {ForAll {@waitingorder getlist($)}
%       proc{$ X}
%	  case {Dictionary.member TDic X.id} then
%	     skip
%	  else
%	     {Assign End {Access End}+1}
%	     {Dictionary.put TDic {Assign End} X.id}
%	     {Dictionary.put TDic2 X.id {Assign End}}
%	  end
%	  {MoveTo X.id X.order}
%       end}
%   in
%      {List.forAllInd {List.sort
%		       {List.map
%			{Dictionary.entries TDic}
%			fun{$ P1}
%			   case P1 of O#ID then
%			      r(id:ID order:O)
%			   end
%			end}
%		       fun{$ A B}
%			  A.order<B.order
%		       end}
%       proc{$ I P}
%	  local O in
%	     O={Dictionary.get self.objmap P.id}
%	     {self setlocalorder(O I)}
%	  end
%       end}

	    
      local FINALLIST LM MAX TEMP in
	 FINALLIST={New Objlistclass init()}
	 {FINALLIST appendlist({Reverse {@virtualorder getlist($)}})}
	 LM={self getlast($)}+1
	 {ForAll {@waitingobject getlist($)}
	  proc {$ O}
	     {FINALLIST setmember(LM {O getid($)})}
	  end}
	 MAX=LM+{@waitingobject length($)}+1
	 TEMP={@waitingorder getlist($)}
	 waitingorder<-{New Objlistclass init}
	 {ForAll {Reverse TEMP}
	  proc{$ A}
	     {FINALLIST subtract(A.id)}
	     case A.order=<MAX then
		{FINALLIST setmember(A.order A.id)}
		{@waitingorder addobj(A)}
	     else
		{FINALLIST setmember(MAX A.id)}
		{@waitingorder addobj(tree(order:MAX id:A.id))}
	     end
	  end}
	    % maintenant, FINALLIST represente l'information maximale que l'on
	    % peut avoir a ce moment !
	    % on l'applique donc ici
	 {List.forAllInd {Reverse {FINALLIST getlist($)}}
	  proc{$ V I}
	     local O in
		O={Dictionary.get self.objmap I}
		{self setlocalorder(O V)}
	     end
	  end}
      end
   end
      
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Methodes appeles par le serveur 
   %

   
   % Partie 1 : gestion du client

   meth subsok(W L CHAT)
      RECT SEL LINE ARROW TEXT
      ACTIONS CERC FREEZE BROWSER DC ACTPORT ACTOUT MENU MAIN TOP BOT
      F1 F2 F5 F8
      ScrX ScrY M MenuBar in
      {L Open OS self.localize self.cleanuptemp}
      ACTPORT={NewPort ACTOUT}
      case self.windows then
	 MenuBar={New Tk.menu tkInit(type:menubar parent:nil)}
	 self.window = {New Tk.toplevel tkInit(width:1 height:1
					       bg:gray
					       delete:self.client#exit
					       withdraw:true
\ifndef NOCMAP
					       visual:'truecolor'
%					       colormap:new
\endif					    
					       menu:MenuBar
					      )}
      else
	 self.window = {New Tk.toplevel tkInit(width:1 height:1
					       bg:gray
					       delete:self.client#exit
					       withdraw:true
\ifndef NOCMAP
					       visual:'truecolor'
%					       colormap:new
\endif					    
					      )}
      end
      % Configuration de la fenetre
      {Tk.send wm(title self.window 'TransDraw Editor - '#self.name)}
      F1={New Tk.frame tkInit(parent:self.window
			      bg:gray
			      borderwidth:2
			      relief:groove)} % barre d'icones
      F8={New Tk.frame tkInit(parent:self.window bg:gray
			      width:400)} % status bar
      self.dummy=F8
      MAIN={New Tk.frame tkInit(parent:self.window bg:gray
				width:640
				height:400)} % partie centrale
\ifdef STUDENT
      TOP=MAIN
      BOT={New Tk.frame tkInit(parent:self.window)}
\else      
      {RubberFrame MAIN TOP BOT true 0.85 _}
\endif      
      F2={New Tk.frame tkInit(parent:TOP bg:gray)} % partie superieure du toolbox
      F5={New Tk.frame tkInit(parent:TOP bg:gray
			      width:400)} % selection des couleurs
      case self.windows then
	 ScrX  = {New Tk.scrollbar tkInit(parent: TOP
					  relief: sunken
					  bg:gray
					  orient: horizontal)}
	 ScrY  = {New Tk.scrollbar tkInit(parent: TOP
					  bg:gray
					  relief: sunken)}
      else
	 ScrX  = {New Tk.scrollbar tkInit(parent: TOP
					  relief: sunken
					  bg:gray
					  width:10
					  orient: horizontal)}
	 ScrY  = {New Tk.scrollbar tkInit(parent: TOP
					  bg:gray
					  width:10
					  relief: sunken)}
      end
      DC={New ScrollCanvas init(TOP ScrX ScrY)}
      self.dialogbox=DialogBox
      self.dc=DC
      self.toolbar = {New ToolBox init(F2 ACTPORT self)}
      self.border={New BorderWidth init(F2 self)}
      self.color={New ColorSelection init(F2 self.dialogbox self)}
      self.consistant={New ConsistantState init(F2 self)}
      M={New MenuEvent init(self.window MENU self @server self.consistant
			    self.toolbar self.selicon self.texticon self.dialogbox
			    self.localize)}
      case self.windows then
	 {ForAll [MENU.file MENU.edit MENU.arrange MENU.tools MENU.help]
	  proc{$ MM}
	     {MenuBar tk(add cascade label:{MM tkReturn(cget('-text') $)}
			 menu:MM.menu)}
	  end}
	 {Tk.batch [grid(F1   row:0 column:0              sticky:we)
		    grid(MAIN row:1 column:0              sticky:nswe)
		    grid(F8   row:2 column:0              sticky:we)
		    grid(rowconfigure     self.window 1 weight:1)
		    grid(columnconfigure  self.window 0 weight:1)
		   ]}
      else
	 {Tk.batch [grid(MENU row:0 column:0              sticky:we)
		    grid(F1   row:1 column:0              sticky:we)
		    grid(MAIN row:2 column:0              sticky:nswe)
		    grid(F8   row:3 column:0              sticky:we)
		    grid(rowconfigure     self.window 2 weight:1)
		    grid(columnconfigure  self.window 0 weight:1)
		   ]}
      end
      {Tk.batch [grid(F2   row:0 column:0 rowspan:2    sticky:ns)
		 grid(DC   row:0 column:1              sticky:nswe)
		 grid(ScrY row:0 column:2              sticky:ns)
		 grid(ScrX row:1 column:1              sticky:we)
		 grid(F5   row:2 column:0 columnspan:3 sticky:we)
		 grid(rowconfigure    TOP 0 weight:1)
		 grid(columnconfigure TOP 1 weight:1)]}
      self.wand={New Wand init(DC self self.name)}
      self.chat={New ChatRoom init(BOT self.name self self.wand windows:self.windows)}
      {ForAll CHAT
       proc{$ I}
	  case I of ID#Name then
	     {self.chat addChater(ID Name)}
	  else skip end
       end}
      {self.chat addChater('system' 'System')}
      {self.chat setCol('system' c(255 0 0))}
      {self.chat removeChater('system')}
      {self.chat addMsg('system' "Welcome "#self.name true r(1 3 3 1))}
      ACTIONS = {New Actions init(DC M self self.toolbar self.name
				  self.wand ACTPORT ACTOUT)}
      self.iconbar=r(ToolBar F1 25)
      local
	 DefIconBar={New ToolBar init(parent:F1 height:25)}
      in
	 {DefIconBar addButtons([command(bitmap:{self.localize "net-new.gif"}
					 action:ACTPORT#menu(new(2))
					 tooltips:"New drawing with this editor")
				 command(bitmap:{self.localize "net-open.gif"}
					 action:ACTPORT#menu(new(5))
					 tooltips:"Load a file into a new drawing with this editor")
				 command(bitmap:{self.localize "net-save.gif"}
					 action:ACTPORT#menu(save)
					 tooltips:"Save a snapshot of the drawing")
				 space
				 command(bitmap:{self.localize "net-print.gif"}
					 action:ACTPORT#menu(printps)
					 tooltips:"Print the drawing")
				 separator
				])}
      end
      self.status={New StatusBar init(F8 "TransDraw by Donatien Grolaux (ned@info.ucl.ac.be)")} 
      SEL = {New SelectTool init(self.toolbar DC self ACTIONS
				 {self.localize "select_on.gif"}
				 {self.localize "select_off.gif"}
				 ACTPORT self.color self.border
				 self.selicon self.iconbar self.localize)}
      self.seltool=SEL
      FREEZE = {New FreezeTool init(self.toolbar DC self ACTIONS
				    {self.localize "freeze_on.gif"}
				    {self.localize "freeze_off.gif"}
				    {self.localize "steal_on.gif"}
				    {self.localize "steal_off.gif"}
				    self.iconbar self.localize)}
      self.freezetool=FREEZE
      self.zoomtool={New ZoomTool init(self.toolbar DC self ACTIONS
				    {self.localize "zoom_on.gif"}
				    {self.localize "zoom_off.gif"}
				    self.iconbar self.dialogbox self.localize)}
      RECT = {New StandardTool init(self.toolbar DC
				    self ACTIONS
				    {self.localize "rectangle_on.gif"}
				    {self.localize "rectangle_off.gif"}
				    rect 1 2
				    self.color
				    self.border
				    SEL self.iconbar self.localize)}
      CERC = {New StandardTool init(self.toolbar DC
				    self ACTIONS
				    {self.localize "circle_on.gif"}
				    {self.localize "circle_off.gif"}
				    oval 0 2
				    self.color
				    self.border
				    SEL self.iconbar self.localize)}
      LINE = {New LineTool init(self.toolbar DC
				self ACTIONS ACTPORT
				{self.localize "polyline_on.gif"}
				{self.localize "polyline_off.gif"}
				0 3
				self.color
				self.border
				SEL self.iconbar self.localize)}
      ARROW = {New ArrowTool init(self.toolbar DC
				  self ACTIONS ACTPORT self.dialogbox
				  {self.localize "arrow_on.gif"}
				  {self.localize "arrow_off.gif"}
				  0 4
				  self.color
				  self.border
				  SEL self.iconbar self.localize)}
      BROWSER = {New BrowseTool init(self.toolbar DC self ACTIONS ACTPORT
				     {self.localize "browse_on.gif"}
				     {self.localize "browse_off.gif"}
				     1 4
				     self.iconbar self.localize)}
      TEXT = {New TextTool init(self.toolbar DC self.window
				self ACTIONS
				{self.localize "text_on.gif"}
				{self.localize "text_off.gif"}
				1 3
				self.color
				self.border
				SEL
				self.texticon
				self.iconbar self.localize
				self.dialogbox self.client)}
      self.texttool=TEXT
      self.freezer={New ResetFreeze init(F2 FREEZE self)}
      case self.dbg==0 then skip else
	 self.debug={New Debug init(F2 self)}
      end
      case self.slownetwork==0 then skip else
	 self.slownet={New SlowNet init(F2 self)}
      end
      self.colorbar={New ColorBar init(F5 self.color self.dialogbox self)}
      self.actport=ACTPORT
      self.actions=ACTIONS
      {M setparams(SEL self.actions self.actport self.freezer DC)}
         % on construit le whiteboard en fonction du serveur
      {Tk.batch [pack(propagate F8 false)
		 pack(propagate F1 false)
%		 pack(propagate self.window false)
		 wm(deiconify self.window)]}
      {self rebuildwhiteboard(W)}
%      {Tk.send wm(colormapwindows self.window self.window)}
      thread % ecoute le serveur
	 self.listener={Thread.this}
	 {ForAll self.myport
	  proc{$ Msg}
	     {Send self.actport client(Msg)}
	  end}
      end
   end

   meth closeclient % le serveur demande au client de se fermer
      try
	 {self.actions stopactionserver} % on arrete ce thread
	 {self.freezer count(0)} % celui-ci aussi
	 {self.cleanuptemp} % on efface les fichiers temporaires
	 {Delay 1000} % on attend une seconde
	 {Tk.send wm(withdraw self.window)}
%	 {self.window tkClose} % on ferme la fenetre
      catch X then skip end
      % c'est fini !
      % pour etre sur :
      {ForAll @ender proc{$ Q} {Wait Q} end}
      self.quit=unit
      local ID in
	 {Thread.this ID}
	 try {Thread.terminate ID}
	 catch X then skip
	 end
      end
   end

   meth exit
      lock
	 Synch in
         % on arrete les differents thread possibles en cours
	 try
	    {Tk.send wm(withdraw self.window)}
	    {{self.toolbar getcurtool($)} deselect(nil)} % desactive l'outil en cours
	 catch X then skip end
	 try
	    {Thread.terminate self.listener}
	 catch X then skip end
	 {self.actions stopactionserver}
         % on envoie la demande de fermeture
	 case self.dbg==0 then skip else
	    {self.debug close}
	 end
	 {@server closeclient(self.client Synch)}
	 {Wait Synch}
	 {self closeclient}
      end
   end
   
   meth statetoobj(S ?O)
      case S.type
      of rect then
	 O={New StandardObj
	    initstate(self.dc S self.actions self)}
      [] oval then
	 O={New StandardObj
	    initstate(self.dc S self.actions self)}
      [] text then
	 O={New TextObj
	    initstate(self.dc S self.actions self)}
      [] line then
	 O={New LineObj
	    initstate(self.dc S self.actions self)}
      [] curve then
	 O={New ArrowObj
	    initstate(self.dc S self.actions self)}
      [] group then
	 O={New GroupObj
	    initstate(self.dc S self.actions self)}
      else
	 skip
      end
   end

   % Partie 2 : notification du serveur d'evenements exterieurs
   
   meth createobj(S) % on recoit la creation d'un nouvel obj
      local TEMP OLDWAIT in
	 {self statetoobj(S TEMP)}
	 {@objlist addobj(TEMP)}	 
	 {Dictionary.put self.objmap S.id TEMP}
	 {@virtualorder setmember(S.order S.id)} % on place dans le bon ordre
	 OLDWAIT={@waitingorder getlist($)}
	 waitingorder<-{New Objlistclass init()}
	 {ForAll {Reverse OLDWAIT}
	  proc{$ T}
	     O in
	     {Dictionary.get self.objmap T.id O}
	     case {O isvisible($)} then
		T1 in
		T1=tree(id:T.id order:T.order+1)
		{@waitingorder addobj(T1)}
	     else
		{@waitingorder addobj(T)}
	     end
	  end}
	 {self recalcorder}
	 {{self.toolbar getcurtool($)} modifyobj(TEMP)}
      end
   end

   meth deleteobj(S) % on recoit une notification d'effacement d'un obj
      O in
      O={Dictionary.condGet self.objmap S.id nil $}
      case O==nil then skip else
	 case {{self getfulltrans($)} member(O $)} then
	    % si cet objet est implique dans une transaction -> roll up
	    {self rollup}                   
	 else skip end
         % supression de l'objet de la liste des objets
	 {@virtualorder subtract(S.id)} % suppression du virtual order
	 {ForAll {@waitingorder getlist($)} % suppresion du waiting order
	  proc{$ T}
	     case T.id==S.id then
		{@waitingorder subtract(T)}
		{@ordersent subtract(T.id)}
	     else skip end
	  end}
         % suppresion des locks s'il le faut
	 {@lockset subtract(O)}
	 {@freezeset subtract(O)}
	 case {IsDet self.freezetool} then
	    {self.freezetool subtract(O)}
	    {self.freezer count({@freezeset length($)})}
	 else skip end
         % mise a jour des savestates
	 {ForAll {@savestate getlist($)}
	  proc{$ T}
	     case T.order>S.order then
		T1 in
		{AdjoinAt T order (T.order)-1 T1}
		{@savestate subtract(T)}
		{@savestate addobj(T1)}
	     else skip end
	  end}
	 {ForAll {@commitlist getlist($)}
	  proc{$ L}
	     {ForAll {L.savestate getlist($)}
	      proc{$ T}
		 case T.order>S.order then
		    T1 in
		    {AdjoinAt T order (T.order)-1 T1}
		    {L.savestate subtract(T)}
		    {L.savestate addobj(T1)}
		 else skip end
	      end}
	  end}		    
%	    TEMP={@waitingorder getlist($)}
%	    waitingorder<-{New Objlistclass init()}
%	    {ForAll {Reverse TEMP}
%	     proc{$ T}
%		O in
%		{Dictionary.get self.objmap T.id O}
%		case {O isvisible($)} then
%		   T1 in
%		   T1=tree(id:T.id order:T.order-1)
%		   {@waitingorder addobj(T1)}
%		else
%		   {@waitingorder addobj(T)}
%		end
%	     end}
	    % suicide final
	 {Dictionary.remove self.objmap S.id} % supression du mapping
	 {self recalcorder}
	 {O kill}
	 {@objlist subtract(O)}
      end
   end

   meth modifyobj(S) % on recoit une notif de modif
      local O in
	 O={Dictionary.get self.objmap S.id $}
	 % on recalcule les savestates pour correspondre au changement
	 % passe le message a l'outil actif
	 case S.order<{O getorder($)} then
	    {ForAll {@savestate getlist($)}
	     proc{$ T}
		case T.order>=S.order andthen T.order<{O getorder($)} then
		   T1 in
		   {AdjoinAt T order (T.order)+1 T1}
		   {@savestate subtract(T)}
		   {@savestate addobj(T1)}
		else skip end
	     end}
	    {ForAll {@commitlist getlist($)}
	     proc{$ L}
		{ForAll {L.savestate getlist($)}
		 proc{$ T}
		    case T.order>=S.order andthen T.order<{O getorder($)} then
		       T1 in
		       {AdjoinAt T order (T.order)+1 T1}
		       {L.savestate subtract(T)}
		       {L.savestate addobj(T1)}
		    else skip end
		 end}
	     end}
	 elsecase S.order>{O getorder($)} then
	    {ForAll {@savestate getlist($)}
	     proc{$ T}
		case T.order=<S.order andthen T.order>{O getorder($)} then
		   T1 in
		   {AdjoinAt T order (T.order)-1 T1}
		   {@savestate subtract(T)}
		   {@savestate addobj(T1)}
		else skip end
	     end}
	    {ForAll {@commitlist getlist($)}
	     proc{$ L}
		{ForAll {L.savestate getlist($)}
		 proc{$ T}
		    case T.order=<S.order andthen T.order>{O getorder($)} then
		       T1 in
		       {AdjoinAt T order (T.order)-1 T1}
		       {L.savestate subtract(T)}
		       {L.savestate addobj(T1)}
		    else skip end
		 end}
	     end}		  
	 else skip end
	 case {{self getfulltrans($)} member(O $)} then
            % fait partie de la liste des objets en transactions
	    % contrairement a deleteobj ou on sera sur que l'on aura
	    % d'office un refus de lock, ici ca ne l'est pas !
	    % la solution consiste a mettre a jour l'etat sauvegarde
	    local OLDLIST in
	       OLDLIST={@savestate getlist($)}
	       savestate<-{New Objlistclass init()}
	       {ForAll OLDLIST
		proc {$ T}
		   case T.id==S.id then
		      {@savestate addobj(S)}
		   else
		      {@savestate addobj(T)}
		   end
		end}
	    end
	    % de plus, si c'est une modification de l'ordre des objets,
	    % on l'applique a l'ordre virtuel.
	    case S.order=={O getorder($)} then
	       skip
	    else
	       {@virtualorder movemember({@virtualorder getindex(S.id $)}
					 S.order)}
	       % comme on veut qu'il revienne a l'ordre actuel, on fait comme
	       % si on l'avait amene ici depuis
	       {self updateorder(O)}
	       {self recalcorder}
	    end
	 else
	    case S.order=={O getorder($)} then
	       {O setstate(S)} % on place juste l'etat
	    else
	       {@virtualorder movemember({@virtualorder getindex(S.id $)}
					 S.order)}
	       {O setstate(S)}
	       {self recalcorder}
	    end
	 end
	 {{self.toolbar getcurtool($)} modifyobj(O)}
      end
   end

   meth commitorder(ID ORDER)
         % super, on peut maintenant reellement appliquer le changement d'ordre
         % on l'applique au virtual order
      {@virtualorder subtract(ID)}
      {@virtualorder setmember(ORDER ID)}
         % on le supprime du waitingorder
         % normalement, par le fifo, c'est le premier
         % on prend quand meme nos precautions au cas d'un rollup malvenu
         % mais je suis meme pas sur qu'il y a un bug possible
         % mais bon, on n'est jamais trop prudent comme on dit...
      case {@waitingorder length($)}>0 then
	 {@waitingorder removefirst}
	 % else {Browse 'dropped commit order'} end
      else skip end
      {@ordersent subtract(ID)}
	 % on remet a jour encore une fois
      {self recalcorder}
   end

   meth addfont(LI X)
      {self.texttool addfont(LI X)}
   end

   meth placeWand(C X1 Y1 X2 Y2)
      {self.wand placeWand(C X1 Y1 X2 Y2)}
   end

   meth deleteWand(C)
      {self.wand deleteWand(C)}
   end

   meth radar(C X Y)
      {self.wand radar(C X Y)}
   end
      
   meth broadWand(X1 Y1 X2 Y2)
      {@server placeWand(self.client X1 Y1 X2 Y2)}
   end

   meth broadDelWand
      {@server deleteWand(self.client)}
   end

   meth broadRadar(X Y)
      {@server radar(self.client X Y)}
   end
		    
   % Partie 3 : gestion des locks

   meth lockok(ID) % on recoit une confirmation de lock
%      {Show ok}
      local O L in
	 O={Dictionary.get self.objmap ID $}
            % on va verifier que l'on en a toujours besoin
%	 {Show 1#O}
	 if {@lockset member(O $)} then   % si on l'a deja
%	    {Show 2}
	    if {@selset member(O $)} orelse {@freezeset member(O $)} then
%	       {Show 3}
	       {O settag(black)}
	    else skip
%	       {Show 4}
	    end
	 else
%	    {Show 5}
	    L={self getfulltrans($)}
%	    {Show 6#{L getlist($)}}
	    if {L member(O $)} then % c'est un lock de selection
%	       {Show 7}
	       sellocktoget<-@sellocktoget-1
	    else skip
%	       {Show 8}
	    end
	    {L appendlist({@freezeset getlist($)})}
	    if {L member(O $)} then       % et si on en a besoin
%	       {Show 9}
	          % on prend le lock
	       {@lockset addobj(O)}
%	       {Show 10}
	       if {@selset member(O $)} orelse {@freezeset member(O $)} then
%		  {Show 11}
		  {O settag(black)}
		  {self.freezer count({@freezeset length($)})}
	       else skip
%		  {Show 12}
	       end
%	       {Show 13}
	       {self resolvetrans}
%	       {Show 14}
	    else
%	       {Show 15}
	       {@lockset subtract(O)}
%	       {Show 16}
	       {@server releaselock(self.client ID)} % on le relache direc
%	       {Show 17}
	    end
	 end
      end
   end
   
   meth lockko(ID) % on recoit un refus de lock
%      {Show ko}
      local O in
	 O={Dictionary.condGet self.objmap ID nil $}
	 temp<-false
	 {ForAll {@savestate getlist($)}
	  proc {$ N}
	     case N.id==ID then temp<-true
	     else skip end
	  end}
	 case @temp then
	       % c'est un objet dont on a la charge
	    {self rollup} % on annule
	 else skip end
	 case O==nil then skip else % on est prudent au cas ou l'objet a ete efface
	    {O settag(blink)}
	    {@freezeset subtract(O)} % on le supprime de la freeze list s'il y etait
	    {self.freezetool subtract(O)}
	    {self.freezer count({@freezeset length($)})}
	 end
      end
   end

   meth droplock(ID CLIENT)
      proc{SetTimer}
	 XNew XOld X B in
	 try {Thread.terminate @thid}
	 catch X then skip
	 end
	 local B in thid<-B end
	 thread
	    MyList in
	    {Thread.this X}
	    {Wait @thid}
	    {Delay 2000}
	    {Exchange self.mylock XOld XNew}
	    {Wait XOld}
	    local B in {Assign self.cursynch B} end
	    MyList={@stealset getlist($)}
	    {@stealset setlist(nil)}
	    XNew=unit
	    {ForAll MyList
	     proc {$ R}
		local O in
		   O={Dictionary.condGet self.objmap R.id nil}
		   case {@lockset member(O $)} then
		      {O settag(stealon)}
		   else skip end
		end
	     end}
	    {self.status start(B)}
	    {ForAll MyList
	     proc {$ R}
		case B==true then
		   {self droplockok(R.id R.client)}
		else
		   {self droplockko(R.id R.client)}
		end
	     end}
	    local XNew XOld in
	       {Exchange self.mylock XOld XNew}
	       {Wait XOld}
	       {Assign self.cursynch unit}
	       XNew=unit
	       case {@stealset getlist($)}==nil then skip else
		  local B in thid<-B end
		  thread @thid={Thread.this} end
		  {Wait @thid}
		  {SetTimer}
	       end
	    end
	 end
	 @thid=X
      end
      XNew XOld
   in
      {Exchange self.mylock XOld XNew}
      {Wait XOld}
      {@stealset addobj(r(id:ID client:CLIENT))}
      case {IsDet {Access self.cursynch}} then
	 {SetTimer}
      else skip end
      XNew=unit
   end
      
   meth droplockok(ID CLIENT)
      % ici, il va falloir etre tres prudent :
      % - on n'a pas de garantie d'etre encore le proprietaire du lock ID
      % - si cela tombe, l'utilisateur est en train de le modifier (pas bon du tout)
      local O in
	 O={Dictionary.condGet self.objmap ID nil}
	 case O\=nil then {O settag(stealoff)} else skip end
	 case O==nil then
	    skip % cetobjet n'existe meme plus
	 elsecase {@lockset member(O $)}==false then
	    % on n'a plus la possession de cet objet
	    {@server droplockko(self.client ID CLIENT)}
	 elsecase {self getfulltrans($)}==true then
	    % encore necessaire a une transaction...
	    % malgre la generosite de l'utilisateur, on va plutot garder le lock
	    {@server droplockko(self.client ID CLIENT)}
	 elsecase {@selset member(O $)}==true andthen
	    {self.toolbar getcurrent($)}\=self.selicon then
	       % objet selectionne pendant sa creation/modif par autre outil =>
	       % on refuse de le locker : ce choix est grandement discutable
	    {@server droplockko(self.client ID CLIENT)}
	 else
	    case {@selset member(O $)}==false then
	       skip
	    else
	       % dans ce cas, on annule la selection de l'utilisateur.
	       % violent, mais bon ...
%	       {self.seltool abort}
	       {{self.toolbar getcurtool($)} abort}
	       local TEMP in
		  TEMP={New Objlistclass init()}
		  {TEMP appendlist({@selset getlist($)})}
		  {TEMP subtract(O)}
		  {self releasesellock({TEMP getlist($)})}
		  {@selset subtract(O)}
	       end
	    end
	    {@freezeset subtract(O)}
	    {self.freezetool subtract(O)}
	    {self.freezer count({@freezeset length($)})}
	    {O settag(none)}
	    {@lockset subtract(O)}
	    {@server droplockok(self.client ID CLIENT)}
	 end
      end
   end

   meth droplockko(ID CLIENT)
      local O in
	 O={Dictionary.condGet self.objmap ID nil}
	 case O\=nil then {O settag(stealoff)} else skip end
      end
      {@server droplockko(self.client ID CLIENT)}
   end
      
	       	    	    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Methodes appeles par les differents outils du client
   %
   
   % Partie 1 : creation et modification

   meth addobject(O)
      % on cree un nouvel objet
%      {@objlist setmember({O getorder($)} O)} % on retient l'objet dans la liste
      {@objlist addobj(O)}
      {@selset addobj(O)}
      {Dictionary.put self.objmap {O getid($)} O}
      {@lockset addobj(O)}     % on le retient dans la liste des objs lockes
      {self addundo(O undodelete(O))}
      {@waitingorder addobj(tree(id:{O getid($)} order:{O getorder($)}))}
      {@server createobj(self.client {O getstate($)})} % on envoie la creation au serveur
      {@ordersent addobj({O getid($)})}
      {self recalcorder}
   end

   meth addcommitobj(O)
      % on cree un nouvel objet qui RENTRE dans le systeme des transactions commits
      case {@commitlist length($)}==0 then
	 {self addobject(O)} % on peut utiliser le principe habituel
	 {@selset subtract(O)} % pas de selection automatique
	 {self recalcorder}
      else
%	 {@objlist setmember({self maxorder({O getorder($)} $)} O)} % on retient l'obj dans la liste des objs
	 {@objlist addobj(O)} % sinon pas recalcule correctemment a l'affichage
	 {Dictionary.put self.objmap {O getid($)} O}
	 {@waitingobject addobj(O)}
	 {self addundo(O undodelete(O))}
	 {@waitingorder addobj(tree(id:{O getid($)} order:{O getorder($)}))}
	 {{@commitlist getlast($)}.commit addobj(createobj(self.client {O getstate($)}))}
	 {self recalcorder}
      end
   end
   
   meth update(O)
      case {self.consistant get($)} then % si on est dans un etat consistant
	 {@server modifyobj(self.client {O getstate($)})}
      else
	    % place le modifyobj dans la liste des commandes commit
	 {{@commitlist getlast($)}.commit addobj(modifyobj(self.client {O getstate($)}))}
      end
   end

   meth addstateobject(S)
      local O S1 in
	 {AdjoinAt S id {NewName} S1}
	 O={self statetoobj(S1 $)}
	 {O setorder(S1.order)} % restaure l'ordre
	 {self addcommitobj(O)}
      end
   end
   
   meth updateorder(O)
         % comme on a une modification de l'ordre, on la retient dans
         % waitingorder
      {@waitingorder addobj(tree(id:{O getid($)} order:{O getorder($)}))}
      case {self.consistant get($)} then % si on est dans un etat consistant
	 {@server modifyobjorder(self.client {O getstate($)})}
	 {@ordersent addobj({O getid($)})}
      else
	    % place le modifyobj dans la liste des commandes commit
	 {{@commitlist getlast($)}.commit addobj(modifyobjorder(self.client {O getstate($)}))}
      end
   end
   
   meth updatenow(O)
      {@server modifyobj(self.client {O getstate($)})}
   end

   meth setstate(O S)
      TEMP in
      TEMP={O getstate($)}
      {self addundo(O setstate(O TEMP))}
      {O setstate(S)}
      {self update(O)}
   end
   
   meth move(O X Y)
      {self addundo(O setstate(O {O getstate($)}))}
      local X1 Y1 X2 Y2 in
	 {O getsize(X1 Y1 X2 Y2)}
	 {O changesize(X+X1 Y+Y1 X+X2 Y+Y2)}
	 {self update(O)}
      end
   end

   meth sethyperlink(O H)
      {self startundolog}
      {self addundo(O setstate(O {O getstate($)}))}
      {O sethyperlink(H)}
      {self update(O)}
   end      
   
   meth transform(O W)
      {self addundo(O setstate(O {O getstate($)}))}
      {O transform(W)}
      {self update(O)}
   end

   meth resize(O X1 Y1 X2 Y2)
      {self addundo(O setstate(O {O getstate($)}))}
      {O changesize(X1 Y1 X2 Y2)}
      {self update(O)}
   end

   meth setoutlinecolor(O C)
      {self addundo(O setstate(O {O getstate($)}))}
      {O setoutlinecolor(C)}
      {self update(O)}
   end

   meth setfillcolor(O C)
      {self addundo(O setstate(O {O getstate($)}))}
      {O setfillcolor(C)}
      {self update(O)}
   end

   meth setwidth(O W)
      {self addundo(O setstate(O {O getstate($)}))}
      {O setwidth(W)}
      {self update(O)}
   end
   
   meth setorder(O N1)
      N in
      case N1==0 then N=1 else N=N1 end
      {self addundo(O setorder(O {O getorder($)}))}
      {self setlocalorder(O N)}
      {self updateorder(O)}
   end

   meth orderthat(L ?P)
      P={New Objlistclass init()}
      case {Length L}==0 then
	 skip
      else
%	 CL in
%	 CL={New Objlistclass init()}
%	 {CL appendlist(L)}
%	 {ForAll {CL getlist($)}
%	  proc{$ Dummy}
%	     temp<-{CL getfirst($)}
%	     % trouve l'objet d'ordre minimal
%	     {ForAll {CL getlist($)}
%	      proc{$ O}
%		 case {O getorder($)}>{@temp getorder($)} then
%		    temp<-O
%		 else skip end
%	      end}
%	     {P addobj(@temp)}
%	     {CL subtract(@temp)}
%	  end}
	 {P appendlist({List.sort L fun{$ A B} {A getorder($)}>{B getorder($)} end})}
      end
   end   
   
   meth delete(L)
      P in
      {self orderthat(L P)}
      {ForAll {Reverse {P getlist($)}}
       proc {$ O}
	  {self addundo(nil addstateobject({O getstate($)}))}
%	  {self addundo(nil addcommitobject(O))}
	  {O markinvisible}
	  {@selset subtract(O)}
	  case {self.consistant get($)} then
             % si on est dans un etat consistant
	     {@server delobj(self.client {O getstate($)})}
	     {@ordersent addobj({O getid($)})}
	  else
	     % place le delobj dans la liste des commandes commit
	     {{@commitlist getlast($)}.commit
	      addobj(delobj(self.client {O getstate($)}))}
	  end
   	     % l'envoie a la fin
%	  {self setlocalorder(O {@objlist length($)})}
	  {@waitingorder addobj(tree(id:{O getid($)} order:{@objlist length($)}))}
       end
      }
      {self recalcorder}
      {self.seltool resetsellist} % au cas ou !!!
   end

   meth undodelete(O)
%	 case {@waitingobject member(O $)} then
%	    {Show 'Deleting waitingobject'}
%	    {@objlist subtract(O)} % le supprime de la liste
%	    {Dictionary.remove self.objmap {O getid($)}} % enleve le mapping
%	    {@waitingobject subtract(O)} % supprime l'etat d'attente
%	    {@freezeset subtract(O)}
%	    {ForAll {@waitingorder getlist($)}
%	     proc{$ I}
%		case I.id=={O getid($)} then
%		   {@waitingorder subtract(I)}
%		else skip end
%	     end}
%	    {ForAll {@savestate getlist($)}
%	     proc{$ S}
%		case S.id=={O getid($)} then
%		   {@savestate subtract(S)}
%		else skip end
%	     end}
%	    sellocktoget<-@sellocktoget-1
%	    {O settag(none)}
%	    {O kill} % efface l'objet
%	    {self debug}
%	 else
%	    {Show 'Deleting commited object'}
      {self delete([O])}
%	 end
   end
   
   % Partie 2 : renseignements generaux

   meth getlist(?O)
      {@objlist getlist(O)}       % retourne la liste des objets
   end

   meth getlocklist(?L)
      L={@lockset getlist($)}
   end

   meth getsellist(?L)
      L={@selset getlist($)}
   end

   meth resetsel
      {self releasesellock({@selset getlist($)})}
      {self.seltool resetsellist}
   end
   
   meth setsel(L)
      {@selset appendlist(L)}
      {self.seltool setsel({@selset getlist($)})}
   end
   
   meth setcursor(C)
      {self.dc tk(configure cursor:C)}
   end

   meth setstatus(T)
      {self.status push(T)}
   end

   meth unsetstatus
      {self.status pop}
   end

   meth setmousestatus(Wind Text force:Force<=false
		      leave:Leave<=nil)
      Lock Inside in
      Lock={NewCell unit}
      Inside={NewCell false}
      {Wind tkBind(event:'<Enter>'
		   action:proc{$}
			     New Old in
			     {Exchange Lock Old New}
			     {Wait Old}
			     {self setstatus(Text)}
			     New=unit
			  end)}
      {Wind tkBind(event:'<Leave>'
		   action:proc{$}
			     New Old in
			     {Exchange Lock Old New}
			     {Wait Old}
			     {self unsetstatus}
			     case Leave==nil then skip else
				{Leave}
			     end
			     New=unit
			  end)}
      case Force then
	 New Old in
	 {Exchange Lock Old New}
	 {Wait Old}
	 {self unsetstatus}
	 {self setstatus(Text)}
	 New=unit
      else skip end
   end
   
   % Partie 3 : gestion des locks

   meth getgenlock(L C) % une seule procedure pour getsellock et regetsellock
      local NewT in % on cree une nouvelle transaction
	 NewT=tree(obj:{New Objlistclass init}
		   commit:{New Objlistclass init}
		   savestate:{New Objlistclass init})
	 {ForAll L % on va traiter les elements au cas par cas
	  proc {$ O}
	     S in
	     {@selset addobj(O)} % mise a jour des obj selectionnes
	        % on regarde si on doit aussi sauvegarder son etat
	     S={O getstate($)}
	     temp<-false
	     {ForAll {@savestate getlist($)}
	      proc {$ T}
		 case S.id==T.id then
		    temp<-true
		 else skip end
	      end}
	     case @temp then
		skip
	     else
		{@savestate addobj(S)}
	     end
	        % a t'on deja le lock ?
	     case {@lockset member(O $)} then
		   % oui
		{O settag(black)} % on affiche le tag que c'est locke
	     else
		   % fait-il partie de la freeze list ?
		case {@freezeset member(O $)} then
		      % oui
		   skip % rien a faire dans ce cas
		else
		      % l'a t'on deja demande,
		      % c'est a dire est-il deja implique dans une transaction ?
		   case {{self getfulltrans($)} member(O $)} then
		         % oui
		      {O settag(red)} % on affiche le tag que c'est en attente
		   else
		         % c'est qu'on doit demander le lock au serveur
		      case {@waitingobject member(O $)} then
			 skip
		      else
			 {@server C(self.client S.id)}
			 sellocktoget<-@sellocktoget+1
		      end
		   end
		end
	     end
	  end}
	 {NewT.obj appendlist({@selset getlist($)})} % on retient que cet objet participe a la transaction
	    % avant d'ajouter cette creation, on va mettre a jour (si
	    % necessaire la savestate de la transaction precedente)
	 case {@commitlist length($)}==0 then skip
	 else
	    {ForAll {{@commitlist getlast($)}.obj getlist($)}
	     proc{$ O}
		{{@commitlist getlast($)}.savestate addobj({O getstate($)})}
	     end}
	 end
	 {@commitlist addobj(NewT)}
      end
      case C==getlock then
	 {self resolvetrans} % verifie que la transaction n'est pas superflue
      else
	 {self.consistant count(@sellocktoget)}
      end
      case {self.consistant get($)} then
%	 {self.seltool updsel}
	 {{self.toolbar getcurtool($)} updsel}
      else skip end
   end
   
   meth getsellock(L) % demande d'un ou plusieurs lock
      {self getgenlock(L getlock)}
   end      

   meth regetlock(L) % copie presque exacte de la methode precedente
      L2 in % on ne selectionne pas deux fois le meme element
      L2={New Objlistclass init()}
      {ForAll L
       proc {$ O}
	  case {@selset member(O $)} then skip else
	     {L2 addobj(O)}
	  end
       end}
      {self getgenlock({L2 getlist($)} regetlock)}
   end

   meth frozen(O ?B) % O est-il gele ??
      {@freezeset member(O B)}
   end

   meth addfreeze(O)
      case {@freezeset member(O $)} then skip else
	 {@freezeset addobj(O)}
	 {self.freezetool addfreeze(O)}
	 {O settag(red)}
	 {self.freezer count({@freezeset length($)})}
      end
   end

   meth getobj(ID ?O)
      {Dictionary.get self.objmap ID O}
   end
   
   meth alllocked(?B)
      B={self.consistant get($)}
   end

   meth releasesellock(L)
      {ForAll L
       proc{$ O}
	  case {self.consistant get($)} then
	     case {@freezeset member(O $)} then % si cet objet doit rester locke
		skip
	     else
		% sinon on le relache
		{@lockset subtract(O)}
		{@server releaselock(self.client {O getid($)})}
		{O settag(none)}
	     end
	  else
	     case {@freezeset member(O $)} then
		skip
	     else
		{O settag(none)}		   
	     end % si pas consistant, on ne relache rien du tout
	  end
	  {@selset subtract(O)}
       end}
   end

   meth releaselock(O)
         % on a pas a se poser de question : on relache ce lock
      {@selset subtract(O)}
      {@lockset subtract(O)}
      {@server releaselock(self.client {O getid($)})}
   end

   meth getfreezelock(L)
      {ForAll L
       proc{$ O}
	  case {@freezeset member(O $)} then
	     skip % deja dans la freezelist
	  else
	     {@freezeset addobj(O)}
	     {self.freezer count({@freezeset length($)})}
	        % a t'on deja le lock ?
	     case {@lockset member(O $)} then
		   % oui
		{O settag(black)} % on affiche le tag que c'est locke
	     else
		{O settag(red)} % on affiche le tag que c'est en attente
	           % l'a t'on deja demande,
	           % c'est a dire est-il deja implique dans une transaction ?
		case {{self getfulltrans($)} member(O $)} orelse
		   {@selset member(O $)}
		then
	              % oui : rien a faire
		   skip
		else
		      % c'est qu'on doit demander le lock au serveur
		   case {@waitingobject member(O $)} then
		      skip
		   else
		      {@server getlock(self.client {O getid($)})}
		   end
		end
	     end
	  end
       end}
   end

   meth steallock(L)
      {ForAll L
       proc{$ O}
	  case {@freezeset member(O $)} then
	     skip % deja dans la freezelist
	  else
	     {@freezeset addobj(O)}
	     {self.freezer count({@freezeset length($)})}
	        % a t'on deja le lock ?
	     case {@lockset member(O $)} then
		   % oui
		{O settag(black)} % on affiche le tag que c'est locke
	     else
		{O settag(red)} % on affiche le tag que c'est en attente
	           % l'a t'on deja demande,
	           % c'est a dire est-il deja implique dans une transaction ?
		case {{self getfulltrans($)} member(O $)} orelse
		   {@selset member(O $)}
		then
	              % oui : rien a faire
		   skip
		else
		      % c'est qu'on doit demander le lock au serveur
		   case {@waitingobject member(O $)} then
		      skip
		   else
		      {@server steallock(self.client {O getid($)})}
		   end
		end
	     end
	  end
       end}
   end

   meth releasefreezelock(L)
      {ForAll L
       proc {$ O}
	  case {@freezeset member(O $)} then
	     {@freezeset subtract(O)}
	     {self.freezer count({@freezeset length($)})}
	        % a-t'on le lock ?
	     case {@lockset member(O $)} then
	           % doit-on garder le lock ?
		temp<-false
		case {{self getfulltrans($)} member(O $)} then
		   temp<-true
		   {O settag(none)} % efface le tag
		else skip end
		case {@selset member(O $)} then
		   temp<-true
		   {O settag(black)} % restaure le tag noir
		else skip end
		case @temp then
		      % on doit garder le lock => on ne fait rien
		   skip
		else
		   {O settag(none)}
		   {@lockset subtract(O)}
		   {@server releaselock(self.client {O getid($)})}
		end
	     else
	           % on n'a pas le lock
		case {@selset member(O $)} then
		   skip
		else
		   {O settag(none)}
		end
	     end
	  else skip end
       end}
   end

   meth debug()
      case self.dbg % les differents type de debug
      of 1 then
	 {self.debug print('Orders to commit : '#{@waitingorder length($)})}
      [] 2 then
	 {self.debug print('Commit'#'s to go : '#{@commitlist length($)})}
      [] 3 then
	 {ForAll {@undodata getlist($)}
	  proc{$ U}
	     {self.debug print({Label U.cmd $})}
	  end}
      [] 4 then
	 {self.debug print('nbr of object : '#{@objlist length($)})}
	 {self.debug print('nbr of frozen : '#{@freezeset length($)})}
      [] 5 then
	 {self.debug print('(objlist,waitingorder,waitingobject,virtualorder,ordersent) : ('#{@objlist length($)}#','#{@waitingorder length($)}#','#{@waitingobject length($)}#','#{@virtualorder length($)}#','#{@ordersent length($)}#')')}	 
	 {self.debug print('-------------')}
      [] 6 then
	 case {Access self.netdelay}==self.delay then
	    {Assign self.netdelay 0}
	 else
	    {Assign self.netdelay self.delay}
	 end
	 {self.debug print('Network speed : '#{Access self.netdelay})}
      [] 7 then
	 {self.debug print('objlist : '#{@objlist length($)})}
	 {self.debug print('lockset : '#{@lockset length($)})}
	 {self.debug print('selset : '#{@selset length($)})}
	 {self.debug print('freezeset : '#{@freezeset length($)})}
	 {self.debug print('savestate : '#{@savestate length($)})}
	 {self.debug print('commitlist : '#{@commitlist length($)})}
	 {self.debug print('virtualorder : '#{@virtualorder length($)})}
	 {self.debug print('waitingorder : '#{@waitingorder length($)})}
	 {self.debug print('undodata : '#{@undodata length($)})}
	 {self.debug print('ordersent : '#{@ordersent length($)})}
	 {self.debug print('')}
      [] 8 then
	 {Send self.actport revive}
      else skip end
   end

   meth switchslownetwork
      case {Access self.netdelay}==self.delay then
	 {Assign self.netdelay 0}
      else
	 {Assign self.netdelay self.delay}
      end
   end

   meth getserverinfo(?INFO)
      serverinfo<-INFO
      {@server getinfo(self.client)}
   end

   meth receiveserverinfo(INFO)
      case {IsFree @serverinfo} then @serverinfo=INFO else skip end
   end

   meth send(Msg)
      {@server Msg}
   end
   
%   partie 4 : gestion du chatroom et de l'aide
   meth sendmsg(Msg To Mood)
      {@server sendMsg(self.client Msg To Mood)}
   end

   meth addChatter(ID Name)
      {self.chat addChater(ID Name)}
      {self.chat addMsg(ID 'has just entered the whiteboard' false r(1 3 3 1))}
   end

   meth removechater(ID)
      {self.chat addMsg(ID 'has just left the whiteboard' false r(1 3 3 1))}
      {self.chat removeChater(ID)}
   end

   meth getchatters(?IDs)
      {self.chat getchatters(IDs)}
   end

   meth receivemsg(From Msg B Mood)
      {self.chat addMsg(From Msg B Mood)}
   end

   meth getserver(?Server)
      Server=@server
   end
   
%   partie 5 : creation et gestion d'un nouveau serveur dans un process separe.

%   meth startnewserver(?Info)
%      %
%      % Cette methode va lancer un nouveau process unix/windows
%      % Ce process va ensuite recuperer le code du serveur par un push
%      % ensuite il va retourner des informations concernant ce serveur
%      %
%      ModMan
%      functor ServerStub
	 
%      export
%	 StartServer

%      define	    
%	 proc{StartServer ModMan ServerDialog DialogBox ?SERVER ?Quit}
%	    SERVER Quit ServerGui
%	    TkTools OS Open Pickle Remote Connection
%	 in
%	    {ModMan enter(name:"System" System)}
%	    {System.show "hello"}
%	    {ModMan enter(name:"Tk" Tk)}
%	    {System.show "hello"}
%	    {ModMan enter(name:"TkTools" TkTools)}
%	    {System.show "hello"}
%	    {ModMan enter(name:"OS" OS)}
%	    {System.show "hello"}
%	    {ModMan enter(name:"Open" Open)}
%	    {System.show "hello"}
%	    {ModMan enter(name:"Pickle" Pickle)}
%	    {System.show "hello"}
%	    {ModMan enter(name:"Remote" Remote)}
%	    {System.show "hello"}
%	    {ModMan enter(name:"Connection" Connection)}
%	    {System.show "hello"}
%%	    ServerGui={New ServerDialog init(SERVER Tk TkTools OS System Open Pickle Remote Connection DialogBox)}
%%	    {ServerGui startgui(Quit)}
%	 end
%      end   

%      ST SERVER Quit
%   in
%      ModMan={New Remote.manager init(host:'localhost' fork:'automatic' detach:true)}
%      {ModMan apply(name:"Tk" ServerStub ST)} % x-oz://boot
%      {ST.startServer ModMan ServerDialog DialogBox ?SERVER ?Quit}
%      Info=r(ticket:"Test"
%	     clients:0
%	     objects:0
%	     uname:{OS.uName})
%   end

   meth tickettoserver(Ticket ?SERVER)
      lock
	 try
	    {Connection.take Ticket SERVER}
	 catch X then
	    _={self.dialogbox message(title:"Error with ticket"
				      text:"\nUnable to connect to ticket :\n"#Ticket#"\n\nSite is dead ?\n"
				      bitmap:error
				      buttons:ok)}
	 end
	 case {IsFree SERVER} then SERVER=nil else skip end
      end
   end
   
   meth startnewserver(?Info ?ServerGui)
      Quit SERVER
      in
      ender<-Quit|@ender
      ServerGui={New ServerDialog init(SERVER Tk TkTools OS System Open Pickle Remote Connection DialogBox)}
      {ServerGui startgui(Quit withdraw:true windows:self.windows)}
      Info=r(ticket:ServerGui.ticket
	     clients:0
	     objects:0
	     uname:{OS.uName})
   end

   meth startnewclientref(SERVER)
      lock
	 Quit Client in
	 ender<-Quit|@ender
	 Client={New ClientObject init(self.name SERVER 0 0 Quit 0)}
	 {Client subscribe(windows:self.windows)}
      end
   end

   meth startnewclient(Ticket)
      lock
	 SERVER in
	 {self tickettoserver(Ticket SERVER)}
	 case SERVER==nil then skip else
	    {self startnewclientref(SERVER)}
	 end
      end
   end

   meth resubscriberef(SERVER)
      lock
	 W CHAT 
	 Synch in
         % on arrete les differents thread possibles en cours
         % on envoie la demande de fermeture
	 case self.dbg==0 then skip else
	    {self.debug close}
	 end
	 {@server closeclient(self.client Synch)}
	 {Wait Synch}
%	 {Thread.suspend self.listener}
	 {ForAll {@objlist getlist($)} proc{$ O} {O kill} end}
	 {self.chat removeAllChater}
	 objlist<-{New Objlistclass init()}
	 lockset<-{New Objlistclass init()}
	 selset<-{New Objlistclass init()}
	 freezeset<-{New Objlistclass init()}
	 savestate<-{New Objlistclass init()}
	 commitlist<-{New Objlistclass init()}
	 virtualorder<-{New Objlistclass init()}
	 waitingorder<-{New Objlistclass init()}
	 waitingobject<-{New Objlistclass init()}
	 undodata<-{New Objlistclass init()}
	 ordersent<-{New Objlistclass init()}
	 sellocktoget<-0
	 undodata<-{New Objlistclass init}
	 stealset<-{New Objlistclass init()}
	 {self.freezer count(0)}
	 {{self.toolbar getcurtool($)} abort}
	 {SERVER subscribe(self.client self.name W CHAT)}
	 server<-SERVER
	 {ForAll CHAT
	  proc{$ I}
	     case I of ID#Name then
		{self.chat addChater(ID Name)}
	     else skip end
	  end}
	 % le L sert a faire le localize du serveur : on garde le serveur
	 % d'origine !
	 {self rebuildwhiteboard(W)}
	 {self.chat addMsg('system' "Welcome "#self.name true r(1 3 3 1))}
%	 {Thread.resume self.listener}
      end
   end
   
   meth resubscribe(Ticket)
      lock
	 SERVER in
	 {self tickettoserver(Ticket SERVER)}
	 case SERVER==nil then skip else
	    {self resubscriberef(SERVER)}
	 end
      end
   end
   
   meth displayer(MyFrame windows:Windows<=false browser:Browser<=false)
      Port P1 P2 P3 ScrX ScrY DC ACTPORT ACTOUT ACTIONS W
   in
      self.windows=Windows
      Port={NewPort self.myport}
      self.client=proc{$ Msg} {Send Port Msg} end
      {@server subscribe(self.client self.name P1 P3)}
      P2=NewLocalizeGifs
      W=P1
      case Windows then
	 ScrX  = {New Tk.scrollbar tkInit(parent:MyFrame
					  relief: sunken
					  bg:gray
					  orient: horizontal)}
	 ScrY  = {New Tk.scrollbar tkInit(parent:MyFrame
					  bg:gray
					  relief: sunken)}
      else
	 ScrX  = {New Tk.scrollbar tkInit(parent:MyFrame
					  relief: sunken
					  bg:gray
					  width:10
					  orient: horizontal)}
	 ScrY  = {New Tk.scrollbar tkInit(parent:MyFrame
					  bg:gray
					  width:10
					  relief: sunken)}
      end
      DC={New ScrollCanvas init(MyFrame ScrX ScrY)}
      self.dialogbox=DialogBox
      self.dc=DC
      ACTPORT={NewPort ACTOUT}
      {Tk.batch [grid(DC   row:0 column:0              sticky:nswe)
		 grid(ScrY row:0 column:1              sticky:ns)
		 grid(ScrX row:1 column:0              sticky:we)
		 grid(rowconfigure    MyFrame 0 weight:1)
		 grid(columnconfigure MyFrame 0 weight:1)]}
      ACTIONS = {New DummyActions init(self ACTPORT ACTOUT browser:Browser)}
      self.actport=ACTPORT
      self.actions=ACTIONS
      local
	 class DummyToolbar
	    meth init skip end
	    meth getcurtool(E)
	       E=proc{$ D}
		    skip
		 end
	    end
	 end
      in
	 self.toolbar={New DummyToolbar init}
      end
      self.freezer=proc{$ O} skip end
      self.cleanuptemp=proc{$} skip end
      self.window=proc{$ O} skip end
      ender<-nil
         % on construit le whiteboard en fonction du serveur
      {self rebuildwhiteboard(W)}
%      {Tk.send wm(colormapwindows self.window self.window)}
      thread % ecoute le serveur
	 self.listener={Thread.this}
	 {ForAll self.myport
	  proc{$ Msg}
	     {Send self.actport client(Msg)}
	  end}
      end
   end

   meth help(PURL)
      URL
      case {Length PURL}>7 andthen {StringToAtom {List.take PURL 7}}=='http://' then
	 URL=PURL else
	 URL={VirtualString.toString "http://www.info.ucl.ac.be/people/ned/transdrawhelp/"#PURL#".trd"}
      end
      Index={StringToAtom URL}
      Server Frame Ok
   in
      case {Dictionary.member self.helpserverdict Index} then
	 T={Dictionary.get self.helpserverdict Index}
      in
	 Server=T.server
	 Ok=true
      else
	 ServerGui W
	 proc{FEED}
	    try
	       {ForAll {List.sort W fun{$ A B} A.order<B.order end}
		proc{$ S}
		   {ServerGui.server createobj('dummy' S)}
		   {ServerGui.server releaselock('dummy' S.id)}
		end}
	    catch X then
	       _={self.dialogbox message(title:"Error while loading file"
					 text:"\nBad file format ?\n"
					 bitmap:error
					 buttons:ok)}
	    end
	 end
      in
	 try
	    {Pickle.load URL W}
	 catch X then
	    _={self.dialogbox message(title:"Error"
				      text:"\nUnable to read the file "#URL#"\n"
				      bitmap:error
				      buttons:ok)}
	 end
	 case {IsFree W} then Ok=false else Ok=true end
	 case Ok then
	    Quit SERVER in
	    ServerGui={New ServerDialog init(Server Tk TkTools OS System Open Pickle Remote Connection DialogBox)}
	    {ServerGui startgui(Quit withdraw:true windows:self.windows)}
	    {FEED}
	    {Dictionary.put self.helpserverdict Index r(server:Server clientframe:Frame)}
	 else skip end
      end
      case Ok then
	 Client
	 F0 F1 F2 IconBar T M L Quit
	 In Out
	 In={NewPort Out}
	 proc{Bind O}
	    Tag={O getfulltag($)}
	    Link={O gethyperlink($)}
	 in
	    case Link=="" then
	       {Tag tkBind(event:"<Enter>")}
	       {Tag tkBind(event:"<Leave>")}
	    else
	       {Tag tkBind(event:"<Enter>"
			   action:In#status("trek" "Hyperlink to "#Link))}
	       {Tag tkBind(event:"<Leave>"
			   action:In#status("left_ptr" ""))}
	       {Tag tkBind(event:"<1>"
			   action:In#browse(Link))}
	       {O markhyperlink(true)}
	    end
	 end
	 thread
	    {ForAll Out
	     proc{$ Msg}
		case Msg
		of status(C S) then
		   {Client setcursor(C)}
		   {L tk(configure text:S)}
		[] close then
		   helpwindow<-nil
		   {T tkClose}
		[] browse(X) then
		   {self help(X)}
		[] browseback then
		   case {Length @helpback}>1 then
		      To={Nth @helpback 2}
		   in
		      helpback<-{List.drop @helpback 2}
		      {self help(To)}
		   else skip end
		[] home then
		   {self help("main")}
		[] opendrawing then
		   W
		   proc{FEED}
		      {ForAll {List.sort W fun{$ A B} A.order<B.order end}
		       proc{$ S}
			  {ServerGui.server createobj('dummy' S)}
			  {ServerGui.server releaselock('dummy' S.id)}
		       end}
		   end
		   ServerGui Quit Server in
		   {Pickle.load URL W}
		   ServerGui={New ServerDialog init(Server Tk TkTools OS System Open Pickle Remote Connection DialogBox)}
		   {ServerGui startgui(Quit withdraw:true windows:self.windows)}
		   {FEED}
		   ender<-Quit|@ender
		   {ServerGui show}
		else skip end
	     end}
	 end
      in
	 case @helpwindow==nil then
	    T={New Tk.toplevel tkInit(title:"Help - "#PURL
				      delete:In#close
				      width:640
				      height:480)}
	    F0={New Tk.frame tkInit(parent:T borderwidth:1 relief:raised)}
	    F1={New Tk.frame tkInit(parent:T width:640 height:480)}
	    Frame={New Tk.frame tkInit(parent:F1)}
	    F2={New Tk.frame tkInit(parent:T bg:gray relief:sunken borderwidth:2)}
	    L={New Tk.label tkInit(parent:F2 text:"")}
	    IconBar={New ToolBar init(parent:F0 height:25)}
	    {IconBar addButtons([command(bitmap:{self.localize "mini-left.gif"}
					 action:In#browseback
					 feature:left
					 active:{Length @helpback}>0
					 tooltips:"Browse back")
				 separator
				 command(bitmap:{self.localize "net-open.gif"}
					 action:In#opendrawing
					 tooltips:"Open this drawing into a drawing server")
				 command(bitmap:{self.localize "mini-manual.gif"}
					 action:In#home
					 tooltips:"Main help page")
				])}
	    {Tk.batch [grid(F0 row:0 column:0 sticky:we)
		       grid(F1 row:1 column:0 sticky:nswe)
		       pack(Frame fill:both expand:yes)
		       grid(F2 row:2 column:0 sticky:nswe)
		       grid(rowconfigure T 1 weight:1)
		       grid(columnconfigure T 0 weight:1)
		       pack(L side:left anchor:nw)]}
	    Client={New ClientObject init(self.name Server 0 0 Quit 0)}
	    {Client displayer(Frame windows:self.windows browser:true)}
	    {ForAll {Client getlist($)}
	     proc{$ O}
		{Bind O}
	     end}
	 else
	    case {IsDet @helpwindow.actframe} then {Tk.send pack(forget @helpwindow.actframe)} else skip end
	    T=@helpwindow.parent
	    F1=@helpwindow.frame
	    L=@helpwindow.label
	    IconBar=@helpwindow.iconbar
	    {IconBar setState(button:left active:{Length @helpback}>0)}
	    Frame={New Tk.frame tkInit(parent:F1)}
	    Client={New ClientObject init(self.name Server 0 0 Quit 0)}
	    {Client displayer(Frame windows:self.windows browser:true)}
	    {ForAll {Client getlist($)}
	     proc{$ O}
		{Bind O}
	     end}
	    {Tk.send pack(Frame fill:both expand:yes)}
	 end
	 helpwindow<-r(parent:T frame:F1 label:L actframe:Frame iconbar:IconBar)
	 {Tk.send wm(iconname T "TransDraw Help")}
	 {Tk.send wm(title T "TransDraw Help - "#URL)}
	 helpback<-URL|@helpback
      else skip end
   end
      
   meth inviteto(Name Ticket Comment)
      T L1 B1 B2 B3 B4 Quit F1 Lock
   in
      
      T={New Tk.toplevel tkInit(title:"Invitation from "#Name#" to another drawing"
				withdraw:true)}
      F1={New Tk.frame tkInit(parent:T
			      relief:sunken
			      borderwidth:2)}
      L1={New Tk.label tkInit(parent:F1
			      justify:left
			      anchor:nw
			      bg:white
			      text:Comment)}
      Lock={NewCell unit}
      {L1 tkBind(event:'<Configure>'
		 action:proc{$ H W}
			   New Old in
			   {Exchange Lock Old New}
			   {Wait Old}
			   {L1 tk(configure wraplength:W-5.0)}
			   New=unit
			end
		 args: [float(h) float(w)]
		 append:true)}
      B1={New Tk.button tkInit(parent:T
			       text:"Open in a new editor"
			       action:proc{$}
					 New Old in
					 {Exchange Lock Old New}
					 {Wait Old}
					 case {IsFree Quit} then Quit=new else skip end
					 New=unit
				      end)}
      B2={New Tk.button tkInit(parent:T
			       text:"Open in this editor"
			       action:proc{$}
					 New Old in
					 {Exchange Lock Old New}
					 {Wait Old}
					 case {IsFree Quit} then Quit=this else skip end
					 New=unit
				      end)}
      B3={New Tk.button tkInit(parent:T
			       text:"Refuse invitation"
			       action:proc{$}
					 New Old in
					 {Exchange Lock Old New}
					 {Wait Old}
					 case {IsFree Quit} then Quit=refuse else skip end
					 New=unit
				      end)}
      B4={New Tk.button tkInit(parent:T
			       text:"Help"
			       action:self#help("invitation"))}
      {Tk.batch [pack(L1 expand:true fill:both)
		 pack(F1 side:top expand:true fill:both padx:5 pady:5)
		 pack(B1 B2 B3 side:left padx:5 pady:5)
%		 pack(B4 side:right padx:5 pady:5)
		 wm(deiconify T)]}
      {Wait Quit}
      {T tkClose}
      case Quit
      of new then % ouvre cela dans une nouvelle fenetre
	 {self startnewclient(Ticket)}
      [] this then
	 {self resubscribe(Ticket)}
      else skip end
   end

   meth browseto(B Addr)
      case {Length Addr}>13 andthen {List.take Addr 13}=="x-oz-ticket://" then
	 % connection a un serveur dont on connait le ticket
	 case B then
	    {self startnewclient(Addr)}
	 else
	    {self resubscribe(Addr)}
	 end
      elsecase {Length Addr}>4 andthen {List.take {Reverse Addr} 4}=="drt." then
	 % nouveau serveur chargeant le fichier demande
	 Info Gui MyList Error
      in
	 try
	    MyList={Pickle.load Addr}
	 catch X then Error=unit end
	 case {IsDet Error} then
	    _={self.dialogbox message(title:"Error while loading file"
				      text:"\nFile : "#Addr#" is unaccessible.\n"
				      bitmap:error
				      buttons:ok)}
	 else
	    {self startnewserver(Info Gui)}
	    try
	       {ForAll {List.sort MyList fun{$ A B} A.order<B.order end}
		proc{$ S}
		   {Gui.server createobj('dummy' S)}
		   {Gui.server releaselock('dummy' S.id)}
		end}
	    catch X then Error=unit end
	    case {IsDet Error} then
	       _={self.dialogbox message(title:"Error while loading file"
					 text:"\nBad file format ?\n"
					 bitmap:error
					 buttons:ok)}
	    else
	       {Tk.send wm(deiconify Gui.parent)}
	       case B then
		  {self startnewclient(Info.ticket)}
	       else
		  {self resubscribe(Info.ticket)}
	       end
	    end
	 end
      else
	 % connection a un serveur dont on connait un pickle du ticket
	 Error Ticket
      in
	 try
	    Ticket={Pickle.load Addr}
	 catch X then Error=unit end
	 case {IsDet Error} then
	    _={self.dialogbox message(title:"Error while loading file"
				      text:"\nFile : "#Addr#" is unaccessible.\n"
				      bitmap:error
				      buttons:ok)}
	 else
	    case B then
	       {self startnewclient(Ticket)}
	    else
	       {self resubscribe(Ticket)}
	    end
	 end
      end
   end
   
%%%%%%%%%%%%%%%%%% Zooms

   meth getscale(S)
      S=@scale
   end

   meth setscale(S)
      T Old
   in
      T={New Tk.toplevel tkInit(withdraw:true)}
      {Tk.send grab(T)}
      Old={self.dc tkReturn(cget('-cursor') $)}
      {self.dc tk(config cursor:"watch")}
      scale<-S
      {self.actions setscale(S)}
      {self.dc tk(configure scrollregion:{StringToAtom {VirtualString.toString
							"0.0 0.0 "#1000.0*S#" "#1000.0*S}}
		 )}
      {self.dc zoom(S)}
      case {IsDet self.wand} then
	 {self.wand redrawAll}
      else skip end
      %
      % regenere le whiteboard et les fonts
      %
      {ForAll {@objlist getlist($)}
       proc{$ O}
	  {O redraw}
       end}
      {self.dc tk(config cursor:Old)}
      {Tk.send grab(release T)}
      {T tkClose}
   end
   
end

