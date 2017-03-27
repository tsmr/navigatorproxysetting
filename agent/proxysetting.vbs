'Author: Valentin DEVILLE & MTeck (Stackoverflow)

const HKEY_USERS = &H80000003
strComputer = "."
PUBLIC strUsers, UserName

Function StripAccents(str)
	accent   = "��������������������������"
	noaccent = "EEEEUUIIAAOOCeeeeuuiiaaooc"
	currentChar = ""
	result = ""
	k = 0
	o = 0

	For k = 1 To len(str)
		currentChar = mid(str,k, 1)
		o = InStr(1, accent, currentChar, 1)
		If o > 0 Then
			result = result & mid(noaccent,o,1)
		Else
			result = result & currentChar
		End If
	Next
	StripAccents = result
End Function
	
on error resume next
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")


Set StdOut = WScript.StdOut
Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer &  "\root\default:StdRegProv")
strKeyPath = ""
oReg.EnumKey HKEY_USERS, strKeyPath, arrKeys
For Each key In arrKeys
'len(key) > 35 AND
   If Instr(key,"Classes") = 0 Then
      'key = SID
	  Set objAccount = objWMIService.Get("Win32_SID.SID='" & key & "'")
	  UserName = objAccount.AccountName
      'Set objNetwork = CreateObject("WScript.Network")
      'Set objShell = CreateObject("WScript.Shell")
      'Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
      'Set objAccount = objWMIService.Get("Win32_UserAccount.Name='" & objNetwork.UserName & "',Domain='" & objNetwork.UserDomain & "'")
      If UserName <> "" then

         Set shell = WScript.CreateObject("WScript.Shell")
         proxyEnable = shell.RegRead ("HKEY_USERS\"& key &"\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyEnable")
         proxyServerKey = "HKEY_USERS\"& key &"\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyServer"
         proxyOverrideKey = "HKEY_USERS\"& key &"\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyOverride"
         autoConfigURLKey = "HKEY_USERS\"& key &"\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\AutoConfigURL"
         'detectAutoKey = "HKEY_USERS\"& key &"\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections\DefaultConnectionSettings"

         on error resume next
         proxyServer = shell.RegRead(proxyServerKey)

         if err.number<>0 then
             if right(proxyServerKey,1)="\" then
                 if instr(1,err.description,ssig,1)<>0 then
                     bExists=true
                 else
                     bExists=false
                 end if
             else
                 bExists=false
             end if
             err.clear
         else
             bExists=true
         end if
         on error goto 0
         if bExists=vbFalse then
             proxyServer = "None"
         end if


         on error resume next
         autoConfigURL = shell.RegRead(autoConfigURLKey)

         if err.number<>0 then
             if right(autoConfigURLKey,1)="\" then
                 if instr(1,err.description,ssig,1)<>0 then
                     bExists=true
                 else
                     bExists=false
                 end if
             else
                 bExists=false
             end if
             err.clear
         else
             bExists=true
         end if
         on error goto 0
         if bExists=vbFalse then
             autoConfigURL = "None"
         end if

         on error resume next
         proxyOverride = shell.RegRead(proxyOverrideKey)

         Wscript.Echo "<NAVIGATORPROXYSETTING>"
         Wscript.Echo "<USER>" & StripAccents(UserName) & "</USER>"
         Wscript.Echo "<ENABLE>" & proxyEnable & "</ENABLE>"
         Wscript.Echo "<AUTOCONFIGURL>" & autoConfigURL & "</AUTOCONFIGURL>"
         Wscript.Echo "<ADDRESS>" & proxyServer & "</ADDRESS>"
         Wscript.Echo "<OVERRIDE>" & proxyOverride & "</OVERRIDE>"
         Wscript.Echo "</NAVIGATORPROXYSETTING>"
      End If
   End If
Next

