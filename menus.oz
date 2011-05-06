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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cette classe contient toutes les methodes appelees par le menu
%
%

LockCell={NewCell unit}
proc{Lock Proc}
   Old New in
   {Exchange LockCell Old New}
   {Wait Old}
   {Proc}
   New=unit
end

fun{LabelledFrame F Text}
   MyF MyL F1 F2 in
   F1={New Tk.frame tkInit(parent:F height:20)}
   F2={New Tk.frame tkInit(parent:F
			   relief:groove
			   borderwidth:2)}
   MyF={New Tk.frame tkInit(parent:F2)}
   MyL={New Tk.label tkInit(parent:F
			    relief:sunken
			    borderwidth:1
			    text:Text)}
   {Tk.send pack(F1 side:top)}
   {Tk.send pack(F2 side:top expand:yes fill:both padx:5)}
   {Tk.send pack(MyF side:top expand:yes fill:both padx:5 pady:5)}
   {Tk.send place(MyL x:5 y:5)}
   MyF
end
	

class MenuEvent

   feat server client window seltool actions freeze dc consistant actport tools selicon texticon dialogbox menu menuhelp localize

   attr temp tmp indisp curmenu curentry askedserverinfo name grid gridx gridy
      defsaveps defprintps printcmd

   prop locking
      
   meth init(T ?MENU CLIENT SERVER CONSISTANT TOOLBAR SELICON TEXTICON DIALOGBOX LOCALIZE)
      V={New Tk.variable tkInit(true)}
   in
      grid<-false
      gridx<-10.0 gridy<-10.0
      self.server=SERVER
      self.client=CLIENT
      thread
	 {self.client.actions setgrid(@gridx @gridy)}
      end
      self.consistant=CONSISTANT
      self.window=T
      self.dialogbox=DIALOGBOX
      self.localize=LOCALIZE
      name<-nil
      askedserverinfo<-nil
      printcmd<-"lp "
      MENU = {TkTools.menubar T T
	      [menubutton(text:"File" underline:0
			  menu:
			     [cascade(label:"New drawing..."
				      menu:[command(label:"With a new editor"
						    action:self.actport#menu(new(1))
						    key:ctrl(n))
					    command(label:"With this editor"
						    action:self.actport#menu(new(2))
						    key:alt(n))
					    command(label:"Without any editors"
						    action:self.actport#menu(new(3))
						    key:ctrl(alt(n)))]
				      feature:new)
			      cascade(label:"Open another drawing..."
				      menu:[command(label:"With a new editor..."
						    action:self.actport#menu(open(1)))
					    command(label:"With this editor..."
						    action:self.actport#menu(open(2)))
					    separator
					    command(label:"Open a new editor with the current drawing"
						    action:self.actport#menu(open(3)))]
				      feature:openserver)
			      cascade(label:"Open file into a new drawing..."
				      menu:[command(label:"With a new editor..."
						    action:self.actport#menu(new(4)))
					    command(label:"With this editor..."
						    action:self.actport#menu(new(5)))
					    command(label:"Without any editors..."
						    action:self.actport#menu(new(6)))]
				      feature:openfile)
			      separator
			      command(label:"Save snapshot"
				      action:self.actport#menu(save)
				      key:ctrl(s)
				      feature:save)
			      command(label:"Save snapshot as..."
				      action:self.actport#menu(saveas)
				      feature:saveas)
			      separator
			      command(label:"Import an Image..."
				      action:self#dummy
				      feature:importimage)
			      command(label:"Export as PostScript..."
				      action:self.actport#menu(savetops)
				      feature:exportps)
			      separator
			      command(label:"Print..."
				      action:self.actport#menu(printps)
				      feature:print)
			      command(label:"Configure Printer..."
				      action:self.actport#menu(configureps)
				      feature:configureprint)
			      separator
			      command(label: "Exit"
				      action:self.actport#menu(exit)
				      key: alt(x)
				      feature :quit)]
			  feature:file)
	       menubutton(text:"Edit" underline:0
			  menu:
			     [command(label:"Undo"
				      action:self.actport#menu(undo)
				      feature:undo)
			      separator
			      command(label:"Cut"
				      action:self.actport#menu(cut)
				      feature:cut
				      key:ctrl(x))
			      command(label:"Copy"
				      action:self.actport#menu(copy)
				      feature:copy
				      key:ctrl(c))
			      command(label:"Paste"
				      action:self.actport#menu(paste)
				      feature:paste
				      key:ctrl(v))
			      separator
			      command(label:"Delete"
				      action:self.actport#menu(delete)
				      feature:delete
				      key:"Del"
				      event:"<Delete>")
			      command(label:"Duplicate"
				      action:self.actport#menu(duplicate)
				      feature:duplicate
				      key:ctrl(d))
			      command(label:"Select All"
				      action:self.actport#menu(selectall)
				      feature:selectall)]
			  feature:edit)
	       menubutton(text:"Arrange" underline:0
			  menu:
			     [cascade(label:"Align"
				      menu:[command(label:"To Top"
						    action:self.actport#menu(align(top)))
					    command(label:"To Vertical Middle"
						    action:self.actport#menu(align(vmid)))
					    command(label:"To Bottom"
						    action:self.actport#menu(align(bot)))
					    separator
					    command(label:"To Left"
						    action:self.actport#menu(align(left)))
					    command(label:"To Horizontal Middle"
						    action:self.actport#menu(align(hmid)))
					    command(label:"To Right"
						    action:self.actport#menu(align(right)))]
				      feature:align)
			      separator
			      command(label:"Rotate +90"
				      action:self.actport#menu(transform(rrotate))
				      feature:rightrotation)
			      command(label:"Rotate -90"
				      action:self.actport#menu(transform(lrotate))
				      feature:leftrotation)
			      command(label:"Rotate 180"
				      action:self.actport#menu(transform(hrotate))
				      feature:halfrotation)
			      separator
			      command(label:"Flip Horizontal"
				      action:self.actport#menu(transform(hflip))
				      feature:fliphoriz)
			      command(label:"Flip Vertical"
				      action:self.actport#menu(transform(vflip))
				      feature:flipvert)
			      separator
			      command(label:"Group"
				      action:self.actport#menu(group)
				      feature:group
				      key:ctrl(g))
			      command(label:"Ungroup"
				      action:self.actport#menu(ungroup)
				      feature:ungroup
				      key:ctrl(u))
			      separator
			      command(label:"Send To Back"
				      action:self.actport#menu(sendback)
				      feature:sendback
				      key:ctrl(b))
			      command(label:"Back One"
				      action:self.actport#menu(backone)
				      feature:backone
				      key:ctrl(k))
			      command(label:"Forward One"
				      action:self.actport#menu(forwardone)
				      feature:forwardone
				      key:ctrl(o))
			      command(label:"Bring To Front"
				      action:self.actport#menu(bringfront)
				      feature:bringfront
				      key:ctrl(f))]			  
			  feature:arrange)
	       menubutton(text:'Tools' underline:0
			  menu:
			     [cascade(label:"Grid"
				      menu:[checkbutton(
					       label:"Grid"
					       action:self.actport#menu(switchgrid)
					       offvalue:false
					       onvalue:true
					       variable:V
					       key:ctrl(r))
					    command(
					       label:"Configure grid..."
					       action:self.actport#menu(confgrid))]
				      feature:grid)
			      separator
			      command(label:"Invite by mail..."
				      action:self.actport#menu(invitebymail)
				      feature:invitemail)
			      command(label:"Invite from another drawing.."
				      action:self.actport#menu(invitefrom)
				      feature:inviteanother)
			      command(label:"Invite to another drawing..."
				      action:self.actport#menu(inviteto)
				      feature:invitetoanother)
			      separator
			      command(label:"Bring the server of the drawing here..."
				      action:self#dummy
				      feature:serverhere)
			      command(label:"Drawing informations..."
				      action:self.actport#menu(serverinfo)
				      feature:serverinfo)]
			  feature:tools)]
	      [menubutton(text:"Help" underline:0
			  menu:
			     [command(label:"Help..."
				      action:self.actport#client(help("main"))
				      feature:help)
			      command(label:"About TransDraw..."
				      action:self#about
				      feature:about)]
			  feature:help)]}
      {ForAll [serverhere]
       proc{$ N} {MENU.tools.N tk(entryconfigure state:disabled)} end}
      {ForAll [importimage]
       proc{$ N} {MENU.file.N tk(entryconfigure state:disabled)} end}
      {MENU.edit.menu tk(configure postcommand:{New Tk.action tkInit(action:self#calcclip
								     parent:MENU.edit.menu)})}
      thread
	 self.tools=TOOLBAR
	 self.selicon=SELICON
	 self.texticon=TEXTICON
      end
      {ForAll [file tools arrange edit help]
       proc{$ M}
	  {MENU.M.menu tk(configure tearoff:false)}
       end}
      {ForAll [new openserver openfile]
       proc{$ M}
	  {MENU.file.M.menu tk(configure tearoff:false)}
       end}
      {MENU.tools.grid.menu tk(configure tearoff:false)}
      {MENU.arrange.align.menu tk(configure tearoff:false)}
      {ForAll [MENU.file#"File operations menu"
	       MENU.edit#"Edit operations menu"
	       MENU.arrange#"Arrange operations menu"
	       MENU.tools#"Special tools menu"
	       MENU.help#"Help menu"]
       proc{$ E}
	  case E of A#B then
	     {self.client setmousestatus(A B)}
	  end
       end}
      self.menu=MENU
      curmenu<-0
      self.menuhelp=[["File menu" "Open a new drawing" "Connect to another drawing" "Open a file in a new drawing" "" "Save a snapshot of the drawing" "Save As a snapshot of the drawing" "" "Import a gif or a jpeg into the drawing" "Export the drawing as a Postscript file" "" "Print the drawing as Postscript" "Configure the Postscript printer" "" "Exit the editor"]
		     ["Edit menu" "Undo last command" "" "Cut the selection" "Copy the selection" "Paste the clipboard" "" "Delete the selection" "Duplicate the selection" "Select all objects in the drawing"]
		     ["Arrange menu" "Align a group of selected objects" "" "Rotate the selection +90 degrees" "Rotate the selection -90 degrees" "Rotate the selection 180 degrees" "" "Flip the selection horizontaly" "Flip the selection Verticaly" "" "Group the selection" "Ungroup the selection" "" "Send the selection to back" "Send the selection back one" "Send the selection one forward" "Bring the selection to front"]
		     ["Tools menu" "Grid settings" "" "Invite someone by sending him a mail" "Invite someone from another opened drawing" "Invite people from this drawing to another drawing" "" "Bring the server of the drawing here" "Show informations about the drawing"]
		     ["Help menu" "Help about TransDraw" "About TransDraw"]
		     ["New drawing menu" "Open a new drawing and a new editor" "Open a new drawing with the current editor" "Open a new drawing without any editors" ]
		     ["Open drawing menu" "Open a new editor connected with another drawing" "Connect the current editor with another drawing" "" "Open another editor with the current drawing"]
		     ["Open file menu" "Open a file into a new drawing with a new editor" "Open a file into a new drawing using the current editor" "Open a file into a new drawing without any editors"]
		     ["Grid settings" "Turn on or off grid" "Change grid size"]
		     ["Align menu" "Align selected objects to top of selection" "Align selected objects to the vertical middle of the selection" "Align selected objects to bottom of selection" "" "Align selected objects to left of selection" "Align selected objects to horizontal middle of selection" "Align selected objects to right of selection"]
		    ]
      {List.forAllInd [file edit arrange tools help]
       proc{$ I M}
	  {MENU.M.menu tkBind(event:"<Enter>"
			      action:self#menuEnter(I MENU.M.menu))}
	  {MENU.M.menu tkBind(event:"<Leave>"
			      action:self#menuLeave)}
	  {MENU.M.menu tkBind(event:"<Motion>"
			      action:self#menuMotion)}
       end}
      {List.forAllInd [new openserver openfile]
       proc{$ I M}
	  {MENU.file.M.menu tkBind(event:"<Enter>"
				   action:self#menuEnter(I+5 MENU.file.M.menu))}
	  {MENU.file.M.menu tkBind(event:"<Leave>"
				   action:self#menuLeave)}
	  {MENU.file.M.menu tkBind(event:"<Motion>"
				   action:self#menuMotion)}
       end}
      {MENU.tools.grid.menu tkBind(event:"<Enter>"
				   action:self#menuEnter(9 MENU.tools.grid.menu))}
      {MENU.tools.grid.menu tkBind(event:"<Leave>"
				   action:self#menuLeave)}
      {MENU.tools.grid.menu tkBind(event:"<Motion>"
				   action:self#menuMotion)}
      {MENU.arrange.align.menu tkBind(event:"<Enter>"
				      action:self#menuEnter(10 MENU.arrange.align.menu))}
      {MENU.arrange.align.menu tkBind(event:"<Leave>"
				      action:self#menuLeave)}
      {MENU.arrange.align.menu tkBind(event:"<Motion>"
				      action:self#menuMotion)}
      defsaveps<-r(zoom:1.0
		   rotate:false
		   pagewidth:"210m"
		   pageheight:"297m"
		   fit:true
		   pagex:"20m"
		   pagey:"20m"
		   width:1000
		   height:1000
		   x:0
		   y:0
		   colormode:color)
      defprintps<-r(zoom:1.0
		    rotate:false
		    pagewidth:"210m"
		    pageheight:"297m"
		    fit:false
		    pagex:"20m"
		    pagey:"20m"
		    width:1000
		    height:1000
		    x:0
		    y:0
		    colormode:grey
		    cmd:"lp"
		    colormap:nil
		    fontmap:nil)
      thread
	 {self switchgrid}
      end
   end

   meth showEntry
      {self.client unsetstatus}
      {self.client setstatus({Nth {Nth self.menuhelp @curmenu.nu} @curentry})}
   end

   meth menuEnter(Nu This)
      lock
	 curmenu<-r(nu:Nu menu:This)
	 curentry<-1
	 {self.client setstatus("")}
	 {self showEntry}
      end
   end

   meth menuLeave
      lock
	 {self.client unsetstatus}
      end
   end

   meth menuMotion
      lock
	 Opt X in
	 try
	    X={@curmenu.menu tkReturnInt(index(active) $)}
	    {Wait X}
	    case {IsInt X} then Opt=X+2 else Opt=1 end
	    case Opt==@curentry then skip else
	       curentry<-Opt
	       {self showEntry}
	    end
	 catch X then skip end
      end
   end
      
   meth setparams(SELTOOL ACTIONS ACTPORT FREEZER DC)
      self.seltool=SELTOOL
      self.actions=ACTIONS
      self.actport=ACTPORT
      self.freeze=FREEZER
      self.dc=DC
   end
   
   meth dummy
      skip
   end

   meth calcclip
      State in
      case {Tk.returnInt 'catch'(v('{selection get -selection CLIPBOARD -type OZCLIP}'))}==0 then
	 {self.menu.edit.paste tk(entryconfigure state:normal label:"Paste object(s)")}
      else
	 {self.menu.edit.paste tk(entryconfigure state:disabled)}
      end
      case {self.tools getcurrent($)}==self.selicon then
	 case {self.client getsellist($)}\=nil then
	    State=normal
	 else skip end
      elsecase {self.tools getcurrent($)}==self.texticon then
	 State=normal
      else skip end
      case {IsFree State} then State=disabled else skip end
      {self.menu.edit.cut tk(entryconfigure state:State)}
      {self.menu.edit.copy tk(entryconfigure state:State)}
   end
      
   meth exit
      {self.client exit}
   end

   meth delete
      {self.tools settool(self.selicon)}
      {self.client startundolog}
      {self.client delete({self.seltool getsellist($)})}
   end

   meth cut
      case {self.tools getcurrent($)}==self.selicon then
	 {self.client startundolog}
	 {self copy}
	 {self.client delete({self.seltool getsellist($)})}	 
      else skip end
   end

   meth copy
      case {self.tools getcurrent($)}==self.selicon then
	 MyList ToClip in
	 {self.client startundolog}
	 {Tk.send clipboard(clear)}
	 MyList={List.map {self.client getsellist($)}
		 fun{$ O} {O getstate($)} end}
	 local Tmp F in
	    Tmp={OS.tmpnam}
	    {Pickle.save MyList Tmp}
	    F={New Open.file
	       init(name:Tmp flags:[read])}
	    {F read(list:ToClip size:all)}
	    {F close}
	    {OS.unlink Tmp}
	 end
	 local
	    fun{RemoveNul X} % le clipboard s'arrete en cas de caractere=0
	       case X of Y|Ys then
		  case Y==0 then
		     1|1|{RemoveNul Ys}
		  elsecase Y==1 then
		     1|2|{RemoveNul Ys}
		  else
		     Y|{RemoveNul Ys}
		  end
	       else
		  X
	       end
	    end
	 in
	    {Tk.send clipboard(append v('-type OZCLIP') {RemoveNul ToClip})}
	 end
      else skip end
   end
   
   meth paste
      case {self.tools getcurrent($)}==self.selicon andthen
	 {Tk.returnInt 'catch'(v('{selection get -selection CLIPBOARD -type OZCLIP}'))}==0 then
	 L in
	 {self.client startundolog}
	 local Tmp F FromClip
	    fun{AddNul X}
	       case X of Y|Ys then
		  case Y==1 then
		     case Ys of Z|Zs then
			case Z==1 then
			   0|{AddNul Zs}
			else
			   1|{AddNul Zs}
			end
		     end
		  else
		     Y|{AddNul Ys}
		  end
	       else
		  X
	       end
	    end
	 in
	    Tmp={OS.tmpnam}
	    FromClip={AddNul {Tk.return selection(get selection:'CLIPBOARD' type:'OZCLIP')}}
	    F={New Open.file
	       init(name:Tmp flags:[create write])}
	    {F write(vs:FromClip len:{Length FromClip})}
	    {F close}
	    L={Pickle.load Tmp}
	    {OS.unlink Tmp}
	 end
	 try
	    {ForAll {List.sort L fun{$ A B} A.order<B.order end}
	     proc{$ S}
		S1 O in
		S1={AdjoinAt S id {NewName}}
		O={self.client statetoobj(S1 $)}
		{self.client addobject(O)}
		{self.client releaselock(O)}
	     end}
	 catch X then
	    _={self.dialogbox message(title:"Error while processing clipboard"
				      text:"\nBad clipboard data ?\n"
				      bitmap:error
				      buttons:ok)}
	 end	 
      else skip end
   end
   
   meth undo
      {self.client undo}
   end

   meth orderthat(L ?P)
      P={New Objlistclass init()}
      case {L length($)}==0 then
	 skip
      else
	 {P appendlist({List.sort {L getlist($)}
			fun{$ A B}
			   {A getorder($)}>{B getorder($)}
			end})}
      end
   end
   
   meth sendback
      {self.tools settool(self.selicon)}
      {self.client startundolog}
         % on va envoyer les objets selectiones au fond de l'ecran, en respectant
         % l'ordre dans lequel ils etaient affiches
      local L P in
	 L={New Objlistclass init}
	 {L appendlist({self.seltool getsellist($)})} % recoit la liste des objs selectionnes
	 case {L length($)}==0 then
	    skip % rien a faire
	 else
	       % on va determiner ou les envoyer
	    P={self orderthat(L $)}
	       % maintenant P contient la liste des objets a amener devant, de maniere
	       % ordonnee -> on place les objets
	    {List.forAllInd {P getlist($)}
	     proc{$ I O}
		{self.client setorder(O I)}
	     end}
	 end
      end
   end
   
   meth bringfront
      {self.tools settool(self.selicon)}
      {self.client startundolog}
         % on va envoyer les objets selectiones au fond de l'ecran, en respectant
         % l'ordre dans lequel ils etaient affiches
      local L P N in
	 L={New Objlistclass init}
	 {L appendlist({self.seltool getsellist($)})} % recoit la liste des objs selectionnes
	 case {L length($)}==0 then
	    skip % rien a faire
	 else
	       % on va determiner ou les envoyer
	    P={self orderthat(L $)}
  	       % maintenant P contient la liste des objets a amener devant, de maniere
	       % ordonnee -> on place les objets
	    N={self.client getlast($)}
	    {ForAll {P getlist($)}
	     proc{$ O}
		{self.client setorder(O N)}
	     end}
	 end
      end
   end

   meth backone
      {self.tools settool(self.selicon)}
      {self.client startundolog}
      local L M P in
	 L={New Objlistclass init}
	 M={New Objlistclass init}
	 {L appendlist({self.seltool getsellist($)})}
	 {M appendlist({self.client getlist($)})}
	 case {L length($)}==0 then
	    skip
	 else
	    P={self orderthat(L $)}
	    temp<-{{P getlast($)} getorder($)} %prend le premier de la liste
	    case @temp==1 then skip else
	       temp<-@temp-1
	    end
	       % on va inserer a partir de @temp
	    {ForAll {P getlist($)}
	     proc{$ O}
		{self.client setorder(O @temp)}
		temp<-@temp+1
	     end}
	 end
      end	    
   end

   meth forwardone
      {self.tools settool(self.selicon)}
      {self.client startundolog}
      local L M P N1 N2 in
	 L={New Objlistclass init}
	 M={New Objlistclass init}
	 {L appendlist({self.seltool getsellist($)})}
	 {M appendlist({self.client getlist($)})}
	 case {L length($)}==0 then
	    skip
	 else
	    P={self orderthat(L $)}
	    N1={{P getfirst($)} getorder($)} %prend le dernier de la liste
	    case N1>={self.client getlast($)} then
	       N2=N1
	    else
	       N2=N1+1
	    end
	       % on va inserer a partir de @temp
	    {ForAll {P getlist($)}
	     proc{$ O}
		{self.client setorder(O N2)}
	     end}
	 end
      end
   end

   meth group
      {self.client startundolog}
      tmp<-false
      local L P S TEMP in
	 P={New Objlistclass init}
	 S={New Objlistclass init}
	 {P appendlist({Reverse {self.seltool getsellist($)}})}
	 case {P length($)}==0 then skip else
	    {self orderthat(P L)}
	    {ForAll {Reverse {L getlist($)}}
	     proc {$ O}
		{S addobj({O getstate($)})}
		case {self.client frozen(O $)} then tmp<-true
		else skip end
	     end}
	    {self.client delete({self.seltool getsellist($)})}
	    TEMP={New GroupObj init(self.dc S
				    self.actions self.client)}
	    {self.client addcommitobj(TEMP)}
	    {self.client setsel([TEMP])} % selectionne par defaut
	    case @tmp then
	       {self.client addfreeze(TEMP)}
	    else skip end
	 end
      end
      {self.client resolvetrans}
      {self.client recalcorder}
   end

   meth ungroup
      {self.client startundolog}
      local L P S SL FL TOD in
	 P={New Objlistclass init}
	 {P appendlist({Reverse {self.seltool getsellist($)}})}
	 S={New Objlistclass init}
	 SL={New Objlistclass init}
	 FL={New Objlistclass init}
	 TOD={New Objlistclass init}
	 {ForAll {P getlist($)}
	  proc{$ O}
	     case {O getstate($)}.type==group then % on ungroup ce groupe
		{TOD addobj(O)}
		case {self.client frozen(O $)} then
		   tmp<-true else tmp<-false end
		{SL addobj(O)}
		{ForAll {O getlist($)}
		 proc {$ OO}
		    {S addobj({OO getstate($)})}
		    case @tmp then
		       {FL addobj({OO getstate($)})}
		    else skip end
		 end}
	     else skip end
	  end}
	 case {SL length($)}==0 then skip else
%	       {self.seltool setsel({SL getlist($)})}
	    {self.client delete({TOD getlist($)})}
	    L={New Objlistclass init}
	    {ForAll {S getlist($)}
	     proc{$ SS}
		local TEMP in
		   {self.client statetoobj(SS TEMP)}
		   {self.client addcommitobj(TEMP)}
		   case {FL member(SS $)} then
		      {self.client addfreeze({self.client getobj(SS.id $)})}
		   else skip end
		   {L addobj(TEMP)}
		end
	     end}
	    {self.client setsel({L getlist($)})}
	 end
      end
      {self.client resolvetrans}
      {self.client recalcorder}
   end

   meth duplicate
      {self.tools settool(self.selicon)}
      {self.client startundolog}
      local P L N in
	 L={New Objlistclass init}
	 N={New Objlistclass init}
	 {L appendlist({self.seltool getsellist($)})}
	 P={self orderthat(L $)}
	 {ForAll {P getlist($)}
	  proc{$ O}
	     local S S1 TEMP in
		S={O getstate($)}
		S1={AdjoinAt S id {NewName $}}
		TEMP={self.client statetoobj(S1 $)}
		{self.client addcommitobj(TEMP)}
		{self.client move(TEMP 20.0 20.0)}
		{N addobj(TEMP)}
	     end
	  end}
	 {self.client resetsel}
	 {self.client setsel({N getlist($)})}
      end
   end

   meth selectall
      % Tout d'abord, on selectionne l'outil de selection (sic)
      {self.tools settool(self.selicon)}
      local L S T in
	 {self.client getlist(L)}
	 {self.client getsellist(S)}
	 T={New Objlistclass init}
	 {T appendlist(L)}
	 {ForAll S
	  proc{$ O}
	     {T subtract(O)}
	  end}
	 {self.client getsellock({T getlist($)})}
	 {self.client setsel(nil)} % bizarre, mais fonctionne
      end
   end

   meth align(A)
      OX2={NewCell 0.0}
      OY2={NewCell 0.0}
      OX1={NewCell 1000.0}
      OY1={NewCell 1000.0}
      X1 Y1 X2 Y2
   in
      {self.tools settool(self.selicon)}
      {self.client startundolog}
      {ForAll {self.seltool getsellist($)}
       proc{$ O}
	  X1 Y1 X2 Y2
       in
	  {O getsize(X1 Y1 X2 Y2)}
	  case X1<{Access OX1} then {Assign OX1 X1} else skip end
	  case Y1<{Access OY1} then {Assign OY1 Y1} else skip end
	  case X2>{Access OX2} then {Assign OX2 X2} else skip end
	  case Y2>{Access OY2} then {Assign OY2 Y2} else skip end
       end}
      X1={Access OX1} X2={Access OX2}
      Y1={Access OY1} Y2={Access OY2}
      % maintenant on connait la taille generale... on va pouvoir aligner
      {ForAll {self.seltool getsellist($)}
       proc{$ O}
	  OX1 OX2 OY1 OY2 DX DY
       in
	  {O getsize(OX1 OY1 OX2 OY2)}
	  case A
	  of top then DX=0.0 DY=Y1-OY1
	  [] vmid then DX=0.0 DY=(Y1+Y2)/2.0-(OY1+OY2)/2.0
	  [] bot then DX=0.0 DY=Y2-OY2
	  [] left then DX=X1-OX1 DY=0.0
	  [] hmid then DX=(X1+X2)/2.0-(OX1+OX2)/2.0 DY=0.0
	  [] right then DX=X2-OX2 DY=0.0
	  end
	  {self.client move(O DX DY)}
       end}
      {self.client setsel(nil)} % bizarre, mais fonctionne
   end

   meth transform(W)
      OX2={NewCell 0.0}
      OY2={NewCell 0.0}
      OX1={NewCell 1000.0}
      OY1={NewCell 1000.0}
      X1 Y1 X2 Y2 MX MY
   in
      {self.tools settool(self.selicon)}
      {self.client startundolog}
      {ForAll {self.seltool getsellist($)}
       proc{$ O}
	  X1 Y1 X2 Y2
       in
	  {O getsize(X1 Y1 X2 Y2)}
	  case X1<{Access OX1} then {Assign OX1 X1} else skip end
	  case Y1<{Access OY1} then {Assign OY1 Y1} else skip end
	  case X2>{Access OX2} then {Assign OX2 X2} else skip end
	  case Y2>{Access OY2} then {Assign OY2 Y2} else skip end
       end}
      X1={Access OX1} X2={Access OX2}
      Y1={Access OY1} Y2={Access OY2}
      MX=(X1+X2)/2.0
      MY=(Y1+Y2)/2.0
      % maintenant on connait la taille generale... on va pouvoir transformer
      {ForAll {self.seltool getsellist($)}
       proc{$ O}
	  OX1 OX2 OY1 OY2 DX DY OX OY 
       in
	  {self.client transform(O W)} % applique la transformation
	  {O getsize(OX1 OY1 OX2 OY2)}
	  OX=(OX1+OX2)/2.0
	  OY=(OY1+OY2)/2.0
	  case W
	  of lrotate then % faire tourner le pt (OX,OY) autour de (MX,MY)
	     DX=MX+OY-MY-OX
	     DY=MY-OX+MX-OY
	  [] rrotate then
	     DX=MX-OY+MY-OX
	     DY=MY+OX-MX-OY
	  [] hrotate then
	     DX=2.0*MX-2.0*OX
	     DY=2.0*MY-2.0*OY
	  [] vflip then
	     DX=0.0
	     DY=2.0*MY-2.0*OY
	  [] hflip then
	     DX=2.0*MX-2.0*OX
	     DY=0.0
	  end
	  {self.client move(O DX DY)}
       end}
      {self.client setsel(nil)} % bizarre, mais fonctionne
   end
   
   meth about
      T I1 I2 I3 I4 I5 C L F B1 B2 Mozart V Tag1 Tag2 Tag3 Tag4 Tag5 Quit
   in
      T={New Tk.toplevel tkInit(title:"About TransDraw..."
				withdraw:true
				delete:proc{$} skip end)}
      C={New Tk.canvas tkInit(parent:T
			      width:200
			      height:100
			      relief:sunken
			      borderwidth:2)}
      {List.forAllInd [I1 I2 I3 I4 I5]
       proc{$ I V}
	  Tag={Nth [Tag1 Tag2 Tag3 Tag4 Tag5] I} in
	  V={New Tk.image tkInit(type:photo
				 format:gif
				 data:{self.localize {VirtualString.toString "trd0000"#I-1#".gif"}}
				 palette:'6/6/5')}
	  Tag={New Tk.canvasTag tkInit(parent:C)}
	  {C tk(crea image
		0 0
		image:V
		anchor:nw
		tags:Tag)}
       end}
      {C tk('raise' Tag1)}
      L={New Tk.label tkInit(parent:T
			     text:"V0.9beta\n\nNo warranty\n\nBy Donatien Grolaux (c) 1998\nSend bug reports to ned@info.ucl.ac.be"
			     anchor:c
			     justify:center)}
      {Tk.batch [grid(C row:0 column:0 padx:5 pady:5)
		 grid(L row:1 column:0 padx:5 pady:5)
		 wm(deiconify T)]}
      {Delay 1000}
      {ForAll [Tag1 Tag2 Tag3 Tag4 Tag5]
       proc{$ Tag}
	  {C tk('raise' Tag)}
	  {Delay 200}
       end}
      F={New Tk.frame tkInit(parent:T)}
      B1={New Tk.button tkInit(parent:F
			       text:"Ok"
			       action:proc{$} Quit=unit end)}
      B2={New Tk.button tkInit(parent:F
			       text:"License..."
			       action:proc{$}
					 {Tk.batch [pack(forget B2)
						    grid(forget C)
						    grid(forget L)]}
					 B={New Tk.listbox tkInit(parent:T
								  width:80)}
					 S1 = {New Tk.scrollbar tkInit(parent:T
								       orient: horizontal)}
					 S2  = {New Tk.scrollbar tkInit(parent: T)}
				      in
					 {ForAll
					  [
"License Agreement for TransDraw"
"-------------------------------"
""
"TransDraw is owned by the Walloon Region of Belgium.  This license hereby"
"grants you a non-transferable, non-exclusive royalty-free worldwide license"
"to use TransDraw for non-commercial purposes, subject to your agreement to"
"the following terms and conditions:"
" "
"- This license agreement shall be included in the source code and"
"  documentation and must be retained in all copies, partial or complete,"
"  of TransDraw."
" "
"- You acquire no ownership right, title, or interest in TransDraw except"
"  as provided herein."
" "
"- The following copyright notice is included in the source code and must be"
"  retained in all files:"
" "
"    Copyright 1998 Walloon Region of Belgium.  All Rights Reserved."
" "
"- You agree to defend, indemnify and save the Walloon Region against all"
"  liability, attorney's fees, and costs of defending against third party"
"  claims against the Walloon Region arising out of your use of TransDraw."
" "
"- You may not use the name of the Walloon Region in any advertisement, press"
"  release or for other publicity with reference to TransDraw without prior"
"  written consent of the Walloon Region."
" "
"TRANSDRAW IS A RESEARCH WORK WHICH IS PROVIDED "#'"'#"AS IS"#'"'#", AND THE WALLOON REGION"
"DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING ALL IMPLIED"
"WARRANTIES OF MERCHANTABILITY AND FITNESS OF PURPOSE.  IN NO EVENT SHALL THE"
"WALLOON REGION BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL"
"DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,"
"WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,"
"ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE."
					  ]
					  proc{$ M}
					     {B tk(insert 'end' M)}
					  end}
					 {Tk.batch [grid(B row:0 column:0 sticky:nswe)
						    grid(S1 row:1 column:0 sticky:we)
						    grid(S2 row:0 column:1 sticky:ns)
						    grid(columnconfigure T 0 weight:1)
						    grid(rowconfigure T 0 weight:1)]}
					 {Tk.addXScrollbar B S1}
					 {Tk.addYScrollbar B S2}
				      end)}
      V={New Tk.image tkInit(type:photo
			     format:gif
			     data:{self.localize {VirtualString.toString "mozart-powered-75.gif"}}
			     palette:'6/6/5')}
      Mozart={New Tk.label tkInit(parent:F image:V)}
      {Tk.batch [pack(B1 B2 side:left padx:5 pady:5)
		 pack(Mozart side:right)
		 grid(F row:2 column:0 padx:5 pady:5 sticky:we)]}
      {T tkBind(event:"<Return>"
		action:proc{$} Quit=unit end)}
      {Wait Quit}
      {T tkClose}	
%      _={self.dialogbox message(title:"About TransDraw..."
%				text:"TransDraw V0.9beta\n\nNo warranty\n\nBy Donatien Grolaux (c) 1998\nSend bugs report to ned@info.ucl.ac.be"
%				bitmap:info
%				buttons:ok)}
   end
   
   meth new(N)
      Info ServerGui Ok W
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
      case N<4 then Ok=true
      else
	 Name in
	 Name={self.dialogbox getFile(title:"Load from the file..."
				      type:'open'
				      defaultextension:'.trd'
				      filetypes:[['TransDraw files' [".trd" ".TRD"]]
						 ['All files' ["*" ".*"]]])}
	 case Name=='' then Ok=false else
	    try
	       {Pickle.load Name W}
	    catch X then
	       _={self.dialogbox message(title:"Error"
					 text:"\nUnable to read the file "#Name#"\n"
					 bitmap:error
					 buttons:ok)}
	    end
	    case {IsFree W} then Ok=false else Ok=true end
	 end
      end
      case Ok then
	 {self.client startnewserver(Info ServerGui)}
	 {Wait Info}
	 case Info=='' then
	    _={self.dialogbox message(title:"Unable to start a new drawing"
				      text:"Enough ressource available ?"
				      bitmap:error
				      buttons:ok)}
	 else
	    {ServerGui show}
	    case N
	    of 1 then
	       {self.client startnewclient(Info.ticket)}
	    [] 2 then
	       {self.client resubscribe(Info.ticket)}
	    [] 3 then skip
	    [] 4 then % nouveau serveur d'un fichier avec un nouveau client
	       {FEED}
	       {self.client startnewclient(Info.ticket)}
	    [] 5 then % nouveau serveur d'un fichier avec ce client-ci
	       {FEED}
	       {self.client resubscribe(Info.ticket)}
	    [] 6 then % nouveau serveur d'un fichier, sans rien
	       {FEED}
	    else skip end
	 end
      else skip end
   end

   meth obtainticket(?Ticket)
      Clip T F L1 E1 R1 R2 B1 B2 B3 V1 Ok
   in
      T={New Tk.toplevel tkInit(title:"Enter the adress of the drawing"
				delete:proc{$} skip end)}
      {Tk.send grab(T)}
      F={New Tk.frame tkInit(parent:T
			     relief:sunken
			     borderwidth:2)}
      L1={New Tk.label tkInit(parent:F
			      text:"Ticket or URL :")}
      E1={New Tk.entry tkInit(parent:F
			      bg:white)}
      % acces au clipboard avec gestion Tk de l'erreur
      case {Tk.returnInt 'catch'(v('{selection get -selection CLIPBOARD -type STRING}'))}==0 then
	 Clip={Tk.returnString selection(get selection:'CLIPBOARD' type:'STRING')}
      else
	 Clip=""
      end
      case {Length Clip}>13 andthen {List.take Clip 13}=="x-ozticket://" then
	 {E1 tk(insert 0 Clip)}
	 V1={New Tk.variable tkInit(1)}
      else 
	 V1={New Tk.variable tkInit(2)}
      end
      R1={New Tk.radiobutton tkInit(parent:F
				    text:"Ticket"
				    anchor:w
				    variable:V1
				    value:1)}
      R2={New Tk.radiobutton tkInit(parent:F
				    text:"Pickled Ticket on URL"
				    anchor:w
				    variable:V1
				    value:2)}     
      B1={New Tk.button tkInit(parent:T
			       text:"Ok"
			       action:proc{$}
					 {Lock proc{$} case {IsFree Ok} then Ok=true else skip end end}
				      end)}
      {T tkBind(event:"<Return>"
		action:proc{$}
			  {Lock proc{$} case {IsFree Ok} then Ok=true else skip end end}
		       end)}
      {T tkBind(event:"<Escape>"
		action:proc{$}
			  {Lock proc{$} case {IsFree Ok} then Ok=false else skip end end}
		       end)}
      B2={New Tk.button tkInit(parent:T
			       text:"Cancel"
			       action:proc{$}
					 {Lock proc{$} case {IsFree Ok} then Ok=false else skip end end}
				      end)}
      B3={New Tk.button tkInit(parent:T
			       text:"Help"
			       action:proc{$}
					 {Lock proc{$} {self.client help("obtainticket")} end}
				      end)}
      {Tk.batch [pack(F side:top padx:5 pady:5 expand:true fill:both)
		 pack(B1 B2 side:left padx:5 pady:5)
%		 pack(B3 side:right padx:5 pady:5)
		 grid(L1 row:0 column:0)
		 grid(E1 row:0 column:1 padx:5 pady:5 sticky:we)
		 grid(R1 row:1 column:0 columnspan:2 sticky:we)
		 grid(R2 row:2 column:0 columnspan:2 sticky:we)
		 grid(columnconfigure F 1 weight:1)
		 grid(rowconfigure    F 0 weight:1)
		 focus(E1)]}
      {Wait Ok}
      case Ok then
	 case {V1 tkReturnInt($)}==1 then
	    Ticket={E1 tkReturnAtom(get $)}
	 else
	    URL M in
	    URL={E1 tkReturn(get $)}
	    try
	       {Pickle.load URL M}
	    catch X then _={self.dialogbox message(title:"Error"
						   text:"\nUnable to load a ticket from this URL :\n"#URL#"\n"
						   bitmap:error
						   buttons:ok)}
	       Ticket=''
	    end
	    case {IsFree Ticket} then Ticket={StringToAtom {VirtualString.toString M}} else skip end
	 end
      else Ticket='' end
      {Tk.send grab(release T)}
      {T tkClose}
   end
   
   meth open(N)
      case N
      of 1  then % ouvrir un nouveau client connecte a un autre serveur
	 Ticket in
	 {self obtainticket(Ticket)}
	 case Ticket\='' then
	    {self.client startnewclient(Ticket)}
	 else skip end
      [] 2 then % reconnecter ce client a un autre serveur
	 Ticket in
	 {self obtainticket(Ticket)}
	 case Ticket\='' then
	    {self.client resubscribe(Ticket)}
	 else skip end	 
      [] 3 then % ouvrir un nouveau client connecte a ce serveur-ci
	 {self.client startnewclientref({self.client getserver($)})}
      end
   end

   meth save
      Name in
      case @name==nil then
	 Name={self.dialogbox getFile(title:"Save a snapshot to the file..."
				      type:'save'
				      defaultextension:'.trd'
				      filetypes:[['TransDraw files' [".trd" ".TRD"]]
						 ['All files' ["*" ".*"]]])}
      else
	 Name=@name
      end
      case Name=='' then skip else	 
	 name<-Name
	 {self.tools settool(self.selicon)}
	 Error in
	 {self.menu.file.save tk(entryconfigure label:"Save snapshot to "#Name)}
	 try
	    {Pickle.save {List.map {self.client getlist($)}
			  fun{$ O}
			     {O getstate($)}
			  end}
	     Name}
	 catch X then Error=unit
	 end
	 case {IsDet Error} then
	    _={self.dialogbox message(title:"Error"
				      text:"\nUnable to save to the file "#Name#"\n"
				      bitmap:error
				      buttons:ok)}
	    name<-nil
	    {self.menu.file.save tk(entryconfigure label:"Save snapshot")}
	 else
	    _={self.dialogbox message(title:"Success"
				      text:"\nDrawing saved to "#Name#"\n"
				      bitmap:error
				      buttons:ok)}
	 end
      end
   end

   meth saveas
      name<-nil
      {self.menu.file.save tk(entryconfigure label:"Save snapshot")}
      {self save}
   end
   
   meth serverinfo
      INFO TICKET BUTTONS in
      case @askedserverinfo==nil then
	 askedserverinfo<-unit
	 {self.client getserverinfo(INFO)}
	 thread
	    {Wait INFO}
	    case INFO.ticket==nil then
	       TICKET="Centralized server"
	       BUTTONS=["Close"]
	    else
	       TICKET="Ticket       : "#INFO.ticket
	       BUTTONS=["Close" "Copy ticket to clipboard"]
	    end
	    local
	       proc{Loop}
		  case {self.dialogbox message(title:"Server informations"
					       text:TICKET#"\n# of users   : "#INFO.clients#"\n# of objects : "#INFO.objects#"\nMachine      : "#INFO.uname.nodename#" ("#INFO.uname.machine#")\nSystem       : "#INFO.uname.sysname#" "#INFO.uname.release#" "#INFO.uname.version
					       bitmap:info
					       justify:left
					       buttons:BUTTONS)}==1 then
		     {Tk.send clipboard(clear)}
		     {Tk.send clipboard(append INFO.ticket)}
		     _={self.dialogbox message(title:"Clipboard"
					       text:"\nTicket was succesfully copied to the clipboard\n"
					       bitmap:info
					       buttons:ok)}
		     {Loop}
		  else 
		     askedserverinfo<-nil
		  end
	       end
	    in
	       {Loop}
	    end  
	 end
      else skip end
   end

   meth switchgrid
      grid<-(@grid==false)
      {self.client.actions switchgrid(@grid)}
   end

   meth confgrid
      T L1 L2 C B1 B2 F TX={NewCell @gridx} TY={NewCell @gridy} Tagx Tagy Mode={NewCell 0}
      Quit
      proc{Ok}
	 case {IsFree Quit} then
	    gridx<-{Access TX}
	    gridy<-{Access TY}
	    {self.client.actions setgrid(@gridx @gridy)}
	    {Tk.send grab(release T)}
	    {T tkClose}
	    Quit=unit
	 else skip end
      end
      proc{Cancel}
	 case {IsFree Quit} then
	    {Tk.send grab(release T)}
	    {T tkClose}
	    Quit=unit
	 else skip end
      end
      proc{SetVal IX IY}
	 X Y in
	 case IX<1.0 then X=1.0 elsecase IX>100.0 then X=100.0 else X=IX end
	 case IY<1.0 then Y=1.0 elsecase IY>100.0 then Y=100.0 else Y=IY end
	 {L1 tk(configure text:X)}
	 {L2 tk(configure text:Y)}
	 {Assign TX X}
	 {Assign TY Y}
	 {Tagx tk(delete)}
	 {Tagy tk(delete)}
	 {C tk(crea line
	       X 0
	       X 100
	       tags:Tagx)}
	 {C tk(crea line
	       0 Y
	       100 Y
	       tags:Tagy)}
      end
      proc{Click X Y}
	 {Lock proc{$}
		  {Assign Mode 1}
		  {SetVal X Y}
	       end}
      end
      proc{Move X Y}
	 {Lock proc{$}
		  case {Access Mode}==1 then
		     {SetVal X Y}
		  else skip end
	       end}
      end
      proc{Release X Y}
	 {Lock proc{$}
		  {Assign Mode 0}
	       end}
      end
   in
      T={New Tk.toplevel tkInit(title:"Grid size")}
      L1={New Tk.label tkInit(parent:T width:5)}
      L2={New Tk.label tkInit(parent:T width:5)}
      C={New Tk.canvas tkInit(parent:T
			      bg:white
			      width:100
			      height:100
			      relief:sunken
			      borderwidth:1)}
      Tagx={New Tk.canvasTag tkInit(parent:C)}
      Tagy={New Tk.canvasTag tkInit(parent:C)}
      F={New Tk.frame tkInit(parent:T)}
      B1={New Tk.button tkInit(parent:F
			       text:"Ok"
			       action:proc{$} {Lock Ok} end)}
      B2={New Tk.button tkInit(parent:F
			       text:"Cancel"
			       action:proc{$} {Lock Cancel} end)}
      {T tkBind(event:"<Return>"
		action:proc{$} {Lock Ok} end)}
      {T tkBind(event:"<Escape>"
		action:proc{$} {Lock Cancel} end)}
      {C tkBind(event:"<1>"
		args:[float(x) float(y)]
		action:proc{$ X Y} {Click X Y} end)}
      {C tkBind(event:"<B1-Motion>"
		args:[float(x) float(y)]
		action:proc{$ X Y} {Move X Y} end)}
      {C tkBind(event:"<B1-ButtonRelease>"
		args:[float(x) float(y)]
		action:proc{$ X Y} {Release X Y} end)}
      {Tk.batch [grid(L1 row:0 column:0 columnspan:2)
		 grid(C  row:1 column:0 padx:5 pady:5 sticky:nswe)
		 grid(L2 row:0 column:1 rowspan:2)
		 grid(F  row:2 column:0 columnspan:2 sticky:we)
		 grid(rowconfigure    T 1 weight:1)
		 grid(columnconfigure T 0 weight:1)
		 pack(B1 B2 side:left padx:5 pady:5)
		 grab(set T)]}
      {SetVal @gridx @gridy}
   end

   meth createpostscript(Client File Param ColorMap FontMap)
      {Client.dc hideborders}
      {Client.dc tk(crea rect
		    ~1000000 ~1000000
		    1000000 Param.y*Param.zoom-1.0
		    fill:white
		    outline:white)}
      {Client.dc tk(crea rect
		    ~1000000 ~1000000
		    Param.x*Param.zoom-1.0   1000000
		    fill:white
		    outline:white)}
      {Client.dc tk(crea rect
		    (Param.x+Param.width)*Param.zoom+1.0 ~1000000
		    1000000   1000000
		    fill:white
		    outline:white)}
      {Client.dc tk(crea rect
		    ~1000000 1000000
		    1000000  (Param.y+Param.height)*Param.zoom+1.0
		    fill:white
		    outline:white)}
      {Client setscale(Param.zoom)}
%      local Cmd Cmd2 Cmd3 Cmd4 in
%	 Cmd=tk(postscript
%		colormode:Param.colormode
%		pagewidth:Param.pagewidth
%		pagex:0.0
%		pagey:0.0
%		pageanchor:sw
%		rotate:Param.rotate
%		width:Param.tkwidth
%		height:Param.tkheight
%		x:Param.tkx
%		y:Param.tky
%		file:File)
%	 case ColorMap==nil then
%	    Cmd2=Cmd
%	 else Cmd2={AdjoinAt Cmd colormap ColorMap} end
%	 case FontMap==nil then
%	    Cmd3=Cmd2
%	 else Cmd3={AdjoinAt Cmd2 fontmap FontMap} end
%	 {Client.dc Cmd3}
%      end
      local Cmd Cmd2 Cmd3 Cmd4 X in
	 Cmd=postscript(
		colormode:Param.colormode
		pagewidth:Param.pagewidth
		pagex:0.0
		pagey:0.0
		pageanchor:sw
		rotate:Param.rotate
		width:Param.tkwidth
		height:Param.tkheight
		x:Param.tkx
		y:Param.tky
		file:File)
	 case ColorMap==nil then
	    Cmd2=Cmd
	 else Cmd2={AdjoinAt Cmd colormap ColorMap} end
	 case FontMap==nil then
	    Cmd3=Cmd2
	 else Cmd3={AdjoinAt Cmd2 fontmap FontMap} end
	 X={Client.dc tkReturn(Cmd3 $)}
	 {Wait X}
      end
   end

   meth dupdc(T ?Client)
      MyServer={New ServerObject init(OS)}
      Quit NewClient in
      NewClient={MyServer getclientclass($)}
      {NewClient Tk TkTools Open OS Pickle dummy dummy dummy
       nil
       Client Quit 0 0 0 MyServer}
      {Client displayer(T)}
      {Client setscale(1.0)}
      {ForAll {List.sort {self.client getlist($)} fun{$ A B} {A getorder($)}<{B getorder($)} end}
       proc{$ O}
	  S={O getstate($)} in
	  {MyServer createobj('dummy' S)}
	  {MyServer releaselock('dummy' S.id)}
       end}
   end
   
   meth savetops
      Return File T Client in
      T={New Tk.toplevel tkInit(title:"Temp"
				withdraw:true
			       )}
      {self dupdc(T Client)}
      Return={self.dialogbox getPSOptions(canvas:Client.dc
					  title:"Select area to save..."
					  region:[0 0 1000 1000]
					  zoom:@defsaveps.zoom
					  rotate:@defsaveps.rotate
					  pagewidth:@defsaveps.pagewidth
					  pageheight:@defsaveps.pageheight
					  fit:@defsaveps.fit
					  pagex:@defsaveps.pagex
					  pagey:@defsaveps.pagey
					  width:@defsaveps.width
					  height:@defsaveps.height
					  x:@defsaveps.x
					  y:@defsaveps.y
					  colormode:@defsaveps.colormode)}
      case Return=='' then skip else
	 defsaveps<-r(zoom:Return.zoom
		      rotate:Return.rotate
		      pagewidth:Return.pagewidth
		      pageheight:Return.pageheight
		      fit:Return.fit
		      pagex:Return.pagex
		      pagey:Return.pagey
		      width:Return.width
		      height:Return.height
		      x:Return.x
		      y:Return.y
		      colormode:Return.colormode)
	 File={self.dialogbox getFile(type:save
				      title:"Save postscript to file..."
				      defaultextension:".ps"
				      filetypes:[['Postscript files' [".ps" ".PS"]]
						 ['All files' ["*" ".*"]]])}
	 case File=='' then skip else
	    {self createpostscript(Client File Return nil nil)}
	 end
      end
      {T tkClose}
%      defprintps<-r(zoom:1.0
%		    rotate:false
%		    pagewidth:"210m"
%		    pageheight:"297m"
%		    pagex:"20m"
%		    pagey:"20m"
%		    width:1000
%		    height:1000
%		    x:0
%		    y:0
%		    colormode:grey
%		    cmd:"lp"
%		    colormap:nil
%		    fontmap:nil)
   end

   meth printps
      Return File T Client in
      T={New Tk.toplevel tkInit(title:"Temp"
				withdraw:true
			       )}
      {self dupdc(T Client)}
      Return={self.dialogbox getPSOptions(canvas:Client.dc
					  title:"Select area to print..."
					  region:[0 0 1000 1000]
					  zoom:@defsaveps.zoom
					  rotate:@defsaveps.rotate
					  pagewidth:@defsaveps.pagewidth
					  pageheight:@defsaveps.pageheight
					  fit:@defsaveps.fit
					  pagex:@defsaveps.pagex
					  pagey:@defsaveps.pagey
					  width:@defsaveps.width
					  height:@defsaveps.height
					  x:@defsaveps.x
					  y:@defsaveps.y
					  colormode:@defsaveps.colormode)}
      case Return=='' then skip else
	 defsaveps<-r(zoom:Return.zoom
		      rotate:Return.rotate
		      pagewidth:Return.pagewidth
		      pageheight:Return.pageheight
		      fit:Return.fit
		      pagex:Return.pagex
		      pagey:Return.pagey
		      width:Return.width
		      height:Return.height
		      x:Return.x
		      y:Return.y
		      colormode:Return.colormode)
	 File={OS.tmpnam}
	 case File=='' then skip else
	    Ret in
	    {self createpostscript(Client File Return nil nil)}
	    {Delay 1000}
	    Ret={OS.system (@printcmd#" "#File)}
	    case
	       Ret
	    of 0 then skip
	    else
	       _={self.dialogbox message(title:"Unable to print the page."
					 text:"\nError # :"#Ret#"\nHave you correctly set the printer command line ?\n"
					 bitmap:error
					 buttons:ok)}
	    end
	    try
	       {OS.unlink File}
	    catch X then skip end
	 end
      end
      {T tkClose}
   end

   meth configureps
      T L1 E1 F1 F2 B1 B2 B3 B4 Quit S in
      S={NewLock}
      T={New Tk.toplevel tkInit(title:"Configure print command"
				delete:proc{$}
					  lock S in
					     case {IsFree Quit} then Quit=cancel else skip end
					  end
				       end
				withdraw:true)}
      F1={New Tk.frame tkInit(relief:sunken borderwidth:2 parent:T)}
      F2={New Tk.frame tkInit(parent:T)}
      L1={New Tk.label tkInit(text:"What is the command you want to use for printing ?\nTip : use ghostview for preview, lp for printing."
			      parent:F1
			      anchor:nw
			      justify:left)}
      E1={New Tk.entry tkInit(bg:white parent:F1)}
      B1={New Tk.button tkInit(text:"Ok"
			       parent:F2
			       action:proc{$}
					 lock S in
					    case {IsFree Quit} then Quit=ok else skip end
					 end
				      end)}
      B2={New Tk.button tkInit(text:"Cancel"
			       parent:F2
			       action:proc{$}
					 lock S in
					    case {IsFree Quit} then Quit=cancel else skip end
					 end
				      end)}
      B3={New Tk.button tkInit(text:"Font map..."
			       parent:F2
			       action:proc{$} skip end
			       state:disabled)}
      B4={New Tk.button tkInit(text:"Color map..."
			       parent:F2
			       action:proc{$} skip end
			       state:disabled)}
      {T tkBind(event:"<Return>"
		action:proc{$}
			  lock S in
			     case {IsFree Quit} then Quit=ok else skip end
			  end
		       end)}
      {T tkBind(event:"<Escape>"
		action:proc{$}
			  lock S in
			     case {IsFree Quit} then Quit=cancel else skip end
			  end
		       end)}
      {Tk.batch [pack(F1 side:top fill:both expand:true)
		 pack(F2 side:top pady:5 fill:x expand:true)
		 pack(L1 side:top padx:5 pady:5)
		 pack(E1 side:top fill:x padx:5 pady:5 expand:true)
		 pack(B1 B2 side:left padx:5)
		 pack(B3 B4 side:right padx:5)
		 focus(E1)
		 grab(set T)
		 wm(deiconify T)]}
      {E1 tk(insert 'end' @printcmd)}
      {Wait Quit}
      case Quit==ok then
	 printcmd<-{E1 tkReturn(get $)}
      else skip end
      {Tk.send grab(release T)}
      {T tkClose}
   end
   
   meth invitebymail
      T F1 L1 L2 E1 E2 E3 V1 C1 C2 B1 B2 B3 Quit ServerTicket INFO in
      {self.client getserverinfo(INFO)}
      thread
	 {Wait INFO}
	 case INFO.ticket==nil then
	    _={self.dialogbox message(title:"Error"
				      text:"\nSorry : the drawing is'nt distributed\n"
				      bitmap:error
				      buttons:ok)}
	 else
	    ServerTicket=INFO.ticket
	    T={New Tk.toplevel tkInit(title:"Invite by mail"
				      withdraw:true)}
	    F1={New Tk.frame tkInit(parent:T
				    borderwidth:2
				    relief:sunken)}
	    L1={New Tk.label tkInit(parent:F1
				    text:"To :"
				    justify:left
				    anchor:w)}
	    L2={New Tk.label tkInit(parent:F1
				    text:"Subject :"
				    justify:left
				    anchor:w)}
	    E1={New Tk.entry tkInit(parent:F1
				    font:"Courier 10"
				    bg:white)}
	    E2={New Tk.entry tkInit(parent:F1
				    font:"Courier 10"
				    bg:white)}
	    E3={New Tk.text tkInit(parent:F1 height:10 width:60
				   font:"Courier 10"
				   bg:white)}
	    V1={New Tk.variable tkInit(1)}
	    C1={New Tk.radiobutton tkInit(parent:F1
					  text:"Short description (only the file to click on)"
					  justify:left
					  anchor:nw
					  value:1
					  variable:V1)}
	    C2={New Tk.radiobutton tkInit(parent:F1
					  text:"Full description (the file AND the manual)"
					  justify:left
					  anchor:nw
					  value:2
					  variable:V1)}
	    B1={New Tk.button tkInit(parent:T
				     text:"Ok"
				     action:proc{$}
					       {Lock proc{$} case {IsFree Quit} then
								Quit=ok
							     else skip end
						     end}
					    end)}
	    B2={New Tk.button tkInit(parent:T
				     text:"Cancel"
				     action:proc{$}
					       {Lock proc{$} case {IsFree Quit} then
								Quit=cancel
							     else skip end
						     end}
					       end)}
	    {T tkBind(event:"<Escape>"
		      action:proc{$}
				{Lock proc{$} case {IsFree Quit} then
						 Quit=cancel
					      else skip end
				      end}
			     end)}
	    B3={New Tk.button tkInit(parent:T
				     text:"Help"
				     action:proc{$} {self.client help(invitebymail)} end)}
	    {Tk.batch [pack(F1 side:top expand:true fill:both padx:5 pady:5)
		       pack(B1 B2 side:left fill:y padx:5 pady:5)
%		       pack(B3 side:right fill:y padx:5 pady:5)
		       grid(L1 row:0 column:0 sticky:we)
		       grid(L2 row:1 column:0 sticky:we)
		       grid(E1 row:0 column:1 padx:5 pady:5 sticky:we)
		       grid(E2 row:1 column:1 padx:5 pady:5 sticky:we)
		       grid(E3 row:2 column:0 columnspan:2 padx:5 pady:5 sticky:nswe)
		       grid(C1 row:3 column:0 columnspan:2 padx:5 sticky:we)
		       grid(C2 row:4 column:0 columnspan:2 padx:5 sticky:we)
		       grid(columnconfigure F1 1 weight:1)
		       grid(rowconfigure    F1 2 weight:1)
		       wm(deiconify T)
		       grab(T)
		       focus(E1)]}
	    {Wait Quit}
	    case Quit=='ok' then
	       fun{GenFunc Ticket Name}
		  MyFunc in
		  MyFunc=functor
		  import
		     Tk TkTools Open OS Pickle Remote Module
		     System
		     Application
		     Connection
		     Property	    
		  define
                     Windows=({Property.get 'platform'}.os=='win32')
		     local
			SERVER Temp NewClient Quit M L B Error
			proc{Insert Msg}
			   {L tk(insert 'end' Msg)}
			end
		     in
			{Tk.send tk_setPalette(grey)}
			M={New Tk.toplevel tkInit(title:"Connecting to a drawing"
						  delete:proc{$} {Application.exit 1} end)}
			L={New Tk.listbox tkInit(parent:M
						 width:60
						 height:15)}
			B={New Tk.button tkInit(parent:M
						text:"Cancel"
						action:proc{$} {Application.exit 1} end)}
			{Tk.send pack(L expand:true fill:both)}
			{Tk.send pack(B side:bottom)}
			{Tk.send grab(B)}
			{Insert "Ticket : "#Ticket}
			{Insert "Connecting to the server"}
			try
			   {Connection.take Ticket SERVER}
			catch X then Error=unit end
			case {IsDet Error} then
			   {Insert "Error : wrong ticket (is the drawing server still alive ?)"}
			else
			   {Insert "Retrieving application"}
			   try
			      {SERVER getclientclass(NewClient)}
			   catch X then Error=unit end
			   case {IsDet Error} then
			      {Insert "Error : unable to get the application back."}
			   else
			      {Insert "Linking to local resources"}
			      try
				 {NewClient Tk TkTools Open OS Pickle System Remote Connection Name Temp Quit 0 0 0 SERVER} % on demande un client
			      catch X then Error=unit end
			      case {IsDet Error} then
				 {Insert "Error : version conflict ?"}
			      else
				 {Insert "Starting application"}
				 {Temp subscribe(windows:Windows)}
				 {Tk.send grab(release B)}
				 {M tkClose}
			      end
			   end
			end
			{Wait Quit}
			{Application.exit 0}
		     end
		  end
%		        {Connection.take Ticket SERVER}
%			{SERVER getclientclass(NewClient)}
%			{NewClient Tk TkTools Open OS Pickle System Remote Connection Name Temp Quit 0 0 0 SERVER} % on demande un client
%			{Temp subscribe} % on lance le client
%			{Wait Quit}
%		     end
%		     {Application.exit 0}
%		  end
		  MyFunc
	       end
	       FN1 FN2 To Subject Text Error
	       proc{SaveTxt FN Text}
		  MyFile in
		  MyFile={New Open.file init(name:FN
					     flags:[write create])}
		  {MyFile write(vs:Text)}
		  {MyFile close}
	       end
	    in
	       To={E1 tkReturn(get $)}
	       {Wait To}
	       Subject={E2 tkReturn(get $)}
	       Text={E3 tkReturn(get('0.0' {E3 tkReturn(index('end') $)}) $)}
	       case To=="" then
		  _={self.dialogbox message(title:"No destination adress"
					    text:"\nYou must specify a target.\n"
					    bitmap:error
					    buttons:ok)}
	       else
		  try
		  FN1={OS.tmpnam}
		     {Pickle.saveCompressed
		      {GenFunc ServerTicket To} FN1 9}
		     case Text=="" andthen {V1 tkReturnInt($)}==1 then
			skip
		     else
			Txt Txt2 in
			FN2={OS.tmpnam}
			case {V1 tkReturnInt($)}==1 then
			   Txt2=""
			else
			   Txt2=
			   "\n------------------------\n"#
			   "You are invited to co-edit a drawing.\n"#
			   "\n"#
			   "In order for this application to work, you must have a Mozart ozengine working on your system.\n"#
			   "You can get one at the url : http://www.ps.uni-sb.de/mozart/system\n"#
			   "\n"#
			   "Once it's done, you must set the following MIME type extension for your mailer application :\n"#
			   "MIME type : application/x-oz-application\n"#
			   "File extension : oza\n"#
			   "Program location : /directory/ozengine %s\n"#
			   "\n"#
			   "Where '/directory/' is the place where you've just installed the ozengine.\n"#
			   "\n"#
			   "More informations can be found at the url : http://www.ps.uni-sb.de/mozart/documentation/demo/node20.html#appendix.enable\n"#
			   "\n"#
			   "When all that is done, clicking on the file below launches the drawing editor.\n"
			end
			Txt=Text#Txt2
			{SaveTxt FN2 Txt}
		     end
		     case
			{OS.system ('metasend -b'#
				    case {IsDet FN2} then
				       ' -e 7bit -f '#FN2#
				       ' -m text/plain'#
				       ' -n'
				    else ''
				    end#
				    ' -e base64 -f '#FN1#
				    ' -m application/x-oz-application'#
				    ' -s "'#Subject#'" -t '#To#'>/dev/null')}
		     of 0 then skip
		     else
			{self.dialogbox message(title:"Unable to send the mail"
						text:"\nMaybe metasend is unavailable,\n or you don't have a mail account ?\n"
						bitmap:error
						buttons:ok)}
		     end
		     {OS.unlink FN1}
		     case {IsDet FN2} then {OS.unlink FN2} else skip end
		  catch X then 
		     _={self.dialogbox message(title:"Error"
					       text:"\nUnable to write to a temporary file\n"
					       bitmap:error
					       buttons:ok)}
		  end
	       end
	    else skip end
	    {Tk.send grab(release T)}
	    {T tkClose}
	 end
      end
   end

   meth selectchatters(CH ?IDs ?Comment)
      % recoit CH qui est une liste de paires ID#Nom et retourne
      % une liste des ID selectionnes ainsi qu'un eventuel commentaire
      T F1 F2 F3 F4 L S B1 B2 B3 L1 E Quit in
      T={New Tk.toplevel tkInit(title:"Invite who ?"
				withdraw:true)}
      F1={New Tk.frame tkInit(parent:T)}
      F2={New Tk.frame tkInit(parent:T)}
      F3={New Tk.frame tkInit(parent:F1)}
      F4={New Tk.frame tkInit(parent:F1)}
      L={New Tk.listbox tkInit(parent:F3
			       width:20
			       selectmode:multiple)}
      S={New Tk.scrollbar tkInit(parent:F3
				 width:10
				 orient:vert)}
      {Tk.addYScrollbar L S}
      B1={New Tk.button tkInit(parent:F4
			       text:"Ok"
			       justify:center
			       anchor:w
			       action:proc{$} {Lock proc{$} case {IsFree Quit} then Quit=ok else skip end end}
				      end)}
      B2={New Tk.button tkInit(parent:F4
			       text:"Cancel"
			       justify:center
			       anchor:w
			       action:proc{$} {Lock proc{$} case {IsFree Quit} then Quit=cancel else skip end end}
				      end)}
      B3={New Tk.button tkInit(parent:F4
			       text:"Help"
			       justify:center
			       anchor:w
			       action:self.client#help("selectinvitation"))}
      L1={New Tk.label tkInit(parent:T
			      text:"Message :"
			      anchor:w justify:left)}
      E={New Tk.text tkInit(parent:F2
			    width:60
			    height:15
			    bg:white)}
      {Tk.batch [grid(L row:0 column:0 sticky:nswe)
		 grid(S row:0 column:1 sticky:ns)
		 grid(rowconfigure    F3 0 weight:1)
		 grid(columnconfigure F3 0 weight:1)
		 pack(B1 B2 side:top fill:x pady:5 padx:5)
%		 pack(B3 side:bottom fill:x pady:5 padx:5)
		 grid(F3 row:0 column:0 sticky:nswe)
		 grid(F4 row:0 column:1 sticky:nswe)
		 grid(rowconfigure F1 0 weight:1)
		 grid(columnconfigure F1 0 weight:1)
		 pack(E expand:true fill:both)
		 pack(F1 L1 F2 side:top expand:true fill:both padx:5 pady:5)
		 grid(columnconfigure T 0 weight:0)
		 wm(deiconify T)
		 grab(T)]}
      {ForAll CH
       proc{$ CHID}
	  case CHID of ID#Name then
	     {L tk(insert 'end' Name)}
	  end
       end}
      {Wait Quit}
      case Quit==ok then
	 IDs={List.map
	      {List.filterInd CH
	       fun{$ I CHID}
		  case {L tkReturnInt(selection(includes I-1) $)}==1 then
		     true
		  else
		     false
		  end
	       end}
	      fun{$ CHID}
		 case CHID of Id#Name then
		    Id
		 end
	      end}
	 Comment={E tkReturn(get('0.0' {E tkReturn(index('end') $)}) $)}
	 {Tk.send grab(release T)}
	 {T tkClose}
      else
	 IDs=nil
	 Comment=nil
	 {Tk.send grab(release T)}
	 {T tkClose}
      end
   end
      
   
   meth invitefrom
      Ticket Server INFO ServerTicket in
      {self.client getserverinfo(INFO)}
      thread
	 {Wait INFO}
	 case INFO.ticket==nil then
	    _={self.dialogbox message(title:"Error"
				      text:"\nSorry : this drawing is'nt distributed !\n"
				      bitmap:error
				      buttons:ok)}
	 else
	    ServerTicket=INFO.ticket
	    {self obtainticket(Ticket)}
	    case Ticket=='' then skip else
	       {self.client tickettoserver(Ticket Server)}
	       case Server==nil then skip else
		  CH
	       in
		  {Server getchatters(CH)}
		  case {Length CH}==0 then
		     _={self.dialogbox message(title:"Invite from another drawing"
					       text:"\nThere's nobody there to invite !\n"
					       bitmap:error
					       buttons:ok)}
		  else
		     IDs Comment in
		     {self selectchatters(CH IDs Comment)}
		     {ForAll IDs
		      proc{$ ID}
			 Name=self.client.name in
			 {Server inviteto(ID Name ServerTicket Comment)}
		      end}
		  end
	       end
	    end
	 end
      end
   end
   
   meth inviteto
      Ticket Server CH
   in
      {self.client getchatters(CH)}
      case {Length CH}==0 then
	 _={self.dialogbox message(title:"Invite to another drawing"
				   text:"\nThere's nobody here to invite !\n"
				   bitmap:error
				   buttons:ok)}
      else
	 {self obtainticket(Ticket)}
	 case Ticket=='' then skip else
	    {self.client tickettoserver(Ticket Server)}
	    case Server==nil then skip else
	       IDs Comment in
	       {self selectchatters(CH IDs Comment)}
	       {ForAll IDs
		proc{$ ID}
		   Name=self.client.name in
		   {{self.client getserver($)} inviteto(ID Name Ticket Comment)}
		end}
	    end
	 end
      end
   end
   
end
