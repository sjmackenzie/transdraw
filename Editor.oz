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
   Tk TkTools Open OS Pickle Remote Module
   System
   Application
   Connection
   Property
   
require NedTools(get:GNed)

define
   Windows=({Property.get 'platform'}.os=='win32')
   Args={Application.getCmdArgs plain}
   DialogBox={GNed Tk System Pickle OS Open $}

   AllwaysProceed={NewCell false}

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % security achievement
   %

   proc{Security Operation Text OKProc CANCELException}
      case {Access AllwaysProceed} then
	 {OKProc}
      else
	 Return in
	 Return={DialogBox message(title:"Security manager"
				   text:"Operation : "#Operation#"\n"#Text
				   bitmap:question
				   justify:left
				   buttons:["Ok" "Allways OK" "Ignore" "Cancel" "Help"])}
	 case Return
	 of 0 then
	    {OKProc}
	 [] 1 then
	    {Assign AllwaysProceed true}
	    {OKProc}
	 [] 2 then
	    skip
	 [] 3 then
	    raise CANCELException end
	 [] 4 then
	    _={DialogBox message(title:"Security manager help"
				 text:"The dialogbox allows you to accept or cancel the execution of an instruction that can be dangerous to your computer\n\n"#"The Ok button allows the execution of just this command.\n"#"The Allways Ok button allows always the execution of potentially dangerous commands.\n"#"The Ignore Button just skip the command, which may crash the program.\n"#"The Cancel button prevents the execution, which may surely crash the program.\n\n"#"If you don't trust the site from which you launched the program, it may be dangerous to allow all commands !"
				 bitmap:info
				 justify:left
				 buttons:ok)}
	    {Security Operation Text OKProc CANCELException}
	 end
      end
   end
	 
	 
   % OS part

   proc{SafeOSUnlink P1}
      {Security "Delete a file ?" "File : "#P1 proc{$} {OS.unlink P1} end 'UserPreventedUnlink'}
   end
   
   proc{SafeOSPutEnv P1 P2}
      {Security "Set environment variable ?" "setenv "#P1#" "#P2 proc{$} {OS.putEnv P1 P2} end 'UserPreventedPutEnv'}
   end

   proc{SafeOSSystem P1 P2}
      {Security "Start a new shell ?" "Command : "#P1 proc{$} {OS.system P1 P2} end 'UserPreventedShell'}
   end

   proc{SafeOSSocket P1 P2 P3 P4}
      {Security "Accept a socket creation ?" "Domain : "#P1#",protocol :"#P3 proc{$} {OS.socket P1 P2 P3 P4} end 'UserPreventedSocket'}
   end

   proc{SafeOSConnect P1 P2 P3}
      {Security "Connect to a socket ?" "Host : "#P2 proc{$} {OS.connect P1 P2 P3} end 'UserPreventedConnect'}
   end

   proc{SafeOSPipe P1 P2 P3 P4}
      {Security "Forks a pipe ?" "Command : "#P1 proc{$} {OS.pipe P1 P2 P3 P4} end 'UserPreventedPipe'}
   end
   
   proc{SafeOSOpen P1 P2 P3 P4}
      {Security "Open a file ?" "File : "#P1#", mode "#P2#" ?" proc{$} {OS.open P1 P2 P3 P4} end 'UserPreventedLoading'}
   end
   
   SafeOS={AdjoinList OS [unlink#SafeOSUnlink putEnv#SafeOSPutEnv system#SafeOSSystem socket#SafeOSSocket connect#SafeOSConnect pipe#SafeOSPipe open#SafeOSOpen]}

   % Open part
   
   class SafeOpenFile

      from Open.file

      meth init(name: NameV 
		flags:FlagsAs <= [read]
		mode: ModeR   <= mode(owner:[write] all:[read]))

	 case {Member write FlagsAs} orelse
	    {Member create FlagsAs} orelse
	    {Member append FlagsAs} orelse
	    {Member truncate FlagsAs} then
	    {Security "Open a file for writing ?" "File : "#NameV proc{$} Open.file,init(name:NameV flags:FlagsAs mode:ModeR) end 'UserPrenventedFileOpening'}
	 else
	    Open.file,init(name:NameV flags:FlagsAs mode:ModeR)
	 end	 
      end

   end

   SafeOpen={AdjoinList Open [file#SafeOpenFile]}

   % Pickle part

   proc{SafePickleSave P1 P2}
      {Security "Save a pickle to a file ?" "File : "#P2 proc{$} {Pickle.save P1 P2} end 'UserPreventedPickleSave'}
   end
   
   proc{SafePickleSaveCompressed P1 P2 P3}
      {Security "Save a pickle to a file ?" "File : "#P2 proc{$} {Pickle.saveCompressed P1 P2} end 'UserPreventedPickleSave'}
   end
   
   proc{SafePickleSaveWithHeader P1 P2 P3 P4}
      {Security "Save a pickle to a file ?" "File : "#P2 proc{$} {Pickle.saveWithHeader P1 P2} end 'UserPreventedPickleSave'}
   end
   
   SafePickle={AdjoinList Pickle [save#SafePickleSave saveCompressed#SafePickleSaveCompressed saveWithHeader#SafePickleSaveWithHeader]}

   % System part

   SafeSystem=System

   % Remote part

   class SafeRemoteManager

      from Remote.manager

      meth init(host:   HostV   <= localhost
		fork:   ForkA   <= automatic
		detach: DetachB <= false)
	 {Security "Allow remote execution ?" "On system : "#HostV proc{$} Remote,init(host:HostV fork:ForkA detach:DetachB) end 'UserPreventedRemoteExecution'}
      end
   end

   SafeRemote='export'(manager:SafeRemoteManager)
   
   % Connection part

   proc{SafeConnectionOffer P1 P2}
      {Security "Offer a connection ?" "Ticket : "#P2 proc{$} {Connection.offer P1 P2} end 'UserPreventedConnectionOffer'}
   end

   proc{SafeConnectionTake P1 P2}
      {Security "Take a connection ?" "Ticket : "#P1 proc{$} {Connection.take P1 P2} end 'UserPreventedConnectionTake'}
   end

   class SafeConnectionGate

      from Connection.gate

      meth init(X TicketA)
	 {Security "Offer a connection ?" "Ticket : "#TicketA proc{$} Connection.gate,init(X TicketA) end 'UserPreventedConnectionOffer'}
      end

   end

   SafeConnection={AdjoinList Connection [offer#SafeConnectionOffer take#SafeConnectionTake gate#SafeConnectionGate]}

   % Tk security achievement
   
%   {Tk.send v("toplevel .mysafe")}
%   {Tk.send v("wm withdraw .mysafe")}
%   {Tk.send v("set slave [::safe::loadTk [::safe::interpCreate] -use .mysafe]")}
%   {Tk.send v("set slave [::safe::interpCreate]")}
   {Tk.send tk_setPalette(grey)}
   
   local
      DEBUG=0
      SLOWNETWORK=0
      DELAY=0
      SERVER
      CLIENT
      TEMP
      TICKET
      Show=proc{$ I} {System.showInfo {StringToAtom {VirtualString.toString I}}} end
      Browse=proc{$ I} skip end
      Usage=proc{$}
	       {Show " "}
	       {Show "Usage: Client [-h] [-s] <ticket or url> [UserName]"}
	       {Show "       where -h displays the command line parameters"}
	       {Show "             -s runs a secured version of the editor"}
	       {Show "             <ticket or url> is the place where to get the ticket"}
	       {Show "             UserName is the name of the user (default:NoName)"}
	       {Show " "}
	       {Application.exit 2}
	    end
   in
      case Args==nil orelse
	 case Args of "-h"|X then true else false end orelse
	 case Args of "-?"|X then true else false end
      then
	 {Usage}
      else
	 Safe F1 M L B Error
	 proc{Insert Msg}
	    {L tk(insert 'end' Msg)}
	 end
      in
	 case Args of "-s"|F2 then
	    F1=F2
	    Safe=true
	 else
	    F1=Args
	    Safe=false
	 end
	 case F1==nil then
	    Error=unit
	    {Usage} 
	 elsecase F1 of F|R then
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
		  {Insert "Retrieving application"}
		  try
		     {SERVER getclientclass(NEWCLIENT)}
		  catch X then Error=unit end
		  case {IsDet Error} then
		     {Insert "Error : unable to get the application back."}
		  else
		     case R==nil then Txt='NoName'
		     else Txt={StringToAtom {List.drop {List.flatten {List.map R fun{$ T} " "|T end}} 1}}
		     end
		     {Insert "Linking to local resources"}
		     try
			case Safe then
			   {NEWCLIENT Tk TkTools SafeOpen SafeOS SafePickle SafeSystem SafeRemote SafeConnection Txt TEMP Quit 0 0 0 SERVER} % on demande un client
			else
			   {NEWCLIENT Tk TkTools Open OS Pickle System Remote Connection Txt TEMP Quit 0 0 0 SERVER} % on demande un client
			end
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
	 end
	 case {IsDet Error} then
	    skip % ne termine pas
	 else
	    {Application.exit 0}
	 end
      end
      {Application.exit 0}
   end
end
