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


   
local
   NoArgs={NewName}
   
   class StdButton
      
      feat tag parent tag2 ttag btag rtag itag tooltip text imggray imgcolor
	 itag2
	 
      attr mode pos thid toolwin:nil
	 
      meth init(Parent Pos Text Img<=nil ToolTip<=nil)
	 Height in
	 self.parent=Parent
	 self.tooltip=ToolTip
	 self.text=Text
	 toolwin<-nil
	 Height={self.parent tkReturnInt(cget('-height') $)}
	 pos<-Pos
	 {ForAll [self.tag self.tag2 self.ttag self.rtag self.btag]
	  proc{$ T} T={New Tk.canvasTag tkInit(parent:Parent)} end}
	 case Text==nil then skip else
	    {self.parent tk(crea text
			    Pos 0
			    text:Text
			    tags:q(self.tag self.ttag self.btag)
			    anchor:nw
			    fill:black
			    justify:left)}
	 end
	 case Img==nil then skip else
	    local X1 Y1 X2 Y2
	       L H
	       Tmp in
	       case Text==nil then skip else
		  [X1 Y1 X2 Y2]={self getSize($)}
	       end
	       case {IsAtom Img} then
		  self.imgcolor={New Tk.image tkInit(type:photo
						     url:Img
						     palette:'6/6/5')}
		  self.imggray={New Tk.image tkInit(type:photo
						    url:Img
						    palette:15)}
	       else
		  self.imgcolor={New Tk.image tkInit(type:photo
						     data:Img
						     palette:'6/6/5')}
		  self.imggray={New Tk.image tkInit(type:photo
						    data:Img
						    palette:15)}
	       end
	       self.itag={New Tk.canvasTag tkInit(parent:Parent)}
	       {self.parent tk(crea image
			       ~100 0
			       image:self.imggray
			       anchor:nw
			       tags:q(self.itag self.tag self.btag))}
	       [_ _ L H]={Map {self.parent tkReturnList(bbox(self.itag) $)} StringToInt}
	       case Text==nil then
		  {self.itag tk(move @pos+100 5)}
	       else
		  {self.itag tk(move (((X2-X1)-L) div 2)+@pos+100 5)}
		  {self.ttag tk(move 0 H+4)}
	       end
	       local X Y in
		  self.itag2={New Tk.canvasTag tkInit(parent:Parent)}
		  [X Y _ _]={Map {self.parent tkReturnList(bbox(self.itag) $)} StringToInt}
		  {self.parent tk(crea image
				  X Y
				  image:self.imgcolor
				  anchor:nw
				  tags:q(self.itag2 self.tag self.btag))}
		  {self.parent tk('raise' self.itag self.itag2)}
	       end
	    end
	 end
	 local X1 Y1 X2 Y2 in
	    [X1 Y1 X2 Y2]={self getSize($)}
	    {self.parent tk(crea rect
			    X1-2 2
			    X2+3 Height
			    fill:gray
			    outline:gray
			    tags:q(self.rtag self.tag))}
	    {self.ttag tk(move 0 (Height-(Y2-Y1-1)) div 2)}
	    {self.parent tk(lower self.rtag)}
	 end
	 mode<-0
      end

      meth getSize(?L)
	 try
	    L={Map {self.parent tkReturnList(bbox(self.tag) $)} StringToInt}
	 catch error(...) then
	    case {IsFree L} then L=[~100 ~100 ~99 ~99] else skip end
	 end
      end

      meth setactive(St)
	 case {IsDet self.text} then
	    case self.text==nil then skip else
	       case St then
		  {self.ttag tk(itemconfigure fill:black)}
	       else
		  {self.ttag tk(itemconfigure fill:lightgray)}
	       end
	    end
	 else skip end
      end
      
      meth drawselected
	 case @mode==0 then
	    X1 Y1 X2 Y2 in
	    {self.btag tk(move 1 1)}
	    {self.tag2 tk(delete)}
	    [X1 Y1 X2 Y2]=StdButton,getSize($)
	    {self.parent tk(crea line
			    X1+1 Y2-1
			    X1+1 Y1+1
			    X2-1 Y1+1
			    fill:black
			    width:2
			    tags:self.tag2)}
	    {self.parent tk(crea line
			    X2-1 Y1+1
			    X2-1 Y2-1
			    X1+1 Y2-1
			    fill:white
			    width:2
			    tags:self.tag2)}
	    {self.ttag tk(itemconfigure fill:blue)}
	    mode<-1
	 else skip end
      end

      meth upditag(Img)
	 case {IsDet self.itag} then
	    case Img==self.imggray then
	       {self.parent tk('raise' self.itag self.itag2)}
	    else
	       {self.parent tk('raise' self.itag2 self.itag)}
	    end
%	    {self.itag tk(itemconfigure image:Img)}
%	    local X Y Tag in
%	       [X Y _ _]={Map {self.parent tkReturnList(bbox(self.itag) $)} StringToInt}
%	       Tag={New Tk.canvasTag tkInit(parent:self.parent)}
%	       {self.parent tk(crea image
%			       X Y
%			       image:Img
%			       anchor:nw
%			       tags:q(Tag self.tag self.btag))}
%	       {self.itag tk(delete)}
%	       {self.parent tk(addtag self.itag withtag Tag)}
%	    end
	 else skip end
      end
      
      meth drawactive
	 X1 Y1 X2 Y2 in
	 case @mode==1 then
	    {self.btag tk(move ~1 ~1)}
	 else skip end
	 [X1 Y1 X2 Y2]=StdButton,getSize($)
	 {self.parent tk(crea line
			 X1+1 Y2-1
			 X1+1 Y1+1
			 X2-1 Y1+1
			 fill:white
			 width:2
			 tags:self.tag2)}
	 {self.parent tk(crea line
			 X2-1 Y1+1
			 X2-1 Y2-1
			 X1+1 Y2-1
			 fill:black
			 width:2
			 tags:self.tag2)}
	 {self.ttag tk(itemconfigure fill:blue)}
	 {self upditag(self.imgcolor)}
	 mode<-0
      end

      meth drawpassive
	 case @mode==1 then
	    {self.btag tk(move ~1 ~1)}
	 else skip end
	 {self.tag2 tk(delete)}
	 {self.ttag tk(itemconfigure fill:black)}
	 {self upditag(self.imggray)}
	 mode<-0
      end

      meth drawtooltip
	 case {IsDet self.tooltip} then
	    case self.tooltip==nil then skip else
	       M X Y X1 Y1 in
	       [X1 _ _ Y1]={self getSize($)}
	       X={Tk.returnInt winfo(rootx self.parent)}
	       Y={Tk.returnInt winfo(rooty self.parent)}
	       toolwin<-{New Tk.toplevel tkInit(withdraw:true bg:black width:1 height:1
						visual:{Tk.return winfo(visual self.parent)}
						colormap:self.parent)}
	       M={New Tk.message tkInit(parent:@toolwin text:self.tooltip
					bg:'#e4e2bc' aspect:800
					font:'helvetica 8')}
	       {Tk.batch [wm(overrideredirect @toolwin true)
			  wm(geometry @toolwin '+'#{IntToString (X1+X+2)}#'+'#{IntToString (Y1+Y+2)})
			  pack(M padx:1 pady:1)
			  wm(deiconify @toolwin)]}
	    end
	 else skip end
      end

      meth removetooltip
	 case {IsObject @toolwin} then
	    {@toolwin tkClose}
	    toolwin<-nil
	 else skip end
      end
   
      meth action
	 skip
      end

      meth getState(B)
	 B='stateless'
      end

      meth setState(B)
	 skip
      end
   
      meth move(X)
	 {self.tag tk(move X 0)}
	 pos<-@pos+X
      end

      meth kill
	 {self.tag tk(delete)}
      end
      
   end

   class CmdButton
   
      from StdButton

      feat action port
      
      meth init(Parent Pos Text Img ToolTip Action Port)
	 StdButton,init(Parent Pos Text Img ToolTip)
	 self.action=Action
	 self.port=Port
      end
      
      meth action
	 {Send self.port r(action:self.action)}
      end

   end

   class Space

      from StdButton

      meth init(Parent Pos)
	 Height in
	 self.parent=Parent
	 self.tooltip=nil
	 Height={self.parent tkReturnInt(cget('-height') $)}
	 pos<-Pos
	 self.tag={New Tk.canvasTag tkInit(parent:self.parent)}
	 {self.parent tk(crea rect
			 Pos-3 0
			 Pos+3 Height
			 fill:gray
			 outline:gray
			 tags:self.tag)}
      end
      
      meth drawselected
	 skip
      end

      meth drawactive
	 skip
      end

      meth drawpassive
	 skip
      end
   
   end

   class Separator

      from Space

      meth init(Parent Pos)
	 Height in
	 Space,init(Parent Pos)
	 Height={self.parent tkReturnInt(cget('-height') $)}
	 {self.parent tk(crea line
			 Pos-1 0
			 Pos-1 Height
			 fill:white
			 width:1
			 tags:self.tag)}
	 {self.parent tk(crea line
			 Pos 0
			 Pos Height
			 fill:c(127 127 127)
			 width:1
			 tags:self.tag)}
      end
   end

   class CheckButton
   
      from StdButton

      attr state

      feat stag action port
      
      meth init(Parent Pos Text State Img ToolTip Action Port)
	 StdButton,init(Parent Pos Text Img ToolTip)
	 state<-State
	 self.stag={New Tk.canvasTag tkInit(parent:self.parent)}
	 self.action=Action
	 self.port=Port
	 case @state then
	    {self showon}
	 else skip end
      end

      meth showon
	 X1 Y1 X2 Y2 in
	 {self.parent tk(itemconfigure self.rtag outline:gray fill:'#808080'
%			 stipple:'gray25'
			)}
	 {self.btag tk(move 1 1)}
	 [X1 Y1 X2 Y2]={self getSize($)}
	 {self.parent tk(crea line
			 X1+1 Y2-1
			 X1+1 Y1+1
			 X2-1 Y1+1
			 fill:black
			 tags:self.stag)}
	 {self.parent tk(crea line
			 X2-1 Y1+1
			 X2-1 Y2-1
			 X1+1 Y2-1
			 fill:white
			 tags:self.stag)}
      end

      meth showoff
	 {self.parent tk(itemconfigure self.rtag fill:gray outline:gray
			 stipple:'')}
	 {self.btag tk(move ~1 ~1)}
	 {self.stag tk(delete)}
      end

      meth move(X)
	 StdButton,move(X)
	 {self.stag tk(move X 0)}
      end

      meth kill
	 StdButton,kill
	 {self.stag tk(delete)}
      end
      
      meth action
	 state<-(@state==false)
	 case @state then
	    {self showon}
	 else
	    {self showoff}
	 end
	 {Send self.port r(action:self.action param:{self getState($)})}
      end

      meth getState(?State)
	 State=@state
      end

      meth setState(State)
	 case State==@state then skip else
	    case @state then
	       {self showoff}
	    else
	       {self showon}
	    end
	    state<-State
	 end
      end

   end

   Radios={NewDictionary}

   class RadioButton

      from CheckButton

      feat ref

      meth init(Parent Pos Text Ref State Img ToolTip Action Port)
	 CheckButton,init(Parent Pos Text State Img ToolTip Action Port)
	 self.ref=Ref
	 case {Dictionary.member Radios Ref} then
	    {Dictionary.put Radios Ref self|{Dictionary.get Radios Ref}}
	 else
	    {Dictionary.put Radios Ref self|nil}
	 end
	 state<-false
	 {self setState(State)}
      end

      meth action
	 {self setState(true)}
	 {Send self.port r(action:self.action)}
      end
   
      meth setState(State)
	 case State==@state then skip else
	    case @state then
	       {self showoff}
	    else
	       {ForAll {Dictionary.get Radios self.ref}
		proc{$ P}
		   {P setState(false)}
		end}
	       {self showon}
	    end
	    state<-State
	 end
      end

      meth kill
	 CheckButton,kill
	 {Dictionary.remove Radios self.ref}
      end
      
   end

   class ComboList

      from StdButton

      feat width listx listy action port label binder
	 
      attr current list showfirst
      
      meth init(Parent Pos ToolTip Width ListW
		ListH Liste Default ShowFirst Action Port
		Binder)
	 Height in
	 self.parent=Parent
	 self.tooltip=ToolTip
	 self.binder=Binder
	 toolwin<-nil
	 Height={self.parent tkReturnInt(cget('-height') $)}
	 pos<-Pos
	 mode<-0
	 self.width=Width
	 self.listx=ListW
	 self.listy=ListH
	 list<-Liste
	 current<-Default
	 showfirst<-ShowFirst
	 self.action=Action
	 self.port=Port
	 {ForAll [self.tag self.tag2 self.ttag self.rtag self.btag]
	  proc{$ T} T={New Tk.canvasTag tkInit(parent:Parent)} end}
	 self.label={New Tk.label tkInit(parent:self.parent
					 anchor:nw
					 justify:left
					 background:'#E0E0E0'
					 borderwidth:1
					 foreground:black
					 text:{List.nth Liste Default})}
	 {Tk.send place(self.label x:Pos y:3 width:Width anchor:nw
			bordermode:ignore)}
	 {self.parent tk(crea rect
			 Pos-2 2
			 Pos+Width+15 Height
			 fill:'#E0E0E0'
			 outline:black
			 tags:q(self.rtag self.tag))}
	 {self.parent tk(crea poly
			 Pos+Width+6 Height-6
			 Pos+Width+1 6
			 Pos+Width+11 6
			 fill:gray
			 tags:q(self.tag self.btag))}			 
	 {self.parent tk(crea line
			 Pos+Width+6 Height-6
			 Pos+Width+1 6
			 Pos+Width+11 6
			 fill:white
			 tags:q(self.tag self.btag))}
	 {self.parent tk(crea line
			 Pos+Width+11 6
			 Pos+Width+6 Height-6
			 fill:black
			 tags:q(self.btag self.tag))}
	 {self.label tkBind(event:'<Motion>'
			    args:[int(x) int(y)]
			    action:proc{$ X Y}
				      {Binder mousemove(X+@pos Y+3)}
				   end)}
	 {self.label tkBind(event:'<1>'
			    action:Binder#clickdown)}
	 {self.label tkBind(event:'<ButtonRelease-1>'
			    action:Binder#clickup)}
      end

      meth move(X)
	 StdButton,move(X)
	 {Tk.send place(self.label x:@pos)}
      end

      meth drawselected
	 case @mode==0 then
	    {Tk.send place(self.label x:@pos+1 y:4)}
	 else skip end
	 StdButton,drawselected
      end

      meth drawactive
	 case @mode==1 then
	    {Tk.send place(self.label x:@pos y:3)}
	 else skip end
	 StdButton,drawactive
      end

      meth drawpassive
	 case @mode==1 then
	    {Tk.send place(self.label x:@pos y:3)}
	 else skip end
	 StdButton,drawpassive
      end

      meth action
	 T L S X Y X1 Y1 in
	 [X1 _ _ Y1]={self getSize($)}
	 X={Tk.returnInt winfo(rootx self.parent)}
	 Y={Tk.returnInt winfo(rooty self.parent)}
	 T={New Tk.toplevel tkInit(withdraw:true bg:black width:1 height:1
				   visual:{Tk.return winfo(visual self.parent)}
				   colormap:self.parent)}
	 L={New Tk.listbox tkInit(parent:T borderwidth:1 width:self.listx
				  background:white
				  height:self.listy)}
	 S={New Tk.scrollbar tkInit(parent:T borderwidth:1 orient:vert
				    width:10)}
	 {Tk.batch [wm(overrideredirect T true)
		    wm(geometry T '+'#{IntToString (X1+X-1)}#'+'#{IntToString (Y1+Y)})
		    grid(L column:0 row:0 sticky:nesw)
		    grid(S column:1 row:0 sticky:ns)
		    wm(deiconify T)]}
	 {Tk.addYScrollbar L S}
	 {self.label tk(configure background:white)}
	 {self.rtag tk(itemconfigure fill:white)}
	 {Tk.send grab(set T)}
	 {List.forAllInd @list
	  proc{$ I O}
	     case @showfirst orelse I\=1 then
		{L tk(insert 'end' O)}
	     else skip end
	  end}
	 local
	    St
	    P={NewPort St}
	    End
	    proc {Loop S}
	       case S of X|Xs then
		  case X
		  of 'liste' then
		     A B in
		     A={L tkReturnListInt(curselection $)}
		     B={List.last A}+case @showfirst then 0 else 1 end
		     {Tk.send grab(release T)}
		     {self setState(r(index:B+1))}
		     {Send self.port r(action:self.action param:@current)}
		     {T tkClose}
		     End=unit
		  [] 'exit' then
		     {Tk.send grab(release T)}
		     {T tkClose}
		     End=unit
		  [] 'scroll' then
		     case Xs of Y|Ys then
			{Loop Ys}
		     end
		  end
	       end
	    end
	 in
	    {L tkBind(event:'<ButtonRelease-1>'
		      action:P#'liste')}
	    {S tkBind(event:'<ButtonRelease-1>'
		      action:P#'scroll')}
	    {T tkBind(event:'<ButtonRelease-1>'
		      action:P#'exit')}
	    {self.binder mouseleave(0 0)}
	    {self drawselected}
	    thread
	       {Loop St}
	    end
	    {Wait End}
	    {self.label tk(configure background:'#E0E0E0')}
	    {self.rtag tk(itemconfigure fill:'#E0E0E0')}
	    {self drawpassive}
	 end
      end

      meth setState(St)
	 case {HasFeature St list} then
	    list<-St.list
	    current<-1
	    {self.label tk(configure text:{List.nth @list @current})}
	 else skip end
	 case {HasFeature St index} then
	    current<-St.index
	    {self.label tk(configure text:{List.nth @list @current})}
	 else skip end
	 case {HasFeature St showfirst} then
	    showfirst<-St.showfirst
	 else skip end
      end

      meth getState(?St)
	 St=@current
      end

      meth setactive(St)
	 case St then
	    {self.label tk(configure foreground:black)}
	 else
	    {self.label tk(configure foreground:gray)}
	 end
      end

      meth kill
	 StdButton,kill
	 {Tk.send place(forget self.label)}
      end
      
   end
in

   class ToolBar

      attr
	 height width blist curbutton mode thid showntip activebuttons

      feat
	 parent canvas port featdict

      prop locking
      
      meth init(parent:Parent
		height:Height <= 0)
	 S
	 proc {Server L}
	    case L of X|Xs then
	       case X=='stopserver' then
		  skip
	       else
		  case X.action of A#B then
		     C in
		     case {HasFeature X param} then
			C={AdjoinAt B {Record.width B}+1 X.param}
		     else
			C=B
		     end
		     case {IsPort A} then
			{Send A C}
		     else
			{A C}
		     end
		  else
		     case {HasFeature X param} then
			{X.action X.param}
		     else
			{X.action}
		     end
		  end
		  {Server Xs}
	       end
	    else skip end
	 end
	 Out In
      in
	 In={NewPort Out}
	 self.parent=Parent
	 height<-Height
	 blist<-nil
	 activebuttons<-nil
	 self.canvas={New Tk.canvas tkInit(parent:Parent width:1 height:Height bg:gray
					   highlightthickness:0)}
	 {Tk.send pack(self.canvas anchor:nw side:left)}
	 curbutton<-nil
	 {self.canvas tkBind(event:"<Enter>"
			     args:[int(x) int(y)]
			     action:In#mousemove)}
	 {self.canvas tkBind(event:"<Leave>"
			     args:[int(x) int(y)]
			     action:In#mouseleave)}
	 {self.canvas tkBind(event:"<Motion>"
			     args:[int(x) int(y)]
			     action:In#mousemove)}
	 {self.canvas tkBind(event:"<1>"
			     action:In#clickdown)}
	 {self.canvas tkBind(event:"<ButtonRelease-1>"
			     action:In#clickup)}
	 local
	    proc{MouseLoop L}
	       B in
	       case L of X|Y then
		  case {Label X}==mousemove then
		     case {IsDet Y} then
			case Y of Z|W then
			   case {Label Z}==mousemove then
			      B=unit
			   else skip end
			else skip end
		     else skip end
		  else skip end
		  case {IsFree B} then
		     {self X}
		  else skip end
		  {MouseLoop Y}
	       end
	    end
	 in
	    thread
	       {MouseLoop Out}
	    end
	 end
	 mode<-0
	 thid<-nil
	 showntip<-nil
	 self.featdict={NewDictionary}
	 self.port={NewPort S}
	 thread
	    {Server S}
	 end
      end

      meth getbutton(X Y ?B)
	 B1 in
	 {ForAll @blist
	  proc{$ But}
	     X1 Y1 X2 Y2 in
	     [X1 Y1 X2 Y2]={But getSize($)}
	     case X>=X1 andthen X=<X2 andthen
		Y>=Y1 andthen Y=<Y2 andthen {IsFree B1} then
		B1=But
	     else skip end
	  end}
	 case {IsFree B1} then B=nil else
	    case {Member B1 @activebuttons} then
	       B=B1
	    else
	       B=nil
	    end
	 end
      end
   
      meth mousemove(X Y)
	 lock
	    N in
	    case @thid==nil then
	       skip
	    else
	       try {Thread.terminate @thid}
	       catch error(...) then skip
	       end
	    end
	    {self getbutton(X Y N)}
	    case {IsObject @showntip} then
	       case N==@showntip then skip else
		  {@showntip removetooltip}
		  showntip<-N
		  case {IsObject @showntip} then
		     {@showntip drawtooltip}
		  else skip end
	       end
	    else
	 % start the timer
	       local T in
		  thread
		     {Thread.this T}
		     {Delay 1000}
		     showntip<-N
		     case {IsObject @showntip} then
			{@showntip drawtooltip}
		     else skip end
		     thid<-nil
		  end
		  {Wait T}
		  thid<-T
	       end
	    end
	    case N==@curbutton then
	       skip
	    else
	       case @curbutton==nil then
		  skip
	       else
		  {@curbutton drawpassive}
	       end
	       case N==nil then skip else
		  case @mode==0 then
		     {N drawactive}
		  else
		     {N drawselected}
		  end
	       end
	       curbutton<-N
	    end
	 end
      end
   
      meth mouseleave(X Y)
	 lock
	    case @curbutton==nil then skip else
	       {@curbutton drawpassive}
	    end
	    curbutton<-nil
	    case @thid==nil then skip else
	       try {Thread.terminate @thid}
	       catch error(...) then skip
	       end
	    end
	    case {IsObject @showntip} then
	       {@showntip removetooltip}
	       showntip<-nil
	    else skip end
	 end
      end

      meth clickdown
	 lock
	    mode<-1
	    case @curbutton==nil then skip else
	       {@curbutton drawselected}
	    end
	 end
      end

      meth clickup
	 lock
	    mode<-0
	    case @curbutton==nil then skip else
	       {@curbutton action}
	       case @curbutton==nil then skip else
		  {@curbutton drawactive}
	       end
	    end
	 end
      end
   
      meth insertButton(pos:Pos   <=NoArgs
			...) = Params
	 lock
	    P X
	 in
	    case Pos==NoArgs then
	       P={Length @blist}+1
	    else
	       P=Pos
	    end
	    case P==1 then
	       X=5
	    else
	       T in
	       [_ _ T _]={{List.nth @blist P-1} getSize($)}
	       X=T+3
	    end
	    local This Prms in
	       local Tmp={NewCell Params.1} in
		  {ForAll [bitmap#nil text#nil tooltips#nil state#false
			   action#proc{$} skip end default#1
			   width#150 listw#10 listh#5
			   active#true showfirst#true]
		   proc{$ F}
		      case F of A#B then
			 case {HasFeature Params.1 A} then skip else
			    {Assign Tmp {AdjoinAt {Access Tmp} A B}}
			 end
		      end
		   end}
		  Prms={Access Tmp}
	       end
	       case {Label Prms}
	       of command then
		  This={New CmdButton init(self.canvas X
					   Prms.text
					   Prms.bitmap
					   Prms.tooltips
					   Prms.action self.port)}
	       [] check then
		  This={New CheckButton init(self.canvas X
					     Prms.text
					     Prms.state
					     Prms.bitmap
					     Prms.tooltips
					     Prms.action self.port)}
	       [] radio then
		  This={New RadioButton init(self.canvas X
					     Prms.text
					     Prms.ref
					     Prms.state
					     Prms.bitmap
					     Prms.tooltips
					     Prms.action self.port)}
	       [] list then
		  This={New ComboList init(self.canvas X
					   Prms.tooltips
					   Prms.width
					   Prms.listw
					   Prms.listh
					   Prms.list
					   Prms.default
					   Prms.showfirst
					   Prms.action self.port self)}	    
	       [] separator then
		  This={New Separator init(self.canvas X)}
	       [] space then
		  This={New Space init(self.canvas X)}
	       else skip end
	       case {IsDet This} then
		  case {HasFeature Params.1 'feature'} then
		     {Dictionary.put self.featdict Params.1.feature This}
		  else skip end
		  {This setactive(Prms.active)}
		  case Prms.active then activebuttons<-This|@activebuttons else skip end
		  Pos={NewCell 0}
		  T in [_ _ T _]={This getSize($)}
		  {Assign Pos T}
		  {ForAll {List.drop @blist P-1}
		   proc{$ But}
		      T2 T3 in
		      [T2 _ _ _]={But getSize($)}
		      {But move({Access Pos}-T2-1)}
		      [_ _ T3 _]={But getSize($)}
		      {Assign Pos T3}
		   end}
		  blist<-{Append {Append {List.take @blist P-1} [This]} {List.drop @blist P-1}}
		  local L T in
		     {{List.last @blist} getSize(L)}
		     [_ _ T _]=L
		     {self.canvas tk(configure width:T+1)}
		  end
	       else skip end
	    end
	 end
      end

      meth deleteButton(Button)
	 lock
	    This
	    Active={NewCell false}
	    L X1 X2
	 in
	    This={self getButtonRef(Button $)}
	    [X1 _ X2 _]={This getSize($)}
	    {This kill}
	    case {Member This @activebuttons} then
	       activebuttons<-{List.subtract @activebuttons This}
	    else skip end
	    L=~(X2-X1)
	    {ForAll @blist
	     proc{$ O}
		case O==This then
		   {Assign Active true}
		else
		   case {Access Active} then
		      {O move(L)}
		   else skip
		   end
		end
	     end}
	    blist<-{List.subtract @blist This}
	    local L T in
	       {{List.last @blist} getSize(L)}
	       [_ _ T _]=L
	       {self.canvas tk(configure width:T+1)}
	    end
	 end
      end

      meth getButtonRef(Button ?Ref)
	 case {IsInt Button} then
	    Ref={List.nth @blist Button}
	 else
	    Ref={Dictionary.get self.featdict Button}
	 end
      end
      
      meth setState(button:Button
		    ...)=Params
	 lock
	    This in
	    This={self getButtonRef(Button $)}
	    case {HasFeature Params active} then
	       case Params.active then
		  case {Member This @activebuttons} then skip else
		     activebuttons<-This|@activebuttons
		     {This setactive(true)}
		  end
	       else
		  activebuttons<-{List.subtract @activebuttons This}
		  {This setactive(false)}
	       end
	    else skip end
	    case {HasFeature Params state} then
	       {This setState(Params.state)}
	    else skip end
	 end
      end

      meth getState(button:Button ?Out)
	 lock
	    This in
	    This={self getButtonRef(Button $)}
	    Out=button(active:{Member This @activebuttons}
		       state:{This getState($)})
	 end
      end
      
      meth addButtons(List)
	 lock
	    {ForAll List proc{$ B} {self insertButton(B)} end}
	 end
      end

      meth deleteButtons(List)
	 lock
	    {ForAll List proc{$ B} {self deleteButton(B)} end}
	 end
      end
      
   end
end


%local T F TB in
%   T={New Tk.toplevel tkInit(width:500 height:300)}
%   F={New Tk.frame tkInit(parent:T)}
%   {Tk.send pack(F side:left anchor:nw)}
%   TB={New ToolBar init(parent:F height:25)}
%   {TB addButtons([command(%text:'Open'
%			   action:proc{$} {Show 'Open'} end
%			   bitmap:'gifs/mini-folder.gif'
%			   tooltips:'Open a file'
%			   feature:open
%			   active:false
%			  )
%		   command(%text:'Save'
%			   action:proc{$}
%				     skip
%				  end
%			   bitmap:'gifs/mini-diskette.gif'
%			   tooltips:'Save the file'
%			   feature:save
%			  )
%		   separator
%		   check(%text:'Insert'
%			 action:proc{$ S}
%				   case S==true then
%				      {TB setState(button:liste
%						   active:true)}
%				   else
%				      {TB setState(button:liste
%						   active:false)}
%				   end
%				end
%			 state:true
%			 bitmap:'gifs/mini-edit.gif'
%			 tooltips:'Switch insertion mode')
%		   separator
%		   radio(%text:'Lower'
%			 ref:justify
%			 state:true
%			 action:proc{$} {TB setState(button:open active:false)} end
%			 bitmap:'gifs/mini-lower.gif'
%			 tooltips:'Auto lower')
%		   space
%		   radio(%text:'Raise'
%			 ref:justify
%			 action:proc{$} {TB setState(button:open active:true)} end
%			 bitmap:'gifs/mini-raise.gif'
%			 tooltips:'Auto raise')
%		   separator
%		   list(list:['Choice 1' 'Choice 2' 'Choice 3']
%			width:100	   
%			listw:20
%			listh:5
%			default:1
%			feature:liste
%			tooltips:'Pick a choice'
%			action:proc{$ I} {Show I} end)
%		   space
%		   list(list:['Choice 1' 'Choice 2' 'Choice 3'
%			     'very long choice de la mort' '1' '2' '3' '4' '5' '6']
%			width:100	   
%			listw:20
%			listh:5
%			default:1
%			tooltips:'Pick a choice'
%			action:proc{$ I} {Show I} end)
%		   separator
%		  ])}
%   {TB setState(button:liste state:r(index:3))}
%   {TB insertButton(pos:1 command(%text:'New'
%				  action:proc{$} {Show 'New'} end
%				  bitmap:'gifs/mini-book1.gif'
%				  tooltips:'Create a new file'
%				  feature:new
%				 ))}
%   {TB deleteButton(liste)}
%end
