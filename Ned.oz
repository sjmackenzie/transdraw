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

import
   System Connection Application
   Open OS Pickle Remote Module
   NedTools(get:GNed)
   Server(serverObject:ServerObject
	  serverDialog:ServerDialog)
   Property
   Tk TkTools
   
define
   Windows=({Property.get 'platform'}.os=='win32')
   Args={Application.getCmdArgs record(mode:start
				       nogui(single
					     char:&n
					     optional:true)
				       pickle(single
					      type:string
					      optional:true)
				       load(single
					    type:string
					    optional:true)
				       help(single
					    char:[&h &?])
				       demo(single)
				       mono(single)
				       debug(single)
				       slownet(single)
				       editor(single)
				       terminate(single)
				      )}
   if {HasFeature Args nogui} then
      skip
   else
      {Tk.send tk_setPalette(grey)}
   end
   TICKET Quit ServerGui Help
   proc{Load Server}
      case {HasFeature Args load} then
	 try
	    WH
	    {Pickle.load Args.load WH}
	 in
	    {ForAll {List.sort WH fun{$ A B} A.order<B.order end}
	     proc{$ S}
		{Server createobj('dummy' S)}
		{Server releaselock('dummy' S.id)}
	     end}
	 catch X then
	    S=tree(type:text
		   x1:10.0 y1:10.0
		   x2:500.0 y2:30.0
		   c1:red c2:red
		   id:{NewName}
		   text:r(text:{VirtualString.toString "Unable to load the file : "#Args.load}
			  font:r(fam:'Times' size:10 bold:false underline:false italic:false)
			  width:491.0
			  height:21.0
			  x:10.0
			  y:10.0
			  justify:left)
		   width:1.0
		   order:1)
	 in
	    {Server createobj('dummy' S)}
	    {Server releaselock('dummy' S.id)}
	 end
      else skip end
   end
in
   case {HasFeature Args help} then Help=unit
   elsecase {HasFeature Args editor} orelse {HasFeature Args terminate} then
      case {Length Args.1}>0 then skip else Help=unit end
   elsecase {Length Args.1}>0 then Help=unit
   else skip end
   case {IsDet Help} then
      {System.showInfo " "}
      {System.showInfo "Usage : TransDraw [-h] [-n] [--pickle="#'"filename"'#"] [--load="#'"filename"'#"]"}
      {System.showInfo "   or : TransDraw --demo [--debug] [--slownet] [--load="#'"filename"'#"]"}
      {System.showInfo "   or : TransDraw --mono [--debug] [--slownet] [--load="#'"filename"'#"]"}
      {System.showInfo "   or : TransDraw --editor Ticket_or_URL_of_pickled_ticket [Name of the user]"}
      {System.showInfo "   or : TransDraw --terminate Ticket_or_URL_of_pickled_ticket"}
      {System.showInfo " "}
      {System.showInfo "where -h displays this message"}
      {System.showInfo "      -n doesn't start the GUI interface"}
      {System.showInfo "      --pickle saves the ticket of the server in the specified file"}
      {System.showInfo "      --load loads the specified TransDraw file"}
      {System.showInfo " "}
      {System.showInfo "      --demo starts a local drawing with two editors"}      
      {System.showInfo "      --debug adds a debug button"}
      {System.showInfo "      --slownet adds a slownetwork button (simulates a slow network)"}
      {System.showInfo " "}
      {System.showInfo "      --mono is the same as --demo with only one editor"}
      {System.showInfo " "}
      {System.showInfo "      --editor starts an editor connected to the drawing specified"}
%      {System.showInfo " "}
%      {System.showInfo "      --terminate kills the drawing specified. Use with care"}
      {System.showInfo " "}
      {Application.exit 0}
   else
      proc {NewAsynch Cl Init ?AObj}
	 P={NewPort S}
	 X={New Cl Init}
	 S
      in
	 proc {AObj M}
	    {Send P M}
	 end
	 thread
	    {ForAll S
	     proc{$ M}
		{X M}
	     end}
	 end
      end
   in
      case {HasFeature Args demo} orelse {HasFeature Args mono} then
	 SERVER NEWCLIENT Client1 Client2 Quit1 Quit2 SLOWNETWORK DEBUG DELAY
      in
	 case {HasFeature Args slownet} then SLOWNETWORK=1 else SLOWNETWORK=0 end
	 case {HasFeature Args debug} then DEBUG=7 else DEBUG=0 end
	 DELAY=3000
	 SERVER={NewAsynch ServerObject init(OS)}
	 {SERVER set(SERVER)}
	 {SERVER getclientclass(NEWCLIENT)}
	 {Load SERVER}
	 thread
	    {NEWCLIENT Tk TkTools Open OS Pickle System Remote Connection 'Client 1' Client1 Quit1 DEBUG SLOWNETWORK DELAY SERVER}
	    {Client1 subscribe(windows:Windows)}
	 end
	 case {HasFeature Args demo} then
	    thread
	       {NEWCLIENT Tk TkTools Open OS Pickle System Remote Connection 'Client 2' Client2 Quit2 DEBUG SLOWNETWORK DELAY SERVER}
	       {Client2 subscribe(windows:Windows)}
	    end
	 else Quit2=unit end
	 {Wait Quit1}
	 {Wait Quit2}
	 {Application.exit 0}
      elsecase {HasFeature Args editor} then
	 SERVER TICKET
	 M L B Error Quit
	 proc{Insert Msg}
	    {L tk(insert 'end' Msg)}
	 end
	 SLOWNETWORK
	 case {HasFeature Args slownet} then
	    SLOWNETWORK=1
	 else
	    SLOWNETWORK=0
	 end
      in
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
	 case Args.1 of F|R then
	    case {Length F}>13 andthen {List.take F 13}=="x-ozticket://" then
	       TICKET=F
	    else
	       {Insert "Retrieving ticket from "#F}
	       try
		  TICKET={Pickle.load F}
	       catch X then Error=unit end
	    end
	    case {IsDet Error} then
	       {Insert "Error : wrong URL (still available ?)"}
	    else
	       {Insert "Connecting to the server"}
	       try
		  {Connection.take TICKET SERVER}
	       catch X then Error=unit end
	       case {IsDet Error} then
		  {Insert "Error : wrong ticket (is the drawing server still alive ?)"}
	       else
		  TEMP NEWCLIENT Quit Txt in
		  {Insert "Ticket : "#TICKET}
		  {Insert "Using local editor code"}
		  local LOCALSERVER in
		     LOCALSERVER={NewAsynch ServerObject init(OS)}
		     {LOCALSERVER set(LOCALSERVER)}
		     {LOCALSERVER getclientclass(NEWCLIENT)}
		  end
		  {Insert "Linking to local resources"}
		  case R==nil then Txt='NoName'
		  else Txt={StringToAtom {List.drop {List.flatten {List.map R fun{$ T} " "|T end}} 1}}
		  end
		  try
		     {NEWCLIENT Tk TkTools Open OS Pickle System Remote Connection Txt TEMP Quit 0 SLOWNETWORK 2000 SERVER} % on demande un client
		  catch X then Error=unit end
		  case {IsDet Error} then
		     {Insert "Error : version conflict ?"}
		  else
		     {Insert "Starting application"}
		     {TEMP subscribe(windows:Windows)}
		     {Tk.send grab(release B)}
		     {M tkClose}
		     {Wait Quit}
		  end
	       end
	    end
	 end
	 case {IsDet Error} then
	    skip % ne termine pas
	 else
	    {Application.exit 0}
	 end
      elsecase {HasFeature Args terminate} then
	 SERVER TICKET
	 M L B Error Quit
	 proc{Insert Msg}
	    {L tk(insert 'end' Msg)}
	 end
	 SLOWNETWORK
	 case {HasFeature Args slownet} then
	    SLOWNETWORK=1
	 else
	    SLOWNETWORK=0
	 end
      in
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
	 case Args.1 of F|R then
	    case {Length F}>13 andthen {List.take F 13}=="x-ozticket://" then
	       TICKET=F
	    else
	       {Insert "Retrieving ticket from "#F}
	       try
		  TICKET={Pickle.load F}
	       catch X then Error=unit end
	    end
	    case {IsDet Error} then
	       {Insert "Error : wrong URL (still available ?)"}
	    else
	       {Insert "Connecting to the server"}
	       try
		  {Connection.take TICKET SERVER}
	       catch X then Error=unit end
	       case {IsDet Error} then
		  {Insert "Error : wrong ticket (is the drawing server still alive ?)"}
	       else
		  {Insert "Ticket : "#TICKET}
		  {Insert "Terminating the server"}
		  {SERVER quit}
		  {Tk.send grab(release B)}
		  {Delay 5000}
		  {Application.exit 0}
		  {Wait Quit}
	       end
	    end
	 end
	 case {IsDet Error} then
	    skip % ne termine pas
	 else
	    {Application.exit 0}
	 end
      else
	 Server
      in
	 case {HasFeature Args nogui}==false then
	    SERVER DialogBox
	 in
	    {GNed Tk System Pickle OS Open DialogBox}
	    ServerGui={New ServerDialog init(SERVER Tk TkTools OS System Open Pickle Remote Connection DialogBox)}
	    {ServerGui startgui(Quit debug:false ticket:TICKET windows:Windows)}
	    Server=ServerGui.server
	 else
	    SERVER
	 in
	    SERVER={NewAsynch ServerObject init(OS)}
	    {SERVER set(SERVER)}
	    {New Connection.gate init(SERVER TICKET) _}
	    {SERVER setticket(TICKET)}
	    Server=SERVER
	 end
	 {Load Server}
	 case {HasFeature Args pickle} then
	    try
	       {Pickle.save TICKET Args.pickle}
	    catch X then skip end
	 else skip end
	 case {HasFeature Args nogui}==false then % attend la terminaison
	    {Wait Quit}
	    {Application.exit 0}
	 else
	    Quit
	 in
	    {Server waitQuit}
	    {Application.exit 0}
	 end % ne termine pas (snif)
      end
   end
end
