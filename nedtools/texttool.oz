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


declare

proc{Break}
   raise break end
end

proc{Next}
   raise nextloop end
end

proc{Loop Proc}
   D in
   try {Proc}
   catch
      break then D=break
   [] nextloop then D=loop
   end
   case {IsDet D} andthen D==break then
      skip
   else
      {Loop Proc}
   end
else skip end

proc{ForI Start End Step Proc}
   case (Step>0 andthen Start=<End) orelse
      (Step<0 andthen Start>=End) then
      D in
      try
	 {Proc Start}
      catch
	 break then D=break
      [] nextloop then D=loop
      end
      case {IsDet D} andthen D==break then
	 skip
      else
	 {ForI Start+Step End Step Proc}
      end
   else skip end
end

proc{While Cond Proc}
   case {Cond} then
      D in
      try
	 {Proc}
      catch
	 break then D=break
      [] nextloop then D=loop
      end
      case {IsDet D} andthen D==break then
	 skip
      else
	 {While Cond Proc}
      end
   else skip end
end

proc{RepeatUntil Proc Cond}
   D in
   try
      {Proc}
   catch
      break then D=break
   [] nextloop then D=loop
   end
   case ({IsDet D} andthen D==break) orelse {Cond} then
      skip
   else
      {RepeatUntil Proc Cond}
   end
end

fun{Max A B}
   case A>B then A else B end
end

fun{Min A B}
   case A<B then A else B end
end

class RichText

   feat insertproc tag canvas tabproc lineorg
   attr lenlo defaultfont defaultcolor y x len
      defaultsize

   meth init(y:Y x:X length:L
	     canvas:Canvas
	     font:Font   <='Times'
	     size:Size <=10
	     color:Color <='black'
	     insert:InsertProc <= proc{$ Old ?New} New=Old end
	     tab:TabProc <= proc{$ L ?T}
			       L={List.mapInd {MakeList 20}
				  fun{$ I N} I*40#left end}
			    end)
      self.canvas=Canvas
      self.insertproc=InsertProc
      self.tabroc=TabProc
      defaultfont<-Font
      defaultcolor<-Color
      defaultsize<-Size
      x<-X % origine de tout le texte
      y<-Y
      len<-L
      self.lineorg={NewDictionary}
      lenlo<-0
      RichText,AddLine(1)
   end

   meth setfont(F)
      defaultfont<-F
   end

   meth setcolor(C)
      defaultcolor<-C
   end

   meth getfont(?F)
      F=@defaultfont
   end

   meth getcolor(?C)
      C=@defaultcolor
   end

   meth AddLine(Nu)      
      case Nu=1 then
	 % premiere ligne
	 NewLine in
	 NewLine=r(line:{NewDictionary}  % ligne vide
		   len:{NewCell 0}       % d'ou lg=0
		   just:{NewCell left}   % justif gauche par defaut
		   width:{NewCell @len}  % lg max de la ligne affichable
		   height:{NewCell 0}    % rien a afficher => hauteur zero
		   posy:{NewCell @y}     % position verticale
		   posx:{NewCell @x}     % position horizontale
		   padx:{NewCell 0}      % pad horizontal
		   pady:{NewCell 0}      % bcz interligne de 0
		   newline:{NewCell 0}   % a 1 si termine par eol
		  )
      else
	 % lignes suivantes, en considerant que l'on continue la ligne
	 % precedente (hyp implicite)
	 OldLine NewLine C Left Right in
	 OldLine={Nth @lineorg Nu-1}
	 {self.insertproc r(nu:Nu
			    x:{Access OldLine.posx}
			    y:{Access OldLine.posy}+{Access OldLine.pady}+{Access OldLine.height}
			    width:{Access OldLine.width}) C}
	 NewLine=r(line:{NewDictionary}
		   len:{NewCell 0}
		   just:{NewCell {Access OldLine.just}}
		   width:{NewCell C.width}
		   height:{NewCell 0}
		   posy:{NewCell C.y}
		   posx:{NewCell C.x}
		   padx:{NewCell 0}
		   pady:{NewCell {Access OldLine.pady}}
		   newline:{NewCell 0}
		  )
      end
      {ForI @lenlo Nu ~1
       proc{$ I}
	  {Dictionary.put self.lineorg I+1
	   {Dictionary.get self.lineorg I}}
       end}
      {Dictionary.put self.lineorg Nu NewLine}
      lenlo<-@lenlo+1
   end

   meth XyToWord(X Y ?WordNu ?Char)
%      proc{Count Xs I}
%	 case Xs of Z|Zs then
%	    case X=<I+{Length Z.word} then % on a trouve le bon mot
%	       Word=Z
%	       Char=X-I
%	    else
%	       % loop
%	       {Count Zs I+{Length Z.word}}
%	    end
%	 else
%	    % beyond the line
%	    Word={List.last {Access {Nth @lineorg Y}.line}}
%	    Char={Length Word.word}+1
%	 end
%      end
%   in
%      {Count {Access {Nth @lineorg Y}.line} 0}
      Line={Dictionary.get self.lineorg Y}
      I={NewCell 0} J={NewCell 0}
   in
      {While fun{$} X=<{Access I} andthen {Access J}<{Access Line.len} end
       proc{$}
	  {Assign J {Access J+1}}
	  {Assign I {Access I}+{Length {Dictionary.get Line.line {Access J}}}}
       end}
      case X=<{Access I} then
	 WordNu={Access J}
	 Char=X-({Access I}-{Length {Dictionary.get Line.line {Access J}}})
      else
	 WordNu={Access Line.len} % dernier mot
	 Char={Length {Dictionary.get Line.line WordNu}}+1
      end
   end

   meth PosToWord(Pos ?Line ?WordNu ?Char)
%      proc{FindLine Xs I Y}
%	 case Xs of Z|Zs then
%	    L in
%	    L={List.foldL {Access Z.line} fun{$ Y X}
%					     {Length X.word}+Y
%					  end 0}+{Access Z.newline}
%	    case Pos=<I+L then % on a trouve la bonne ligne
%	       Line=Y
%	       RichText,XyToWord(Pos-I Line Word Char)
%	    else
%	       % loop
%	       {FindLine Zs I+L Y+1}
%	    end
%	 else
%	    % beyond the end of the text
%	    Line={Length @lineorg}
%	    Word={List.last {Access {List.last @lineorg}.line}}
%	    Char={Length Word.word}+1
%	 end
%      end
%   in
%      {FindLine @lineorg 0 1}
      fun{Len I ?N}
	 Li={Dictionary.get self.lineorg I}
	 L={NewCell 0}
	 {ForI 1 {Access Li.len} 1
	  proc{$ I}
	     {Assign L {Access L}+{Length {Dictionary.get Li.line I}}}
	  end}
	 N={Access Li.newline}==1
	 Len={Access L}+{Access Li.newline}
      end
   in
      X={NewCell Pos}
      Y=1
      {Loop
       proc{$}
	  L N in
	  case {Access Y}>@lenlo then % a la fin
	     {Break}
	  else L={Len {Access Y} N} end
	  case N then % ligne se terminant par un newline
	     case L=<X then
		{Assign X {Access X}-L}
	     else {Break} end % trouve !
	  elsecase L<X then
	     {Assign X {Access X}-L}
	  else {Break} end % trouve !
	  {Assign Y {Access Y}+1}
       end}
      case {Access Y}>@lenlo then
	 T in
	 Line=@lenlo
	 T={Dictionary.condGet self.lineorg Line nil}
	 case T==nil then
	    WordNu=0
	    Char=1
	 else
	    WordNu={Access Line.len}
	    Char={Length {Dictionary.condGet Line.line WordNu nil}}+1
	 end
      else
	 Line={Access Y}
	 RichText,XyToWord({Access X} {Access Y} WordNu Char)
      end
   end
	 
   meth xyToPos(X Y ?Pos)
      W C
      P={NewCell 0}
      L
   in
      RichText,XyToWord(X Y W C)
      % ajoute les lignes precedentes
      {ForI 1 Y-1 1
       proc{$ I}
	  L={Dictionary.get self.lineorg I} in
	  {ForI 1 {Access L.len} 1
	   proc{$ J}
	      {Assign P {Access P}+{Length {Dictionary.get L.line J}}}
	   end}
	  {Assign P {Access P}+{Access L.newline}}
       end}
      % ajoute la ligne en cours
      L={Dictionary.get self.lineorg Y}
      {ForI 1 W-1 1
       proc{$ I}
	  {Assign P {Access P}+{Length {Dictionary.get L.line I}}}
       end}
      % ajoute aussi le caractere en cours
      Pos={Access P}+C
   end

   meth PosToxy(Pos ?X ?Y)
      W C
      P={NewCell 0}
   in
      RichText,PosToWord(Pos Y W C)
      L={Dictionary.get self.lineorg Y}
      {ForI 1 W-1
       proc{$ I}
	  {Assign P {Access P}+{Length {DIctionary.get L.line I}}}
       end}
      X={Access P}+C
   end

   meth ListToWord(Liste ?Word)
      Height={NewCell 0}
      Width={NewCell 0}
      X Y
   in
      Tag={New Tk.canvasTag tkInit(parent:self.canvas)}
      {ForAll Liste
       proc{$ C}
	  case C.height>{Access Height} then {Assign Height C.height} else skip end
	  {Assign Width {Access Width}+C.width}
	  {self.canvas tk(addtag Tag withtag C.tag)}
       end}
      Word=r(word:Liste
	     height:{Access Height}
	     width:{Access Width}
	     x:X % keeps that unbound
	     y:Y % unbound
	     tag:Tag
	     left:nil
	     right:nil)
   end
   
   meth Split(Word Pos ?Out1 ?Out2)
      Left Right in
      {List.takeDrop Word Pos Left Right}
      RichText,ListToWord(Left Out1)
      RichText,ListToWord(Right Out2)
      Out1.x=Word.x
      Out1.y=Word.y+Word.height-Out1.height
      Out2.x=Word.x+Out1.width
      Out2.y=Word.y+Word.height-Out2.height
      {self.canvas tk(dtag Word.tag)}
   end

   meth Merge(Word1 Word2 ?Out)
      Out=r(word:{Append Word1.word Word2.word}
	    height:{Max Word1.height Word2.height}
	    width:Word1.width+Word2.width
	    x:Word1.x
	    y:Word1.y
	    tag:Word1.tag % recupere ce tag-ci
	    left:nil
	    right:nil)
      case Word2.height>Word1.height then
	 {self.canvas tk(move Word1.tag
			 0 Word2.height-Word1.height)}
      else skip end
      % positionne Word2 correctement
      {self.canvas tk(coords Word2.tag
		      Word1.x+Word1.width
		      Out.y+Out.height-Word2.height)}
      {self.canvas tk(addtag Out.tag withtag Word2.tag)}
      {self.canve tk(dtag Word2.tag)}
   end

   meth print(x:XP          <=nil
	      y:YP          <=nil
	      pos:PosP      <=nil
	      word:WordNuP  <=nil
	      char:CharP    <=nil
	      text:TextList)

      LineNu={NewCell 0}
      WordNu={NewCell 0}
      CharNu={NewCell 0}
      Line={NewCell nil}
      Word={NewCell nil}

      % Step 1 : trouver le pt d'insertion, c'est a dire
      % le numero de ligne, le numero de mot et le numero de caractere

      case PosP\=nil then
	 % on recoit le numero de position du caractere
	 %
	 % Si Pos trop grand => on pointe apres le dernier caractere
	 %                      de la derniere ligne
	 %
	 L W C in
	 RichText,PosToWord(PosP L W C)
	 {Assign LineNu L}
	 {Assign Word W}
	 {Assign Line {Nth @lineorg L}}
	 {Assign CharNu C}
	 {Assign WordNu 1+{Length {List.takeWhile {Access Line}
				   fun{$ A}
				      A\=W
				   end}}}
      elsecase YP\=nil andthen XP\=nil then
	 % on recoit des coordonnees X et Y
	 L W C in
	 case YP>{Length @lineorg} then
	    {Assign LineNu {Length @lineorg}}
	    {Assign Line {List.last @lineorg}}
	    {Assign WordNu {Length {Access LineNu}.line}}
	    {Assign Word {List.last {Access LineNu}.line}}
	    {Assign CharNu {Length {Access Word}.word}+1}
	 else
	    RichText,XyToWord(XP YP W C)
	    {Assign LineNu YP}
	    {Assign Word W}
	    {Assign Line {Nth @lineorg YP}}
	    {Assign CharNu C}
	    {Assign WordNu 1+{Length {List.takeWhile {Access Line}
				      fun{$ A}
					 A\=W
				      end}}}
	 end
      elsecase YP\=nil andthen WordNuP\=nil andthen CharP\=nil then
	 % on recoit les numeros de ligne, word et caractere
	 case YP>{Length @lineorg} then
	    {Assign LineNu {Length @lineorg}}
	    {Assign Line {List.last @lineorg}}
	    {Assign WordNu {Length {Access LineNu}.line}}
	    {Assign Word {List.last {Access LineNu}.line}}
	    {Assign CharNu {Length {Access Word}.word}+1}
	 else	 
	    {Assign LineNu YP}
	    {Assign WordNu WordNuP}
	    {Assign CharNu CharNuP}
	    {Assign Line {Nth @lineorg YP}}
	    {Assign Word {Nth {Access Line} CharNuP}}
	 end
      else
	 raise noPlaceSpecifiedForPrinting end
      end
      % regarde si on ne doit pas creer un nouveau mot
      local
	 CH % hauteur en cours
	 CF % font en cours
	 CO % couleur en cours
	 TKF% nom Tcl/Tk au complet
	 SI % size en cours
	 BO IT UN OV % bold, italic, underline, overstrike
	 fun{GetFont}
	    T in
	    T={VirtualString.toString
	       {Access CF} # " " #
	       {Access SI} # " " #
	       case {Access BO} then
		  "bold "
	       else
		  "normal "
	       end # 
	       case {Access IT} then
		  "italic "
	       else
		  "roman "
	       end #
	       case {Access UN} then
		  "underline "
	       else
		  "" % ou nil
	       end #
	       case {Access OV} then
		  "overstrike"
	       else
		  ""
	       end}
	    CH={NewCell {StringToInt
			 {Nth
			  {Tk.returnList font(metrics T)}
			  6}}}
	    T
	 end				
	 fun{GetWord Xs ?R}
	    L W X
	    proc{Add Char}
	       NC Tag in
	       NC=r(char:[Char]
		    tag:{New Tk.canvasTag tkInit(parent:self.canvas)}
		    height:{Access CH}
		    width:{Tk.returnInt font(measure {GetFont} [Char])})
	       {self.canvas tk(crea text
			       {Access X} % coordonnees en X
			       ~10000-{Access CH} % coordonnees en Y
			       fill:{Access CO}
			       font:{Access TKF}
			       text:[Char]
			       justify:left
			       anchor:nw
			       tags:NC.tag)}
	       {Assign W NC|{Access W}}
	    end
	    Result
	 in
	    {NewCell Xs L}
	    {NewCell W nil}
	    {NewCell X ~10000} % coord X pour imprimer le mot d'un seul tenant
	    {RepeatUntil
	     proc{$}
		case {Access L} of Y|Ys then
		   case {IsInt Y} then
		      % insere ce caractere
		      %
		      {Add Y}
		      case Y==32 then
			 Result={Reverse {Access W}}
			 R=Ys
		      else
			 skip
		      end
		   elsecase Y
		   of newline then % return (fin de ligne)
		      case {Length {Access W}}==0 then
			 % retourne le mot special "newline"
			 Result=newline
			 R=Ys
		      else
			 % termine ce mot
			 Result={Reverse {Access W}}
			 R=Y
		      end
		   [] font#X then % chg de police de caractere
		      {Assign CF X}
		      {Assign TKF {GetFont}}
		   [] color#X then % chg de couleur
		      {Assign CO X}
%		   [] tab#X then % tabulation gauche, droite et centree
%		      skip
%		      {Break}
%		   [] pady#X then % interligne en pixels
%		      skip
%		   [] base#X then % offset de base verticale du caractere
%		      skip
%		   [] justify#X then % justification de la ligne
%		      skip
		   [] bd#X then % bold true ou false
		      {Assign BO X}
		      {Assign TKF {GetFont}}
		   [] ul#X then % underline true ou false
		      {Assign UL X}
		      {Assign TKF {GetFont}}
		   [] it#X then % italique true ou false
		      {Assign IT X}
		      {Assign TKF {GetFont}}
		   [] ov#X then % overstrike
		      {Assign OV X}
		      {Assign TKF {GetFont}}
		   [] size#X then % taille
		      {Assign SI X}
		      {Assign TKF {GetFont}}
		   else
		      raise unknownCode(Y) end
		   end
		else
		   Result=eof
		   R=nil
		end
		{Assign L Ys}
	     end
	     fun{$}
		{IsFree Result}
	     end}
	    case Result
	    of newline then
	       newline
	    else
	       W={NewCell 0}
	       H={NewCell 0}
	       Tag={New Tk.canvasTag tkInit(parent:self.canvas)}
	       {List.forAllInd Result
		proc{$ I C}
		   {Assign W {Access W}+C.width}
		   case C.height>{Access H} then
		      {Assign H C.height}
		   else skip end
		   {self.canvas tk(addtag Tag withtag C.tag)}
		end}
	       r(word:Result
		 height:{Access H}
		 width:{Access W}
		 x:~10000
		 y:~10000-{Access H}
		 tag:Tag
		 left:nil
		 right:nil)
	    end
	 end
      in
	 case {Access CharNu}>{Length {Access Word}.word} andthen
	    {List.last {Access Word}.word}==[32] then
	    % ajoute un mot a la ligne
	    T in
	    T={GetWord nil _}
	    {Assign Word T}
	    {Assign WordNu {Access WordNu}+1}
	    {Assign Line.list {Append {Access Line.list} Word}}
	 else skip end
	 CF={NewCell @defaultfont}
	 CO={NewCell @defaultcolor}
	 SI={NewCell @defaultsize}
	 {ForAll [BO IT UN OV] proc{$ C} C={NewCell false} end}
	 TKF={NewCell {Getfont}}
	 %
	 % Step 2.1 : Insertion du mot au debut de la ligne. Loop sur le
	 %            step 2.1 tant que cela peut envoyer a la ligne precedente
	 %

	 % Step 2.1.1 fusionne avec le mot precedent...

	 local
	    T WL={NewCell TextList} Rest L Old
	    Left Right
	 in
	    RichText,Split({Access Word} {Access CharNu}-1 Left Right)
	    Rest=Right|{List.drop {Dictionary.items {Access Line.line}} {Access CharNu}-1}
	    {Assign Word Left}
	    case {Access WordNu}==1 then
	       % maintenant, boucle pour essayer d'envoyer le mot a la ligne prec
	       {Loop
		proc{$}
		   case {Access Word}.width
		
	       
	    else skip end

	    % Step 2.2 : Insertion de TextList a la suite de cette ligne

	    % Step 2.3 : Insertion du reste de la ligne
	    % Step 2.3.1 : Fusion avec le premier mot
	    
	    % Step 3 : Remise en forme
	    
	 end
	    

	  
      end
      

      
   end
   

   
   meth print(Pos TextList AllowMove<=true)
      % pre : Post is integer, TextList is a valid text list, AllowMove is boolean
      % post : updates the memory structures according to the textlist and updates
      %        the display
      % warning : print(0 ...) prints before the first character,
      %           print(1 ...) prints after it
      UpdFrom % ligne a partir de laquelle on fait l'update...
              % Soit c'est celle-ci,
              % Soit c'est la ligne precedente celle-ci (cas d'un espace),
              % Soit c'est la ligne ou commence la justif s'il elle a change
      UpdTo
      UpdFromDef 
      CurLine % indique la ligne en cours de traitement
      CurNu   % indique son numero
      Offset  % indique l'offset du caractere actif sur cette ligne
      Y X1 X2 % positions pour le texte
      Justif  % justification en cours
      Font    % police de caractere en cours
      Height  % hauteur de la police de caractere active
      LineH   % hauteur d'origine de la ligne
      ToPrev  % non determine indique que le texte est susceptible de remonter une ligne
      DX DY   % coordonnees a l'ecran du caractere suivant a afficher
      MTag    % tag place sur les caracteres affiches pour les replacer si necessaire
   in
      {Show 0.01}
      CurNu={NewCell RichText,getline(Pos $ UpdFromDef)}
      Offset={NewCell UpdFromDef}
      {Show 0.02}
      % partie 1 : insertion des nouveaux caracteres, a la queuleuleu tout le monde s'eclate
      case {Length @lineorg}==0 then
	 {Show 0.03}
	 {NewCell @y Y}
	 {NewCell @x1 X1}
	 {NewCell @x2 X2}
	 lineorg<-{Append @lineorg [r(line:{NewCell nil} len:{NewCell 0}
				      just:{NewCell left} width:{NewCell 0} height:{NewCell 0}
				      newline:{NewCell 0}
				      y:{NewCell @y} x1:{NewCell @x1} x2:{NewCell @x2}
				      linetag:{New Tk.canvasTag tkInit(parent:self.canvas)}
				     )]}
	 {Assign CurNu 1}
	 CurLine={NewCell {Nth @lineorg 1}}
      else
	 {Show 0.04}
	 CL in
	 {Show 0.05}
	 CurLine={NewCell {Nth @lineorg {Access CurNu}}}
	 {Show 0.06}
	 CL={Access CurLine}
	 {Show 0.07}
	 {NewCell {Access CL.y} Y}
	 {Show 0.08}
	 {NewCell {Access CL.x1} X1}
	 {NewCell {Access CL.x2} X2}
      end
      {Show 0}
      DX={NewCell {List.foldL
		   {List.take {Access {Access CurLine}.line} {Access Offset}}
		   fun{$ Y X}
		      Y+X.w
		   end {Access {Access CurLine}.x1}}}
      DY={NewCell {Access {Access CurLine}.y}}
      {Show 0.1}
      LineH={NewCell {Access {Access CurLine}.height}}
      Justif={NewCell {Access {Access CurLine}.just}}
      Font={NewCell @defaultfont}
      Height={NewCell {StringToInt {Nth {Tk.returnList font(metrics {Access Font})} 6}} }
      {Show 0.2}
      {ForAll {Flatten TextList}
       proc{$ C}
	  case C
	  of newline then
	     CL Do in
	     case {IsFree ToPrev} % si on est encore susceptible de renvoyer a la ligne precedente
		andthen C==32 % si on insere un espace
	     then case {Access CurNu}>1 % et on n'est pas a la premiere ligne
		     andthen {Access {Nth @lineorg {Access CurNu}-1}.newline}==0 % et si pas de eol
		     andthen % et si c'est le premier sur cette ligne
		     {List.all {List.take {Access CL.line} {Access Offset}}
		      fun{$ C} C\=32 end}
		     andthen % et si cela rentre sur la ligne precedente
		     {List.foldL {List.take {Access CL.line}
				  {Access Offset}}
		      fun{$ Y X}
			 Y+X.width
		      end 0}=<{Access {Nth @lineorg {Access CurNu}-1}.x2}-{Access {Nth @lineorg {Access CurNu}-1}.x1}
		  then % alors envoie cette partie de texte rejoindre la ligne precedente
		     {Show 3}
		     CL={Access CurLine}
		     PL={Nth @lineorg {Access CurNu}-1}
		     Left Right Len
		  in
		     Do=unit
		     % reorganise les lignes correctement
		     {List.takeDrop {Access CL.line} {Access Offset} Left Right}
		     {Assign CL.line Right}
		     {Assign PL.newline 1}
		     % restaure les tags
		     {ForAll Left
		      proc{$ C}
			 {self.canvas tk(dtag C.tag PL.linetag)}
			 {self.canvas tk(addtag PL.linetag withtag C.tag)}
		      end}
		     {Show 4}
		     % restaure les structures de donnees
		     Len={List.foldL {List.take {Access CL.line}
				      {Access Offset}}
			  fun{$ Y X}
			     Y+X.w
			  end 0}
		     {Assign CL.len {Length {Access CL.line}}}
		     {Assign PL.len {Length {Access PL.line}}}
		     {Assign CL.width {Access CL.width}-Len}
		     {Assign PL.width {Access PL.width}+Len}
		     local M={NewCell 0} in
			{ForAll {Access CL.line}
			 proc{$ C}
			    case C.h>{Access M} then {Assign M C.h} else skip end
			 end}
			{Assign CL.height {Access M}}
			{Assign M 0}
			{ForAll {Access PL.line}
			 proc{$ C}
			    case C.h>{Access M} then {Assign M C.h} else skip end
			 end}
			{Assign PL.height {Access M}}
		     end
		     {Show 5}
		  else
		     ToPrev=unit % inutile de continuer a tester : faux maintenant => faux plus tard
		  end
	     else skip end
	     case {IsFree Do} then % on doit ajouter ce caractere a la ligne courrante
		{Assign CurLine l}
	     end
	  [] justify#X then
	     case X\={Access Justif} then
		proc{SetJust S E}
	           % modifie la justification des lignes comprises entre S et E
		   J in
		   J={Access Justif}
		   _={List.takeWhileInd @lineorg
		      fun{$ I L}
			 case I>=S then
			    {Assign L.just J}
			 else skip end
			 case I>E then false else true end
		      end}
%		   {ForAll {List.take {List.drop @lineorg S-1} E-S+1}
%		    proc{$ L}
%		       {Assign L.just J}
%		    end}
		end
		fun{Min A B}
		   case A<B then A else B end
		end
	     in
		{Assign Justif X}
		case {IsFree UpdFrom} then
		   UpdFrom={Min {Length
				 {List.dropWhile {Reverse {List.take @lineorg {Access CurNu}}}
				  fun{$ L} L.newline==0 end}}
			    {Access CurLine}-1}
		   {SetJust UpdFrom {Access CurNu}}
		else
		   {SetJust {Access CurNu} {Access CurNu}}
		end
	     else skip end
	  [] font#N then
	     {Assign Font N}
	     {Assign Height {StringToInt {Nth {Tk.returnList font(metrics {Access Font})} 6}}}
	  [] tab then
	     skip
	  else
	     {Show 1}
	     Char CTag Width H={Access Height} CL Do in
	     Char={VirtualString.toString [C]}
	     CTag={New Tk.canvasTag tkInit(parent:self.canvas)}
	     Width={Tk.returnInt font(measure {Access Font} Char)}
	     % imprime le caractere, a une place approximative !
	     {self.canvas tk(crea text
			     {Access DX} {Access DY}+{Access LineH}-H
			     fill:black
			     tags:CTag
			     justify:left
			     anchor:nw
			     text:Char
			     font:{Access Font})}
	     CL={Access CurLine}
	     {Show [{Access DX} {Access DY}+{Access {Access CurLine}.height}-H]}
	     {Assign DX {Access DX}+Width}
	     % Maintenant : Width = largeur du caractere, H=hauteur de celui-ci
	     %
	     % on va d'abord tester si le texte ne va pas devoir remonter d'une ligne
	     %
	     case {IsFree ToPrev} % si on est encore susceptible de renvoyer a la ligne precedente
		andthen C==32 % si on insere un espace
	     then case {Access CurNu}>1 % et on n'est pas a la premiere ligne
		     andthen {Access {Nth @lineorg {Access CurNu}-1}.newline}==0 % et si pas de eol
		     andthen % et si c'est le premier sur cette ligne
		     {List.all {List.take {Access CL.line} {Access Offset}}
		      fun{$ C} C\=32 end}
		     andthen % et si cela rentre sur la ligne precedente
		     {List.foldL {List.take {Access CL.line}
				  {Access Offset}}
		      fun{$ Y X}
			 Y+X.width
		      end 0}=<{Access {Nth @lineorg {Access CurNu}-1}.x2}-{Access {Nth @lineorg {Access CurNu}-1}.x1}
		  then % alors envoie cette partie de texte rejoindre la ligne precedente
		     {Show 3}
		     PL={Nth @lineorg {Access CurNu}-1}
		     Left Right Len
		  in
		     Do=unit
		     % reorganise les lignes correctement
		     {List.takeDrop {Access CL.line} {Access Offset} Left Right}
		     {Assign CL.line Right}
		     {Assign PL.line {Append {Append {Access PL.line} Left} r(char:Char w:Width h:H
									      tag:CTag
									      space:true)|nil}}
		     % restaure les tags
		     {ForAll Left
		      proc{$ C}
			 {self.canvas tk(dtag C.tag PL.linetag)}
			 {self.canvas tk(addtag PL.linetag withtag C.tag)}
		      end}
		     {self.canvas tk(addtag PL.linetag withtag CTag)}
		     {Show 4}
		     % restaure les structures de donnees
		     Len={List.foldL {List.take {Access CL.line}
				      {Access Offset}}
			  fun{$ Y X}
			     Y+X.w
			  end 0}
		     {Assign CL.len {Length {Access CL.line}}}
		     {Assign PL.len {Length {Access PL.line}}}
		     {Assign CL.width {Access CL.width}-Len}
		     {Assign PL.width {Access PL.width}+Len+Width}
		     local M={NewCell 0} in
			{ForAll {Access CL.line}
			 proc{$ C}
			    case C.h>{Access M} then {Assign M C.h} else skip end
			 end}
			{Assign CL.height {Access M}}
			{Assign M 0}
			{ForAll {Access PL.line}
			 proc{$ C}
			    case C.h>{Access M} then {Assign M C.h} else skip end
			 end}
			{Assign PL.height {Access M}}
		     end
		     {Show 5}
		  else
		     ToPrev=unit % inutile de continuer a tester : faux maintenant => faux plus tard
		  end
	     else skip end
	     case {IsFree Do} then % on doit ajouter ce caractere a la ligne courrante
		{Show 6}
		Char Tag Width H={Access Height} CL in
		Char={VirtualString.toString [C]}
		Tag={New Tk.canvasTag tkInit(parent:self.canvas)}
		Width={Tk.returnInt font(measure {Access Font} Char)}
		CL={Access CurLine}
		{Show 7}
		case ((C==32 andthen {Access CL.width}>=({Access CL.x2}-{Access CL.x1}+1)) orelse % espace final ne compte pas pour le word wrap
		   (C\=32 andthen {Access CL.width}+Width>=({Access CL.x2}-{Access CL.x1}+1))) andthen
		   {Length {Access CL.line}}\=0 % au moins un caractere par ligne
		then
		   {Show 8}
		   % le caractere va a la ligne suivante
		   %
		   % deux cas possibles : AllowMove true ou false (les lignes suivantes
		   % peuvent etre decalees vers le bas ou pas)
		   % deux algorithmes possibles :
		   % - methode push : on ajoute les caracteres au debut de la ligne suivante,
		   %   en poussant les caracteres suivantes le reste des lignes : MAUVAIS
		   % - methode new & pull : on insere des lignes au besoin. Des que fini, 
		   %   les insertions, on tire les caracteres des lignes suivantes, au besoin.
		   %   En meme temps, on essaie de synchroniser cela avec les lignes qui etaient
		   %   deja affichees, pour eviter le recalcul de celles-ci, si et seulemet si
		   %   AllowMove car sinon on ne peut faire de suppositions sur la longueur possible
		   %   des lignes suivantes. C'est cette methode que je vais utiliser.
		   %
		   
		   proc{InsertLine}
		      NewPos NewLine Left Right End Beg CL Tag NewC
		      {Show 8.1}
		      CL={Access CurLine}
		      {self.insertproc r(y:{Access CL.y}+{Access CL.height}+1
					 x1:{Access CL.x1} x2:{Access CL.x2}) NewC}
%		      {Box r(y:CL.y+CL.height+1 x1:CL.x1 x2:CL.x2) New}
		      {Show 8.2}
		      % CurLine est donc trop longue, et on la coupe sur la ligne suivante
		      D L C I J
		   in
		      {Show 9}
		      I={NewCell {List.length {Access CL.line}}}
		      L={Access CL.x2}-{Access CL.x1}+1
		      C={NewCell {Access CL.width}}
		      _={List.takeWhile {Reverse {Access CL.line}}
			 fun{$ O}
			    {Assign C {Access C}-O.w}
			    case {Access C}<L then % on entre dans le vif du sujet
			       case {IsFree D} then % premiere fois que l'on y vient
				  D={NewCell {Access I}+1} % endroit par defaut
			       else skip end
			       case O.space then % un espace ?
				  {Assign D {Access I}}
				  false % exit loop
			       else
				  {Assign I {Access I}-1}
				  true
			       end
			    else
			       {Assign I {Access I}-1}
			       true
			    end
			 end}
		      {Show 10}
		      case {IsFree D} then D={NewCell 1} else skip end
		      {List.takeDrop {Access CL.line} {Access D}-1 Beg End}
		      {Show '----'#Beg#End}
			 % mise jour des tags
		      Tag={New Tk.canvasTag tkInit(parent:self.canvas)}
		      {Show 11}
		      {ForAll End
		       proc{$ C}
			  {self.canvas tk(dtag C.tag CL.linetag)}
			  {self.canvas tk(addtag Tag withtag C.tag)}
		       end}
		      {List.takeDrop @lineorg {Access CurNu} Left Right}
		      NewLine=r(line:{NewCell End} len:{NewCell {Length End}}
				just:{NewCell {Access CL.just}}
				width:{NewCell
				       {List.foldL End
					   fun{$ Y X}
					      Y+X.w
					   end 0}}
				height:{NewCell {List.foldL End
						 fun{$ Y X}
						    case X.h>Y then
						       X.h else
						       Y
						    end
						 end 0}}
				newline:{NewCell {Access CL.newline}}
				y:{NewCell NewC.y} x1:{NewCell NewC.x1} x2:{NewCell NewC.x2}
				linetag:Tag)
		      {Show 12}
		      {Assign CL.newline 0}
		      {Assign CL.width {List.foldL {Access CL.line}
					fun{$ Y X}
					   Y+X.w
					end 0}}
		      {Assign CL.height {List.foldL {Access CL.line}
					 fun{$ Y X}
					    case X.h>Y then
					       X.h else Y end
					 end 0}}
		      {Show 13}
		      {Assign CurNu {Access CurNu}+1}
		      {Assign CurLine NewLine}
		      lineorg<-{Append Left NewLine|Right}
		      case {Access NewLine.width}>({Access NewLine.x2}-{Access NewLine.x1}+1) then
			 {InsertLine}
		      else skip end
		      % redessine les caracteres au bon endroit
		      local
			 Tag={New Tk.canvasTag tkInit(parent:self.canvas)}
			 X1 Y1 X2 Y2
		      in
			 {Assign DX {Access CL.x1}}
			 {Assign DY {Access CL.y}}
			 {Assign LineH {Access CL.height}}
			 {ForAll End
			  proc{$ C}
			     {self.canvas tk(addtag Tag withtag C.tag)}
			  end}
			 [X1 Y1 X2 Y2]={List.mapInd {self.canvas tkReturnListInt(bbox(Tag) $)}
					fun{$ A I}
					   case {IsEven A} then I else I+1 end
					end}
			 {self.canvas tk(move Tag {Access DX}-X1 {Access DY}-Y1)}
			 {self.canvas tk(dtag Tag)}
			 {ForAll End
			  proc{$ C}
			     {Assign DX {Access DX}+C.w}
			  end}
			 {Show 14}
		      end
		   end
		in
		   % insere le caractere
		   {Show 15}
		   {self.canvas tk(addtag CL.linetag withtag CTag)}
		   {Show 15.1}
		   {Assign CL.line {Append {Access CL.line} r(char:Char w:Width h:H
							      tag:CTag
							      space:C==32)|nil}}
		   {Show 15.2}
		   {Assign CL.width {Access CL.width}+Width}
		   {Show 15.3}
		   case H>{Access CL.height} then {Assign CL.height H} else skip end
		   % reconfigure la ligne
		   {Show 15.4}
		   {InsertLine}
		   {Show 16}
		else
		   % insere le caractere au bout, tout simplement
		   {Show 17}
		   {self.canvas tk(addtag CL.linetag withtag CTag)}
		   {Show 17.1}
		   {Assign CL.line {Append {Access CL.line} r(char:Char w:Width h:H
							      tag:CTag
							      space:C==32)|nil}}
		   {Show 17.2}
		   {Assign CL.width {Access CL.width}+Width}
		   {Show 17.3}
		   {Show H#{Access CL.height}}
		   case H>{Access CL.height} then {Assign CL.height H} else skip end
		   {Show 18}
		end
	     else skip end
	  end % case du debut
       end}
      {Show 19}
      case {IsFree UpdFrom} then
	 case UpdFromDef>1 then UpdFrom=UpdFromDef-1 else
	    UpdFrom=UpdFromDef
	 end
      else skip end
      {Show 20}
      % Maintenant, propage la justification jusqu'a ce qu'on tombe sur un newline
      local I={NewCell {Access CurNu}+1} in
	 {ForAll {List.takeWhile {List.drop @lineorg {Access CurNu}+1}
		  fun{$ L}
		     {Access L.newline}==0
		  end}
	  proc{$ L}
	     {Assign L.just {Access Justif}}
	     {Assign I {Access I}+1}
	  end}
	 UpdTo={Access I}
	 {Show 21}
%	 {Browse @lineorg}
%	 {Browse {Access {Nth @lineorg 1}.line}}
      end
      % Maintenant, reorganise les lignes suivantes
      % si AllowMove est true, on peu ne pas avoir a aller jusqu'a la fin !
      local
	 proc{Loop Nu}
	    case Nu>={Length @lineorg} then skip else
	       Line={Nth @lineorg Nu}
	       NL={Nth @lineorg Nu+1}
	       % prend de la ligne suivante
	       %
	       % Step 1, avance tant qu'on peut prendre des caracteres
	       % Step 2, recule jusqu'a un espace => on peut prendre tout cela.
	       % ensuite, reconfigure la ligne suivante
	       % si on peut tout prendre de la ligne suivante
	       %     si AllowMove => on peut s'arreter et faire remonter les lignes suivantes
	       %                     et s'arreter
	       %     si pas AllowMove => (pas d'optimisation pour le moment), on itere
	       %                         comme normalement.
	       % si on ne peut rien prendre de la ligne suivante
	       %     si AllowMove => on peut s'arreter et replacer correctement les lignes suivantes
	       %     si pas AllowMove => on itere comme normalement.
	       % Optimisations possibles pour AllowMove :
	       %     remonter une ligne de la meme largeur vers la meme largeur => pas de recalcul
	       %     reconfigurer une ligne dont la taille cible est la meme que la taille originelle
	       %     => pas de reconfiguration.
	       %
	       % En meme temps, l'algorithme redessine le texte :
	       % si la ligne n'a pas encore ete placee, il faut deplacer caractere par caractere
	       % directement a l'endroit approprie. Un champs de la ligne retient les coordonnees
	       % x et y du caractere place en haut a gauche.
	       % Si une ligne a deja ete placee, comme on connait deja la largeur du texte et sa
	       % hauteur, dans le cas de justification gauche, droite et centre, cela ne demande
	       % qu'un move du tag de la ligne.
	       % Si c'est une justification des deux cotes, on construit un tag pour chaque mot, en
	       % comptant le nombre d'espaces. Chaque mot est ensuite place directement a la bonne
	       % place en une seule fois.
	       %
	       % Ceci devrait minimiser au maximum les recalculs inutiles, ainsi que maximiser les
	       % reaffichage par groupes.
	       %
	    in
	       skip
	    end
	 end
      in
	 skip
      end


%	       
%	       case Nu
%	    NL=
%	 end
%      in
%	 {Loop {Access CurNu}}
%      end
	 



      
      % maintenant, reaffiche le tout. Deux cas possibles : speedy, c'est a dire AllowMove est true.
      % ou bien slow, c'est a dire AllowMove est false.
%      {ForAll {List.drop @lineorg UpdFrom}
%       proc{$ L}
      
   end

   meth delete
      skip
   end

   meth replace
      skip
   end

   meth move
      skip
   end

   meth resize
      skip
   end

   meth select
      skip
   end

   meth showcursor
      skip
   end

   meth getpos
      skip
   end

   meth getcoords
      skip
   end

   meth gettag
      skip
   end

   meth gettext
      skip
   end

   meth getlength
      skip
   end
   
   meth kill
      skip
   end

end

class TextTool

   feat families
   
   prop locking
   
   meth init
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

   meth chooseFont(default:Default <= nil
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
	 {Show 'deleted'}
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
   
end

local T in
   T={New TextTool init}
   {Show {T chooseFont(return:$)}}
end

%T={New Tk.toplevel tkInit}
%Can={New Tk.canvas tkInit(parent:T
%			  width:300
%			  height:300)}
%{Tk.send pack(Can)}
%C={New RichText init(Box 50 10 100 Can 'Times 10' Tab)}
%{C print(0 "Hello les petits enfants."|newline|"Hello les petits enfants. Comment allez-vous ? Moi je me porte a merveille.")}
