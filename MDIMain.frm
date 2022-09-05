#include once "Text.bi"
#include once "vbcompat.bi"

'#Region "Form"
	#if defined(__FB_WIN32__) AndAlso defined(__FB_MAIN__)
		#cmdline "Form1.rc"
	#endif
	
	#include once "mff/Form.bi"
	#include once "mff/Menus.bi"
	#include once "mff/ReBar.bi"
	#include once "mff/ImageList.bi"
	#include once "mff/StatusBar.bi"
	#include once "mff/List.bi"
	#include once "mff/ToolBar.bi"
	#include once "mff/Dialogs.bi"
	
	Using My.Sys.Forms
	#ifdef __USE_WINAPI__
		InitDarkMode
	#endif
	
	Type MDIMainType Extends Form
		'mdichild
		Dim lstMdiChild As List
		Dim actMdiChildIdx As Integer
		
		Declare Function MDIChildFind(ByRef newName As Const WString) As Integer
		Declare Function MDIChildNew() As Any Ptr
		Declare Sub MDIChildActivate(Child As Any Ptr)
		Declare Sub MDIChildDestroy(Child As Any Ptr)
		Declare Sub MDIChildClick(Child As Any Ptr)
		Declare Sub ControlEnabled(Enabled As Boolean)
		
		Declare Sub FileOpen(ByRef FileName As Const WString)
		Declare Sub FileInsert(ByRef FileName As Const WString, Child As Any Ptr)
		
		Dim mFindBack As Boolean = False
		
		Declare Sub Find(ByRef FindStr As Const WString, ByVal FindCase As Boolean = False,ByVal FindWarp As Boolean=True, ByVal FindBack As Boolean = False)
		Declare Sub Replace(ByRef FindStr As Const WString, ByRef ReplaceStr As Const WString, ByVal FindCase As Boolean = False, ByVal FindWarp As Boolean = True)
		Declare Sub ReplaceAll(ByRef FindStr As Const WString, ByRef ReplaceStr As Const WString, ByVal FindCase As Boolean = False)
		Declare Sub GotoLineNo(ByVal LineNumber As Integer)
		
		'mdichild menu
		Dim mnuWindowCount As Integer = -1
		Dim mnuWindows(Any) As MenuItem Ptr
		Declare Sub MDIChildMenuUpdate()
		
		Declare Static Sub _mnuEdit_Click(ByRef Sender As MenuItem)
		Declare Sub mnuEdit_Click(ByRef Sender As MenuItem)
		Declare Static Sub _mnuFile_Click(ByRef Sender As MenuItem)
		Declare Sub mnuFile_Click(ByRef Sender As MenuItem)
		Declare Static Sub _mnuWindow_Click(ByRef Sender As MenuItem)
		Declare Sub mnuWindow_Click(ByRef Sender As MenuItem)
		Declare Static Sub _mnuView_Click(ByRef Sender As MenuItem)
		Declare Sub mnuView_Click(ByRef Sender As MenuItem)
		Declare Static Sub _mnuHelp_Click(ByRef Sender As MenuItem)
		Declare Sub mnuHelp_Click(ByRef Sender As MenuItem)
		Declare Static Sub _mnuEncoding_Click(ByRef Sender As MenuItem)
		Declare Sub mnuEncoding_Click(ByRef Sender As MenuItem)
		Declare Static Sub _ToolBar1_ButtonClick(ByRef Sender As ToolBar, ByRef Button As ToolButton)
		Declare Sub ToolBar1_ButtonClick(ByRef Sender As ToolBar,ByRef Button As ToolButton)
		Declare Static Sub _mnuConvert_Click(ByRef Sender As MenuItem)
		Declare Sub mnuConvert_Click(ByRef Sender As MenuItem)
		Declare Static Sub _Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		Declare Sub Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		Declare Static Sub _Form_Create(ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Constructor
		
		Dim As MainMenu MainMenu1
		Dim As MenuItem mnuFile, mnuFileNew, mnuFileOpen, mnuFileBar1, mnuFileSave, mnuFileSaveAs, mnuFileSaveAll, mnuFileBar2, mnuFileBrowse, mnuFileBar3, mnuFilePrintSetup, mnuFilePrintPreview, mnuFilePrint, mnuFileBar4, mnuFileExit
		Dim As MenuItem mnuEdit, mnuEditRedo, mnuEditUndo, mnuEditBar1, mnuEditCut, mnuEditCopy, mnuEditPaste, mnuEditDelete, mnuEditBar2, mnuEditFind, mnuEditFindNext, mnuEditFindPrevious, mnuEditReplace, mnuEditGoto, mnuEditBar3, mnuEditDSelectAll, mnuEditDateTime
		Dim As MenuItem mnuView, mnuViewToolbar, mnuViewStatusBar, mnuViewBar1, mnuViewDarkMode, mnuViewBar2, mnuViewWordWarps, mnuViewFont, mnuViewAllFont, mnuViewBackColor, mnuViewAllBackColor
		Dim As MenuItem mnuEncoding, mnuEncodingPlainText, mnuEncodingUtf8, mnuEncodingUtf8BOM, mnuEncodingUtf16BOM, mnuEncodingUtf32BOM, mnuEncodingBar1, mnuEncodingCRLF, mnuEncodingLF, mnuEncodingCR
		Dim As MenuItem mnuConvert, mnuConvertTraditional, mnuConvertSimplified, mnuConvertBar1, mnuConvertFullWidth, mnuConvertHalfWidth, mnuConvertLowerCase, mnuConvertUpperCase, mnuConvertTitleCase, mnuConvertBar2, mnuConvertBIG5ToGB, mnuConvertGBToBIG5
		Dim As MenuItem mnuWindow, mnuWindowTileHorizontal, mnuWindowTileVertical, mnuWindowCascade, mnuWindowArrangeIcons, mnuWindowBar1, mnuWindowClose, mnuWindowCloseAll
		Dim As MenuItem mnuHelp, mnuHelpAbout
		Dim As ImageList ImageList1
		Dim As StatusBar StatusBar1
		Dim As ToolBar ToolBar1
		Dim As OpenFileDialog OpenFileDialog1
		Dim As SaveFileDialog SaveFileDialog1
		Dim As ToolButton tbFileNew, tbFileOpen, tbFileSave, tbFileSaveAll
		Dim As ColorDialog ColorDialog1
		Dim As FontDialog FontDialog1
		Dim As StatusPanel spFileName, spLocation, spEncode, spEOL
	End Type
	
	Constructor MDIMainType
		' MDIMain
		With This
			.Name = "MDIMain"
			.Text = "VFBE MDI Notepad"
			.Designer = @This
			.Menu = @MainMenu1
			.FormStyle = FormStyles.fsMDIForm
			#ifdef __USE_GTK__
				This.Icon.LoadFromFile(ExePath & "VisualFBEditor.ico")
			#else
				This.Icon.LoadFromResourceID(1)
			#endif
			'.WindowState = WindowStates.wsMaximized
			.Caption = "VFBE MDI Notepad"
			.StartPosition = FormStartPosition.CenterScreen
			.AllowDrop = True
			.OnDropFile = @_Form_DropFile
			.OnCreate = @_Form_Create
			.SetBounds 0, 0, 1024, 720
		End With
		' OpenFileDialog1
		With OpenFileDialog1
			.Name = "OpenFileDialog1"
			.SetBounds 60, 40, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' SaveFileDialog1
		With SaveFileDialog1
			.Name = "SaveFileDialog1"
			.SetBounds 80, 40, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' ImageList1
		With ImageList1
			.Name = "ImageList1"
			.ImageWidth = 16
			.ImageHeight = 16
			.SetBounds 20, 40, 16, 16
			.Designer = @This
			.Add "New", "New"
			.Add "About", "About"
			.Add "Cut", "Cut"
			.Add "Exit", "Exit"
			.Add "File", "File"
			.Add "Open", "Open"
			.Add "Paste", "Paste"
			.Add "Save", "Save"
			.Add "SaveAll", "SaveAll"
			.Parent = @This
		End With
		' ColorDialog1
		With ColorDialog1
			.Name = "ColorDialog1"
			.SetBounds 100, 40, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' FontDialog1
		With FontDialog1
			.Name = "FontDialog1"
			.SetBounds 120, 40, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' ToolBar1
		With ToolBar1
			.Name = "ToolBar1"
			.Text = "ToolBar1"
			.Align = DockStyle.alTop
			.ImagesList = @ImageList1
			.HotImagesList = @ImageList1
			.DisabledImagesList = @ImageList1
			.Controls = 0
			.BorderStyle = BorderStyles.bsNone
			.SetBounds 0, 0, 464, 26
			.Designer = @This
			.OnButtonClick = @_ToolBar1_ButtonClick
			.Parent = @This
		End With
		' StatusBar1
		With StatusBar1
			.Name = "StatusBar1"
			.Text = "StatusBar1"
			.Align = DockStyle.alBottom
			.SetBounds 0, 239, 334, 22
			.Designer = @This
			.Parent = @This
		End With
		' MainMenu1
		With MainMenu1
			.Name = "MainMenu1"
			.SetBounds 40, 39, 16, 16
			.Designer = @This
			.Parent = @This
		End With
		' mnuFile
		With mnuFile
			.Name = "mnuFile"
			.Designer = @This
			.Caption = "&File"
			.Parent = @MainMenu1
		End With
		' mnuFileNew
		With mnuFileNew
			.Name = "mnuFileNew"
			.Designer = @This
			.Caption = !"&New\tCtrl+N"
			.ImageKey = "New"
			.OnClick = @_mnuFile_Click
			.Parent = @mnuFile
		End With
		' mnuFileOpen
		With mnuFileOpen
			.Name = "mnuFileOpen"
			.Designer = @This
			.Caption = !"&Open\tCtrl+O"
			.ImageKey = "Open"
			.OnClick = @_mnuFile_Click
			.Parent = @mnuFile
		End With
		' mnuFileBar1
		With mnuFileBar1
			.Name = "mnuFileBar1"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuFile
		End With
		' mnuFileSave
		With mnuFileSave
			.Name = "mnuFileSave"
			.Designer = @This
			.Caption = !"Save\tCtrl+S"
			.ImageKey = "Save"
			.OnClick = @_mnuFile_Click
			.Parent = @mnuFile
		End With
		' mnuFileSaveAs
		With mnuFileSaveAs
			.Name = "mnuFileSaveAs"
			.Designer = @This
			.Caption = "Save &As..."
			.ImageKey = "SaveAs"
			.OnClick = @_mnuFile_Click
			.Parent = @mnuFile
		End With
		' mnuFileSaveAll
		With mnuFileSaveAll
			.Name = "mnuFileSaveAll"
			.Designer = @This
			.Caption = "Save A&ll"
			.ImageKey = "SaveAll"
			.OnClick = @_mnuFile_Click
			.Parent = @mnuFile
		End With
		' mnuFileBar2
		With mnuFileBar2
			.Name = "mnuFileBar2"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuFile
		End With
		' mnuFileBrowse
		With mnuFileBrowse
			.Name = "mnuFileBrowse"
			.Designer = @This
			.Caption = "Browse"
			.OnClick = @_mnuFile_Click
			.Parent = @mnuFile
		End With
		' mnuFileBar3
		With mnuFileBar3
			.Name = "mnuFileBar3"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuFile
		End With
		' mnuFilePrintSetup
		With mnuFilePrintSetup
			.Name = "mnuFilePrintSetup"
			.Designer = @This
			.Caption = "Print Set&up..."
			.OnClick = @_mnuFile_Click
			.Parent = @mnuFile
		End With
		' mnuFilePrintPreview
		With mnuFilePrintPreview
			.Name = "mnuFilePrintPreview"
			.Designer = @This
			.Caption = "Print Pre&view"
			.MenuIndex = 11
			.OnClick = @_mnuFile_Click
			.Parent = @mnuFile
		End With
		' mnuFilePrint
		With mnuFilePrint
			.Name = "mnuFilePrint"
			.Designer = @This
			.Caption = !"&Print...\tCtrl+P"
			.OnClick = @_mnuFile_Click
			.Parent = @mnuFile
		End With
		' mnuFileBar4
		With mnuFileBar4
			.Name = "mnuFileBar4"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuFile
		End With
		' mnuFileExit
		With mnuFileExit
			.Name = "mnuFileExit"
			.Designer = @This
			.Caption = "E&xit"
			.ImageKey = "Exit"
			.OnClick = @_mnuFile_Click
			.Parent = @mnuFile
		End With
		' mnuEdit
		With mnuEdit
			.Name = "mnuEdit"
			.Designer = @This
			.Caption = "&Edit"
			.Parent = @MainMenu1
		End With
		' mnuEditRedo
		With mnuEditRedo
			.Name = "mnuEditRedo"
			.Designer = @This
			.Caption = "&Redo"
			.OnClick = @_mnuEdit_Click
			.Parent = @mnuEdit
		End With
		' mnuEditUndo
		With mnuEditUndo
			.Name = "mnuEditUndo"
			.Designer = @This
			.Caption = !"&Undo\tCtrl+Z"
			.OnClick = @_mnuEdit_Click
			.Parent = @mnuEdit
		End With
		' mnuEditBar1
		With mnuEditBar1
			.Name = "mnuEditBar1"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuEdit
		End With
		' mnuEditCut
		With mnuEditCut
			.Name = "mnuEditCut"
			.Designer = @This
			.Caption = !"Cu&t\tCtrl+X"
			.ImageKey = "Cut"
			.OnClick = @_mnuEdit_Click
			.Parent =  @mnuEdit
		End With
		' mnuEditCopy
		With mnuEditCopy
			.Name = "mnuEditCopy"
			.Designer = @This
			.Caption = !"&Copy\tCtrl+C"
			.ImageKey = "Copy"
			.OnClick = @_mnuEdit_Click
			.Parent = @mnuEdit
		End With
		' mnuEditPaste
		With mnuEditPaste
			.Name = "mnuEditPaste"
			.Designer = @This
			.Caption = !"&Paste\tCtrl+V"
			.ImageKey = "Paste"
			.OnClick = @_mnuEdit_Click
			.Parent = @mnuEdit
		End With
		' mnuEditDelete
		With mnuEditDelete
			.Name = "mnuEditDelete"
			.Designer = @This
			.Caption = !"Delete\tDel"
			.OnClick = @_mnuEdit_Click
			.Parent = @mnuEdit
		End With
		' mnuEditBar2
		With mnuEditBar2
			.Name = "mnuEditBar2"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuEdit
		End With
		' mnuEditFind
		With mnuEditFind
			.Name = "mnuEditFind"
			.Designer = @This
			.Caption = !"Find...\tCtrl+F"
			.OnClick = @_mnuEdit_Click
			.Parent = @mnuEdit
		End With
		' mnuEditFindNext
		With mnuEditFindNext
			.Name = "mnuEditFindNext"
			.Designer = @This
			.Caption = !"Find Next\tF3"
			.OnClick = @_mnuEdit_Click
			.Parent = @mnuEdit
		End With
		' mnuEditFindPrevious
		With mnuEditFindPrevious
			.Name = "mnuEditFindPrevious"
			.Designer = @This
			.Caption = !"Find Previous\tShift+F3"
			.OnClick = @_mnuEdit_Click
			.Parent = @mnuEdit
		End With
		' mnuEditReplace
		With mnuEditReplace
			.Name = "mnuEditReplace"
			.Designer = @This
			.Caption = !"Replace...\tCtrl+H"
			.OnClick = @_mnuEdit_Click
			.Parent = @mnuEdit
		End With
		' mnuEditGoto
		With mnuEditGoto
			.Name = "mnuEditGoto"
			.Designer = @This
			.Caption = !"Goto...\tCtrl+G"
			.OnClick = @_mnuEdit_Click
			.Parent = @mnuEdit
		End With
		' mnuEditBar3
		With mnuEditBar3
			.Name = "mnuEditBar3"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuEdit
		End With
		' mnuEditDSelectAll
		With mnuEditDSelectAll
			.Name = "mnuEditDSelectAll"
			.Designer = @This
			.Caption = !"Select &All\tCtrl+A"
			.OnClick = @_mnuEdit_Click
			.Parent = @mnuEdit
		End With
		' mnuEditDateTime
		With mnuEditDateTime
			.Name = "mnuEditDateTime"
			.Designer = @This
			.Caption = !"Date Time\tF5"
			.OnClick = @_mnuEdit_Click
			.Parent = @mnuEdit
		End With
		' mnuView
		With mnuView
			.Name = "mnuView"
			.Designer = @This
			.Caption = "&View"
			.Parent = @MainMenu1
		End With
		' mnuViewToolbar
		With mnuViewToolbar
			.Name = "mnuViewToolbar"
			.Caption = "&Toolbar"
			.Designer = @This
			.OnClick = @_mnuView_Click
			.Checked = True
			.Parent = @mnuView
		End With
		' mnuViewStatusBar
		With mnuViewStatusBar
			.Name = "mnuViewStatusBar"
			.Caption = "Status &Bar"
			.Designer = @This
			.OnClick = @_mnuView_Click
			.Checked = True
			.Parent = @mnuView
		End With
		' mnuViewBar1
		With mnuViewBar1
			.Name = "mnuViewBar1"
			.Caption = "-"
			.Designer = @This
			.Parent = @mnuView
		End With
		' mnuViewDarkMode
		With mnuViewDarkMode
			.Name = "mnuViewDarkMode"
			.Designer = @This
			.Caption = "Dark Mode"
			.Checked = False
			.OnClick = @_mnuView_Click
			.Parent = @mnuView
		End With
		' mnuViewBar2
		With mnuViewBar2
			.Name = "mnuViewBar2"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuView
		End With
		' mnuViewWordWarps
		With mnuViewWordWarps
			.Name = "mnuViewWordWarps"
			.Designer = @This
			.Caption = "Word Warps"
			.OnClick = @_mnuView_Click
			.Parent = @mnuView
		End With
		' mnuViewFont
		With mnuViewFont
			.Name = "mnuViewFont"
			.Caption = "Font..."
			.Designer = @This
			.OnClick = @_mnuView_Click
			.Parent = @mnuView
		End With
		' mnuViewBackColor
		With mnuViewBackColor
			.Name = "mnuViewBackColor"
			.Designer = @This
			.Caption = "Back Color..."
			.OnClick = @_mnuView_Click
			.Parent = @mnuView
		End With
		' mnuViewAllFont
		With mnuViewAllFont
			.Name = "mnuViewAllFont"
			.Designer = @This
			.Caption = "All Font..."
			.OnClick = @_mnuView_Click
			.Parent = @mnuView
		End With
		' mnuViewAllBackColor
		With mnuViewAllBackColor
			.Name = "mnuViewAllBackColor"
			.Designer = @This
			.Caption = "All Back Color..."
			.OnClick = @_mnuView_Click
			.Parent = @mnuView
		End With
		' mnuEncoding
		With mnuEncoding
			.Name = "mnuEncoding"
			.Designer = @This
			.Caption = "Encoding"
			.Parent = @MainMenu1
		End With
		' mnuEncodingPlainText
		With mnuEncodingPlainText
			.Name = "mnuEncodingPlainText"
			.Designer = @This
			.Caption = "Plain Text"
			.RadioItem = True
			.OnClick = @_mnuEncoding_Click
			.Parent = @mnuEncoding
		End With
		' mnuEncodingUtf8
		With mnuEncodingUtf8
			.Name = "mnuEncodingUtf8"
			.Designer = @This
			.Caption = "Utf8"
			.OnClick = @_mnuEncoding_Click
			.Parent = @mnuEncoding
		End With
		' mnuEncodingUtf8BOM
		With mnuEncodingUtf8BOM
			.Name = "mnuEncodingUtf8BOM"
			.Designer = @This
			.Caption = "Utf8 (BOM)"
			.OnClick = @_mnuEncoding_Click
			.Parent = @mnuEncoding
		End With
		' mnuEncodingUtf16BOM
		With mnuEncodingUtf16BOM
			.Name = "mnuEncodingUtf16BOM"
			.Designer = @This
			.Caption = "Utf16 (BOM)"
			.OnClick = @_mnuEncoding_Click
			.Parent = @mnuEncoding
		End With
		' mnuEncodingUtf32BOM
		With mnuEncodingUtf32BOM
			.Name = "mnuEncodingUtf32BOM"
			.Designer = @This
			.Caption = "Utf32 (BOM)"
			.OnClick = @_mnuEncoding_Click
			.Parent = @mnuEncoding
		End With
		' mnuEncodingBar1
		With mnuEncodingBar1
			.Name = "mnuEncodingBar1"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuEncoding
		End With
		' mnuEncodingCRLF
		With mnuEncodingCRLF
			.Name = "mnuEncodingCRLF"
			.Designer = @This
			.Caption = "Windows CRLF"
			.OnClick = @_mnuEncoding_Click
			.Parent = @mnuEncoding
		End With
		' mnuEncodingLF
		With mnuEncodingLF
			.Name = "mnuEncodingLF"
			.Designer = @This
			.Caption = "Linux LF"
			.OnClick = @_mnuEncoding_Click
			.Parent = @mnuEncoding
		End With
		' mnuEncodingCR
		With mnuEncodingCR
			.Name = "mnuEncodingCR"
			.Designer = @This
			.Caption = "MacOS CR"
			.OnClick = @_mnuEncoding_Click
			.Parent = @mnuEncoding
		End With
		' mnuConvert
		With mnuConvert
			.Name = "mnuConvert"
			.Designer = @This
			.Caption = "Convert"
			.MenuIndex = 6
			.Parent =  @MainMenu1
		End With
		' mnuConvertTraditional
		With mnuConvertTraditional
			.Name = "mnuConvertTraditional"
			.Designer = @This
			.Caption = "Traditional"
			.OnClick = @_mnuConvert_Click
			.Parent = @mnuConvert
		End With
		' mnuConvertSimplified
		With mnuConvertSimplified
			.Name = "mnuConvertSimplified"
			.Designer = @This
			.Caption = "Simplified"
			.OnClick = @_mnuConvert_Click
			.Parent = @mnuConvert
		End With
		' mnuConvertBar1
		With mnuConvertBar1
			.Name = "mnuConvertBar1"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuConvert
		End With
		' mnuConvertFullWidth
		With mnuConvertFullWidth
			.Name = "mnuConvertFullWidth"
			.Designer = @This
			.Caption = "Full Width"
			.OnClick = @_mnuConvert_Click
			.Parent = @mnuConvert
		End With
		' mnuConvertHalfWidth
		With mnuConvertHalfWidth
			.Name = "mnuConvertHalfWidth"
			.Designer = @This
			.Caption = "Half Width"
			.OnClick = @_mnuConvert_Click
			.Parent = @mnuConvert
		End With
		' mnuConvertLowerCase
		With mnuConvertLowerCase
			.Name = "mnuConvertLowerCase"
			.Designer = @This
			.Caption = "Lower Case"
			.OnClick = @_mnuConvert_Click
			.Parent = @mnuConvert
		End With
		' mnuConvertUpperCase
		With mnuConvertUpperCase
			.Name = "mnuConvertUpperCase"
			.Designer = @This
			.Caption = "Upper Case"
			.OnClick = @_mnuConvert_Click
			.Parent = @mnuConvert
		End With
		' mnuConvertTitleCase
		With mnuConvertTitleCase
			.Name = "mnuConvertTitleCase"
			.Designer = @This
			.Caption = "Title Case"
			.OnClick = @_mnuConvert_Click
			.Parent = @mnuConvert
		End With
		' mnuConvertBar2
		With mnuConvertBar2
			.Name = "mnuConvertBar2"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuConvert
		End With
		' mnuConvertBIG5ToGB
		With mnuConvertBIG5ToGB
			.Name = "mnuConvertBIG5ToGB"
			.Designer = @This
			.Caption = "BIG5 to GB"
			.OnClick = @_mnuConvert_Click
			.Parent = @mnuConvert
		End With
		' mnuConvertGBToBIG5
		With mnuConvertGBToBIG5
			.Name = "mnuConvertGBToBIG5"
			.Designer = @This
			.Caption = "GB to BIG5"
			.OnClick = @_mnuConvert_Click
			.Parent = @mnuConvert
		End With
		' mnuWindow
		With mnuWindow
			.Name = "mnuWindow"
			.Caption = "&Window"
			.Designer = @This
			.Enabled = True
			.Parent = @MainMenu1
		End With
		' mnuWindowTileHorizontal
		With mnuWindowTileHorizontal
			.Name = "mnuWindowTileHorizontal"
			.Caption = "Tile &Horizontal"
			.Designer = @This
			.OnClick = @_mnuWindow_Click
			.Parent = @mnuWindow
		End With
		' mnuWindowTileVertical
		With mnuWindowTileVertical
			.Name = "mnuWindowTileVertical"
			.Caption = "Tile &Vertical"
			.Designer = @This
			.OnClick = @_mnuWindow_Click
			.Parent = @mnuWindow
		End With
		' mnuWindowCascade
		With mnuWindowCascade
			.Name = "mnuWindowCascade"
			.Caption = "&Cascade"
			.Designer = @This
			.OnClick = @_mnuWindow_Click
			.Parent = @mnuWindow
		End With
		' mnuWindowArrangeIcons
		With mnuWindowArrangeIcons
			.Name= "mnuWindowArrangeIcons"
			.Caption = "&Arrange Icons"
			.Designer = @This
			.OnClick = @_mnuWindow_Click
			.Parent = @mnuWindow
		End With
		' mnuWindowBar1
		With mnuWindowBar1
			.Name = "mnuWindowBar1"
			.Designer = @This
			.Caption = "-"
			.Parent = @mnuWindow
		End With
		' mnuWindowClose
		With mnuWindowClose
			.Name = "mnuWindowClose"
			.Designer = @This
			.Caption = "Close"
			.OnClick = @_mnuWindow_Click
			.Parent = @mnuWindow
		End With
		' mnuWindowCloseAll
		With mnuWindowCloseAll
			.Name = "mnuWindowCloseAll"
			.Designer = @This
			.Caption = "Close All"
			.OnClick = @_mnuWindow_Click
			.Parent = @mnuWindow
		End With
		With mnuHelp
			.Name = "mnuHelp"
			.Designer = @This
			.Caption = "&Help"
			.Parent = @MainMenu1
		End With
		' mnuHelpAbout
		With mnuHelpAbout
			.Name = "mnuHelpAbout"
			.Designer = @This
			.Caption = "About"
			.ImageKey = "About"
			.OnClick = @_mnuHelp_Click
			.Parent = @mnuHelp
		End With
		' tbFileNew
		With tbFileNew
			.Name = "tbFileNew"
			.Designer = @This
			.ImageKey = "New"
			.Parent = @ToolBar1
		End With
		' tbFileOpen
		With tbFileOpen
			.Name = "tbFileOpen"
			.Designer = @This
			.ImageKey = "Open"
			.Parent = @ToolBar1
		End With
		' tbFileSave
		With tbFileSave
			.Name = "tbFileSave"
			.Designer = @This
			.ImageKey = "Save"
			.Parent = @ToolBar1
		End With
		' tbFileSaveAll
		With tbFileSaveAll
			.Name = "tbFileSaveAll"
			.Designer = @This
			.ImageKey = "SaveAll"
			.Parent = @ToolBar1
		End With
		' spFileName
		With spFileName
			.Name = "spFileName"
			.Designer = @This
			.Width = 200
			.Caption = ""
			.Parent = @StatusBar1
		End With
		' spLocation
		With spLocation
			.Name = "spLocation"
			.Designer = @This
			.Width = 300
			.Caption = ""
			.Parent = @StatusBar1
		End With
		' spEOL
		With spEOL
			.Name = "spEOL"
			.Designer = @This
			.Width = 100
			.Parent = @StatusBar1
		End With
		' spEncode
		With spEncode
			.Name = "spEncode"
			.Designer = @This
			.Width = 100
			.Parent = @StatusBar1
		End With
	End Constructor
	
	Private Sub MDIMainType._Form_Create(ByRef Sender As Control)
		*Cast(MDIMainType Ptr, Sender.Designer).Form_Create(Sender)
	End Sub
	
	Private Sub MDIMainType._Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
		*Cast(MDIMainType Ptr, Sender.Designer).Form_DropFile(Sender, Filename)
	End Sub
	
	Private Sub MDIMainType._mnuConvert_Click(ByRef Sender As MenuItem)
		*Cast(MDIMainType Ptr, Sender.Designer).mnuConvert_Click(Sender)
	End Sub
	
	Private Sub MDIMainType._ToolBar1_ButtonClick(ByRef Sender As ToolBar,ByRef Button As ToolButton)
		*Cast(MDIMainType Ptr, Sender.Designer).ToolBar1_ButtonClick(Sender, Button)
	End Sub
	
	Private Sub MDIMainType._mnuEncoding_Click(ByRef Sender As MenuItem)
		*Cast(MDIMainType Ptr, Sender.Designer).mnuEncoding_Click(Sender)
	End Sub
	
	Private Sub MDIMainType._mnuFile_Click(ByRef Sender As MenuItem)
		*Cast(MDIMainType Ptr, Sender.Designer).mnuFile_Click(Sender)
	End Sub
	
	Private Sub MDIMainType._mnuEdit_Click(ByRef Sender As MenuItem)
		*Cast(MDIMainType Ptr, Sender.Designer).mnuEdit_Click(Sender)
	End Sub
	
	Private Sub MDIMainType._mnuView_Click(ByRef Sender As MenuItem)
		*Cast(MDIMainType Ptr, Sender.Designer).mnuView_Click(Sender)
	End Sub
	
	Private Sub MDIMainType._mnuWindow_Click(ByRef Sender As MenuItem)
		*Cast(MDIMainType Ptr, Sender.Designer).mnuWindow_Click(Sender)
	End Sub
	
	Private Sub MDIMainType._mnuHelp_Click(ByRef Sender As MenuItem)
		*Cast(MDIMainType Ptr, Sender.Designer).mnuHelp_Click(Sender)
	End Sub
	
	Dim Shared MDIMain As MDIMainType
	
	#ifdef __FB_MAIN__
		MDIMain.Show
		
		App.Run
	#endif
'#End Region

#include once "MDIChild.frm"
#include once "MDIList.frm"
#include once "frmGoto.frm"
#include once "frmFindReplace.frm"
#include once "frmCodePage.frm"

Private Sub MDIMainType.ToolBar1_ButtonClick(ByRef Sender As ToolBar, ByRef Button As ToolButton)
	Select Case Button.Name
	Case "tbFileNew"
		mnuFile_Click mnuFileNew
	Case "tbFileSave"
		mnuFile_Click mnuFileSave
	Case "tbFileSaveAll"
		mnuFile_Click mnuFileSaveAll
	Case "tbFileOpen"
		mnuFile_Click mnuFileOpen
	Case Else
		MsgBox Button.Name & !"\r\nThis function is under construction", "ToolBar"
	End Select
End Sub

Private Sub MDIMainType.mnuFile_Click(ByRef Sender As MenuItem)
	Dim a As MDIChildType Ptr
	Dim i As Integer
	Select Case Sender.Name
	Case "mnuFileNew"
		a = MDIChildNew()
		a->Show(MDIMain)
	Case "mnuFileSave"
		a = lstMdiChild.Item(actMdiChildIdx)
		If *a->mFile= "" Then
			mnuFile_Click mnuFileSaveAs
		Else
			TextToFile(*a->mFile, a->TextBox1.Text, a->Encode, a->NewLine, a->CodePage)
			a->Changed = False
		End If
	Case "mnuFileSaveAs"
		If SaveFileDialog1.Execute() Then
			If PathFileExists(SaveFileDialog1.FileName) Then
				If MsgBox(!"Overwrite file?\r\n" & SaveFileDialog1.FileName, "Confirm", mtQuestion, btYesNo) <> mrYes Then
					Exit Sub
				End If
			End If
			a = lstMdiChild.Item(actMdiChildIdx)
			a->SetFile(SaveFileDialog1.FileName)
			mnuFile_Click mnuFileSave
		End If
	Case "mnuFileSaveAll"
		For i = 0 To lstMdiChild.Count - 1
			a = lstMdiChild.Item(i)
			a->SetFocus()
			mnuFile_Click mnuFileSave
		Next
	Case "mnuFileOpen"
		If OpenFileDialog1.Execute() Then
			FileOpen(OpenFileDialog1.FileName)
		End If
	Case "mnuFileBrowse"
		a = lstMdiChild.Item(actMdiChildIdx)
		Exec ("c:\windows\explorer.exe" , "/select," & *a->mFile)
	Case "mnuFileExit"
		ModalResult = ModalResults.OK
		CloseForm
	Case Else
		MsgBox Sender.Name & !"\r\nThis function is under construction", "File"
	End Select
End Sub

Private Sub MDIMainType.FileOpen(ByRef FileName As Const WString)
	Dim Encode As FileEncodings = -1
	Dim CodePage As Integer = -1
	TextGetEncode(FileName, Encode)
	If Encode = FileEncodings.PlainText Then
		If frmCodePage.chkDontShow.Checked = False Then
			frmCodePage.SetMode(0)
			frmCodePage.cobEncod.ItemIndex = 0
			frmCodePage.cobEncod_Selected(frmCodePage.cobEncod, 0)
			frmCodePage.chkSystemCP_Click(frmCodePage.chkSystemCP)
			frmCodePage.SetCodePage(-1)
			frmCodePage.lblFile.Text = "" + FileName
			frmCodePage.ShowModal(MDIMain)
			If frmCodePage.ModalResult <> ModalResults.OK Then Exit Sub
			Encode = frmCodePage.cobEncod.ItemIndex 
			CodePage = Cast(Integer, frmCodePage.lstCodePage.ItemData(frmCodePage.lstCodePage.ItemIndex))
		End If
	End If

	Dim a As MDIChildType Ptr
	Dim i As Integer = MDIChildFind(FileName)
	If i < 0 Then
		a = MDIChildNew()
		a->SetFile(FileName)
		a->Encode = Encode
		a->CodePage = CodePage
		a->TextBox1.Text = TextFromFile(FileName, a->Encode, a->NewLine, a->CodePage)
		a->Show(MDIMain)
	Else
		a = lstMdiChild.Item(i)
		a->SetFocus()
	End If
End Sub

Private Sub MDIMainType.FileInsert(ByRef FileName As Const WString, Child As Any Ptr)
	Dim Encode As FileEncodings = -1
	Dim CodePage As Integer = -1
	TextGetEncode(FileName, Encode)
	If Encode = FileEncodings.PlainText Then
		If frmCodePage.chkDontShow.Checked = False Then
			frmCodePage.SetMode(0)
			frmCodePage.cobEncod.ItemIndex = 0
			frmCodePage.cobEncod_Selected(frmCodePage.cobEncod, 0)
			frmCodePage.chkSystemCP_Click(frmCodePage.chkSystemCP)
			frmCodePage.SetCodePage(-1)
			frmCodePage.lblFile.Text = "" + FileName
			frmCodePage.ShowModal(MDIMain)
			If frmCodePage.ModalResult <> ModalResults.OK Then Exit Sub
			Encode = frmCodePage.cobEncod.ItemIndex 
			CodePage = Cast(Integer, frmCodePage.lstCodePage.ItemData(frmCodePage.lstCodePage.ItemIndex))
		End If
	End If

	Dim a As MDIChildType Ptr = Child
	'a->TextBox1.SelText = "Drop File Start: " & FileName & !"!\r\n"
	a->TextBox1.SelText = TextFromFile(FileName, a->Encode, a->NewLine, a->CodePage)
	'a->TextBox1.SelText = !"\r\nDrop File End: " & FileName
End Sub

Private Sub MDIMainType.mnuEdit_Click(ByRef Sender As MenuItem)
	Dim a As MDIChildType Ptr = lstMdiChild.Item(actMdiChildIdx)
	Select Case Sender.Name
		'Case "mnuEditRedo"
	Case "mnuEditUndo"
		SendMessage(a->TextBox1.Handle, EM_UNDO, 0, 0)
		a->Changed = True
	Case "mnuEditCut"
		SendMessage(a->TextBox1.Handle, WM_CUT, EM_UNDO, 0)
		a->Changed = True
	Case "mnuEditCopy"
		SendMessage(a->TextBox1.Handle, WM_COPY, 0, 0)
	Case "mnuEditPaste"
		SendMessage(a->TextBox1.Handle, WM_PASTE, EM_UNDO, 0)
		a->Changed = True
	Case "mnuEditDelete"
		SendMessage(a->TextBox1.Handle, WM_CLEAR, EM_UNDO, 0)
		a->Changed = True
	Case "mnuEditFind"
		If a->TextBox1.SelText <> "" Then frmFindReplace.txtFind.Text = a->TextBox1.SelText
		frmFindReplace.txtReplace.Visible= True
		frmFindReplace.btnFindReplace_Click(frmFindReplace.btnShowHide)
		frmFindReplace.Show(MDIMain)
	Case "mnuEditFindNext"
		If a->TextBox1.SelText = "" Then mnuEdit_Click(mnuEditFind)
		Find(frmFindReplace.txtFind.Text, frmFindReplace.chkCase.Checked, frmFindReplace.chkWarp.Checked, False)
	Case "mnuEditFindPrevious"
		If a->TextBox1.SelText = "" Then mnuEdit_Click(mnuEditFind)
		Find(frmFindReplace.txtFind.Text, frmFindReplace.chkCase.Checked, frmFindReplace.chkWarp.Checked, True)
	Case "mnuEditReplace"
		If a->TextBox1.SelText <> "" Then frmFindReplace.txtFind.Text = a->TextBox1.SelText
		frmFindReplace.txtReplace.Visible = False
		frmFindReplace.btnFindReplace_Click(frmFindReplace.btnShowHide)
		frmFindReplace.Show(MDIMain)
	Case "mnuEditGoto"
		frmGoto.Show(MDIMain)
	Case "mnuEditDSelectAll"
		SendMessage(a->TextBox1.Handle, EM_SETSEL, 0, -1)
	Case "mnuEditDateTime"
		a->TextBox1.SelText = Format(Now, "yyyy-mm-dd hh:mm:ss")
	Case Else
		MsgBox Sender.Name & !"\r\nThis function is under construction", "Edit"
	End Select
End Sub

Private Sub MDIMainType.mnuView_Click(ByRef Sender As MenuItem)
	Dim i As Integer
	
	Select Case Sender.Name
	Case "mnuViewToolbar"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		ToolBar1.Visible = Sender.Checked = True
	Case "mnuViewStatusBar"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		StatusBar1.Visible = Sender.Checked = True
	Case "mnuViewDarkMode"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		SetDarkMode(Sender.Checked, Sender.Checked)
	Case "mnuViewWordWarps"
		If Sender.Checked Then
			Sender.Checked = False
		Else
			Sender.Checked = True
		End If
		Dim a As MDIChildType Ptr = lstMdiChild.Item(actMdiChildIdx)
		If Sender.Checked Then
			a->TextBox1.WordWraps = True
			a->TextBox1.ScrollBars = ScrollBarsType.Vertical
		Else
			a->TextBox1.WordWraps = False
			a->TextBox1.ScrollBars = ScrollBarsType.Both
		End If
	Case "mnuViewFont"
		Dim a As MDIChildType Ptr = lstMdiChild.Item(actMdiChildIdx)
		FontDialog1.Font.Name = a->TextBox1.Font.Name
		FontDialog1.Font.Size = a->TextBox1.Font.Size
		FontDialog1.Font.Bold = a->TextBox1.Font.Bold
		FontDialog1.Font.CharSet = a->TextBox1.Font.CharSet
		FontDialog1.Font.StrikeOut = a->TextBox1.Font.StrikeOut
		FontDialog1.Font.Underline = a->TextBox1.Font.Underline
		FontDialog1.Font.Italic = a->TextBox1.Font.Italic
		FontDialog1.Font.Color = a->TextBox1.Font.Color
		If FontDialog1.Execute Then
			a->TextBox1.Font.Name = FontDialog1.Font.Name
			a->TextBox1.Font.Size = FontDialog1.Font.Size
			a->TextBox1.Font.Bold = FontDialog1.Font.Bold
			a->TextBox1.Font.CharSet = FontDialog1.Font.CharSet
			a->TextBox1.Font.StrikeOut = FontDialog1.Font.StrikeOut
			a->TextBox1.Font.Underline= FontDialog1.Font.Underline
			a->TextBox1.Font.Italic = FontDialog1.Font.Italic
			a->TextBox1.Font.Color = FontDialog1.Font.Color
		End If
	Case "mnuViewBackColor"
		Dim a As MDIChildType Ptr = lstMdiChild.Item(actMdiChildIdx)
		ColorDialog1.Color = a->TextBox1.BackColor
		If ColorDialog1.Execute Then
			a->TextBox1.BackColor=ColorDialog1.Color
		End If
	Case "mnuViewAllFont"
		Dim a As MDIChildType Ptr = lstMdiChild.Item(actMdiChildIdx)
		FontDialog1.Font.Name = a->TextBox1.Font.Name
		FontDialog1.Font.Size = a->TextBox1.Font.Size
		FontDialog1.Font.Bold = a->TextBox1.Font.Bold
		FontDialog1.Font.CharSet = a->TextBox1.Font.CharSet
		FontDialog1.Font.StrikeOut = a->TextBox1.Font.StrikeOut
		FontDialog1.Font.Underline = a->TextBox1.Font.Underline
		FontDialog1.Font.Italic = a->TextBox1.Font.Italic
		FontDialog1.Font.Color = a->TextBox1.Font.Color
		If FontDialog1.Execute Then
			For i = 0 To lstMdiChild.Count - 1
				a = lstMdiChild.Item(i)
				a->TextBox1.Font.Name = FontDialog1.Font.Name
				a->TextBox1.Font.Size = FontDialog1.Font.Size
				a->TextBox1.Font.Bold = FontDialog1.Font.Bold
				a->TextBox1.Font.CharSet = FontDialog1.Font.CharSet
				a->TextBox1.Font.StrikeOut = FontDialog1.Font.StrikeOut
				a->TextBox1.Font.Underline= FontDialog1.Font.Underline
				a->TextBox1.Font.Italic = FontDialog1.Font.Italic
				a->TextBox1.Font.Color = FontDialog1.Font.Color
			Next
		End If
	Case "mnuViewAllBackColor"
		Dim a As MDIChildType Ptr = lstMdiChild.Item(actMdiChildIdx)
		ColorDialog1.Color = a->TextBox1.BackColor
		If ColorDialog1.Execute Then
			For i = 0 To lstMdiChild.Count - 1
				a = lstMdiChild.Item(i)
				a->TextBox1.BackColor = ColorDialog1.Color
			Next
		End If
	Case Else
		MsgBox Sender.Name & !"\r\nThis function is under construction", "View"
	End Select
	RequestAlign
	InvalidateRect(Handle, NULL, False)
	UpdateWindow(Handle)
End Sub

Private Sub MDIMainType.mnuEncoding_Click(ByRef Sender As MenuItem)
	If actMdiChildIdx < 0 Then Exit Sub
	Dim a As MDIChildType Ptr = lstMdiChild.Item(actMdiChildIdx)
	
	Select Case Sender.Name
	Case "mnuEncodingPlainText"
		'If frmCodePage.chkDontShow.Checked = False Then
		frmCodePage.SetMode(1)
		frmCodePage.cobEncod.ItemIndex = 0
		frmCodePage.cobEncod_Selected(frmCodePage.cobEncod, 0)
		frmCodePage.chkSystemCP_Click(frmCodePage.chkSystemCP)
		frmCodePage.SetCodePage(a->CodePage)
		frmCodePage.ShowModal(MDIMain)
		If frmCodePage.ModalResult <> ModalResults.OK Then Exit Sub
		'End If
		a->Encode = frmCodePage.cobEncod.ItemIndex 'FileEncodings.PlainText
		a->CodePage = Cast(Integer, frmCodePage.lstCodePage.ItemData(frmCodePage.lstCodePage.ItemIndex))
	Case "mnuEncodingUtf8"
		a->Encode = FileEncodings.Utf8
	Case "mnuEncodingUtf8BOM"
		a->Encode = FileEncodings.Utf8BOM
	Case "mnuEncodingUtf16BOM"
		a->Encode = FileEncodings.Utf16BOM
	Case "mnuEncodingUtf32BOM"
		a->Encode = FileEncodings.Utf32BOM
	Case "mnuEncodingCRLF"
		a->NewLine = NewLineTypes.WindowsCRLF
	Case "mnuEncodingLF"
		a->NewLine = NewLineTypes.LinuxLF
	Case "mnuEncodingCR"
		a->NewLine = NewLineTypes.MacOSCR
	Case Else
		MsgBox Sender.Name & !"\r\nThis function is under construction", "Encoding"
	End Select
	
	a->Changed = True
	MDIChildMenuUpdate()
End Sub

Private Sub MDIMainType.mnuConvert_Click(ByRef Sender As MenuItem)
	Dim frm As MDIChildType Ptr = lstMdiChild.Item(actMdiChildIdx)
	Dim a As WString Ptr
	
	Dim s As LongInt = frm->TextBox1.SelStart
	Dim l As LongInt = frm->TextBox1.SelLength
	
	If l Then
		a = StrPtr(frm->TextBox1.SelText)
	Else
		a = StrPtr(frm->TextBox1.Text)
	End If
	Dim k As LongInt = Len(*a) * 2 + 2
	Dim c As WString Ptr = Allocate(k)
	
	Select Case Sender.Name
	Case "mnuConvertTraditional"
		TextConvert(*a, c, LCMAP_TRADITIONAL_CHINESE)
	Case "mnuConvertSimplified"
		TextConvert(*a, c, LCMAP_SIMPLIFIED_CHINESE)
	Case "mnuConvertFullWidth"
		TextConvert(*a, c, LCMAP_FULLWIDTH)
	Case "mnuConvertHalfWidth"
		TextConvert(*a, c, LCMAP_HALFWIDTH)
	Case "mnuConvertLowerCase"
		TextConvert(*a, c, LCMAP_LOWERCASE)
	Case "mnuConvertUpperCase"
		TextConvert(*a, c, LCMAP_UPPERCASE)
	Case "mnuConvertTitleCase"
		TextConvert(*a, c, &h00000300) 'LCMAP_TITLECASE
	Case "mnuConvertBIG5ToGB"
		Dim As String b = TextUnicode2Ansi(*a, CodePage_GB2312)
		Dim d As WString Ptr = Allocate(k)
		TextAnsi2Unicode(b, d, CodePage_BIG5)
		TextConvert(*d, c, LCMAP_SIMPLIFIED_CHINESE)
	Case "mnuConvertGBToBIG5"
		Dim d As WString Ptr = Allocate(k)
		TextConvert(*a, d, LCMAP_TRADITIONAL_CHINESE)
		Dim As String b = TextUnicode2Ansi(*d, CodePage_BIG5)
		TextAnsi2Unicode(b, c, CodePage_GB2312)
	Case Else
		MsgBox Sender.Name & !"\r\nThis function is under construction", "Convert"
	End Select
	
	If l Then
		frm->TextBox1.SelText = *c
		frm->TextBox1.SelStart = s
		frm->TextBox1.SelLength = Len(*c)
	Else
		frm->TextBox1.Text = *c
		frm->TextBox1.SelStart = s
	End If
	frm->TextBox1.ScrollToCaret()
	frm->Changed
	If c Then Deallocate(c)
End Sub

Private Sub MDIMainType.mnuWindow_Click(ByRef Sender As MenuItem)
	Dim h As HWND
	
	Select Case Sender.Name
	Case "mnuWindowClose"
		h = Cast(HWND, SendMessage(FClient, WM_MDIGETACTIVE, 0, 0))
		If h Then SendMessage(h, WM_CLOSE, 0, 0)
	Case "mnuWindowCloseAll"
		Do
			h = Cast(HWND, SendMessage(FClient, WM_MDIGETACTIVE, 0, 0))
			If h Then SendMessage(h, WM_CLOSE, 0, 0)
		Loop While (h)
	Case "mnuWindowCascade"
		SendMessage FClient, WM_MDICASCADE, 0, 0
	Case "mnuWindowArrangeIcons"
		SendMessage FClient, WM_MDIICONARRANGE, 0, 0
	Case "mnuWindowTileHorizontal"
		SendMessage FClient, WM_MDITILE, MDITILE_HORIZONTAL, 0
	Case "mnuWindowTileVertical"
		SendMessage FClient, WM_MDITILE, MDITILE_VERTICAL, 0
	Case "mnuWindowMore"
		With MDIList
			.ShowModal()
			If .ModalResult = ModalResults.OK Then
				If .Tag = 0 Then Exit Sub
				Cast(MDIChildType Ptr, .Tag)->SetFocus()
			End If
		End With
		
		'Dim frm As MDIListType Ptr
		'frm = New MDIListType
		'With *frm
		'	.ShowModal(MDIMain)
		'	If .ModalResult = ModalResults.OK Then
		'		Debug.Print "OK"
		'		Debug.Print "Select: " & .ListControl1.ItemIndex
		'		If .ListControl1.ItemIndex < 0 Then Exit Sub
		'		Cast(MDIChildType Ptr, .ListControl1.ItemData(.ListControl1.ItemIndex))->SetFocus()
		'	End If
		'End With
		'Delete frm
		
	Case Else
		Cast(MDIChildType Ptr, Sender.Tag)->SetFocus()
	End Select
End Sub

Private Sub MDIMainType.mnuHelp_Click(ByRef Sender As MenuItem)
	Select Case Sender.Name
	Case "mnuHelpAbout"
		MsgBox(!"Visual FB Editor\r\n\r\nMDI Notepad\r\nBy Cm Wang", "MDI Notepad")
	Case Else
		MsgBox Sender.Name & !"\r\nThis function is under construction", "Edit"
	End Select
End Sub

Private Sub MDIMainType.Form_DropFile(ByRef Sender As Control, ByRef Filename As WString)
	FileOpen(Filename)
End Sub

Private Sub MDIMainType.Form_Create(ByRef Sender As Control)
	ControlEnabled(False)
End Sub

Private Sub MDIMainType.MDIChildMenuUpdate()
	If actMdiChildIdx < 0 Then
		spFileName.Caption = ""
		spLocation.Caption = ""
		spEncode.Caption = ""
		spEOL.Caption = ""
		ControlEnabled(False)
	Else
		Dim a As MDIChildType Ptr = lstMdiChild.Item(actMdiChildIdx)
		
		mnuViewWordWarps.Checked = a->TextBox1.WordWraps

		
		mnuEncodingPlainText.Caption = !"Plain Text\tCP:" & IIf(a->CodePage< 0, GetACP(), a->CodePage)
		mnuEncodingPlainText.Checked = IIf(a->Encode = FileEncodings.PlainText, True, False)
		mnuEncodingUtf8.Checked = IIf(a->Encode = FileEncodings.Utf8, True, False)
		mnuEncodingUtf8BOM.Checked = IIf(a->Encode = FileEncodings.Utf8BOM, True, False)
		mnuEncodingUtf16BOM.Checked = IIf(a->Encode = FileEncodings.Utf16BOM, True, False)
		mnuEncodingUtf32BOM.Checked = IIf(a->Encode = FileEncodings.Utf32BOM, True, False)
		
		mnuEncodingCRLF.Checked = IIf(a->NewLine = NewLineTypes.WindowsCRLF, True, False)
		mnuEncodingLF.Checked = IIf(a->NewLine = NewLineTypes.LinuxLF, True, False)
		mnuEncodingCR.Checked = IIf(a->NewLine = NewLineTypes.MacOSCR, True, False)
		
		ControlEnabled(True)
	End If
	
	Dim mMax As Integer = 5
	Dim i As Integer
	Dim j As Integer
	
	'delete and release menu
	For i = mnuWindowCount To 0 Step -1
		mnuWindow.Remove(mnuWindows(i))
		Delete mnuWindows(i)
	Next
	Erase mnuWindows
	
	mnuWindowCount = lstMdiChild.Count
	If mnuWindowCount = 0 Then
		mnuWindowCount = -1
		mnuWindow.Enabled = False
		If frmFindReplace.Visible Then frmFindReplace.CloseForm
		If frmGoto.Visible Then frmGoto.CloseForm
		Exit Sub
	End If
	mnuWindow.Enabled = True
	
	If mnuWindowCount > mMax Then
		j = mMax
		mnuWindowCount = mMax + 1
	Else
		j = mnuWindowCount
	End If
	
	ReDim mnuWindows(mnuWindowCount)
	
	'create a split bar menu
	i = 0
	mnuWindows(i) = New MenuItem
	mnuWindows(i)->Caption = "-"
	mnuWindow.Add mnuWindows(i)
	
	'create child list menu
	For i = 1 To j
		mnuWindows(i) = New MenuItem
		mnuWindows(i)->Tag = lstMdiChild.Item(i - 1)
		mnuWindows(i)->Caption = Cast(MDIChildType Ptr, lstMdiChild.Item(i - 1))->Text
		mnuWindows(i)->OnClick = @_mnuWindow_Click
		If (i - 1) = actMdiChildIdx Then mnuWindows(i)->Checked = True
		mnuWindow.Add mnuWindows(i)
	Next
	
	'create a list... menu
	If j < mnuWindowCount Then
		i = mnuWindowCount
		mnuWindows(i) = New MenuItem
		mnuWindows(i)->Name= "mnuWindowMore"
		mnuWindows(i)->Caption = "More Windows..."
		mnuWindows(i)->OnClick = @_mnuWindow_Click
		mnuWindow.Add mnuWindows(i)
	End If
End Sub

Private Function MDIMainType.MDIChildFind(ByRef newName As Const WString) As Integer
	Dim i As Integer
	Dim a As MDIChildType Ptr
	For i = 0 To lstMdiChild.Count - 1
		a = lstMdiChild.Item(i)
		If newName = *a->mFile Then
			Return i
		End If
	Next
	Return -1
End Function

Private Sub MDIMainType.ControlEnabled(Enabled As Boolean)
	'menu
	mnuFileSave.Enabled = Enabled
	mnuFileSaveAs.Enabled = Enabled
	mnuFileSaveAll.Enabled = Enabled
	mnuFileBar2.Enabled = Enabled
	mnuFileBrowse.Enabled = Enabled
	mnuFileBar3.Enabled = Enabled
	mnuFilePrintSetup.Enabled = Enabled
	mnuFilePrintPreview.Enabled = Enabled
	mnuFilePrint.Enabled = Enabled
	mnuFileBar4.Enabled = Enabled
	
	mnuEdit.Enabled = Enabled
	
	mnuViewBar2.Enabled = Enabled
	mnuViewWordWarps.Enabled = Enabled
	mnuViewFont.Enabled = Enabled
	mnuViewBackColor.Enabled = Enabled
	mnuViewAllFont.Enabled = Enabled
	mnuViewAllBackColor.Enabled = Enabled
	
	mnuEncoding.Enabled = Enabled
	mnuConvert.Enabled = Enabled
	mnuWindow.Enabled = Enabled
	
	'toolbar
	tbFileSave.Enabled = Enabled
	tbFileSaveAll.Enabled = Enabled
	
	UpdateWindow(Handle)
End Sub

Private Function MDIMainType.MDIChildNew() As Any Ptr
	Static ChildIdx As Integer = 0
	Dim frm As MDIChildType Ptr
	
	ChildIdx += 1
	frm = New MDIChildType
	frm->Index = ChildIdx
	lstMdiChild.Add frm
	Return frm
End Function

Private Sub MDIMainType.MDIChildActivate(Child As Any Ptr)
	actMdiChildIdx = lstMdiChild.IndexOf(Child)
	MDIChildMenuUpdate()
	Dim a As MDIChildType Ptr = Child
	Dim FileInfo As SHFILEINFO
	Dim h As Any Ptr = Cast(Any Ptr, SHGetFileInfo(*a->mFile, 0, @FileInfo, SizeOf(FileInfo), SHGFI_SYSICONINDEX))
	SendMessage(a->Handle, WM_SETICON, 0, Cast(LPARAM, ImageList_GetIcon(h, FileInfo.iIcon, 0)))
	'SendMessage(spFileName.Icon.Handle, WM_SETICON, 0, Cast(LPARAM, ImageList_GetIcon(h, FileInfo.iIcon, 0)))
	MDIChildClick(Child)
End Sub

Private Sub MDIMainType.MDIChildDestroy(Child As Any Ptr)
	lstMdiChild.Remove(lstMdiChild.IndexOf(Child))
	Delete Cast(MDIChildType Ptr, Child)
	
	If lstMdiChild.Count > 0 Then Exit Sub
	actMdiChildIdx = -1
	MDIChildMenuUpdate()
End Sub

Private Sub MDIMainType.MDIChildClick(Child As Any Ptr)
	Dim a As MDIChildType Ptr = Child
	Dim As Integer sx, sy, ex, ey
	Dim As Integer s, e
	
	Select Case a->Encode
	Case FileEncodings.Utf8
		spEncode.Caption = "Utf8"
	Case FileEncodings.Utf8BOM
		spEncode.Caption = "Utf8 (BOM)"
	Case FileEncodings.Utf16BOM
		spEncode.Caption = "Utf16 (BOM)"
	Case FileEncodings.Utf32BOM
		spEncode.Caption = "Utf32 (BOM)"
	Case Else
		spEncode.Caption = "Plain Text CP:" & IIf(a->CodePage< 0, GetACP(), a->CodePage)
	End Select
	
	Select Case a->NewLine
	Case NewLineTypes.LinuxLF
		spEOL.Caption = "Linux LF"
	Case NewLineTypes.MacOSCR
		spEOL.Caption = "MacOS CR"
	Case Else
		spEOL.Caption = "Windows CRLF"
	End Select

	spFileName.Caption = a->Text
	
	a->TextBox1.GetSel(sy, sx, ey, ex)
	a->TextBox1.GetSel(s, e)
	
	If s = e Then
		spLocation.Caption = "Locate at (" & sy & ":" & sx & ") " & s
	Else
		spLocation.Caption = "Selected at (" & sy & ":" & sx & ") - (" & ey & ":" & ex & ") " & s & ":" & e & "(" & e - s & ")"
		If frmFindReplace.Visible = True Then
			frmFindReplace.txtFind.Text = a->TextBox1.SelText
		Else
		End If
	End If
	
	If frmGoto.Visible = True Then
		frmGoto.lblMsg.Text = "Line number (1 -" & a->TextBox1.LinesCount & ")"
		frmGoto.txtLineNo.Text = "" & sy + 1
	Else
	End If
End Sub

Private Sub MDIMainType.Find(ByRef FindStr As Const WString, ByVal FindCase As Boolean = False, ByVal FindWarp As Boolean = True, ByVal FindBack As Boolean = False)
	Dim a As MDIChildType Ptr = lstMdiChild.Item(actMdiChildIdx)
	Dim p As Integer
	mFindBack = FindBack
	If FindBack Then
		If FindCase Then
			p = InWStrRev(a->TextBox1.Text, FindStr, a->TextBox1.SelStart)
			If p = 0 And FindWarp Then
				p = InWStrRev(a->TextBox1.Text, FindStr)
			End If
		Else
			p = InWStrRev(LCase(a->TextBox1.Text), LCase(FindStr), a->TextBox1.SelStart)
			If p = 0 And FindWarp Then
				p = InWStrRev(LCase(a->TextBox1.Text), LCase(FindStr))
			End If
		End If
		If p > 0 Then
			a->TextBox1.SelStart = p - 1
			a->TextBox1.SelEnd = p + Len(FindStr) - 1
		End If
	Else
		If FindCase Then
			p = InWStr(a->TextBox1.SelEnd + 1, a->TextBox1.Text, FindStr)
			If p = 0 And FindWarp Then
				p = InWStr(a->TextBox1.Text, FindStr)
			End If
		Else
			p = InWStr(a->TextBox1.SelEnd + 1, LCase(a->TextBox1.Text), LCase(FindStr))
			If p = 0 And FindWarp Then
				p = InWStr(LCase(a->TextBox1.Text), LCase(FindStr))
			End If
		End If
		If p > 0 Then
			a->TextBox1.SelStart = p - 1
			a->TextBox1.SelEnd = p + Len(FindStr) - 1
		End If
	End If
	MDIChildClick(a)
End Sub

Private Sub MDIMainType.Replace(ByRef FindStr As Const WString, ByRef ReplaceStr As Const WString, ByVal FindCase As Boolean = False, ByVal FindWarp As Boolean = True)
	Dim a As MDIChildType Ptr = lstMdiChild.Item(actMdiChildIdx)
	If a->TextBox1.SelText <> "" Then
		a->TextBox1.SelText = "" + ReplaceStr
		a->Changed = True
	End If
	
	If mFindBack Then
		a->TextBox1.SelStart = a->TextBox1.SelStart + Len(ReplaceStr) - 1
	Else
		a->TextBox1.SelStart = a->TextBox1.SelStart - 1
	End If
	Find(FindStr, FindCase, FindWarp, mFindBack)
	MDIChildClick(a)
End Sub

Private Sub MDIMainType.ReplaceAll(ByRef FindStr As Const WString, ByRef ReplaceStr As Const WString, ByVal FindCase As Boolean = False)
	Dim a As MDIChildType Ptr = lstMdiChild.Item(actMdiChildIdx)
	Dim p As Integer
	If FindCase Then
		p = InWStr(a->TextBox1.Text, FindStr)
	Else
		p = InWStr(LCase(a->TextBox1.Text), LCase(FindStr))
	End If
	If p Then
		Dim s As Integer = a->TextBox1.SelStart
		
		Dim t As WString Ptr = 0
		Dim i As Integer = ReplaceWStr (a->TextBox1.Text, FindStr, ReplaceStr, t, FindCase)
		If i Then
			a->TextBox1.Text = *t
			a->Changed = True
		End If
		If t Then Deallocate(t)
		
		a->TextBox1.SelStart = s
	End If
	MDIChildClick(a)
End Sub

Private Sub MDIMainType.GotoLineNo(ByVal LineNumber As Integer)
	Dim a As MDIChildType Ptr = lstMdiChild.Item(actMdiChildIdx)
	
	If a->TextBox1.LinesCount < LineNumber Then Exit Sub
	Dim l As Integer = 1
	Dim i As Integer
	Dim c As Integer
	For i = 1 To LineNumber - 1
		c = InWStr(l, a->TextBox1.Text, WChr(13, 10))
		If c < 1 Then Exit Sub
		l=c+2
	Next
	
	a->TextBox1.SelStart = l - 1
	a->TextBox1.SelEnd = l - 1
	MDIChildClick(a)
End Sub


