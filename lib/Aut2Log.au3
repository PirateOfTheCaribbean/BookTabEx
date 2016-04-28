#include-once

#include <Array.au3>

; #INDEX# =======================================================================================================================
; Title .........: Aut2Log
; AutoIt Version : 3.3.12.0++
; Language ......: English
; Description ...: An UDF to ease logging to file/console
; Author(s) .....: fede.97
; ===============================================================================================================================

; #CONSTANTS# ===================================================================================================================
Global Const $__A2L_OUT_CONSOLE = 1
Global Const $__A2L_OUT_FILE = 2
Global Const $__A2L_OUT_BOTH = $__A2L_OUT_CONSOLE + $__A2L_OUT_FILE
Global Enum $__A2L_TYPE_MESSAGE, $__A2L_TYPE_ARRAY, $__A2L_TYPE_PARAMETERS, $__A2L_TYPE_RETURN, $__A2L_TYPE_ENVINFO
; ===============================================================================================================================

; #INTERNAL CONFIGS# ============================================================================================================
Global $__LOG_ENABLE = False
Global $__LOG_OUTPUT = $__A2L_OUT_CONSOLE
If StringRight(@ScriptDir, 1) <> '\' Then
	Global $__LOG_STANDARDFILEPATH = @ScriptDir & StringFormat("\logs\%04i\%02i\logfile_%02i-%02i-%02i-%02i.log", _
	@YEAR, @MON, @MDAY, @HOUR, @MIN, @SEC)
Else
	Global $__LOG_STANDARDFILEPATH = @ScriptDir & StringFormat("logs\%04i\%02i\logfile_%02i-%02i-%02i-%02i.log", _
	@YEAR, @MON, @MDAY, @HOUR, @MIN, @SEC)
EndIf
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _Aut2Log_Settings
; _Aut2Log_WriteEnvironment
; _Aut2Log_Write
; ===============================================================================================================================

; #INTERNAL_USE_ONLY# ===========================================================================================================
;
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _Aut2Log_Settings
; Description ...: Configure logging options
; Syntax.........: _Aut2Log_Settings([$bLogging = True[, $iLogOutput = $__A2L_OUT_CONSOLE[, $sFile = $__LOG_STANDARDFILEPATH]]])
; Parameters ....: $bLogging        - Enable/Disable logging (Default = enable)
;                  $iLogOutput      - $__A2L_OUT_CONSOLE = Output to console (Default)
;                                   | $__A2L_OUT_FILE = Output to file
;                                   | $__A2L_OUT_BOTH = Output to both
;                  $sFile           - [optional] Logfile path, if not present and file logging is enabled python's logging rules
;                                     will be used
; Return values .: Success          - 0
;                  Failure          - How is this even possible? You failed really bad man...
; Author ........: fede.97
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Aut2Log_Settings($bLogging = True, $iLogOutput = $__A2L_OUT_CONSOLE, $sFile = $__LOG_STANDARDFILEPATH)
	Global $__LOG_ENABLE = $bLogging
	Global $__LOG_OUTPUT = $iLogOutput
	Global Const $__LOG_FILEPATH = $sFile
	If $bLogging = True And ($__LOG_OUTPUT = $__A2L_OUT_FILE Or $__LOG_OUTPUT = $__A2L_OUT_BOTH) Then
		Global $hLogOpen = FileOpen($__LOG_FILEPATH, 9)
		OnAutoItExitRegister('__Aut2Log_Exit')
	EndIf
	Return 0
EndFunc   ;==>_Aut2Log_Settings

; #FUNCTION# ====================================================================================================================
; Name...........: _Aut2Log_Environment
; Description ...: Get some environment informations, might be useful for debugging...
; Syntax.........: _Aut2Log_Environment()
; Parameters ....:
; Return values .: A string containing your informations
; Author ........: fede.97
; ===============================================================================================================================
Func _Aut2Log_Environment()
	Local $sEnvStats = '<Autoit>' & @CRLF & _
			'Compiled: ' & String(@OSBuild = 1) & @CRLF & _
			'AutoItVersion: ' & @AutoItVersion & @CRLF & _
			'AutoItX64: ' & String(@AutoItX64 = 1) & @CRLF & _
			'<Current User Directory>' & @CRLF & _
			'AppDataDir: ' & @AppDataDir & @CRLF & _
			'DesktopDir: ' & @DesktopDir & @CRLF & _
			'UserProfileDir: ' & @UserProfileDir & @CRLF & _
			'HomeDrive: ' & @HomeDrive & @CRLF & _
			'ProgramFilesDir: ' & @ProgramFilesDir & @CRLF & _
			'SystemDir: ' & @SystemDir & @CRLF & _
			'TempDir: ' & @TempDir & @CRLF & _
			'<System>' & @CRLF & _
			'CPUArch: ' & @CPUArch & @CRLF & _
			'KBLayout: ' & @KBLayout & @CRLF & _
			'OSLang: ' & @OSLang & @CRLF & _
			'OSVersion: ' & @OSVersion & @CRLF & _
			'OSBuild: ' & @OSBuild & @CRLF & _
			'ComputerName: ' & @ComputerName & @CRLF & _
			'UserName: ' & @UserName & @CRLF & _
			'OSBuild: ' & @OSBuild & _
			'<EXE>' & @CRLF & _
			'ScriptFullPath: ' & @ScriptFullPath & @CRLF & _
			'ScriptVer: ' & FileGetVersion (@ScriptFullPath) & @CRLF & _
			'ScriptAttrib: ' & FileGetAttrib (@ScriptFullPath) & @CRLF
	Return $sEnvStats
EndFunc   ;==>_Aut2Log_Environment

; #FUNCTION# ====================================================================================================================
; Name...........: _Aut2Log_Write
; Description ...: Does the actual work
; Syntax.........: _Aut2Log_Write(ByRef $sMessage, $iOutType[[, $bOverride = False],$iLogOutput = $__LOG_OUTPUT])
; Parameters ....: $sMessage        - [byref] The message/array/whatever you want to be written
;                  $iOutType        - An integer to specify the type of message
;                  $bOverride       - [optional] Boolean, if true message will be written even if logging is disabled
;                  $iLogOutput      - [optional] You can specify where to send a single message
;                  $sDivider1       - [optional] 1st divider for _ArrayToString (Check helpfile)
;                  $sDivider2       - [optional] 2nd divider for _ArrayToString (Check helpfile)
;                  $CRType          - [optional] Type of carriage return
; Return values .: Success          - 0 - Everywhing went fine
;                  Failure          - @error = 1 - Message passed as array is not an array
;                                   | @error = 2 - Impossible to write logfile, maybe folder is write protected
; Author ........: fede.97
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func _Aut2Log_Write($Message, $iOutType, $bOverride = False, $iLogOutput = $__LOG_OUTPUT, $sDivider1 = '|', $sDivider2 = @CRLF, $CRType = @CRLF & @CRLF)
	If $__LOG_ENABLE = False And $bOverride = False Then Return
	If $__LOG_ENABLE = False And ($iLogOutput = $__A2L_OUT_FILE Or $iLogOutput = $__A2L_OUT_BOTH) And $bOverride = True Then
		Global $hLogOpen = FileOpen($__LOG_STANDARDFILEPATH, 9)
		OnAutoItExitRegister('__Aut2Log_Exit')
	EndIf
	Switch $iOutType
		Case $__A2L_TYPE_MESSAGE
			Local $sLine = '[' & @HOUR & ':' & @MIN & ':' & @SEC & ':' & @MSEC & '] Log message: "' & $Message & '"' & $CRType
		Case $__A2L_TYPE_ARRAY
			If Not IsArray($Message) Then Return SetError(1)
			Local $sLine = '[' & @HOUR & ':' & @MIN & ':' & @SEC & ':' & @MSEC & '] ARRAY' & @CRLF & _ArrayToString($Message, $sDivider1, 0, 0, $sDivider2) & $CRType
		Case $__A2L_TYPE_PARAMETERS
			Local $sLine = '[' & @HOUR & ':' & @MIN & ':' & @SEC & ':' & @MSEC & '] Parameter: "' & $Message & '"' & $CRType
		Case $__A2L_TYPE_RETURN
			Local $sLine = '[' & @HOUR & ':' & @MIN & ':' & @SEC & ':' & @MSEC & '] Return: "' & $Message & '"' & $CRType
		Case $__A2L_TYPE_ENVINFO
			Local $sLine = '[' & @HOUR & ':' & @MIN & ':' & @SEC & ':' & @MSEC & '] ENVIRONMENT INFO' & @CRLF & $Message & $CRType
		Case Else
			Local $sLine = '[' & @HOUR & ':' & @MIN & ':' & @SEC & ':' & @MSEC & '] Logging error, wrong $iOutType code' & $CRType
	EndSwitch
	Switch $iLogOutput
		Case $__A2L_OUT_CONSOLE
			ConsoleWrite($sLine)
		Case $__A2L_OUT_FILE
			Local $hLogWrite = FileWrite($hLogOpen, $sLine)
			If $hLogWrite = 0 Then Return SetError(2)
		Case $__A2L_OUT_BOTH
			ConsoleWrite($sLine)
			$hLogWrite = FileWrite($hLogOpen, $sLine)
			If $hLogWrite = 0 Then Return SetError(2)
	EndSwitch
	Return
EndFunc   ;==>_Aut2Log_Write

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __Aut2Log_Write
; Description ...: Close file handle on exit/crash
; Syntax.........: __Aut2Log_Write()
; Parameters ....:
; Return values .:
; Author ........: fede.97
; ===============================================================================================================================
Func __Aut2Log_Exit()
	If @exitCode = 1 Then FileWrite($hLogOpen, '[' & @HOUR & ':' & @MIN & ':' & @SEC & ':' & @MSEC & '] CRASH, shit happens...')
	FileClose($hLogOpen)
EndFunc   ;==>__Aut2Log_Exit
