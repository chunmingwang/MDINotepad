' MDINotepad MDIChild.frm
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "MDINotepad.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/TextBox.bi"
	
	Using My.Sys.Forms
	
	Type MDIChildType Extends Form
		Destroied As Boolean
		Index As Integer = -1
		CodePage As Integer = GetACP()
		Encode As FileEncodings = FileEncodings.Utf8BOM
		NewLine As NewLineTypes = NewLineTypes.WindowsCRLF
		IconHandle As Any Ptr
		FileInfo As SHFILEINFO
		mTitle As WString Ptr = NULL
		mTitleTmp As WString Ptr = NULL
		mFile As WString Ptr = NULL
		mChanged As Boolean = False
		
		Declare Property Changed(Val As Boolean)
		Declare Property Changed As Boolean
		Declare Property File(ByRef FileName As WString)
		Declare Property File ByRef As WString
		Declare Property Title() ByRef As WString
		Declare Property TitleFileName() ByRef As WString
		Declare Property TitleFullName() ByRef As WString
		
		Declare Sub Form_Activate(ByRef Sender As Form)
		Declare Sub Form_Close(ByRef Sender As Form, ByRef Action As Integer)
		Declare Sub Form_Destroy(ByRef Sender As Control)
		Declare Sub Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		Declare Sub TextBox1_Change(ByRef Sender As TextBox)
		Declare Sub TextBox1_Click(ByRef Sender As Control)
		Declare Sub TextBox1_KeyPress(ByRef Sender As Control, Key As Integer)
		Declare Sub TextBox1_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
		Declare Sub Form_Show(ByRef Sender As Form)
		Declare Constructor
		
		Dim As TextBox TextBox1
	End Type
	
	Constructor MDIChildType
		'MDIChild
		With This
			.Name = "MDIChild"
			.Text = "Initial..."
			.Designer = @This
			.FormStyle = FormStyles.fsMDIChild
			.Caption = "Initial..."
			.OnDestroy = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Destroy)
			.OnActivate = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @Form_Activate)
			.AllowDrop = True
			.OnDropFile = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Filename As WString), @Form_DropFile)
			.OnClose = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form, ByRef Action As Integer), @Form_Close)
			.OnShow = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Form), @Form_Show)
			.SetBounds 0, 0, 640, 480
		End With
		' TextBox1
		With TextBox1
			.Name = "TextBox1"
			.Text = ""
			.TabIndex = 0
			.Multiline = True
			.ScrollBars = ScrollBarsType.Both
			.Align = DockStyle.alClient
			.HideSelection = False
			.MaxLength = -1
			.SetBounds 0, 0, 624, 441
			.Designer = @This
			.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @TextBox1_Change)
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @TextBox1_Click)
			.OnKeyPress = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer), @TextBox1_KeyPress)
			.OnKeyUp = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control, Key As Integer, Shift As Integer), @TextBox1_KeyUp)
			.Parent = @This
		End With
	End Constructor
	
	Dim Shared MDIChild As MDIChildType
	
	#if _MAIN_FILE_ = __FILE__
		MDIChild.MainForm = True
		MDIChild.Show
		
		App.Run
	#endif
'#End Region

Private Property MDIChildType.Changed(val As Boolean)
	'Debug.Print "MDIChildType.Changed: " & val
	mChanged = val
	Text = IIf(mChanged, "* " , "" ) & Title
	MDIMain.MDIChildClick()
End Property

Private Property MDIChildType.Changed As Boolean
	Return mChanged
End Property

Private Property MDIChildType.TitleFileName() ByRef As WString
	WLet(mTitleTmp, IIf(mChanged, "* " , "" ) & Title)
	Return *mTitleTmp
End Property

Private Property MDIChildType.TitleFullName() ByRef As WString
	If *mFile= "" Then
		WLet(mTitleTmp, IIf(mChanged, "* " , "" ) & Title)
	Else
		WLet(mTitleTmp, IIf(mChanged, "* " , "" ) & *mFile)
	End If
	Return *mTitleTmp
End Property

Private Property MDIChildType.Title() ByRef As WString
	If *mFile = "" Then
		WLet(mTitle, "Untitled - " & Index)
	Else
		WLet(mTitle, FullName2File(*mFile))
	End If
	Return *mTitle
End Property

Private Property MDIChildType.File(ByRef FileName As WString)
	WLet(mFile, FileName)
	Text = IIf(mChanged, "* " , "" ) & Title
	If FileName= "" Then
	Else
		IconHandle = Cast(Any Ptr, SHGetFileInfo(*mFile, 0, @FileInfo, SizeOf(FileInfo), SHGFI_SYSICONINDEX))
		SendMessage(Handle, WM_SETICON, 0, Cast(LPARAM, ImageList_GetIcon(IconHandle, FileInfo.iIcon, 0)))
	End If
End Property

Private Property MDIChildType.File ByRef As WString
	Return *mFile
End Property

Private Sub MDIChildType.Form_Close(ByRef Sender As Form, ByRef Action As Integer)
	'Debug.Print "MDIChildType.Form_Close: " & Caption
	If MDIMain.MDIChildCloseConfirm(@This) = MessageResult.mrCancel Then Action = False
End Sub

Private Sub MDIChildType.Form_Destroy(ByRef Sender As Control)
	'Debug.Print "MDIChildType.Form_Destroy: " & Caption
	If mFile Then Deallocate(mFile)
	If mTitle Then Deallocate(mTitle)
	If mTitleTmp Then Deallocate(mTitleTmp)
	MDIMain.MDIChildDestroy(@This)
End Sub

Private Sub MDIChildType.Form_Activate(ByRef Sender As Form)
	'Debug.Print "MDIChildType.Form_Activate: " & Caption
	If Encode < 0 Then Encode = FileEncodings.Utf8
	If NewLine < 0 Then NewLine = NewLineTypes.WindowsCRLF
	MDIMain.MDIChildActivate(@This)
End Sub

Private Sub MDIChildType.Form_Show(ByRef Sender As Form)
	'Debug.Print "MDIChildType.Form_Show: " & Caption
End Sub

Private Sub MDIChildType.Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
	MDIMain.FileInsert(@This, Filename)
End Sub

Private Sub MDIChildType.TextBox1_Change(ByRef Sender As TextBox)
	Changed = True
End Sub

Private Sub MDIChildType.TextBox1_Click(ByRef Sender As Control)
	'Debug.Print "MDIChildType.TextBox1_Click: " & Caption
	MDIMain.MDIChildClick()
End Sub

Private Sub MDIChildType.TextBox1_KeyPress(ByRef Sender As Control, Key As Integer)
	TextBox1_Click(Sender)
End Sub

Private Sub MDIChildType.TextBox1_KeyUp(ByRef Sender As Control, Key As Integer, Shift As Integer)
	TextBox1_Click(Sender)
End Sub

