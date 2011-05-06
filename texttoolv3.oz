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


class TextObj

   from StandardObj
   
   feat dc actions client tag fname tagmark

   attr x y c1 c2 map shown blinkthread order tagcol black text
      width font height just hyperlink showh

   meth getstate(?S)
      local X1 Y1 X2 Y2 in
	 TextObj,getsize(X1 Y1 X2 Y2)
	 S=tree(type:text
		x1:X1 y1:Y1
		x2:X2 y2:Y2
		c1:@c1 c2:@c2
		id:@map
		text:TextObj,getText(0 TextObj,length($) $)
		hyperlink:@hyperlink
		width:1.0
		order:@order)
      end
   end

   meth gettype(?T)
      T=text
   end

   meth fontToName
      Scale={self.client getscale($)} in
      {self.fname tk(configure
		     family:@font.fam
		     size:{FloatToInt {Float.floor {IntToFloat @font.size}*Scale}}
		     weight:case @font.bold then "bold" else "normal" end
		     slant:case @font.italic then "italic" else "roman" end
		     underline:(@font.underline orelse @showh))}
   end
   
   meth createtk
      Scale={self.client getscale($)} in
      tagcol<-nil
      showh<-false
      self.tag={New Tk.canvasTag tkInit(parent:self.dc)}
      self.tagmark={New Tk.canvasTag tkInit(parent:self.dc)}
      {self.actions bindtag(self.tag self)}
      self.fname={New Tk.font tkInit}
      font<-r(fam:'Times' size:10 bold:false underline:false italic:false)
      TextObj,fontToName
      {self.dc tk(crea text
		  @x*Scale @y*Scale
		  justify:left
		  anchor:nw
		  text:@text
		  width:@width*Scale
		  font:self.fname
		  fill:@c1
		  tags:self.tag)}
   end
   
   meth initstate(DC S ACTIONS CLIENT)
      self.client=CLIENT
      self.dc=DC
      self.actions=ACTIONS
      blinkthread<-nil
      x<-S.text.x
      y<-S.text.y
      height<-S.text.height
      width<-S.text.width
      just<-left
      text<-''
      c1<-S.c1
      c2<-S.c2
      map<-S.id
      hyperlink<-S.hyperlink
      black<-black
      shown<-true
      order<-{self.client getlast($)}+1
      {self createtk}
      {self setstate(S)}
   end
   
   meth init(DC X Y Just C1 C2 ACTIONS CLIENT)
      self.client=CLIENT
      self.dc=DC
      self.actions=ACTIONS
      hyperlink<-""
      blinkthread<-nil
      x<-X
      y<-Y
      c1<-C1
      c2<-C2
      just<-Just
      text<-''
      width<-0.0
      map<-{NewName $}
      black<-black
      shown<-true
      order<-{self.client getlast($)}+1
      {self createtk}
      {self setJustify(0 0 Just)}
   end

   meth bindtag(T)
      {self.actions bindtag(self.tag T)}
   end

   meth resetbind
      {self.actions bindtag(self.tag self)}
   end
   
   meth getfulltag(?T)
      T=self.tag
   end

   meth markhyperlink(B)
      case @showh==B then skip
      elsecase @hyperlink=="" andthen B==true then skip else
	 showh<-B
	 {self redraw}
      end
   end

   meth drawtag(COL)
      Scale={self.client getscale($)} in
      case @tagcol
      of nil then
	 skip
      else
	 {self.tagmark tk(delete)}
      end
      case COL==nil then skip else
	 {self.dc tk(crea rect
		     @x*Scale-2.0 @y*Scale-2.0
		     @x*Scale+2.0 @y*Scale+2.0
		     fill:COL
		     outline:COL
		     tags:self.tagmark)}
      end
      tagcol<-COL
   end
   
   meth setstate(S)
      map<-S.id
      shown<-true
      case @c1==S.c1 then
	 skip
      else
	 c1<-S.c1
	 {self.dc tk(itemconfigure self.tag fill:case @showh then blue else S.c1 end)}
      end
      case @c2==S.c2 then
	 skip
      else
	 c2<-S.c2
      end
      local SD in
	 SD=TextObj,getText(0 TextObj,length($) $)
	 case S.text.width==SD.width then
	    skip
	 else
	    TextObj,setWidth(S.text.width)
	 end
	 TextObj,setHeight(S.text.height)
	 case S.text.text==SD.text then skip else
	    fun {Loop X Y I}
	       case X of Xr|Xs then
		  case Y of Yr|Ys then
		     case Xr==Yr then
			{Loop Xs Ys I+1}
		     else
			I
		     end
		  else
		     I
		  end
	       else
		  I
	       end
	    end
	    Start End L1 L2
	 in
	    L1={Length S.text.text}
	    L2={Length SD.text}
	    Start={Loop S.text.text SD.text 0}
	    End={Loop {Reverse {List.drop S.text.text Start}} {Reverse {List.drop SD.text Start}} 0}
	    TextObj,dchar(Start L2-End-1)
	    TextObj,insert(Start {List.drop {List.take S.text.text L1-End} Start})
	 end
	 case S.text.font==SD.font then skip else
	    font<-S.text.font
	    TextObj,fontToName
	 end
      end
      x<-S.text.x
      y<-S.text.y
      hyperlink<-S.hyperlink
      TextObj,setJustify(0 0 S.text.justify)
%      case @x==S.text.x andthen @y==S.text.y then skip else
%	 TextObj,move(S.text.x-@x S.text.y-@y)
%      end
   end

   meth changesize(NX1 NY1 NX2 NY2)
      Scale={self.client getscale($)}
      X1 Y1 X2 Y2 in
      % d'abord trier tout cela
      case NX1<NX2 then
	 X1=NX1 X2=NX2
      else
	 X1=NX2 X2=NX1
      end
      case NY1<NY2 then
	 Y1=NY1 Y2=NY2
      else
	 Y1=NY2 Y2=NY1
      end
      case @width==0.0 then % passe d'une largeur nulle a une largeur vraie
	 case @just
	 of left then skip
	 [] right then x<-@x-X2+X1
	 [] center then x<-@x-(X2-X1)/2.0
	 else skip end
      else skip end
      TextObj,setWidth(X2-X1)
      TextObj,setHeight(Y2-Y1)
      x<-X1
      y<-Y1
      TextObj,setJustify(0 0 @just)
%      case @just
%      of left then {self.dc tk(coords self.tag X1*Scale Y1*Scale)}
%      [] center then {self.dc tk(coords self.tag (X1+@width/2.0)*Scale Y1*Scale)}
%      [] right then{self.dc tk(coords self.tag (X1+@width)*Scale Y1*Scale)}
%      else {self.dc tk(coords self.tag X1*Scale Y1*Scale)}
%      end
      {self movetag}
   end

   meth transform(W)
      case W==rrotate orelse W==lrotate then
	 % seules ces transformations demandent un changement
	 X Y in
	 X=@x+@width/2.0-@height/2.0
	 Y=@y+@height/2.0-@width/2.0
	 {self changesize(X Y X+@height Y+@width)}
      else skip end
   end

   meth getsize(?X1 ?Y1 ?X2 ?Y2)
      case @width==0.0 then
	 TextObj,getbbox(X1 Y1 X2 Y2)
      else
	 NX1 NX2 NY2 in
	 X1=@x
	 X2=X1+@width
	 Y1=@y
	 Y2=Y1+@height
      end   
   end

   meth getbbox(?RX1 ?RY1 ?RX2 ?RY2)
      NX1 NX2 X1 Y1 X2 Y2
      Scale=1.0/{self.client getscale($)} in
      [NX1 Y1 NX2 Y2]={self.dc tkReturnListFloat(bbox(self.tag) $)}
      case @just
      of left then
	 X1=NX1+1.0
	 X2=NX2+1.0
      [] right then
	 X1=NX1-1.0
	 X2=NX2-1.0
      [] center then
	 X1=NX1-0.5
	 X2=NX2-0.5
      end
      RX1=X1*Scale RX2=X2*Scale RY1=Y1*Scale RY2=Y2*Scale
   end
   
   meth setoutlinecolor(C)
      c1<-C
      {self.dc tk(itemconfigure self.tag fill:case @showh then blue else @c1 end)}
   end

   meth setfillcolor(C)
      c2<-C
   end

   meth setwidth(W)
      skip
   end
   
   meth belowtag(?T)
      T=self.tag
   end

   meth toptag(?T)
      T=self.tag
   end

   meth raiseafter(T)
      {self.dc tk('raise' self.tag T)}
   end

   meth lower
      {self.dc tk(lower self.tag)}
   end

   meth lowerbefore(T)
      {self.dc tk(lower self.tag T)}
   end

   meth getorder(?R)
      R=@order
   end

   meth setorder(R)
      order<-R
   end
   
   meth markinvisible
      {self changesize(~100.0 ~100.0 ~10.0 ~10.0)}
      {self settag(none)}
      shown<-false
   end

   meth isvisible(?B)
      B=@shown
   end
   
   meth redraw
      Scale={self.client getscale($)} in
      {self.dc tk(itemconfigure self.tag width:@width*Scale)}
      case @shown then
	 TextObj,fontToName
	 TextObj,setJustify(0 0 @just)
	 TextObj,setColor(0 0 @c1)
	 {self movetag}
      else skip end
   end

   meth kill
      {self.dc tk(delete self.tag)}
      {self.dc tk(dtag self.tag)}
      {self.fname tk(delete)}
      {self settag(none)}
   end

% methodes specifiques
   meth move(X Y)
      Scale={self.client getscale($)} in
      {self.dc tk(move self.tag X*Scale Y*Scale)}
      x<-@x+X
      y<-@y+Y
   end

   meth moveto(X Y)
      TextObj,move(X-@x Y-@y)
   end
   
   meth getText(Start End ?Text)
      Temp in
      Temp={self.dc tkReturn(itemcget(self.tag '-text') $)}
      Text=r(text:{List.drop {List.take Temp End} Start}
	     font:@font
	     width:@width
	     height:@height
	     x:@x
	     y:@y
	     justify:@just)
   end

   meth getFText(Start End ?Text)
      Tmp
      fun {FontOut In}
	 case @font.bold then 'boldon' else 'boldoff' end|case @font.underline then 'underlineon' else 'underlineoff' end|case @font.italic then 'italicon' else 'italicoff' end
      end
   in
      Tmp=TextObj,getText(Start End $)
      Text=color#@c1|justify#@just|{FontOut Tmp.font}|Tmp.text
   end

   meth getprop(Pos ?P)
      P={AdjoinList @font [color#@c1 justify#@just]}
   end
   
   meth length(?L)
      L={self.dc tkReturnInt(index(self.tag 'end') $)}
   end

   meth dchar(Start End)
      {self.dc tk(dchar self.tag Start End)}
   end

   meth focus
      {self.dc tk(focus self.tag)}
   end

   meth icursor(Index)
      {Tk.send focus(self.dc)}
      {self.dc tk(focus self.tag)}
      {self.dc tk(icursor self.tag Index)}
   end

   meth hidecursor
      {Tk.send focus({Tk.return winfo(parent self.dc)})}
      {self.dc tk(focus self.tagmark)}
   end
   
   meth index(Where ?Ind)
      TkWhere
      Scale={self.client getscale($)} in
      case {Label Where}=='at' then
	 case {IsFloat Where.1} then
	    TkWhere="@"#Where.1*Scale#","#Where.2*Scale
	 else
	    TkWhere="@"#{IntToFloat Where.1}*Scale#","#{IntToFloat Where.2}*Scale
	 end
      else
	 TkWhere=Where
      end
      Ind={self.dc tkReturnInt(index(self.tag TkWhere) $)}
   end

   meth coords(Index1 ?RX1 ?RY1 ?RX2 ?RY2)
      SX1 SX2 SY1 SY2 SSX1 SSX2 SSY1 SSY2
      Char Width Height Leng Index
      X1 Y1 X2 Y2
      Scale={self.client getscale($)}
   in
      Index=Index1+1
      TextObj,getbbox(SSX1 SSY1 SSX2 SSY2)
      [SX1 SY1 SX2 SY2]={List.map [SSX1 SSY1 SSX2 SSY2]
			 fun{$ V} V*Scale end}
      local T in TextObj,getText(Index-1 Index T) Char=T.text end
      Width={Tk.returnFloat font(measure self.fname Char)}
      Height={Tk.returnFloat font(metrics self.fname "-linespace")}
      Leng=TextObj,length($)
      local
	 fun{Loop Line}
	    This in
	    TextObj,index('at'(SX1/Scale+1.0 SY1/Scale+1.0+Line*Height/Scale) This)
	    case This<Index then
	       case This<Leng then
		  {Loop Line+1.0}
	       else
		  Line
	       end
	    else
	       Line
	    end
	 end
	 SL SC SC2 Len Len2 Prev Next
      in
	 SL={Loop 1.0} % maintenant SL contient le numero de ligne
	 SC=TextObj,index('at'(SX1/Scale+1.0 SY1/Scale+1.0+(SL-1.0)*Height/Scale) $)
	 SC2=TextObj,index('at'(SX1/Scale+1.0 SY1/Scale+1.0+SL*Height/Scale) $)
	 % maintenant SC contient l'index du caractere
	 Y1=SY1+(SL-1.0)*Height Y2=Y1+Height
	 local T in TextObj,getText(SC Index-1 T) Prev=T.text end
	 local T in TextObj,getText(Index SC2-1 T) Next=T.text end
	 Len={Tk.returnFloat font(measure self.fname Prev)}
	 Len2={Tk.returnFloat font(measure self.fname Next)}
	 case @just
	 of left then X1=Len+SX1
	 [] right then X1=SX2-Len2
	 [] center then X1=((SX2-SX1)-(Len+Len2))/2.0+Len+SX1
	 end
	 X2=X1+Width
      end
      RX1={FloatToInt X1/Scale} RX2={FloatToInt X2/Scale}
      RY1={FloatToInt Y1/Scale} RY2={FloatToInt Y2/Scale}
   end
   
   meth insert(Index String)
      {self.dc tk(insert self.tag Index String)}
   end

   meth selectClear
      {self.dc tk(select clear)}
   end

   meth selectFrom(Index)
      {self.dc tk(select 'from' self.tag Index)}
   end

   meth selectTo(Index)
      {self.dc tk(select 'to' self.tag Index)}
   end

   meth setFont(Start End Font)
      font<-Font
      TextObj,fontToName
   end

   meth setJustify(Start End Justify)
      Scale={self.client getscale($)} in
      case Justify
      of left then
	 {self.dc tk(itemconfigure self.tag anchor:nw justify:left)}
      [] right then
	 {self.dc tk(itemconfigure self.tag anchor:ne justify:right)}
      [] center then
	 {self.dc tk(itemconfigure self.tag anchor:n justify:center)}
      else
	 {self.dc tk(itemconfigure self.tag anchor:nw justify:left)}
      end
      case @width==0 then
	 skip
      else
	 X in
	 case Justify
	 of left then
	    X=@x
	 [] right then
	    X=@x+@width
	 [] center then
	    X=@x+@width/2.0
	 end
	 {self.dc tk(coords self.tag X*Scale @y*Scale)}
      end
      just<-Justify
   end

   meth setColor(Start End Color)
      {self.dc tk(itemconfigure self.tag fill:case @showh then blue else Color end)}
      c1<-Color
   end

   meth setWidth(Width)
      Scale={self.client getscale($)} in
      width<-Width
      {self.dc tk(itemconfigure self.tag width:Width*Scale)}
   end

   meth setHeight(Height)
      height<-Height
   end
   
   meth insertText(Index Liste)
      Pos in
      Pos={NewCell Index}
      {ForAll Liste
       proc{$ C}
	  case C
	  of justify#X then
	     TextObj,setJustify(0 0 X)
	  [] color#X then
	     TextObj,setColor(0 0 X)
	  [] underlineon then
	     TextObj,setFont({AdjoinAt @font underline true})
	  [] underlineoff then
	     TextObj,setFont({AdjoinAt @font underline false})
	  [] boldon then
	     TextObj,setFont({AdjoinAt @font bold true})
	  [] boldoff then
	     TextObj,setFont({AdjoinAt @font bold false})
	  [] italicon then
	     TextObj,setFont({AdjoinAt @font italic true})
	  [] italicoff then
	     TextObj,setFont({AdjoinAt @font italic false})
	  [] newline then
	     TextObj,insert({Access Pos} '\n')
	     {Assign Pos {Access Pos}+1}
	  else
	     case {IsList C} then
		TextObj,insert({Access Pos} C)
		{Assign Pos {Access Pos}+{Length C}}
	     else skip end
	  end
       end}
   end



end

class TextTool

   from StandardTool
   
   feat dc window client actions actport color border seltool iconbar localize
      texttool dialogbox seltag families sizelist iconb
   
   attr sx sy % lors d'un drag, c'est les coordonees d'origine
      state % etat de la modif : 1 c'est creation par click, 2 c'est creation par drag, 3 c'est modif
      dragmode % permet de savoir si l'utilisateur drag ou pas
      editobj % objet en cours d'edition
      currentfont % police de caractere active
      currentfontname
      underline % true=>mode souligne
      curpos % position du curseur
      updtime % permet de ne faire des updates que de temps en temps
      again % idem
      npos % caractere d'ancrage d'une selection de texte
      select % true=>du texte est selectionne
      just % justification en cours
      bold % true=>mode gras
      italic % true=>mode italique
      color % couleur active
      pxlsz % taille de la police de caractere
      ancx ancy % points d'ancrage d'un texte cree par click simple
      
   prop locking
      
   meth drawrect(X1 Y1 X2 Y2 C)
      Scale={self.client getscale($)} in
      {self.seltag tk(delete)}
      {self.dc tk(creat rect
		  X1*Scale Y1*Scale
		  X2*Scale Y2*Scale
		  outline:white
		  width:3
		  tags:self.seltag)}
      {self.dc tk(crea rect
		  X1*Scale Y1*Scale
		  X2*Scale Y2*Scale
		  outline:C
		  tags:self.seltag)}
   end

   meth update
%      Old in
%      Old=updtime<-unit % atomic exchange
%      case {IsDet Old} then % si deja fait
%	 again<-unit % retient qu'on doit le refaire
%      else
%	 % effectue la mis a jour
%	 case @state==3 then
%	    {self.client update(@editobj)}
%	 else
%	    {self.client updatenow(@editobj)}
%	 end
%	 thread
%	    {Delay 2000}
%	    local B={IsDet @again} T1 T2 in
%	       again<-T1
%	       updtime<-T2 %relache
%	       case B then
%		  {self update}
%	       else skip end
%	    end
%	 end
%      end
      case {IsFree @editobj} then skip else
	 case @state==3 then
	    {self.client update(@editobj)}
	 else
	    {self.client updatenow(@editobj)}
	 end
      end
   end
   
   meth release(B)
      case {IsFree @editobj} then skip else
	 case @select then
	    select<-false
	    {@editobj selectClear}
	 else skip end
	 case @state==1 then
	    X1 Y1 X2 Y2 in
	    {@editobj getbbox(X1 Y1 X2 Y2)}
	    {@editobj changesize(X1 Y1 X2 Y2)}
	 else skip end
	 local T in updtime<-T end
	 {self update}
	 {@editobj hidecursor}
	 {self.seltag tk(delete)}
	 case B then 
	    case @state==3 then
	       {self.client releasesellock(@editobj|nil)}
	    else
	       {self.client releaselock(@editobj)}
	    end
	 else skip end
      end
   end

   meth placecursor(Pos)
      L UNDERLINE BOLD ITALIC COLOR FONT JUSTIFY in
      {@editobj icursor(Pos)}
%      L={@editobj getFText(Pos Pos $)}
%      {Show L}
%      {ForAll L
%       proc{$ P}
%	  case P
%	  of 'underlineoff' then UNDERLINE=false
%	  [] 'underlineon' then UNDERLINE=true
%	  [] 'boldoff' then BOLD=false
%	  [] 'boldon' then BOLD=true
%	  [] 'italicoff' then ITALIC=false
%	  [] 'italicon' then ITALIC=true
%	  [] 'color'#X then COLOR=X
%	  [] 'justify'#X then JUSTIFY=X
%	  else skip end
%       end}
%      {ForAll [@underline#UNDERLINE @bold#BOLD @italic#ITALIC @color#COLOR @just#JUSTIFY]
%      proc{$ F}
%	  case F of A#B then
%	     case {IsFree B} then B=A else skip end
%	  end
%       end}
      L={@editobj getprop(Pos $)}
      UNDERLINE=L.underline
      BOLD=L.bold
      ITALIC=L.italic
      COLOR=L.color
      JUSTIFY=L.justify
      case L.fam==@currentfontname then skip else
	 Index in
	 {List.forAllInd self.families
	  proc{$ I N}
	     case {IsDet Index} then skip
	     elsecase N==L.fam then Index=I else skip end
	  end}
	 case {IsDet Index} then % font present
	    {self.iconb setState(button:fontlist
				 state:r(index:Index))}
	    currentfont<-Index
	    currentfontname<-L.fam
	 else
	    {self.iconb setState(button:fontlist
				 state:r(list:{Append self.families [L.fam]}
					 index:{Length self.families}+1))}
	    currentfont<-{Length self.families}+1
	    currentfontname<-L.fam
	 end
      end
      case L.size==@pxlsz then skip else
	 pxlsz<-L.size
	 {self.iconb setState(button:size
			      state:r(list:@pxlsz|self.sizelist
				      index:1))}
      end
      case @underline==UNDERLINE then skip else
	 {self.iconb setState(button:underline state:UNDERLINE)}
	 underline<-UNDERLINE
      end
      case @bold==BOLD then skip else
	 {self.iconb setState(button:bold state:BOLD)}
	 bold<-BOLD
      end
      case @italic==ITALIC then skip else
	 {self.iconb setState(button:italic state:ITALIC)}
	 italic<-ITALIC
      end
      case @just==JUSTIFY then skip else
	 case JUSTIFY
	 of left then
	    {self.iconb setState(button:left state:true)}
	 [] right then
	    {self.iconb setState(button:right state:true)}
	 [] center then
	    {self.iconb setState(button:center state:true)}
%	 [] both then
%	    {self.iconbar setState(button:both state:true)}
	 end
	 just<-JUSTIFY
      end
      case @color==COLOR then skip else
	 color<-COLOR
      end
   end
   
   meth setoutlinecolor(C)
      color<-C
      case {IsFree @editobj} then skip else
	 case @select then
	    Start End in
	    TextTool,getSel(Start End)
	    {@editobj setColor(Start End C)}
	 else
	    {@editobj setColor(0 {@editobj length($)} C)}
	 end
	 TextTool,update
      end
   end

   meth setfillcolor(C)
      skip
   end
   
   meth keypressed(A K)
      lock
	 Cont in
	 case @state==0 then skip else
	    case @select then
	       proc {Del}
		  Start End in
		  TextTool,getSel(Start End)
		  {@editobj dchar(Start End)}
		  {self placecursor(@curpos)}
		  {@editobj selectClear}
	       end
	    in		  
	       case {Member {StringToAtom K}
		     ['BackSpace' 'Delete']} then
		  {Del}
	       elsecase {Member {StringToAtom K}
			 ['Left' 'Right' 'Up' 'Down' 'Home' 'End']} then
		  {@editobj selectClear}
		  Cont=unit
	       else
		  {Del}
		  Cont=unit
	       end
	       select<-false
	    else Cont=unit end
	    case {IsDet Cont} then
	       case {StringToAtom K}
	       of 'BackSpace' then
		  case @curpos>0 then
		     {@editobj dchar(@curpos-1 @curpos-1)}
		     curpos<-@curpos-1
		     {self placecursor(@curpos)}
		     {self update}
		  else skip end
	       [] 'Delete' then
		  case {@editobj length($)}>0 then
		     {@editobj dchar(@curpos @curpos)}
		     {self placecursor(@curpos)}
		     {self update}
		  else skip end
	       [] 'Return' then
		  {@editobj insertText(@curpos newline|nil)}
		  curpos<-@curpos+1
		  {self placecursor(@curpos)}
		  {self update}
	       [] 'Left' then
		  case @curpos>0 then
		     curpos<-@curpos-1
		     {self placecursor(@curpos)}
		  else skip end
	       [] 'Right' then
		  case @curpos<{@editobj length($)} then
		     curpos<-@curpos+1
		     {self placecursor(@curpos)}
		  else skip end	       
	       [] 'Up' then
	       % get old coords
		  X1 Y1 X2 Y2
		  NX1 NX2 NY1 NY2
		  IX1 IX2 IY1 IY2
	       in
		  {@editobj coords(@curpos X1 Y1 X2 Y2)}
		  curpos<-{@editobj index('at'(X1 Y1-2) $)}
		  case @curpos>0 then
		     {@editobj coords(@curpos NX1 NY1 NX2 NY2)}
		     {@editobj coords(@curpos-1 IX1 IY1 IX2 IY2)}
		     case IY1==NY1 andthen {Abs X1-IX1}<{Abs X1-NX1} then
			curpos<-@curpos-1
		     else skip end
		  else skip end
		  {self placecursor(@curpos)}
	       [] 'Down' then
		  X1 Y1 X2 Y2
		  IX1 IX2 IY1 IY2
		  NX1 NX2 NY1 NY2 in
		  {@editobj coords(@curpos X1 Y1 X2 Y2)}
		  curpos<-{@editobj index('at'(X1 Y2+2) $)}
		  case @curpos>0 then
		     {@editobj coords(@curpos NX1 NY1 NX2 NY2)}
		     {@editobj coords(@curpos-1 IX1 IY1 IX2 IY2)}
		     case IY1==NY1 andthen IY1\=Y1 andthen
			{Abs X1-IX1}<{Abs X1-NX1} then
			curpos<-@curpos-1
		     else skip end
		  else skip end
		  {self placecursor(@curpos)}	       
	       [] 'Home' then
		  curpos<-0
		  {self placecursor(@curpos)}	       
	       [] 'End' then
		  curpos<-{@editobj length($)}
		  {self placecursor(@curpos)}
	       [] 'F20' then % cut
		  TextTool,cut
	       [] 'F16' then % copy
		  TextTool,copy
	       [] 'F18' then % paste
		  TextTool,paste
	       else
		  case A\=nil then
		     {@editobj insertText(@curpos A|nil)}
		     curpos<-@curpos+1
		     {self placecursor(@curpos)}
		     {self update}
		  else skip end
	       end
	    else skip end
	 end
      end
   end

   meth getSel(Start End)
      A B in
      A={@editobj index('sel.first' $)}
      B={@editobj index('sel.last' $)}
      case A<B then Start=A End=B else
	 Start=B End=A
      end
%     Len in
%     case @npos<@curpos then
%	 Start=@npos-1
%	 Len=@curpos-@npos+1
%     else
%	 Start=@curpos
%	 Len=@npos-@curpos
%     end
%     End=Start+Len-1
   end
   
   meth setFont
      case @currentfont=<{Length self.families} then
	 currentfontname<-{Nth self.families @currentfont}
      else skip end
      case {IsDet @editobj} then
	 case @select then
	    Start End in
	    TextTool,getSel(Start End)
	    {@editobj setFont(Start End
			      r(fam:@currentfontname
				size:@pxlsz
				bold:@bold
				underline:@underline
				italic:@italic)
			     )}
	 else
	    {@editobj setFont(@curpos @curpos
			      r(fam:@currentfontname
				size:@pxlsz
				bold:@bold
				underline:@underline
				italic:@italic)
			     )}
	 end
      else skip end
   end
   
   meth cclick(X Y) % click
      case {IsDet @editobj} andthen @select then
	 select<-false
	 {@editobj selectClear}
      else skip end
      {self release(true)}
      {self.client startundolog}
      {self.seltag tk(delete)}
      dragmode<-1 % commence un drag
      sx<-X
      sy<-Y
   end

   meth csclick(X Y) % shift-click
      {self cclick(X Y)} % passe la main au click normal
   end

   meth cdclick(X Y)
      skip
   end
   
   meth cmotion(X Y) % deplacement
      case @dragmode
      of 2 then
	 {self drawrect(@sx @sy X Y blue)}
      [] 4 then
	 Pos in
	 Pos={@editobj index('at'({FloatToInt X} {FloatToInt Y}) $)}
	 case Pos==@npos then
	    {@editobj selectClear}
	    select<-false
	    curpos<-Pos
	 else
	    {@editobj selectFrom(@npos)}
	    {@editobj selectTo(Pos)}
	    select<-true
	 end
	 {self placecursor(@curpos)}
      else
	 case ({Abs (@sx-X)}+{Abs (@sy-Y)})>2.0 then
	    dragmode<-2
	    {self drawrect(@sx @sy X Y blue)}
	    skip
	 else skip end
      end
   end

   meth crelease(X Y) % relachement du bouton
      Scale=1.0/{self.client getscale($)} in
      {Tk.send focus(self.dc)}
      case @dragmode
      of 1 then
	 X1 Y1 X2 Y2 in
	 % nouveau texte de largeur et hauteur infinie
	 case {IsFree @editobj} then
	    skip
	 else
	    {@editobj hidecursor}
	    {self.client releaselock(@editobj)}
	 end
	 ancx<-X
	 ancy<-Y
	 editobj<-{New TextObj init(self.dc X Y
				    @just
				    {self.color getoutlinecolor($)}
				    {self.color getfillcolor($)}
				    self.actions self.client)}
	 curpos<-0
	 TextTool,setFont
	 {self placecursor(0)}
	 {self.client addobject(@editobj)}
	 state<-1
      [] 2 then
	 % l'utilisateur a dessine un rectangle ds lequel mettre le texte
	 OX OY X2 Y2 in
	 case {IsFree @editobj} then
	    skip
	 else
	    {@editobj hidecursor}
	    {self.client releaselock(@editobj)}
	 end
	 case X<@sx then OX=X X2=@sx else OX=@sx X2=X end
	 case Y<@sy then OY=Y Y2=@sy else OY=@sy Y2=Y end
	 editobj<-{New TextObj init(self.dc
				    OX OY @just
				    {self.color getoutlinecolor($)}
				    {self.color getfillcolor($)}
				    self.actions self.client)}
	 {@editobj setWidth({Abs @sx-X})}
	 {@editobj setHeight({Abs @sy-Y})}
	 TextTool,setFont
	 {@editobj insertText(@curpos justify#@just|nil)}
	 {self placecursor(0)}
	 curpos<-0
	 {self.client addobject(@editobj)}
	 state<-2
	 {self drawrect(OX-2.0*Scale OY-2.0*Scale X2+2.0*Scale Y+2.0*Scale blue)}
      [] 3 then
	 % edition d'un texte
	 X1 Y1 X2 Y2 B in
	 {self.client getsellock(@editobj|nil)}
	 {self.client startundolog}
	 {self.client addundo(@editobj setstate(@editobj {@editobj getstate($)}))}
	 state<-3
	 {@editobj getsize(X1 Y1 X2 Y2)}
	 case {self.client alllocked($)} then
	    {self drawrect(X1-2.0*Scale Y1-2.0*Scale X2+2.0*Scale Y2+2.0*Scale blue)}
	 else
	    {self drawrect(X1-2.0*Scale Y1-2.0*Scale X2+2.0*Scale Y2+2.0*Scale red)}
	 end
	 curpos<-{@editobj index('at'({FloatToInt X} {FloatToInt Y}) $)}
	 {self placecursor(@curpos)}
      else skip end
      dragmode<-0
   end

   meth oclick(O X Y) % click sur un objet
      Test in
      case {O getstate($)}.type=='text' then % peut-etre veut-on editer cet objet ???
	 case {IsDet @editobj} then
	    case @select then
	       select<-false
	       {@editobj selectClear}
	    else skip end
	    case O==@editobj then %reste sur le meme objet
	       Test=unit
	       dragmode<-4
	       sx<-X
	       sy<-Y
	       curpos<-{@editobj index('at'({FloatToInt X} {FloatToInt Y}) $)}
	       npos<-@curpos % ancre
	       {@editobj selectFrom(@npos)}
	       {self placecursor(@curpos)}	       
	    else skip end
	 else skip end
	 case {IsFree Test} then
	    {self release(true)}
	    sx<-X
	    sy<-Y
	    dragmode<-3
	    editobj<-O
	 else skip end
      else
	 {self cclick(X Y)}
      end
   end

   meth omotion(O X Y)
      {self cmotion(X Y)}
   end

   meth orelease(O X Y)
      {self crelease(X Y)}
   end
   
   meth justundone
      case {IsFree @editobj} then skip else
	 {@editobj hidecursor}
      end
      {self.seltag tk(delete)}
      state<-0
      dragmode<-0
      local T F in
	 updtime<-F
	 editobj<-T
      end
   end

   meth updsel
      case @state==1 orelse {IsFree @editobj} then skip else
	 Scale=1.0/{self.client getscale($)} X1 Y1 X2 Y2 in
	 {@editobj getsize(X1 Y1 X2 Y2)}
	 {self drawrect(X1-2.0*Scale Y1-2.0*Scale X2+2.0*Scale Y2+2.0*Scale blue)}
      end
   end

   meth abort
      case @state==3 then
	 case {IsFree @editobj} then skip else
	    {@editobj hidecursor}
	    case @select then
	       select<-false
	       {@editobj selectClear}
	    else skip end
	 end
	 local T F in
	    updtime<-T
	    editobj<-F
	 end
	 {self.seltag tk(delete)}
	 case @state==0 andthen @dragmode==0 then
	    skip
	 else
	    dragmode<-10
	 end
      else skip end % on s'en fout : creation participe pas aux transactions
   end
   
   meth cut
      skip
   end

   meth copy
      skip
   end

   meth paste
      skip
   end

   meth setsize(Index)
      case Index==1 then skip else
	 case Index==({Length self.sizelist}+1) then
	    proc{Ok}
	       MyVal in
	       {Tk.send grab(release T)}
	       MyVal={E tkReturnInt(get $)}
	       case {IsInt MyVal} andthen MyVal>3 andthen MyVal<101 then
		  pxlsz<-MyVal
		  {T tkClose}
		  {self.iconb setState(button:size
				       state:r(list:@pxlsz|self.sizelist
					       index:1))}
		  TextTool,setFont
		  TextTool,update
	       else
		  _={self.dialogbox message(title:"Error in size selection"
					    text:"\nFont size must be between 4 and 100.\n"
					    bitmap:error
					    buttons:ok)}
	       end
	    end
	    proc{Cancel}
	       {Tk.send grab(release T)}
	       {T tkClose}
	       {self.iconb setState(button:size
				    state:r(index:1))}
	    end
	    T E B1 B2 B3 V in
	    T={New Tk.toplevel tkInit(title:"Choose a size")}
	    E={New Tk.entry tkInit(parent:T)}
	    B1={New Tk.button tkInit(parent:T
				     text:"Ok"
				     action:proc{$} {Ok}
					    end)}
	    B2={New Tk.button tkInit(parent:T
				     text:"Cancel"
				     action:proc{$} {Cancel}
					    end)}
	    {T tkBind(event:"<Return>"
		      action:proc{$} {Ok} end)}
	    {T tkBind(event:"<Escape>"
		      action:proc{$} {Cancel} end)}
	    {Tk.batch [pack(E side:top expand:true fill:x padx:5 pady:5)
		       pack(B1 B2 side:left padx:5 pady:5)
		       focus(E)
		       grab(T)]}
	 else
	    pxlsz<-{Nth self.sizelist Index-1}
	    {self.iconb setState(button:size
				 state:r(list:@pxlsz|self.sizelist
					 index:1))}
	    TextTool,setFont
	    TextTool,update
	 end
      end
   end

   meth setfont(Nu)
      currentfont<-Nu
      TextTool,setFont
      TextTool,update
   end
   
   meth setbold(State)
      bold<-State
      TextTool,setFont
      TextTool,update
   end

   meth setitalic(State)
      italic<-State
      TextTool,setFont
      TextTool,update
   end

   meth setunderline(State)
      underline<-State
      TextTool,setFont
      TextTool,update
   end

   meth setjust(Just)
      just<-Just
      case @state==1 then
	 {@editobj setJustify(0 {@editobj length($)} Just)}
	 case @select then
	    select<-false
	    {@editobj selectClear}
	 else skip end
	 {self placecursor(@curpos)}
	 {self update}
      elsecase @state==2 orelse @state==3 then
	 case @select then
	    Start End in
	    TextTool,getSel(Start End)
	    {@editobj setJustify(Start End Just)}
	    {self placecursor(@curpos)}
	    {self update}
	 else
	    {@editobj setJustify(@curpos @curpos Just)}
	    {self placecursor(@curpos)}
	    {self update}
	 end
      else skip end
   end

   meth select()
      state<-0
      {self.actions setactions(self true true gridded:true)}
      {self.color setactions(self)}
      {self.client setcursor('xterm')}
      {self.client setmousestatus(self.dc "Use mouse to select or drag where to place the text")}
      {self.dc tkBind(event:'<Key>'
		      args:['A' 'K']
		      action:self#keypressed)}
      local T F in
	 updtime<-T
	 editobj<-F
      end
      underline<-false
      bold<-false
      italic<-false
      just<-'left'
      color<-{self.color getoutlinecolor($)}
      select<-false
      {Tk.send pack(self.iconbar side:left)}
   end

   meth deselect(NEXT)
      {Tk.send pack(forget self.iconbar)}
      {self.seltag tk(delete)}
      {self.actions clearactions}
      {self.color clearactions}
      {self.client setcursor('')}
      {self.dc tkBind(event:'<Key>'
		      args:['A']
		      action:proc {$ A} skip end)}
      case {IsFree @editobj} then skip else
	 case NEXT==self.seltool then
	    {self.seltool setautosel(@editobj)}
	    {self release(false)}
	 else
	    {self release(true)}
	 end
      end
      state<-0
   end
   
   meth init(TOOLBAR DC WINDOW CLIENT ACTIONS IMGON IMGOFF X Y COLOR BORDER
	     SELTOOL TEXTICON ICONBAR LOCALIZE DIALOGBOX CLIENTASYNCH)
      self.sizelist=[4 6 8 10 12 14 16 20 24 36 60 72 '...']
      self.dc=DC
      self.localize=LOCALIZE
      self.window=WINDOW
      self.client=CLIENT
      self.actions=ACTIONS
      self.color=COLOR
      self.border=BORDER
      self.seltool=SELTOOL
      self.dialogbox=DIALOGBOX
%      case CLIENT.name=='Ned' then % pour tester si pas ces polices la
%	 self.families=["courier" "helvetica" "times"]
%      else
	 self.families={List.sort {DIALOGBOX getFamilies}
			fun{$ A B}
			   {StringToAtom A}<{StringToAtom B}
			end}
%      end
      state<-0
      dragmode<-0
      self.seltag={New Tk.canvasTag tkInit(parent:self.dc)}
      underline<-false
      bold<-false
      just<-left
      italic<-false
      pxlsz<-10
      select<-false
      currentfont<-1
      currentfontname<-{Nth self.families 1}
      self.iconbar={New Tk.frame tkInit(parent:ICONBAR.2
					bg:gray)}
      self.iconb={New ICONBAR.1 init(parent:self.iconbar height:ICONBAR.3)}
      {self.iconb addButtons([command(bitmap:{self.localize "net-cut.gif"}
				      feature:but1
				      action:self#cut
				      tooltips:'Cut the current selection')
			      command(bitmap:{self.localize "net-copy.gif"}
				      feature:but2
				      action:self#copy
				      tooltips:'Copy the current selection')
			      command(bitmap:{self.localize "net-paste.gif"}
				      feature:but3
				      action:self#paste
				      tooltips:'Paste the current selection')
			      space(feature:but4)
			      command(bitmap:{self.localize "mini-cross.gif"}
				      feature:but5
				      action:proc{$} skip end
				      tooltips:'Delete the current selection')
			      separator(feature:but6)
			      list(list:self.families
				   default:@currentfont
				   width:150
				   listw:25
				   listh:10
				   feature:fontlist
				   tooltips:'Font selection'
				   action:self#setfont)
			      separator(feature:but9)
			      radio(bitmap:{self.localize "justif_left.gif"}
				    feature:left
				    state:true
				    ref:justif
				    tooltips:'Left justification'
				    action:self#setjust(left))
			      radio(bitmap:{self.localize "justif_center.gif"}
				    feature:center
				    ref:justif
				    tooltips:'Center justification'
				    action:self#setjust(center))
			      radio(bitmap:{self.localize "justif_right.gif"}
				    feature:right
				      ref:justif
				    tooltips:'Right justification'
				    action:self#setjust(right))
			      separator(feature:but10)
			      check(bitmap:{self.localize "net-bold.gif"}
				    feature:bold
				    action:self#setbold
				    tooltips:'Bold')
			      check(bitmap:{self.localize "net-underline.gif"}
				    feature:underline
				    action:self#setunderline
				    tooltips:'Underline')
			      check(bitmap:{self.localize "net-italic.gif"}
				    feature:italic
				    action:self#setitalic
				    tooltips:'Italic')
			      separator(feature:but7)
			      list(list:@pxlsz|self.sizelist
				   width:20
				   listw:4
				   listh:10
				   tooltips:'Size selection'
				   feature:size
				   default:1
				   showfirst:false
				   action:self#setsize)
			     ])}       
      {TOOLBAR addbutton(IMGOFF
			 IMGON
			 X Y
			 self
			 "Text drawing tool"
			 TEXTICON)}
    end
    
end

