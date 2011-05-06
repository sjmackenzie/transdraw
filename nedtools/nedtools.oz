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


%declare

NoArgs={NewName}

class StandardDialog

   feat fontlist loading dispwind families
   attr i templist tempstr waitdisp
   prop locking
   
   meth tkInit
      fun {GetOneName X ?Xs}
	 case X of Y|Ys then
	    case Y
	    of 32 then
	       Xs=Ys
	       nil
	    else
	       Y|{GetOneName Ys Xs}
	    end
	 else
	    Xs=nil
	    nil
	 end
      end
      fun {GetAmpName X ?Xs}
	 case X of Y|Ys then
	    case Y
	    of 125 then
	       Xs=Ys
	       nil
	    else
	       Y|{GetAmpName Ys Xs}
	    end
	 else
	    Xs=nil
	    nil
	 end
      end
      fun {GetNames Xs}
	 case Xs of Y|Ys then
	    case Y
	    of 32 then {GetNames Ys}
	    [] 123 then
	       Z in
	       {GetAmpName Ys Z}|{GetNames Z}
	    else
	       Z in
	       {GetOneName Xs Z}|{GetNames Z}
	    end
	 else nil end
      end
   in
      self.families={GetNames {Tk.return font(families)}}
   end
   
   meth message(parent:Parent   <=NoArgs
		title:Title     <=''
		text:Text       <=''
		bitmap:Bitmap   <=''
		default:Default <=0
		justify:Just    <=center
		return:?Return
		buttons:Buttons
		escape:EscapeB  <=NoArgs)
      T B Escape In Out in
      case Parent==NoArgs then
	 T={New Tk.toplevel tkInit(title:Title
				   withdraw:true
				   delete:proc{$} skip end)}
      else
	 T=Parent
      end
      case {IsList Buttons} then
	 B=Buttons
      elsecase Buttons
      of 'ok' then
	 B=['Ok']
      [] 'okcancel' then
	 B=['Ok' 'Cancel']
      [] 'abortretryignore' then
	 B=['Abort' 'Retry' 'Ignore']
      [] 'retrycancel' then
	 B=['Retry' 'Cancel']
      [] 'yesno' then
	 B=['Yes' 'No']
      [] 'yesnocancel' then
	 B=['Yes' 'No' 'Cancel']
      else
	 B=[Buttons]
      end
      case EscapeB==NoArgs then Escape={Length B} else Escape=EscapeB end
      % builds the dialog box
      local
	 F1 F2 L1 L2 Anchor 
      in
	 F1={New Tk.frame tkInit(parent:T relief:groove borderwidth:2)}
	 F2={New Tk.frame tkInit(parent:T )}
	 {Tk.batch [grid(F1 row:0 column:0 sticky:nswe)
		    grid(F2 row:1 column:0)
		    grid(rowconfigure T 0 weight:1)
		    grid(columnconfigure T 0 weight:1)]}
	 case Bitmap=='' then skip else
	    L1={New Tk.label tkInit(parent:F1
				    bitmap:Bitmap)}
	    {Tk.send pack(L1 expand:yes anchor:w side:left padx:10)}
	 end
	 case Just
	 of left then Anchor=nw
	 [] center then Anchor=n
	 [] right then Anchor=ne
	 end
	 L2={New Tk.label tkInit(parent:F1
				 text:Text
				 justify:Just)}
	 {Tk.send pack(L2 expand:yes anchor:Anchor side:left padx:5)}
	 In={NewPort Out}
	 {List.forAllInd B
	  proc{$ I This}
	     But in
	     But={New Tk.button tkInit(parent:F2
				       text:This
				       action:In#I)}
	     case I-1==Default then
		{T tkBind(event:"<Return>"
			  action:In#I)}
	     elsecase I-1==Escape then
		{T tkBind(event:"<Escape>"
			  action:In#I)}
	     else skip end
	     {Tk.send pack(But side:left padx:2 pady:2)}
	  end}
      end
      {Tk.send wm(deiconify T)}
      {Tk.send 'catch'(v('{') grab set T v('}'))} % pour eviter un bug de Tcl/Tk
      case Out of X|Xs then
	 Return=X-1
      end
      {Wait Return}
      {Tk.send grab(release T)}
      {T tkClose}
%      Return={Tk.returnInt tk_dialog(T Title Text Bitmap Default b(B))}
   end

	 

   meth chooseColor(parent:Parent   <=NoArgs
		    initialcolor:IC <=NoArgs
		    title:Title     <=NoArgs
		    return:?Return)
      L={NewCell nil} in
      case Parent==NoArgs then skip else
	 {Assign L 'parent'#Parent|nil}
      end
      case IC==NoArgs then skip else
	 {Assign L 'initialcolor'#IC|{Access L}}
      end
      case Title==NoArgs then skip else
	 {Assign L 'title'#Title|{Access L}}
      end
      Return={Tk.returnAtom {List.toRecord 'tk_chooseColor' {Access L}}}
      {Wait Return}
   end

   meth getFile(type:Type
		defaultextension:DE <= NoArgs
		filetypes:FT        <= NoArgs
		initialdir:ID       <= NoArgs
		initialfile:IF      <= NoArgs
		parent:ParentOz     <= NoArgs
		title:Title         <= NoArgs
		return:?Return)
      MyList={NewCell nil}
      proc {Append String}
	 {ForAll {VirtualString.toString String}
	  proc {$ C}
	     {Assign MyList C|{Access MyList}}
	  end}
      end
      C
   in
      case Type
      of 'open' then
	 {Append "tk_getOpenFile "}
	 C=Unit
      [] 'save' then
	 {Append "tk_getSaveFile "}
	 C=Unit
      else skip end
      case {IsDet C} then skip else raise typeMustBe_open_Or_save(Type) end end
      case FT==NoArgs then skip else
	 {Append '-filetypes {'}
	 {ForAll FT
	  proc {$ Pattern}
	     case Pattern of X|Xs then % X=typeName
		{Append "{{"#X#"}"}
		case Xs of Y|Ys then % Y=list of extensions
		   {Append " {"}
		   {ForAll Y
		    proc {$ Ext}
		       {Append Ext#" "}
		    end}
		   {Append "}"}
		   case Ys of Z|Zs then %Z=list of macextensions
		      {Append " {"}
		      {ForAll Z
		       proc{$ Ext}
			  {Append Ext#" "}
		       end}
		      {Append "}"}
		   else skip end
		else skip end
		{Append "} "}
	     else skip end
	  end}
	 {Append '}'}
      end
      {ForAll [defaultextension#DE initialdir#ID initialfile#IF
	       title#Title]
       proc {$ R}
	  case R of String#Var then
	     case Var==NoArgs then skip else
		{Append " -"#String#" {"#Var#"}"}
	     end
	  end
       end}
      case ParentOz==NoArgs then skip else
	 N P F in
	 N={Tk.return winfo(name ParentOz)}
	 P={Tk.return winfo(parent ParentOz)}
	 {Wait P} {Wait N}
	 F={VirtualString.toString P#N} % now F is the tcl/tk name of ParentOz
	 {Append " -parent "#F}
      end
      Return={Tk.returnAtom v({Reverse {Access MyList}})}
   end      

   meth getLineStyle(parent:Parent <=NoArgs
		     arrowl:Arrowl <=[0 0 0]
		     arrowr:Arrowr <=[0 0 0]
		     dash:Dash     <=''
		     width:Width   <=1
		     fill:Fill     <='black'
		     dashlist:DashList <=['' gray12 gray25 gray50 gray75]
		     colors:Colors <=[black red green yellow white gray gray25 gray50 gray90
				      orange blue brown lightblue cyan magenta turquoise]
		     return:?Return)
      local
	 \insert 'linestyle.oz'
	 CurSet={NewCell r(arrowl:Arrowl arrowr:Arrowr dash:Dash width:Width fill:Fill)}
	 LockCell={NewCell Unit}
	 DBox
	 LTag
	 RTag
	 fun {ListToAtom Liste}
	    {StringToAtom {VirtualString.toString
			   {List.toTuple '#'
			    {Map Liste fun{$ C} " "#C end}}}}
	 end
	 proc {Update}
	    New Old R in
	    {Exchange LockCell Old New}
	    R={Access CurSet}
	    {Wait Old}
	    {LTag tk(delete)}
	    {RTag tk(delete)}
	    {DBox.top32_can52 tk(crea line
				 40 24
				 150 24
				 arrow:first
				 arrowshape:{ListToAtom R.arrowl}
				 fill:R.fill
				 tags:LTag
				 stipple:R.dash
				 width:R.width)}
	    {DBox.top32_can52 tk(crea line
				 150 24
				 270 24
				 arrow:last
				 arrowshape:{ListToAtom R.arrowr}
				 fill:R.fill
				 tags:RTag
				 stipple:R.dash
				 width:R.width)}
	    New=Unit
	 end
      in
	 case {IsDet Return} then
	    raise returnMustNotBeDefined
	    end
	 else skip end
	 DBox={New Linestyle init}
	 case Parent==NoArgs then
	    {DBox top32(delete:proc{$} skip end)}
	 else
	    {DBox top32(parent:Parent delete:proc{$} skip end)}
	 end
	 LTag={New Tk.canvasTag tkInit(parent:DBox.top32_can52)}
	 RTag={New Tk.canvasTag tkInit(parent:DBox.top32_can52)}
	 % Button OK
	 {DBox.top32_fra53_but54 tkAction(action:proc{$}
						    Return={Access CurSet}
						    {DBox.top32 tkClose}
						 end)}
	 % Button Cancel
	 {DBox.top32_fra53_but55 tkAction(action:proc{$}
						    Return=''
						    {DBox.top32 tkClose}
						 end)}
	 % Setting colors
	 {List.forAllInd Colors
	  proc{$ I C}
	     T=case I>8 then 1 else 0 end
	     Tag
	  in
	     Tag={New Tk.canvasTag tkInit(parent:DBox.top32_fra38_can50)}
	     {DBox.top32_fra38_can50 tk(crea rect
					((I-1)-(T*8))*26+1 T*27+1
					(I-T*8)*26+1       (T+1)*27+1
					fill:C
					tags:Tag)}
	     {Tag tkBind(action:proc{$}
				   {Assign CurSet {AdjoinAt {Access CurSet} fill C}}
				   {Update}
				end
			 event:'<1>')}
	  end}
	 % Setting Other color button
	 {DBox.top32_fra38_but49 tkAction(action:proc{$}
						    Tmp in
						    {self chooseColor(parent:DBox.top32
								      return:Tmp
								      initialcolor:{Access CurSet}.fill)}
						    case Tmp=='' then skip else
						       {Assign CurSet {AdjoinAt {Access CurSet} fill Tmp}}
						       {Update}
						    end
						 end)}
	 % Setting width
	 {DBox.top32_fra36_fra64_sca65 tk(set Width)}
	 {DBox.top32_fra36_fra64_sca65 tkAction(args:[int(x)]
						action:proc{$ X}
							  {Assign CurSet {AdjoinAt {Access CurSet} width X}}
							  {Update}
						       end)}
	 % Setting dash patterns
	 local
	    OldTag={NewCell nil}
	    proc{Sel Tag D}
	       case {Access OldTag}==nil then skip else
		  {{Access OldTag} tk(itemconfigure fill:white)}
	       end
	       {Tag tk(itemconfigure fill:gray)}
	       {Assign OldTag Tag}
	       {Assign CurSet {AdjoinAt {Access CurSet} dash D}}
	       {Update}
	    end
	    ToSel={Access CurSet}.dash
	 in
	    {List.forAllInd DashList
	     proc{$ I D}
		Tag RTag
	     in
		Tag={New Tk.canvasTag tkInit(parent:DBox.top32_fra36_fra43_02)}
		RTag={New Tk.canvasTag tkInit(parent:DBox.top32_fra36_fra43_02)}
		{DBox.top32_fra36_fra43_02
		 tk(crea rect
		    0  (I-1)*16
		    300 (I-1)*16+16
		    fill:white
		    outline:white
		    tags:RTag)}
		{DBox.top32_fra36_fra43_02 tk(lower RTag)}
		{DBox.top32_fra36_fra43_02
		 tk(crea line
		    0  (I-1)*16+8
		    300 (I-1)*16+8
		    stipple:D
		    width:4
		    tags:Tag)}
		{Tag tkBind(event:'<1>'
			    action:proc{$}
				      {Sel RTag D}
				   end)}
		{RTag tkBind(event:'<1>'
			     action:proc{$}
				       {Sel RTag D}
				    end)}
		case D==ToSel then {Sel RTag D} else skip end
	     end}
	 end
	 {DBox.top32_fra36_fra43_02
	  tk(configure
	     yscrollincrement:16
	     scrollregion:{StringToAtom
			   {VirtualString.toString '0 0 1000 '#({Length DashList}*16)}})}
	 % generating arrows arrays
	 local
	    Arrows
	    Tab={NewCell [0 0 0]|nil}
	 in
	    {ForAll [10 5 15]
	     proc{$ Third}
		{ForAll [15 ~15 10 ~10 5 ~5 0]
		 proc{$ Second}
		    {ForAll [11 9 7 5 3 1 13 15 17 19 21]
		     proc{$ First}
			{Assign Tab [First Second Third]|{Access Tab}}
		     end}
		 end}
	     end}
	    Arrows={Reverse {Access Tab}}
	    {ForAll [DBox.top32_fra37_fra46_02#first DBox.top32_fra37_fra47_02#last]
	     proc{$ C}
		case C of Canvas#Side then
		   OldTag={NewCell nil}
		   proc{Sel Tag Arrow}
		      case {Access OldTag}==nil then skip else
			 {Canvas tk(itemconfigure {Access OldTag} fill:white)}
		      end
		      {Assign OldTag Tag}
		      {Canvas tk(itemconfigure Tag fill:gray)}
		      {Assign CurSet {AdjoinAt {Access CurSet} case Side==first then arrowl else arrowr end Arrow}}
		      {Update}
		   end
		   ToSel
		   case Side==first then
		      ToSel={Access CurSet}.arrowl
		   else 
		      ToSel={Access CurSet}.arrowr
		   end
		in
		   {List.forAllInd Arrows
		    proc{$ I Arrow}
		       Tag RTag in
		       RTag={New Tk.canvasTag tkInit(parent:Canvas)}
		       Tag={New Tk.canvasTag tkInit(parent:Canvas)}
		       {Canvas
			tk(crea rect
			   0    (I-1)*30-5
			   1000 (I-1)*30+25
			   fill:white
			   outline:white
			   tags:RTag)}
		       {Canvas tk(lower RTag)}
		       {Canvas
			tk(crea line
			   20 (I-1)*30+10
			   110 (I-1)*30+10
			   arrow:Side
			   arrowshape:{ListToAtom Arrow}
			   tags:Tag)}
		       {RTag tkBind(event:'<1>'
				    action:proc{$}
					      {Sel RTag Arrow}
					   end)}
		       {Tag tkBind(event:'<1>'
				   action:proc{$}
					     {Sel RTag Arrow}
					  end)}
		       case Arrow==ToSel then {Sel RTag Arrow} else skip end
		    end}
		   {Canvas tk(configure
			      yscrollincrement:30
			      scrollregion:{StringToAtom
					    {VirtualString.toString '0 0 1000 '#({Length Arrows}*30)}})}
		end
	     end}
	 end
	 % drawing
	 {Update}
	 {Wait Return}
      end
   end

%   meth fontNameToParams(Name return:FontParams)
%      case {VirtualString.toString Name} of 45|_ then
%	 templist<-nil
%	 tempstr<-''
%	 i<-0
%	 {ForAll {VirtualString.toString Name#'-'}
%	  proc{$ C}
%	     case {StringToAtom [C]}
%	     of '-' then
%		Str in
%		{StringToAtom {VirtualString.toString @tempstr $} Str}
%		tempstr<-''
%		i<-@i+1
%		case @i
%		of 1 then skip
%		% passe le premier '-'
%		[] 2 then
%		   templist<-fndry#Str|@templist
%		[] 3 then
%		   templist<-fmly#Str|@templist
%		[] 4 then
%		   templist<-wght#Str|@templist
%		[] 5 then
%		   templist<-slant#Str|@templist
%		[] 6 then
%		   templist<-swdth#Str|@templist
%		[] 7 then
%		   templist<-adstyl#Str|@templist
%		[] 8 then
%		   templist<-pxlsz#Str|@templist
%		[] 9 then
%		   templist<-ptsz#Str|@templist
%		[] 10 then
%		   templist<-resx#Str|@templist
%		[] 11 then
%		   templist<-resy#Str|@templist
%		[] 12 then
%		   templist<-spc#Str|@templist
%		[] 13 then
%		   templist<-avgwidth#Str|@templist
%		[] 14 then
%		   templist<-rgstry#Str|@templist
%		[] 15 then
%		   templist<-encdng#Str|@templist
%		else skip
%		end
%	     [] C then
%		tempstr<-@tempstr#C
%	     end
%	  end}
%	 FontParams={AdjoinList font(fndry:'*' fmly:'*' wght:'*' slant:'*' swdth:'*'
%				     adstyl:'*' pxlsz:'*' ptsz:'*' resx:'*' resy:'*'
%				     spc:'*' avgwidth:'*' rgstry:'*' encdng:'*')
%		     @templist}
%      else
%	 FontParams=font(name:Name)
%      end
%   end

%   meth fontParamsToName(P return:Name)
%      case {HasFeature P name} then Name=P.name else
%	 Name={StringToAtom {VirtualString.toString
%			     "-"#P.fndry#'-'#P.fmly#'-'#P.wght#'-'#P.slant#'-'#P.swdth#'-'#P.adstyl#'-'#P.pxlsz#'-'#P.ptsz#'-'#P.resx#'-'#P.resy#'-'#P.spc#'-'#P.avgwidth#'-'#P.rgstry#'-'#P.encdng
%			    }}
%      end
%   end
   
%   meth loadFonts(return:?Return msg:Msg <=true)
%      local
%	 proc{Disp ?T}
%	    M F
%	 in
%	    T = {New Tk.toplevel tkInit(withdraw:true bg:black)}
%	    F = {New Tk.frame tkInit(parent:T bg:white relief:groove)}
%	    M = {New Tk.message
%		 tkInit(parent:F text:'Please Wait While Loading Fonts List...' aspect:400)}
%	    {Tk.batch [wm(overrideredirect T true)
%		       wm(geometry T '+'#30#'+'#30)
%		       pack(F padx:2 pady:2)
%		       pack(M padx:2 pady:2)
%		       wm(deiconify T)]}
%	 end
%	 T Do
%	 class TextPipe from Open.pipe Open.text
%	    prop final
%	 end
%	 Fonts
%	 LastFont={NewCell ''}
%	 fun {GetFonts}
%	    T in
%	    T={Fonts getS($)}
%	    case T==false then
%	       ''
%	    else
%	       case T=={Access LastFont} then
%		  {GetFonts}
%	       else
%		  {Assign LastFont T}
%		  T|{GetFonts}
%	       end
%	    end
%	 end
%	 fun {Compute Liste}
%	    case Liste of X|Xs then
%	       case X of 45|Ys then
%		  T in
%		  {self fontNameToParams(X return:T)}
%		  T|{Compute Xs}
%	       else
%		  font(name:{StringToAtom X})|{Compute Xs}
%	       end
%	    else ""
%	    end
%	 end
%      in
%	 lock
%	    case {IsDet self.loading} then
%    	       % deja en train de lire
%	       case @waitdisp==false andthen Msg==true andthen {IsFree self.fontlist} then
%		  % affiche la boite
%		  waitdisp<-true
%		  {Disp self.dispwind}
%	       else skip end
%	       Do=false
%	    else
%	       self.loading=true
%	       case Msg then {Disp self.dispwind} else skip end
%	       waitdisp<-Msg
%	       Do=true
%	    end
%	 end
%	 case Do==false then Return=self.fontlist else
%	    Tmp
%	    proc {Loop I}
%	       case I<10 then % try 10 times
%		  try
%		     {System.gcDo}
%		     Fonts={New TextPipe init(cmd:'xlsfonts')}
%		  catch
%		     system(...) then
%		     {Delay 2000}
%		     {Loop I+1}
%		  end
%	       else
%		  raise notEnoughRessourcesForForking end
%	       end
%	    end
%	    Recalc Tmp
%	 in
%	    try
%	       lock
%		  {Pickle.load 'Nedtools.fontlist' Tmp}
%	       end
%	    catch error(...) then
%	       Recalc=unit
%	    end
%	    case {IsFree Recalc} then % determine si c'est la meme machine
%	       case {OS.uName}==Tmp.machine then
%		  self.fontlist=Tmp.fontlist
%		  Return=self.fontlist
%		  case @waitdisp then {self.dispwind tkClose} else skip end
%	       else Recalc=unit end
%	    else skip end
%	    case {IsDet Recalc} then % recalcule effectivemment
%	       {Loop 0}
%	       lock
%		  self.fontlist={Compute {GetFonts}}
%		  {Fonts close}
%		  Return=self.fontlist
%		  case @waitdisp then {self.dispwind tkClose} else skip end
%	       end
%	       try
%		  {Pickle.save r(fontlist:self.fontlist
%				 machine:{OS.uName})
%		   'Nedtools.fontlist'}
%	       catch error(...) then skip
%	       end
%	    else skip end
%	 end
%      end
%   end
   
%   meth getUnixFont(parent:Parent   <=NoArgs
%		    default:Default <='-adobe-helvetica-medium-r-normal--*-*-100-100-*-*-*-*'
%		    return:?Return)
%      {self loadFonts(return:_)}
%      local
%	 \insert 'unixfont.oz'
%	 FontBox
%	 CurFont={NewCell ''}
%	 CurSettings={NewCell font(fndry:'*' fmly:'*' wght:'*' slant:'*' swdth:'*'
%				   adstyl:'*' pxlsz:'*' ptsz:'*' resx:'*' resy:'*'
%				   spc:'*' avgwidth:'*' rgstry:'*' encdng:'*')}
%	 Menus={NewCell nil}
%	 proc {Update}
%	    {Tk.send grab(set FontBox.top17_fra19_lab20)}
%	    {FontBox.top17 tk(configure cursor:'watch')}
%	    C={Access CurSettings}
%	    proc {Updmenu Font}
%	       {ForAll [fndry fmly wght slant swdth adstyl pxlsz ptsz resx resy spc
%			avgwidth rgstry encdng]
%		proc {$ R}
%		   case {Member Font.R {Access Menus}.R} then skip else
%		      {Assign Menus {AdjoinAt {Access Menus} R Font.R|{Access Menus}.R}}
%		   end
%		end}
%	    end
%	 in
%	    {Assign Menus font(fndry:nil fmly:nil wght:nil slant:nil swdth:nil
%			       adstyl:nil pxlsz:nil ptsz:nil resx:nil resy:nil
%			       spc:nil avgwidth:nil rgstry:nil encdng:nil)}
%	    {FontBox.top17_fra19_cpd22_01 tk(delete 0 {Length self.fontlist})}
%	    case C==font(fndry:'*' fmly:'*' wght:'*' slant:'*' swdth:'*'
%			 adstyl:'*' pxlsz:'*' ptsz:'*' resx:'*' resy:'*'
%			 spc:'*' avgwidth:'*' rgstry:'*' encdng:'*') then
%	       {ForAll self.fontlist
%		proc{$ F}
%		   {FontBox.top17_fra19_cpd22_01 tk(insert 'end'
%						    {self fontParamsToName(F return:$)})}
%		   case {HasFeature F name} then skip else {Updmenu F} end
%		end}
%	    else
%	       {ForAll self.fontlist
%		proc{$ F}
%		   case {HasFeature F name} then skip
%		   else
%		      T
%		   in
%		      {ForAll [fndry fmly wght slant swdth adstyl pxlsz ptsz resx resy spc
%			       avgwidth rgstry encdng]
%		       proc {$ R}
%			  case C.R=='*' orelse C.R==F.R then skip
%			  elsecase {IsFree T} then T=unit else skip end
%		       end}
%		      case {IsFree T} then
%			 {FontBox.top17_fra19_cpd22_01 tk(insert 'end'
%							  {self fontParamsToName(F return:$)})}
%			 {Updmenu F}
%		      else skip end
%		   end
%		end}
%	    end
%	    % Rebuild the menus
%	    {ForAll [fndry#top17_fra18_men23_m#false fmly#top17_fra18_men24_m#false wght#top17_fra18_men25_m#false
%		     slant#top17_fra18_men26_m#false swdth#top17_fra18_men27_m#false
%		     adstyl#top17_fra18_men28_m#false pxlsz#top17_fra18_men29_m#true ptsz#top17_fra18_men30_m#true
%		     resx#top17_fra18_men31_m#true spc#top17_fra18_men32_m#false
%		     rgstry#top17_fra18_men33_m#false encdng#top17_fra18_men34_m#false]
%	     proc {$ Re}
%		case Re of R#W#B then
%		   % Destroy the old menu
%		   {FontBox.W tk(delete 0 1000)}
%		   local E1 E2 in
%		      E1={New Tk.menuentry.command
%			  tkInit(parent:FontBox.W label:'*' action:proc{$}
%								      {Assign CurSettings
%								       {AdjoinAt {Access CurSettings}
%									R '*'}}
%								      {Update}
%								   end)}
%		      E2={New Tk.menuentry.separator
%			  tkInit(parent:FontBox.W)}
%		   end
%		   {ForAll {List.sort {Access Menus}.R
%			    fun{$ I J}
%			       case B then
%				  {StringToInt {AtomToString I}}<{StringToInt {AtomToString J}}
%			       else
%				  case I==nil then true
%				  elsecase J==nil then false
%				  else
%				     I<J
%				  end
%			       end
%			    end}
%		    proc{$ En}
%		       E in
%		       E={New Tk.menuentry.command
%			  tkInit(parent:FontBox.W label:En action:proc{$}
%								     {Assign CurSettings
%								      {AdjoinAt {Access CurSettings}
%								       R En}}
%								     {Update}
%								  end)}
%		    end}
%		end
%	     end}
%	    % show filter
%	    {FontBox.top17_fra19_lab20 tk(configure text:{self fontParamsToName({Access CurSettings} return:$)})}
%	    {FontBox.top17 tk(configure cursor:'left_ptr')}
%	    {Tk.send grab(release FontBox.top17_fra19_lab20)}
%	 end
%      in
%	 FontBox={New Unixfont init}
%	 case Parent==NoArgs then
%	    {FontBox top17(delete:proc{$} skip end)}
%	 else
%	    {FontBox top17(parent:Parent delete:proc{$} skip end)}
%	 end	    
%	 % Button Ok
%	 {FontBox.top17_fra21_but40 tkAction(action:proc{$}
%						       Return={Access CurFont}
%						       {FontBox.top17 tkClose}
%						    end)}
%	 % Button Cancel
%	 {FontBox.top17_fra21_but41 tkAction(action:proc{$}
%						       Return=''
%						       {FontBox.top17 tkClose}
%						    end)}
%	 % Font Selection ListBox
%	 {FontBox.top17_fra19_cpd22_01
%	  tkBind(event:'<ButtonRelease-1>'
%		 action:proc{$}
%			   A B C MyFont in
%			   A={FontBox.top17_fra19_cpd22_01 tkReturnListInt(curselection $)}
%			   {Wait A}
%			   B={List.last A}
%			   C={FontBox.top17_fra19_cpd22_01 tkReturnAtom(get B $)}
%			   {Wait C}
%			   MyFont=C
%			   {FontBox.top17_fra20_lab35 tk(configure
%							 text:MyFont)}
%			   {FontBox.top17_fra20_lab36 tk(configure
%							 font:MyFont)}
%			   {FontBox.top17_fra20_lab37 tk(configure
%							 font:MyFont)}
%			   {FontBox.top17_fra20_lab38 tk(configure
%							 font:MyFont)}
%			   {FontBox.top17_fra20_lab39 tk(configure
%							 font:MyFont)}
%			   {Assign CurFont MyFont}
%			end)}
%	 {FontBox.top17_fra20_lab35 tk(configure
%				       text:Default)}
%	 {FontBox.top17_fra20_lab36 tk(configure
%				       font:Default)}
%	 {FontBox.top17_fra20_lab37 tk(configure
%				       font:Default)}
%	 {FontBox.top17_fra20_lab38 tk(configure
%				       font:Default)}
%	 {FontBox.top17_fra20_lab39 tk(configure
%				       font:Default)}
%	 {Assign CurFont Default}
%	 {Update}
%	 {Wait Return}
%      end
%   end

%   meth getFont(parent:Parent   <=NoArgs
%		default:Default <='-adobe-helvetica-medium-r-normal--*-*-100-100-*-*-*-*'
%		defaultul:DefaultUl <= false
%		text:Text       <='The Quick Brown Fox Jumped Over The Lazy Dogs'
%		alias:Alias     <=true
%		return:Return)
%      local
%	 {self loadFonts(return:_)}
%	 \insert 'stdfont.oz'
%	 FontBox
%	 CurFont={NewCell Default}
%	 CurSetting OldSetting
%	 FontList
%	 Tag
%	 NameTag
%	 SizeList={NewCell nil}
%	 proc {Update}
%	    Old={Access OldSetting}
%	    New
%	    TNew={Access CurSetting}
%	    Cf={List.nth FontList {Access CurSetting}.select}
%	    fun {ToInt V}
%	       {StringToInt {VirtualString.toString V}}
%	    end
%	 in
%	    {Tk.send grab(set FontBox.top42_01_011_can19)}
%	    {FontBox.top42 tk(configure cursor:'watch')}
%	    case Old.select==TNew.select andthen Old.bold==TNew.bold andthen Old.italic==TNew.italic then
%	       case Old.size==TNew.size then skip else
%		  {Assign CurFont ''}
%		  {ForAll {Access SizeList}
%		   proc{$ F}
%		      case TNew.size==F.size then
%			 {Assign CurFont {self fontParamsToName(F.font return:$)}}
%		      else skip end
%		   end}
%	       end
%	       New=TNew
%	    else
%	       {Assign SizeList nil}
%	       {FontBox.top42_01_02_08_09 tk(delete 0 10000)}
%	       {Assign CurFont ''}
%	       case {HasFeature Cf fmly} then
%		  local Bo It in
%		     {ForAll self.fontlist
%		      proc{$ F}
%			 case {HasFeature F fmly} then
%			    case F.fndry#F.fmly==Cf.fndry#Cf.fmly then
%			       case {IsFree Bo} then
%				  case F.wght=='bold' orelse F.wght=='demibold' then
%				     Bo=unit
%				  else skip end
%			       else skip end
%			       case {IsFree It} then
%				  case F.slant=='i' orelse F.slant=='o' then
%				     It=unit
%				  else skip end
%			       else skip end
%			    else skip end
%			 else skip end
%		      end}
%		     local Tmp in
%			case {IsDet Bo} then
%			   {FontBox.top42_01_011_013 tk(configure state:normal)}
%			   Tmp={Access CurSetting}
%			else
%			   {FontBox.top42_01_011_013 tk(configure state:disabled)}
%			   Tmp={AdjoinAt {Access CurSetting} bold false}
%			end
%			case {IsDet It} then
%			   {FontBox.top42_01_011_014 tk(configure state:normal)}
%			   New=Tmp
%			else
%			   {FontBox.top42_01_011_014 tk(configure state:disabled)}
%			   New={AdjoinAt Tmp italic false}
%			end
%		     end
%		  end
%	       else New=TNew end
%	       {ForAll self.fontlist
%		proc{$ F}
%		   case {HasFeature F name} andthen {HasFeature Cf name} then
%		      case F.name==Cf.name then
%			 {ForAll [top42_01_011_013
%				  top42_01_011_014]
%			  proc{$ F}
%			     {FontBox.F tk(configure state:disabled)}
%			  end}
%			 {Assign CurFont F.name}
%			 {Assign SizeList nil}
%		      else skip end
%		   elsecase {HasFeature Cf fmly} andthen {HasFeature F fmly} then
%		      case F.fndry#F.fmly==Cf.fndry#Cf.fmly then
%			 case New.bold then
%			    case New.italic then
%			       % asked = bold & italic
%			       case F.wght=='bold' orelse F.wght=='demibold' then
%				  case F.slant=='i' orelse F.slant=='o' then
%				     % found = bold & italic
%				     {Assign SizeList c(size:{ToInt F.pxlsz} font:F)|{Access SizeList}}
%				  else skip end
%			       else skip end
%			    else
%			       % asked = bold & not italic
%			       case F.wght=='bold' orelse F.wght=='demibold' then
%				  case F.slant=='' orelse F.slant=='r' then
%				     % found = bold & not italic
%				     {Assign SizeList c(size:{ToInt F.pxlsz} font:F)|{Access SizeList}}
%				  else skip end
%			       else skip end
%			    end
%			 else
%			    case New.italic then
%			       % asked = not bold & italic
%			       case F.wght=='medium' orelse F.wght=='normal' then
%				  case F.slant=='i' orelse F.slant=='o' then
%				     % found = not bold & italic
%				     {Assign SizeList c(size:{ToInt F.pxlsz} font:F)|{Access SizeList}}
%				  else skip end
%			       else skip end
%			    else
%			       % asked = not bold & not italic
%			       case F.wght=='medium' orelse F.wght=='normal' then
%				  case F.slant=='' orelse F.slant=='r' then
%				     % found = not bold & not italic
%				     {Assign SizeList c(size:{ToInt F.pxlsz} font:F)|{Access SizeList}}
%				  else skip end
%			       else skip end
%			    end
%			 end
%		      else skip end
%		   else skip end
%		end}
%	       local SList Tmp in
%		  SList={List.sort {Access SizeList} fun{$ A B} A.size<B.size end}
%		  {NewCell ~1 Tmp}
%		  {List.forAllInd SList
%		   proc {$ I F}
%		      case {Access Tmp}==F.size then skip else
%			 case F.size==0 then
%			    {FontBox.top42_01_02_08_09 tk(insert 'end' 'Default')}
%			 else
%			    {FontBox.top42_01_02_08_09 tk(insert 'end' F.size)}
%			 end
%			 case New.size=<F.size andthen {Access CurFont}=='' then
%			    {Assign CurFont {self fontParamsToName(F.font return:$)}}
%			 else skip end
%			 {Assign Tmp F.size}
%		      end
%		   end}
%		  case {Access CurFont}=='' andthen {Length SList}>0 then
%		     {Assign CurFont {self fontParamsToName({List.nth SList 1}.font return:$)}}
%		  else skip end   
%	       end
%	    end
%	    case {Access CurFont}=='' then
%	       % pick one by default
%	       {ForAll self.fontlist
%		proc{$ F}
%		   case {HasFeature F fmly} andthen {HasFeature Cf fmly} then
%		      case F.fmly#F.fndry==Cf.fmly#Cf.fndry then
%			 {Assign CurFont {self fontParamsToName(F return:$)}}
%		      else skip end
%		   else skip end
%		end}
%	    else skip end
%	    {Tag tk(delete)}
%	    {NameTag tk(itemconfigure text:{Access CurFont})}
%	    case {Access CurFont}=='' then skip else
%	       {FontBox.top42_01_011_016 tk(crea text
%					    20 20
%					    tags:Tag
%					    text:Text
%					    font:{Access CurFont}
%					    justify:left
%					    anchor:nw)}
%	       case New.underline then
%		  SX1 SX2 SY1 SY2 in
%		  [SX1 SY1 SX2 SY2]={FontBox.top42_01_011_016 tkReturnList(bbox(Tag) $)}
%		  {FontBox.top42_01_011_016 tk(crea line
%					       SX1 {StringToInt SY2}+2
%					       SX2 {StringToInt SY2}+2
%					       tags:Tag)}
%	       else skip end
%	    end
%	    {Assign OldSetting {Access CurSetting}}
%	    {FontBox.top42 tk(configure cursor:'left_ptr')}
%	    {Tk.send grab(release FontBox.top42_01_011_can19)}
%	 end
%	 CurSelLine
%	 DP DB DI DU DS
%      in
%	 FontBox={New Stdfont init}
%	 {FontBox top42(delete:proc{$} skip end)}
%	 {Tk.send grab(set FontBox.top42)}
%	 Tag={New Tk.canvasTag tkInit(parent:FontBox.top42_01_011_016)}
%	 NameTag={New Tk.canvasTag tkInit(parent:FontBox.top42_01_011_can19)}
%	 {FontBox.top42_01_011_can19 tk(crea text
%					2 2
%					font:'-adobe-courier-medium-r-normal-m*'
%					text:'FontName'
%					anchor:nw
%					justify:left
%					tags:NameTag)}
%	 % Button Ok
%	 {FontBox.top42_017_018 tkAction(action:proc{$}
%						   Return=r(font:{Access CurFont}
%							    bold:{Access CurSetting}.bold
%							    italic:{Access CurSetting}.italic
%							    underline:{Access CurSetting}.underline)
%						   {Tk.send grab(release FontBox.top42)}
%						   {FontBox.top42 tkClose}
%						end)}
%	 % Button Cancel
%	 {FontBox.top42_017_019 tkAction(action:proc{$}
%						   Return=''
%						   {Tk.send grab(release FontBox.top42)}
%						   {FontBox.top42 tkClose}
%						end)}
%	 % Button Unix
%	 {FontBox.top42_017_020 tkAction(action:proc{$}
%						   Tmp in
%						   {Tk.send grab(release FontBox.top42)}
%						   {FontBox.top42 tkClose}
%						   Tmp={self getUnixFont(parent:Parent
%									 return:$
%									 default:{Access CurFont})}
%						   Return=r(font:Tmp
%							    bold:false
%							    italic:false
%							    underline:false)
%						end)}
%	 % Font List Box
%	 local
%	    Last={NewCell ""}
%	    TmpList={NewCell nil}
%	    I={NewCell 1}
%	 in
%	    DP={self fontNameToParams(Default return:$)}
%	    {ForAll self.fontlist
%	     proc{$ F}
%		case {HasFeature F name}==false then
%		   case F.wght=='normal' orelse F.wght=='medium' then
%		      case F.fndry#F.fmly=={Access Last} then skip else
%			 {Assign Last F.fndry#F.fmly}
%			 {FontBox.top42_01_02_05_06 tk(insert 'end'
%						       F.fndry#" - "#F.fmly)}
%			 case {HasFeature DP name}==false then
%			    case DP.fndry#DP.fmly==F.fndry#F.fmly andthen {IsFree CurSelLine} then
%			       CurSelLine={Access I}
%			    else skip end
%			 else skip end
%			 {Assign TmpList F|{Access TmpList}}
%			 {Assign I {Access I}+1}
%		      end
%		   else skip end
%		elsecase Alias then
%		   case F.name=={Access Last} then skip else
%		      {Assign Last F.name}
%		      {FontBox.top42_01_02_05_06 tk(insert 'end'
%						    F.name)}
%		      case {HasFeature DP name} then
%			 case DP.name==F.name andthen {IsFree CurSelLine} then
%			    CurSelLine={Access I}
%			 else skip end
%		      else skip end
%		      {Assign TmpList F|{Access TmpList}}
%		      {Assign I {Access I}+1}
%		   end
%		else skip end
%	     end}
%	    FontList={Reverse {Access TmpList}}
%	 end
%	 case {IsFree CurSelLine} then CurSelLine=1 else skip end
%	 case {HasFeature DP wght} then
%	    case DP.wght=='bold' orelse DP.wght=='demibold' then
%	       DB=true
%	       {FontBox.top42_01_011_013 tk(select)}
%	    else DB=false end
%	    case DP.slant=='i' orelse DP.slant=='o' then
%	       DI=true
%	       {FontBox.top42_01_011_014 tk(select)}
%	    else DI=false end
%	    case DP.pxlsz=='*' then DS=0 else
%	       DS={StringToInt {VirtualString.toString DP.pxlsz}}
%	    end
%	 else
%	    DB=false
%	    DI=false
%	    DS=0
%	 end
%	 DU=DefaultUl
%	 case DU then
%	    {FontBox.top42_01_011_015 tk(select)}
%	 else skip end
%	 % bindings
%	 {FontBox.top42_01_02_05_06
%	  tkBind(event:'<ButtonRelease-1>'
%		 action:proc{$}
%			   A B in
%			   A={FontBox.top42_01_02_05_06 tkReturnListInt(curselection $)}
%			   B={List.last A}
%			   {Assign CurSetting {AdjoinAt {Access CurSetting} select B+1}}
%			   {Update}
%			end)}
%	 {FontBox.top42_01_02_08_09
%	  tkBind(event:'<ButtonRelease-1>'
%		 action:proc{$}
%			   A B C in
%			   A={FontBox.top42_01_02_08_09 tkReturnListInt(curselection $)}
%			   B={List.last A}
%			   C={FontBox.top42_01_02_08_09 tkReturnInt(get B $)}
%			   {Assign CurSetting {AdjoinAt {Access CurSetting} size case {IsInt C} then C else 0 end}}
%			   {Update}
%			end)}
%	 {FontBox.top42_01_011_013
%	  tkAction(action:proc{$}
%			     {Assign CurSetting {AdjoinAt {Access CurSetting} bold
%						 {Access CurSetting}.bold==false}}
%			     {Update}
%			  end)}
%	 {FontBox.top42_01_011_014
%	  tkAction(action:proc{$}
%			     {Assign CurSetting {AdjoinAt {Access CurSetting} italic
%						 {Access CurSetting}.italic==false}}
%			     {Update}
%			  end)}
%	 {FontBox.top42_01_011_015
%	  tkAction(action:proc{$}
%			     {Assign CurSetting {AdjoinAt {Access CurSetting} underline
%						 {Access CurSetting}.underline==false}}
%			     {Update}
%			  end)}
%	 % Init
%	 {NewCell r(bold:false underline:false italic:false select:0 size:0) OldSetting}
%	 {NewCell r(bold:DB underline:DU italic:DI select:CurSelLine size:DS) CurSetting}
%	 {Update}
%	 {Wait Return}
%      end
%   end

   meth getFamilies(return:Return)
      Return=self.families
   end
   
   meth chooseFontFamilies(default:Default <= nil
			   text:Text <='The quick brown fox jumps over the lazy dog'
			   return:Return)
      \insert 'stdfont.oz'
      FontBox NameTag Font
      Current={NewCell nil}
      proc{Update}
	 {Tk.send font(delete 'chf')}
	 local T={Access Current} in
	    {Tk.send font(create 'chf' family:T.family slant:T.slant
			  underline:T.underline weight:T.weight
			  size:T.size)}
	 end
	 {NameTag tk(itemconfigure
		     text:{Access Current}.family#"   "#{Access Current}.size)}
      end
   in
      case Default==nil then
	 {Assign Current r(family:{Nth self.families 1})}
      else
	 {Assign Current Default}
      end
      {Assign Current {Adjoin r(size:10 weight:normal slant:roman
				underline:false overstrike:false)
		       {Access Current}}}
      FontBox={New Stdfont init}
      {FontBox top42(delete:proc{$} skip end)}
      {Tk.send grab(set FontBox.top42)}
      NameTag={New Tk.canvasTag tkInit(parent:FontBox.top42_01_011_can19)}
      case {Member 'chf' {Map {Tk.returnListString font(names)} StringToAtom}} then
	 {Tk.send font(delete 'chf')}
      else skip end
      local T={Access Current} in
	 {Tk.send font(create 'chf' family:T.family slant:T.slant
		       underline:T.underline weight:T.weight
		       size:T.size)}
      end
      {FontBox.top42_01_011_can19
       tk(crea text
	  2 2
	  font:'Times 10'
	  text:''
	  anchor:nw
	  justify:left
	  tags:NameTag)}
      {FontBox.top42_01_011_016 tk(crea text
				   20 20
				   text:Text
				   font:'chf'
				   justify:left
				   anchor:nw)}
      % Bouton OK
      {FontBox.top42_017_018
       tkAction(action:proc{$}
			  Return={Access Current}
			  {Tk.send grab(release FontBox.top42)}
			  {FontBox.top42 tkClose}
		       end)}
      % Bouton Cancel
      {FontBox.top42_017_019
       tkAction(action:proc{$}
			  Return=''
			  {Tk.send grab(release FontBox.top42)}
			  {FontBox.top42 tkClose}
		       end)}
      % Bouton Unix
      {Tk.send pack(forget FontBox.top42_017_020)}
      % Font List Box
      {ForAll self.families
       proc{$ F}
	  {FontBox.top42_01_02_05_06 tk(insert 'end' F)}
       end}
      % Size Box
      {ForAll [2 4 6 8 10 12 14 16 18 20 24 28 32 36 48 60 72]
       proc{$ F}
	  {FontBox.top42_01_02_08_09 tk(insert 'end' F)}
       end}      
      % Boutons bold, italic and underline
      case {Access Current}.weight=='bold' then
	 {FontBox.top42_01_011_013 tk(select)}
      else skip end
      case {Access Current}.slant=='italic' then
	 {FontBox.top42_01_011_014 tk(select)}
      else skip end
      case {Access Current}.underline then
	 {FontBox.top42_01_011_015 tk(select)}
      else skip end
      % bindings
      {FontBox.top42_01_02_05_06
       tkBind(event:'<ButtonRelease-1>'
	      action:proc{$}
			T in
			T={FontBox.top42_01_02_05_06 tkReturnInt(curselection $)}
			{Assign Current {AdjoinAt {Access Current} family {Nth self.families T+1}}}
			{Update}
		     end)}
      {FontBox.top42_01_02_08_09
       tkBind(event:'<ButtonRelease-1>'
	      action:proc{$}
			T TT in
			T={FontBox.top42_01_02_08_09 tkReturnInt(curselection $)}
			TT={FontBox.top42_01_02_08_09 tkReturnInt(get T $)}
			{Assign Current {AdjoinAt {Access Current} size TT}}
			{Update}
		     end)}
      {FontBox.top42_01_011_013
       tkAction(action:proc{$}
			  {Assign Current
			   {AdjoinAt {Access Current} weight
			    case {Access Current}.weight=='normal' then 'bold' else 'normal' end}}
			  {Update}
		       end)}
      {FontBox.top42_01_011_014
       tkAction(action:proc{$}
			  {Assign Current
			   {AdjoinAt {Access Current} slant
			    case {Access Current}.slant=='italic' then 'roman' else 'italic' end}}
			  {Update}
		       end)}
      {FontBox.top42_01_011_015
       tkAction(action:proc{$}
			  {Assign Current
			   {AdjoinAt {Access Current} underline
			    {Access Current}.underline==false}}
			  {Update}
		       end)}
      {Update}
      {Wait Return}
   end

   meth copyCanvas(Source Dest DX DY)
      % trouve l'objet le plus au bas de la pile d'affichage
      fun{Loop Tag}
	 NT={New Tk.canvasTag tkInit(parent:Source)} in
	 {Source tk(addtag NT below Tag)}
	 case {Source tkReturnAtom(type(NT) $)}=='' then % plus d'objets au dessous
	    Tag
	 else
	    {Source tk(dtag Tag)}
	    {Loop NT}
	 end
      end
      FTag={New Tk.canvasTag tkInit(parent:Source)}
      {Source tk(addtag FTag closest 0 0)} % selection d'un objet de depart
      Start={Loop FTag} % passage a l'objet le plus bas
      % recree un nouveau canvas en fonction de l'ancien
      fun{Copy Tag}
	 fun{GetParams R L}
	    RetRec={NewCell R}
	 in
	    {ForAll L
	     proc{$ P}
		MyP={List.last {Source tkReturnList(itemconfigure(Tag "-"#P) $)}}
%		MyP={Source tkReturn(itemconfigure(Tag {StringToAtom {VirtualString.toString "-"#P}}) $)}
		{Wait MyP}
	     in
		case MyP=="{}" then skip else
		   {Assign RetRec {AdjoinAt {Access RetRec} P MyP}}
		end
	     end}
	    {Access RetRec}
	 end
	 C={Source tkReturnListFloat(coords(Tag) $)}
	 B={Source tkReturnListFloat(bbox(Tag) $)}
	 S={Source tkReturnAtom(type(Tag) $)}
	 Tr=tk(crea S b(C))
	 Ret
	 R
      in
	 case S
	 of '' then skip
	 [] 'arc' then
	    R={GetParams Tr [extent fill outline start stipple style]} % drop width=>unscalable
	 [] 'bitmap' then
	    F={List.last {Source tkReturnList(itemconfigure(Tag "-foreground") $)}} in
	    R=tk(crea rect b(B) stipple:gray25 fill:F outline:F)
	 [] 'image' then
	    R=tk(crea rect b(B) stipple:gray25 fill:black outline:black)
	 [] 'line' then
	    R={GetParams Tr [fill stipple smooth capstyle joinstyle splinesteps]} %drop arrows=>unscalable
	 [] 'oval' then
	    R={GetParams Tr [fill stipple outline]}
	 [] 'polygon' then
	    R={GetParams Tr [fill smooth outline stipple splinesteps]}
	 [] 'rectangle' then
	    R={GetParams Tr [fill stipple outline]}
	 [] 'text' then
	    R={GetParams tk(crea rect b(B) stipple:gray25 outline:black) [fill]}
	 else R=tk(type Tag)
	 end
	 case {IsFree R} then
	    false
	 else
	    {Dest R}
	    true
	 end
      end
      proc{CopyCanvas Tag}
	 case {Copy Tag} then
	    NT in
	    NT={New Tk.canvasTag tkInit(parent:Dest)}
	    {Source tk(addtag NT above Tag)}
	    {Source tk(dtag Tag)}
	    {CopyCanvas NT} % copie le suivant
	 else skip end
      end
   in
      {CopyCanvas Start}
      {Dest tk(move all ~DX ~DY)} % ramene l'origine a (0,0)
   end
      
   meth getPSOptions(canvas:Canvas
		     title:Title <= "Postscript Generation Options"
		     region:SelReg <=[0 0 200 200]
		     zoom:InitZoom <=1.0
		     rotate:InitRotate <=false
		     fit:InitFit<=false
		     pagewidth:InitPageW <= "210m"
		     pageheight:InitPageH <= "297m"
		     pagex:InitPageX <="10m"
		     pagey:InitPageY <="10m"
		     width:InitW<=NoArgs
		     height:InitH<=NoArgs
		     colormode:InitColor<=mono
		     x:InitX <=0
		     y:InitY <=0
		     return:Return)
      Zoom={NewCell 1.0}
      X1 Y1 X2 Y2 Width Height
      PageZoom={Tk.returnFloat tk(scaling)}
      T
       F1
        F2 L1 C 
        F3 L2 E1 L3 E2 L4
        F4 L5 L51 E3 L6 E4 L7
        B1
       F5
        F51 L8 C2 R1 R2 L18 L19 V1
        L9 Menu M1 F6
        F7 V2 R3 R4 R5
        F8 L11 E5 L12 B2 B3
        F9 L13 L14 L15 L16 E6 E7 E8 E9 L17 B4 B41
       F10 B5 B6
      Read
      Z={NewPort Read}
      class MyClass

	 feat pagetag ps ctag cbtag cctag ptag pbtag pctag

	 attr rotate pagew pageh pagex pagey w h x y zoom state orgx orgy
	    fit
	    ppw pph ppx ppy scale dx dy color
	    
	 meth init
	    StandardDialog,copyCanvas(Canvas C X1 Y1)
	    self.ps=['Custom'#""#""
		     'Fit To Canvas'#""#"Fit"
		     'Letter (8.5"x11")'#"8.5i"#"11i"
		     'Legal (8.5"x14")'#"8.5i"#"14i"
		     'Tabloïd (11"x17")'#"11i"#"17i"
		     'A (8,5"x11")'#"8.5i"#"11i"
		     'B (11"x17")'#"11i"#"17i"
		     'C (17"x22")'#"17i"#"22i"
		     'D (22"x34")'#"22i"#"34i"
		     'E (34"x44")'#"34i"#"44i"
		     'A4 (210mmx297mm)'#"210m"#"297m"
		     'A3 (297mmx420mm)'#"297m"#"420m"
		     'A2 (420mmx594mm)'#"420m"#"594m"
		     'A1 (594mmx841mm)'#"594m"#"841m"
		     'A0 (841mmx1189mm)'#"841m"#"1189m"
		     'B5(JIS) (182mmx257mm)'#"182m"#"257m"]
	    case InitFit then
	       case {Nth self.ps 2} of L#W#H then
		  {M1 tk(configure menu:Menu text:L)}
	       end
	       fit<-true
	    else
	       case {Nth self.ps 1} of L#W#H then
		  {M1 tk(configure menu:Menu text:L)}
	       end
	       fit<-false
	    end
	    {List.forAllInd self.ps
	     proc{$ I E}
		case E of L#W#H then
		   _={New Tk.menuentry.command tkInit(parent:Menu
						      label:L
						      action:Z#selectps(L W H))}
		   case @fit==false andthen W==InitPageW andthen H==InitPageH then
		      {M1 tk(configure menu:Menu text:L)}
		   else skip end
		end
	     end}
	    case InitW==NoArgs then
	       w<-Width
	    else
	       case {IsInt InitW} then
		  w<-{IntToFloat InitW}
	       else
		  w<-InitW
	       end
	    end
	    case InitH==NoArgs then
	       h<-Height
	    else
	       case {IsInt InitH} then
		  h<-{IntToFloat InitH}
	       else
		  h<-InitH
	       end
	    end
	    case {IsInt InitX} then
	       x<-{IntToFloat InitX}
	    else
	       x<-InitX
	    end
	    case {IsInt InitY} then
	       y<-{IntToFloat InitY}
	    else
	       y<-InitY
	    end
	    {self updcanvasentry}
	    self.ctag={New Tk.canvasTag tkInit(parent:C)}
	    self.cbtag={New Tk.canvasTag tkInit(parent:C)}
	    {self.cbtag tkBind(event:"<Enter>"
			       action:Z#setcursor(C fleur))}
	    {self.cbtag tkBind(event:"<Leave>"
			       action:Z#setcursor(C left_ptr))}
	    {self.cbtag tkBind(event:"<1>"
			       args:[float(x) float(y)]
			       action:Z#startcmove)}
	    self.cctag={New Tk.canvasTag tkInit(parent:C)}
	    {self.cctag tkBind(event:"<Enter>"
			       action:Z#setcursor(C sizing))}
	    {self.cctag tkBind(event:"<Leave>"
			       action:Z#setcursor(C left_ptr))}
	    {self.cctag tkBind(event:"<1>"
			       args:[float(x) float(y)]
			       action:Z#startcsize)}
	    {C tkBind(event:"<B1-Motion>"
		      args:[float(x) float(y)]
		      action:Z#cmove)}
	    {C tkBind(event:"<B1-ButtonRelease>"
		      args:[float(x) float(y)]
		      action:Z#crelease)}
	    {self drawcsel}
	    zoom<-InitZoom
	    {E5 tk(insert 0 {FloatToInt InitZoom*100.0})}
	    self.pagetag={New Tk.canvasTag tkInit(parent:C2)}
	    pageh<-InitPageH
	    pagew<-InitPageW
	    pagex<-InitPageX
	    pagey<-InitPageY
	    rotate<-InitRotate
	    {self updpageentry}
	    {self calcsize}
	    {self drawpage}
	    self.ptag={New Tk.canvasTag tkInit(parent:C2)}
	    self.pbtag={New Tk.canvasTag tkInit(parent:C2)}
	    self.pctag={New Tk.canvasTag tkInit(parent:C2)}
	    {self.pbtag tkBind(event:"<Enter>"
			       action:Z#setcursor(C2 fleur))}
	    {self.pbtag tkBind(event:"<Leave>"
			       action:Z#setcursor(C2 left_ptr))}
	    {self.pbtag tkBind(event:"<1>"
			       args:[float(x) float(y)]
			       action:Z#startpmove)}
	    {self.pctag tkBind(event:"<Enter>"
			       action:Z#setcursor(C2 sizing))}
	    {self.pctag tkBind(event:"<Leave>"
			       action:Z#setcursor(C2 left_ptr))}
	    {self.pctag tkBind(event:"<1>"
			       args:[float(x) float(y)]
			       action:Z#startpsize)}
	    {C2 tkBind(event:"<B1-Motion>"
		      args:[float(x) float(y)]
		      action:Z#pmove)}
	    {C2 tkBind(event:"<B1-ButtonRelease>"
		      args:[float(x) float(y)]
		      action:Z#prelease)}
	    {self drawpsel}
	    color<-InitColor
	    state<-0
	 end

	 meth startcmove(X Y)
	    state<-1 % mode deplacement de la selection
	    orgx<-X orgy<-Y
	 end

	 meth startcsize(X Y)
	    state<-2 % mode resize de la selection
	    orgx<-X orgy<-Y
	 end

	 meth cmove(X Y)
	    Scale={Access Zoom} in
	    case @state
	    of 1 then % deplacement de la selection
	       DX=(X-@orgx)/Scale
	       DY=(Y-@orgy)/Scale
	       NX=@x+DX
	       NY=@y+DY
	    in
	       case NX<0.0 then
		  x<-0.0
	       elsecase NX+@w>=Width then
		  x<-Width-@w
	       else
		  x<-NX
		  orgx<-X
	       end
	       case NY<0.0 then
		  y<-0.0
	       elsecase NY+@h>=Height then
		  y<-Height-@h
	       else
		  y<-NY
		  orgy<-Y
	       end
	       {self drawcsel}
	       {self setentry(E3 @x)}
	       {self setentry(E4 @y)}
	    [] 2 then % resize
	       DX=(X-@orgx)/Scale
	       DY=(Y-@orgy)/Scale
	       NW=@w+DX
	       NH=@h+DY
	    in
	       case NW<10.0 then
		  w<-10.0
		  orgx<-(@x+7.0)*Scale
	       elsecase NW+@x>Width then
		  w<-Width-@x
		  orgx<-(@x+@w-1.0)*Scale
	       else
		  w<-NW
		  orgx<-X
	       end
	       case NH<10.0 then
		  h<-10.0
		  orgy<-(@y+7.0)*Scale
	       elsecase NH+@y>Height then
		  h<-Height-@y
		  orgy<-(@y+@h-1.0)*Scale
	       else
		  h<-NH
		  orgy<-Y
	       end
	       {self drawcsel}
	       {self setentry(E1 @w)}
	       {self setentry(E2 @h)}
	    else skip end
	 end

	 meth crelease(X Y)
	    {self cmove(X Y)} % pour prendre en compte cet endroit-ci
	    {self updpsel}
	    state<-0 % retour a l'etat normal
	 end

	 meth cselall
	    x<-0.0
	    y<-0.0
	    w<-Width
	    h<-Height
	    {self drawcsel}
	    {self updpsel}
	    {self updcanvasentry}
	 end
	 
	 meth updc(Which)
	    fun {GetVal E}
	       {E tkReturn(get $)}
	    end
	    Val
	 in
	    case Which
	    of w then
	       case {self stringToFloat({GetVal E1} Val $)} then
		  case @x+Val>=Width then
		     w<-Width-@x
		  elsecase Val<10.0 then
		     w<-10.0
		  else
		     w<-Val
		  end
	       else
		  {Tk.send bell}
	       end
	    [] h then
	       case {self stringToFloat({GetVal E2} Val $)} then
		  case @y+Val>=Height then
		     h<-Height-@y
		  elsecase Val<10.0 then
		     h<-10.0
		  else
		     h<-Val
		  end
	       else
		  {Tk.send bell}
	       end	       
	    [] x then
	       case {self stringToFloat({GetVal E3} Val $)} then
		  case Val>Width-10.0 then
		     x<-Width-10.0
		  else
		     x<-Val
		  end
		  case @x+@w>=Width then
		     w<-Width-@x
		  else skip end
	       else
		  {Tk.send bell}
	       end	       
	    [] y then
	       case {self stringToFloat({GetVal E4} Val $)} then
		  case Val>Height-10.0 then
		     y<-Height-10.0
		  else
		     y<-Val
		  end
		  case @y+@h>=Height then
		     h<-Height-@y
		  else skip end
	       else
		  {Tk.send bell}
	       end	       
	    end
	    {self drawcsel}
	    {self updpsel}
	    {self updcanvasentry}
	 end   
	 
	 meth setcursor(C T)
	    {C tk(configure cursor:T)}
	 end
	 
	 meth updpageentry
	    {self setentry(E6 @pagew)}
	    {self setentry(E7 @pageh)}
	    {self setentry(E8 @pagex)}
	    {self setentry(E9 @pagey)}
	 end

	 meth updcanvasentry
	    {self setentry(E1 @w)}
	    {self setentry(E2 @h)}
	    {self setentry(E3 @x)}
	    {self setentry(E4 @y)}
	 end

	 meth drawsel(X1 Y1 X2 Y2 C Tag1 Tag2 Tag3)
	    {C tk(crea poly
		  X1 Y1     X1+5.0 Y1
		  X1+5.0 Y2 X1     Y2
		  width:1
		  stipple:gray75
		  fill:black
		  tags:Tag2)}
	    {C tk(crea poly
		  X2 Y1     X2-5.0 Y1
		  X2-5.0 Y2 X2     Y2
		  width:1
		  stipple:gray75
		  fill:black
		  tags:Tag2)}
	    {C tk(crea poly
		  X1 Y1     X1 Y1+5.0
		  X2 Y1+5.0 X2 Y1
		  width:1
		  stipple:gray75
		  fill:black
		  tags:Tag2)}
	    {C tk(crea poly
		  X1 Y2     X1 Y2-5.0
		  X2 Y2-5.0 X2 Y2
		  width:1
		  stipple:gray75
		  fill:black
		  tags:Tag2)}
	    {C tk(crea rect
		  X2-5.0 Y2-5.0 X2 Y2
		  width:1
		  outline:black
		  fill:black
		  tags:Tag3)}
	    {C tk(addtag Tag1 withtag Tag2)}
	    {C tk(addtag Tag1 withtag Tag3)}
	 end

	 meth drawcsel
	    X1 Y1 X2 Y2
	    Scale={Access Zoom}
	 in
	    {self.ctag tk(delete)}
	    X1=@x*Scale Y1=@y*Scale X2=(@x+@w-1.0)*Scale Y2=(@y+@h-1.0)*Scale
	    {self drawsel(X1 Y1 X2 Y2 C self.ctag self.cbtag self.cctag)}
	 end
	 
	 meth selectps(L W H)
	    fit<-false
	    {M1 tk(configure text:L)}
	    case W=="" then
	       case H=="Fit" then
		  fit<-true
		  {self calcsize}
		  {self drawpage}
		  {self drawpsel}		  
	       else skip end
	    else
	       pagew<-W
	       pageh<-H
	       {self updpageentry}
	       {self calcsize}
	       {self drawpage}
	       {self drawpsel}
	    end
	 end

	 meth selectcustom
	    case {Nth self.ps 1} of L#W#H then
	       {M1 tk(configure menu:Menu text:L)}
	    end
	    fit<-false
	 end
	 
	 meth rotate(B)
	    rotate<-B
	    {self calcsize}
	    {self drawpage}
	    {self drawpsel}
	 end

	 meth drawpage
	    Prop
	    H W
	 in
	    case @rotate then
	       Prop=@pph/@ppw
	    else
	       Prop=@ppw/@pph
	    end
	    {self.pagetag tk(delete)}
	    case Prop<1.0 then
	       H=65.0
	       W=65.0*Prop
	       case @rotate then
		  scale<-130.0/@ppw
	       else
		  scale<-130.0/@pph
	       end
	       dx<-75.0-W
	       dy<-10.0
	    else
	       W=65.0
	       H=65.0/Prop
	       case @rotate then
		  scale<-130.0/@pph
	       else
		  scale<-130.0/@ppw
	       end
	       dx<-10.0
	       dy<-75.0-H
	    end
	    {C2 tk(crea rect
		   80.0-W 80.0-H
		   80.0+W 80.0+H
		   fill:black
		   outline:black
		   tags:self.pagetag)}
	    {C2 tk(crea rect
		   75.0-W 75.0-H
		   75.0+W 75.0+H
		   fill:white
		   outline:black
		   tags:self.pagetag)}
	 end

	 meth pointToUnit(Val Str Return)
	    case {StringToAtom [{List.last Str}]}
	    of m then Return={VirtualString.toString Val/72.0*25.4#"m"}
	    [] c then Return={VirtualString.toString Val/72.0*2.54#"c"}
	    [] i then Return={VirtualString.toString Val/72.0#"i"}
	    else Return={VirtualString.toString Val#"p"}
	    end
	 end 
	 
	 meth calcsize
	    case @fit then
	       %
	       % la taille depend de ce qui a ete selectionne dans le canvas
	       %
	       case @rotate then
		  ppw<-(@h/PageZoom)*@zoom
		  pph<-(@w/PageZoom)*@zoom
	       else
		  ppw<-(@w/PageZoom)*@zoom
		  pph<-(@h/PageZoom)*@zoom
	       end
	       ppx<-0.0
	       ppy<-0.0
	       pagew<-{self pointToUnit(@ppw @pagew $)}
	       pageh<-{self pointToUnit(@pph @pageh $)}
	       pagex<-{self pointToUnit(@ppx @pagex $)}
	       pagey<-{self pointToUnit(@ppy @pagey $)}
	       {self updpageentry}
	    else
	       fun{T E Old}
		  Val Unit CV CU in
		  case {self extract({E tkReturn(get $)} Val Unit $)} then
		     CV=Val CU=Unit
		  else
		     {self setentry(E Old)} % revient a l'ancienne valeur
		     {Tk.send bell}
		     case {self extract(Old CV CU $)} then
			skip
		     else
			raise badInitialValue end
		     end
		  end
		  case CU
		  of m then % conversion millimetres a points
		     (CV/25.4)*72.0
		  [] c then
		     (CV/2.54)*72.0
		  [] i then
		     CV*72.0
		  [] p then
		     CV
		  end
	       end
	    in
	       ppw<-{T E6 @pagew}
	       case @ppw<10.0 then
		  ppw<-10.0
		  pagew<-{self pointToUnit(@ppw {E6 tkReturn(get $)} $)}
		  {self setentry(E6 @pagew)}
	       else
		  pagew<-{E6 tkReturn(get $)}
	       end
	       pph<-{T E7 @pageh}
	       case @pph<10.0 then
		  pph<-10.0
		  pageh<-{self pointToUnit(@pph {E7 tkReturn(get $)} $)}
		  {self setentry(E7 @pageh)}
	       else
		  pagew<-{E6 tkReturn(get $)}
	       end
	       pageh<-{E7 tkReturn(get $)}
	       ppx<-{T E8 @pagex} pagex<-{E8 tkReturn(get $)}
	       ppy<-{T E9 @pagey} pagey<-{E9 tkReturn(get $)}
	       {self updpageentry}
	    end
	 end

	 meth drawpsel
	    X1 Y1 X2 Y2
	    W=(@w/PageZoom)*@zoom
	    H=(@h/PageZoom)*@zoom
	    IW=W/72.0
	    IH=H/72.0
	    fun{R V}
	       {Float.round V*10.0}/10.0
	    end
	 in
	    {self.ptag tk(delete)}
	    X1=@dx+@scale*@ppx
	    Y1=@dy+@scale*@ppy
	    X2=X1+@scale*W
	    Y2=Y1+@scale*H
	    {C2 tk(crea poly
		   X1 Y1 X1 Y2
		   X2 Y2 X2 Y1
		   fill:black
		   stipple:gray75
		   tags:self.pbtag)}
	    {C2 tk(crea rect
		   X2-3.0 Y2-3.0
		   X2 Y2
		   fill:black
		   tags:self.pctag)}
	    {C2 tk(addtag self.ptag withtag self.pbtag)}
	    {C2 tk(addtag self.ptag withtag self.pctag)}
	    {L19 tk(configure
		    text:{R IW*2.54}#"c x "#{R IH*2.54}#"c\n"#
		    {FloatToInt IW*25.4}#"m x "#{FloatToInt IH*25.4}#"m\n"#
		    {R IW}#"i x "#{R IH}#"i\n"#
		    {FloatToInt W}#"p x "#{FloatToInt W}#"p")}
	 end
	 
	 meth updpsel
	    %
	    % La taille de la zone selectionnee du canvas a change !
	    % On doit le prendre en compte ici
	    %
	    case @fit then
	       {self calcsize}
	       {self drawpage}
	    else skip end
	    {self drawpsel}
	 end
	 
	 meth startpmove(X Y)
	    case @fit then
	       {self selectcustom}
	    else skip end
	    orgx<-X
	    orgy<-Y
	    state<-3
	 end

	 meth startpsize(X Y)
	    {self selectcustom}
	    orgx<-X
	    orgy<-Y
	    state<-4
	 end

	 meth pmove(X Y)
	    case @state
	    of 3 then
	       DX DY NX NY
	    in
	       DX=X-@orgx
	       DY=Y-@orgy
	       NX=@ppx+DX/@scale
	       NY=@ppy+DY/@scale
	       case NX<0.0 then
		  ppx<-0.0
	       else
		  ppx<-NX
		  orgx<-X
	       end
	       case NY<0.0 then
		  ppy<-0.0
	       else
		  ppy<-NY
		  orgy<-Y
	       end
	       {self drawpsel}
	    [] 4 then
	       X1=@dx+@scale*@ppx
	       Y1=@dy+@scale*@ppy
	       OldH=@scale*(@w/PageZoom)*@zoom
	       OldW=@scale*(@h/PageZoom)*@zoom
	       NewW=X-X1
	       NewH=Y-Y1
	       Zoom1=@zoom*NewW/OldW
	       Zoom2=@zoom*NewH/OldH
	       Zoom
	       case Zoom1<Zoom2 then Zoom=Zoom1 else Zoom=Zoom2 end
	    in
	       case Zoom<0.1 then
		  zoom<-0.1
	       else
		  zoom<-Zoom
	       end
	       {self drawpsel}
	    else skip end
	 end

	 meth prelease(X Y)
	    case @state
	    of 3 then
	       {self pmove(X Y)}
	       pagex<-{self pointToUnit(@ppx @pagex $)}
	       pagey<-{self pointToUnit(@ppy @pagey $)}
	       {self setentry(E8 @pagex)}
	       {self setentry(E9 @pagey)}
	    [] 4 then skip
	       {self setentry(E5 @zoom*100.0)}
	    else skip end
	    state<-0
	 end
	 
	 meth updp(Which)
	    case @fit then
	       {self selectcustom}
	    elsecase (Which==w orelse Which==h) andthen (@pagew\={E6 tkReturn(get $)} orelse @pageh\={E7 tkReturn(get $)}) then
	       {self selectcustom}
	    else skip end
	    {self calcsize}
	    {self drawpage}
	    {self drawpsel}
	 end   

	 meth chgzoom
	    Val in
	    case {self stringToFloat({E5 tkReturn(get $)} Val $)} then
	       case Val<10.0 then
		  zoom<-0.1
	       else
		  zoom<-Val/100.0
	       end
	       case @fit then
		  {self calcsize}
		  {self drawpage}
	       else skip end
	       {self drawpsel}
	    else
	       {Tk.send bell}
	    end
	    {self setentry(E5 @zoom*100.0)}
	 end
	 
	 meth hcenter
	    case @fit then
	       skip
	    else
	       case @rotate then
		  ppx<-(@pph-(@w/PageZoom)*@zoom)/2.0
	       else 
		  ppx<-(@ppw-(@w/PageZoom)*@zoom)/2.0
	       end
	       case @ppx<0.0 then ppx<-0.0 else skip end
	       pagex<-{self pointToUnit(@ppx @pagex $)}
	       {self setentry(E8 @pagex)}
	       {self drawpsel}
	    end
	 end

	 meth vcenter
	    case @fit then
	       skip
	    else
	       case @rotate then
		  ppy<-(@ppw-(@h/PageZoom)*@zoom)/2.0
	       else
		  ppy<-(@pph-(@h/PageZoom)*@zoom)/2.0
	       end
	       case @ppy<0.0 then ppy<-0.0 else skip end
	       pagey<-{self pointToUnit(@ppy @pagey $)}
	       {self setentry(E9 @pagey)}
	       {self drawpsel}
	    end
	 end

	 meth zoom100
	    zoom<-1.0
	    {self setentry(E5 100)}
	    case @fit then
	       {self calcsize}
	       {self drawpage}
	    else skip end
	    {self drawpsel}
	 end

	 meth zoomfit
	    case @fit then
	       skip
	    else
	       CW=@w/PageZoom
	       CH=@h/PageZoom
	       H W
	       case @rotate then
		  H=@ppw-2.0*@ppy
		  W=@pph-2.0*@ppx
	       else
		  H=@pph-2.0*@ppy
		  W=@ppw-2.0*@ppx
	       end
	       Zoom1=W/CW
	       Zoom2=H/CH
	       Zoom
	       case Zoom1<Zoom2 then Zoom=Zoom1 else Zoom=Zoom2 end
	    in
	       case Zoom<0.1 then
		  zoom<-0.1
	       else
		  zoom<-Zoom
	       end
	       {self drawpsel}
	       {self setentry(E5 @zoom*100.0)}
	    end
	 end

	 meth chgcolor(Val)
	    color<-Val
	 end
	 
	 meth setentry(E Val)
	    {E tk(delete 0 {E tkReturnInt(index('end') $)}+1)}
	    {E tk(insert 0 Val)}
	 end

	 meth stringToFloat(Str ?Val ?Ok)
	    fun{LoopRight Xs Fact Val}
	       case Xs of X|Xr then
		  case X<48 orelse X>57 then
		     false
		  else
		     {LoopRight Xr Fact*10.0 Val+{IntToFloat (X-48)}/Fact}
		  end
	       else
		  Val
	       end
	    end
	    fun{LoopLeft Xs Val}
	       case Xs of X|Xr then
		  case X==46 then % le point
		     {LoopRight Xr 10.0 Val}
		  elsecase X<48 orelse X>57 then
		     false
		  else
		     {LoopLeft Xr Val*10.0+{IntToFloat X-48}}
		  end
	       else
		  Val
	       end
	    end
	 in
	    Val={LoopLeft Str 0.0}
	    Ok=(Val\=false)
	 end

	 meth extract(Str ?Val ?Unit ?Ok)
	    case {Length Str}<2 then
	       Ok=false
	    else
	       Unit={StringToAtom [{List.last Str}]}
	       case Unit\=m andthen Unit\=c andthen Unit\=p andthen Unit\=i then
		  Ok=false
	       else
		  St
	       in
		  {self stringToFloat({List.take Str {Length Str}-1} Val Ok)}
	       end   
	    end
	 end
	 
	 meth resize(H W)
	    Fact
	    Size S1 Scale
	 in
	    case H<W then S1=H-10.0 else S1=W-10.0 end
	    case S1<50.0 then Size=50.0 else Size=S1 end
	    case Width>Height then
	       Scale=Size/Width
	    else
	       Scale=Size/Height
	    end
	    Fact=Scale/{Access Zoom}
	    {C tk(scale all 0 0 Fact Fact)}
	    {Assign Zoom Scale}
	    {C tk(configure width:Width*Scale-6.0 height:Height*Scale-6.0)}
	    {self drawcsel}
	 end

	 meth ok
	    Return=postscript(
		      height:@h
		      width:@w
		      x:@x
		      y:@y
		      pagewidth:@pagew
		      pageheight:@pageh
		      fit:@fit
		      pagex:@pagex
		      pagey:@pagey
		      rotate:@rotate
		      colormode:@color
		      zoom:@zoom
		      tkx:(~1.0*@ppx*PageZoom+@x*@zoom)
		      tky:(~1.0*@ppy*PageZoom+@y*@zoom)
		      tkwidth:@ppw*PageZoom
		      tkheight:@pph*PageZoom
		      )
	 end

	 meth cancel
	    Return=''
	 end
      end
      proc{Bind E Event}
	 {E tkBind(event:"<FocusOut>"
		   action:Z#Event)}
	 {E tkBind(event:"<Key-Return>"
		   action:Z#Event)}
      end
   in
      [X1 Y1 X2 Y2]={Map SelReg fun{$ V}
				   case {IsInt V} then
				      {IntToFloat V}
				   else
				      V
				   end
				end}
      Width=X2-X1+1.0
      Height=Y2-Y1+1.0
      T={New Tk.toplevel tkInit(title:Title
				withdraw:true)}
      F1={New Tk.frame tkInit(parent:T
			      relief:ridge
			      borderwidth:2)}
      F2={New Tk.frame tkInit(parent:F1 width:10 height:10)}
      {F2 tkBind(event:"<Configure>"
		 args:[float(h) float(w)]
		 append:true
		 action:Z#resize)}
      L1={New Tk.label tkInit(parent:F1
			      text:"Place the area to print below"
			      anchor:w)}
      C={New Tk.canvas tkInit(parent:F2
			      bg:{Canvas tkReturn(cget("-background") $)}
			      relief:ridge
			      width:100
			      height:100
			      borderwidth:2
			      highlightthickness:0)}
      F3={New Tk.frame tkInit(parent:F1)}
      L2={New Tk.label tkInit(parent:F3
			      text:"Size :")}
      E1={New Tk.entry tkInit(parent:F3
			      width:6
			      background:white)}
      {Bind E1 updc(w)}
      L3={New Tk.label tkInit(parent:F3
			      text:"X")}
      E2={New Tk.entry tkInit(parent:F3
			      width:6
			      background:white)}
      {Bind E2 updc(h)}
      L4={New Tk.label tkInit(parent:F3
			      anchor:w
			      text:" screen units")}
      F4={New Tk.frame tkInit(parent:F1)}
      L5={New Tk.label tkInit(parent:F4
			      text:"Origin :")}
      L51={New Tk.label tkInit(parent:F4
			       text:"(")}
      E3={New Tk.entry tkInit(parent:F4
			      width:6
			      background:white)}
      {Bind E3 updc(x)}
      L6={New Tk.label tkInit(parent:F4
			      text:",")}
      E4={New Tk.entry tkInit(parent:F4
			      width:6
			      background:white)}
      {Bind E4 updc(y)}
      L7={New Tk.label tkInit(parent:F4
			      anchor:w
			      text:")")}
      B1={New Tk.button tkInit(parent:F1
			       text:"Select whole canvas"
			       action:Z#cselall)}
      F5={New Tk.frame tkInit(parent:T
			      relief:ridge
			      borderwidth:2)}
      F51={New Tk.frame tkInit(parent:F5)}
      L8={New Tk.label tkInit(parent:F51
			      anchor:w
			      text:"Place the area to print on the page below")}
      C2={New Tk.canvas tkInit(parent:F51
			       background:white
			       width:150
			       height:150
			       relief:sunken
			       borderwidth:2)}
%      L10={New Tk.label tkInit(parent:F51
%			       text:"Orientation :")}
      V1={New Tk.variable tkInit(InitRotate)}
      R1={New Tk.radiobutton tkInit(parent:F51
				    text:"Portait"
				    value:false
				    variable:V1
				    action:Z#rotate(false)
				    anchor:w)}
      R2={New Tk.radiobutton tkInit(parent:F51
				    text:"Landscape"
				    value:true
				    variable:V1
				    action:Z#rotate(true)
				    anchor:w)}
      L18={New Tk.label tkInit(parent:F51
			       anchor:w
			       justify:left
			       text:"Size :")}
      L19={New Tk.label tkInit(parent:F51
			       anchor:n
			       justify:center
			       text:"1c x 1c")}
      F6={New Tk.frame tkInit(parent:F5)}
      L9={New Tk.label tkInit(parent:F6
			      text:"Page size :")}
      M1={New Tk.menubutton tkInit(parent:F6
				   text:""
				   width:25
				   relief:raised)}
      Menu={New Tk.menu tkInit(parent:M1
			       tearoff:false
			       type:normal)}
      F7={New Tk.frame tkInit(parent:F5)}
      V2={New Tk.variable tkInit(InitColor)}
      R3={New Tk.radiobutton tkInit(parent:F7
				    text:"Color"
				    value:color
				    variable:V2
				    action:Z#chgcolor(color)
				    anchor:w)}
      R4={New Tk.radiobutton tkInit(parent:F7
				    text:"Greyscale"
				    value:gray
				    variable:V2
				    action:Z#chgcolor(gray)
				    anchor:w)}
      R5={New Tk.radiobutton tkInit(parent:F7
				    text:"B&W"
				    value:mono
				    variable:V2
				    action:Z#chgcolor(mono)
				    anchor:w)}
      F8={New Tk.frame tkInit(parent:F5)}
      L11={New Tk.label tkInit(parent:F8
			       text:"Zoom :")}
      E5={New Tk.entry tkInit(parent:F8
			      background:white
			      width:6)}
      {Bind E5 chgzoom}
      L12={New Tk.label tkInit(parent:F8
			       text:"%")}
      B2={New Tk.button tkInit(parent:F8
			       pady:0
			       text:"Best Fit"
			       action:Z#zoomfit)}
      B3={New Tk.button tkInit(parent:F8
			       pady:0
			       text:"100%"
			       action:Z#zoom100)}
      F9={New Tk.frame tkInit(parent:F5
			      relief:sunken
			      borderwidth:2)}
      L13={New Tk.label tkInit(parent:F9
			       text:"Page width :"
			       anchor:e)}
      L14={New Tk.label tkInit(parent:F9
			       text:"height :"
			       anchor:e)}
      L15={New Tk.label tkInit(parent:F9
			       text:"Left margin :"
			       anchor:w)}
      L16={New Tk.label tkInit(parent:F9
			       text:"Top margin :"
			       anchor:w)}
      E6={New Tk.entry tkInit(parent:F9
			      background:white
			      width:10)}
      {Bind E6 updp(w)}
      E7={New Tk.entry tkInit(parent:F9
			      background:white
			      width:10)}
      {Bind E7 updp(h)}
      E8={New Tk.entry tkInit(parent:F9
			      background:white
			      width:10)}
      {Bind E8 updp(x)}
      E9={New Tk.entry tkInit(parent:F9
			      background:white
			      width:10)}
      {Bind E9 updp(y)}
      L17={New Tk.label tkInit(parent:F9
			       justify:left
			       anchor:nw
			       text:"m=millimeters,\nc=centimeters,\np=printer points,\ni=inches.")}
      B4={New Tk.button tkInit(parent:F9
			       text:"Center"
			       pady:0
			       action:Z#hcenter)}
      B41={New Tk.button tkInit(parent:F9
				text:"Center"
				pady:0
				action:Z#vcenter)}
      F10={New Tk.frame tkInit(parent:T)}
      B5={New Tk.button tkInit(parent:F10
			       text:"Ok"
			       action:Z#ok)}
      B6={New Tk.button tkInit(parent:F10
			       text:"Cancel"
			       action:Z#cancel)}
      {T tkBind(event:"<Escape>"
		action:Z#cancel)}
      {Tk.batch [% main window
		 grid(F1  row:0 column:0 sticky:nswe padx:5 pady:5)
		 grid(F5  row:0 column:1 sticky:nswe padx:5 pady:5)
		 grid(F10 row:1 column:0 columnspan:2 sticky:nswe)
		 grid(columnconfigure T 0 weight:1)
		 grid(rowconfigure    T 0 weight:1)
		 % Source size selection frame
		 grid(L1 row:0 column:0 sticky:we   padx:5 pady:5)
		 grid(F2 row:1 column:0 sticky:nswe padx:5)
		 grid(F3 row:2 column:0 sticky:we   padx:5 pady:2)
		 grid(F4 row:3 column:0 sticky:we   padx:5 pady:2)
		 grid(B1 row:4 column:0 sticky:we   padx:5 pady:5)
		 grid(columnconfigure F1 0 weight:1)
		 grid(rowconfigure    F1 1 weight:1)
		 % Source canvas selection frame
		 pack(C fill:none expand:true)
		 % Source text selection
		 pack(L2 side:left fill:x padx:5)
		 pack(E1 L3 E2 side:left fill:x)
		 pack(L4 side:left fill:x padx:5)
		 pack(L5 side:left fill:y padx:5)
		 pack(L51 E3 L6 E4 L7 side:left fill:y)
		 % Output size selection frame
		 pack(F51 F6 F9 side:top expand:false fill:x padx:5 pady:5)
		 pack(F7 F8 side:top expand:false fill:x pady:2)
		 % Output text selection
		 grid(L8 row:0 column:0 columnspan:2 sticky:nswe pady:5)
		 grid(C2 row:1 column:0 rowspan:5 padx:5)
		 grid(R1 row:1 column:1 sticky:nswe padx:5 pady:5)
		 grid(R2 row:2 column:1 sticky:nswe padx:5 pady:5)
		 grid(L18 row:3 column:1 sticky:nswe padx:5)
		 grid(L19 row:4 column:1 sticky:nswe padx:5)
		 grid(columnconfigure F51 0 weight:1)
		 grid(rowconfigure    F51 5 weight:3)
		 pack(L9 M1 side:left fill:x padx:5)
		 pack(R3 R4 R5 side:left padx:5)
		 grid(columnconfigure F7 1 weight:1)
		 pack(L11 side:left padx:5)
		 pack(E5 L12 side:left)
		 pack(B2 B3 side:left padx:5)
		 grid(L13 row:0 column:0 sticky:we padx:2 pady:2)
		 grid(L14 row:1 column:0 sticky:we padx:2 pady:2)
		 grid(L15 row:2 column:0 sticky:we padx:2 pady:2)
		 grid(L16 row:3 column:0 sticky:we padx:2 pady:2)
		 grid(E6  row:0 column:1 sticky:we padx:2 pady:2)
		 grid(E7  row:1 column:1 sticky:we padx:2 pady:2)
		 grid(E8  row:2 column:1 sticky:we padx:2 pady:2)
		 grid(E9  row:3 column:1 sticky:we padx:2 pady:2)
		 grid(L17 row:0 column:2 rowspan:2 sticky:we padx:2 pady:2)
		 grid(B4  row:2 column:2 sticky:we padx:2 pady:2)
		 grid(B41 row:3 column:2 sticky:we padx:2 pady:2)
		 grid(columnconfigure F9 2 weight:1)
		 % Ok/Cancel buttons
		 pack(B5 B6 side:left padx:5 pady:5)
		 wm(deiconify T)
		 grab(T)]}
      local ThId in
	 thread
	    Obj
	    proc{Loop Xs}
	       Skip in
	       case Xs of X|Xr then
		  case {Label X}==cmove andthen {IsDet Xr} then
		     case Xr of Y|Yr then
			case {Label Y}==cmove then
			   Skip=unit
			else skip end
		     else skip end
		  elsecase {Label X}==pmove andthen {IsDet Xr} then
		     case Xr of Y|Yr then
			case {Label Y}==pmove then
			   Skip=unit
			else skip end
		     else skip end
		  else skip end
		  case {IsFree Skip} then {Obj X} else skip end
		  {Loop Xr}
	       else skip end
	    end
	 in
	    ThId={Thread.this}
	    Obj={New MyClass init}
	    {ForAll Read
	     proc{$ Msg}
		{Obj Msg}
	     end}
	 end
	 {Wait Return}
	 {Thread.terminate ThId}
	 {Tk.send grab(release T)}
	 {T tkClose}
      end
   end
   
end

fun {NewStDialog}
   Tmp in
   Tmp={New StandardDialog tkInit}
   fun {$ P}
      Tmp2 in
      {Tmp {AdjoinAt P return Tmp2}}
      Tmp2
   end
end

DialogBox={NewStDialog}


%local T C T2 C2 O in
%   T={New Tk.toplevel tkInit(title:"Source"
%			     withdraw:true)}
%   C={New Tk.canvas tkInit(parent:T
%			   bg:white)}
%   {Tk.send pack(C)}
%%   T2={New Tk.toplevel tkInit(title:"Dest")}
%%   C2={New Tk.canvas tkInit(parent:T2)}
%%   {Tk.send pack(C2)}
%   {C tk(crea line 100 100 110 110 30 110 fill:green width:10)}
%   {C tk(crea rect 10 100 20 110 fill:green outline:red stipple:gray25)}
%   {C tk(crea oval 40 10 50 20 fill:blue)}
%   {C tk(crea text 10 100 text:"Hello" fill:black)}
%   {C tk(crea bit 10 40 anchor:c background:red foreground:blue bitmap:hourglass)}
%   {C tk(crea arc 20 20 50 50 start:45 extent:~90 style:pieslice fill:orange outline:gray)}
%   {C tk(crea poly 150 10 160 40 120 90 fill:red)}
%%   O={New StandardDialog tkInit}
%%   {O copyCanvas(C C2)}
%   O={DialogBox getPSOptions(canvas:C
%			     pagewidth:"Fit"
%			     zoom:1.0
%%			     colormode:grey
%			     region:[1 1 250 250])}
%   case O=='' then skip else
%      {Browse O}
%      {C tk(crea rect
%	    ~1000000 ~1000000
%	    1000000 O.y-1.0
%	    fill:white
%	    outline:white)}
%      {C tk(crea rect
%	    ~1000000 ~1000000
%	    O.x-1.0   1000000
%	    fill:white outline:white)}
%      {C tk(crea rect
%	    O.x+O.width+1.0 ~1000000
%	    1000000   1000000
%	    fill:white outline:white)}
%      {C tk(crea rect
%	    ~1000000 1000000
%	    1000000  O.y+O.height+1.0
%	    fill:white outline:white)}
%      {C tk(scale all 0 0 O.zoom O.zoom)} % applique le zoom
%      {C tk(postscript
%	    colormode:O.colormode
%	    pagewidth:O.pagewidth
%	    pageheight:O.pageheight
%	    pagex:O.pagex
%	    pagey:O.pagey
%	    width:O.tkwidth
%	    height:O.tkheight
%	    x:O.tkx
%	    y:O.tky
%	    file:"Test.ps")}
%      {Tk.send wm(deiconify T)}
%   end
%end
