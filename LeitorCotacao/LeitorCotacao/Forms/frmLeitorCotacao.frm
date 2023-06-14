VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Begin VB.Form frmLeitorCotacao 
   Caption         =   "Leitor de Cota��es"
   ClientHeight    =   1440
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   7440
   Icon            =   "frmLeitorCotacao.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1440
   ScaleWidth      =   7440
   StartUpPosition =   2  'CenterScreen
   Begin VB.ComboBox cboFilial 
      Height          =   315
      Left            =   1080
      Style           =   2  'Dropdown List
      TabIndex        =   0
      Top             =   75
      Visible         =   0   'False
      Width           =   1080
   End
   Begin MSComDlg.CommonDialog cdbGeral 
      Left            =   6780
      Top             =   885
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin VB.CommandButton cmdSair 
      Caption         =   "&Sair"
      Height          =   345
      Left            =   5475
      TabIndex        =   2
      Top             =   960
      Width           =   1005
   End
   Begin VB.CommandButton cmdProcessar 
      Caption         =   "&Processar"
      Height          =   345
      Left            =   4455
      TabIndex        =   1
      Top             =   960
      Width           =   1005
   End
   Begin VB.TextBox txtArquivo 
      Height          =   330
      Left            =   1080
      Locked          =   -1  'True
      TabIndex        =   4
      Top             =   435
      Width           =   6165
   End
   Begin VB.Label Label1 
      AutoSize        =   -1  'True
      Caption         =   "Arquivo:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   240
      Index           =   0
      Left            =   180
      TabIndex        =   6
      Top             =   465
      Width           =   825
   End
   Begin VB.Label Label1 
      AutoSize        =   -1  'True
      Caption         =   "Empresa:"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   240
      Index           =   3
      Left            =   120
      TabIndex        =   5
      Top             =   75
      Visible         =   0   'False
      Width           =   915
   End
   Begin VB.Label lblInfo 
      AutoSize        =   -1  'True
      Caption         =   "Aguarde, Lendo arquivo..."
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H000000FF&
      Height          =   285
      Left            =   120
      TabIndex        =   3
      Top             =   975
      Visible         =   0   'False
      Width           =   2940
   End
End
Attribute VB_Name = "frmLeitorCotacao"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub cmdProcessar_Click()
        '<EhHeader>
        On Error GoTo Err_XLS
        '</EhHeader>
100     If Screen.MousePointer = 11 Then Exit Sub
101     Dim xl As New Excel.Application
102     Dim xlw As Excel.Workbook
103     Dim Arquivo As String, Plan As String, n_CTC_Num As Integer
104     Dim cur_CTC_Val As String, cur_CTC_ValNormal As String
105     Dim cur_CTC_Qtde As String, cAcrescimo As String, iPrazoDias As Integer
106     Arquivo = ""
107     With cdbGeral
108         .InitDir = App.Path
109         .DialogTitle = "Localizar Arquivo"
110         .Filter = "Arquivos Excel (*.xls/*.xlsx)| *.xls;*.xlsx"
111         .ShowOpen
112         If .FileName <> "" Then
113             Arquivo = .FileName
114             Plan = .FileTitle
115         End If
116     End With
117     If Arquivo = "" Then
118         MsgBox "Nenhum Arquivo Selecionado.", vbInformation, "Linear Sistemas"
119         Set xlw = Nothing
120         Set xl = Nothing
121         Exit Sub
122     Else
123         txtArquivo = Arquivo
124     End If
125     Screen.MousePointer = 11

126     n_CG2_COD = 0
127     n_emp_cod = 0
128     n_CTC_Num = 0

129     lblInfo.Visible = True
130     lblInfo.Caption = "Aguarde, Lendo arquivo..."
131     Set xlw = xl.Workbooks.Open(Arquivo)
132     xlw.Sheets(1).Select
        'empresa
133     cAux = xlw.Application.Cells(9, 5).Value
134     If cAux <> "" And IsNumeric(cAux) = True Then
135         n_emp_cod = Val(xlw.Application.Cells(9, 5).Value)
136         rs.Open "select emp_codigo from empresa where emp_codigo = " & n_emp_cod, cn, adOpenStatic, adLockReadOnly
137         If rs.EOF = True Then
138             MsgBox "Empresa n�o Localizada. Leitura n�o pode ser realizada.", vbInformation, "Linear Sistemas"
139             xlw.Close False
140             xl.Application.Quit
141             Set xlw = Nothing
142             Set xl = Nothing
143             GoTo Fim
144         End If
145         rs.Close
146     Else
147         MsgBox "Empresa n�o Identificada. Leitura n�o pode ser realizada.", vbInformation, "Linear Sistemas"
148         xlw.Close False
149         xl.Application.Quit
150         Set xlw = Nothing
151         Set xl = Nothing
152         GoTo Fim
153     End If
        'Numero da Cota��o
154     cAux = xlw.Application.Cells(7, 1).Value
155     If Val(Right(cAux, 6)) > 0 And IsNumeric(Val(Right(cAux, 6))) = True Then
156         n_CTC_Num = Val(Right(cAux, 6))
157         cSql = "Select ctc_cod from cotacao where ctc_cod = " & n_CTC_Num & " and ctc_empresa = " & n_emp_cod
158         rs.Open cSql, cn, adOpenStatic, adLockReadOnly
159         If rs.EOF = True Then
160             MsgBox "Cota��o n�o Localizada. Leitura n�o pode ser realizada.", vbInformation, "Linear Sistemas"
161             xlw.Close False
162             xl.Application.Quit
163             Set xlw = Nothing
164             Set xl = Nothing
165             GoTo Fim
166         End If
167         rs.Close
168     Else
169         MsgBox "Cota��o n�o identificada. Leitura n�o pode ser realizada.", vbInformation, "Linear Sistemas"
170         xlw.Close False
171         xl.Application.Quit
172         Set xlw = Nothing
173         Set xl = Nothing
174         GoTo Fim
175     End If
        'Codigo do fornecedor
176     cAcrescimo = 0: iPrazoDias = 0
177     cAux = xlw.Application.Cells(9, 1).Value
178     If Val(Mid(cAux, 12, 6)) > 0 And IsNumeric(Val(Mid(cAux, 12, 6))) = True Then
179         n_CG2_COD = Val(Mid(cAux, 12, 6))
180         rs.Open "select cg2_cod, cg2_acrescimocotacao, cg2_codcondpag from cg2 where cg2_cod = " & n_CG2_COD
181         If rs.EOF = True Then
182             MsgBox "Fornecedor n�o Localizado. Leitura n�o pode ser realizada.", vbInformation, "Linear Sistemas"
183             xlw.Close False
184             xl.Application.Quit
185             Set xlw = Nothing
186             Set xl = Nothing
187             GoTo Fim
188         Else
189             cAcrescimo = Format(rs!cg2_acrescimocotacao, "###,##0.00")
190             If IsNull(rs!cg2_codcondpag) = False Then
191                 If rs!cg2_codcondpag > 0 Then
192                     iPrazoDias = LerNome("fn4", "fn4_cod = " & rs!cg2_codcondpag, "fn4_medio", "N")
193                 End If
194             End If
195         End If
196         rs.Close
197     Else
198         MsgBox "Fornecedor n�o Identificado. Leitura n�o pode ser realizada.", vbInformation, "Linear Sistemas"
199         xlw.Close False
200         xl.Application.Quit
201         Set xlw = Nothing
202         Set xl = Nothing
203         GoTo Fim
204     End If
205     cn.Execute "delete from cotacao_forn where ctc_cod = " & Val(n_CTC_Num) & " and cg2_cod = " & n_CG2_COD & " and ctc_empresa = " & n_emp_cod & " and es1_cod is null"
206     cn.Execute "delete from cotacao_forn where ctc_cod = " & Val(n_CTC_Num) & " and cg2_cod = " & n_CG2_COD & " and ctc_empresa = " & n_emp_cod & " and es1_cod = 0"
207     ReDim acampos1(4, 1)
208     ReDim acampos2(8, 1)
209     For nI = 12 To 10000
210         n_ES1_COD = xlw.Application.Cells(nI, 1).Value
211         cAux = xlw.Application.Cells(nI, 2).Value
212         If n_ES1_COD = 0 And cAux = "" Then Exit For
213         If n_ES1_COD = 0 And cAux <> "" Then
214             Err.Number = 10
215             GoTo Err_XLS
216         End If
217         cur_CTC_Val = xlw.Application.Cells(nI, 6).Value
218         If IsNumeric(cur_CTC_Val) = False Then cur_CTC_Val = 0
219         cur_CTC_ValNormal = cur_CTC_Val
220         cur_CTC_Qtde = xlw.Application.Cells(nI, 4).Value
221         If IsNumeric(cur_CTC_Qtde) = False Then cur_CTC_Qtde = 0
222         If cur_CTC_Qtde = 0 Then cur_CTC_Qtde = 1
223         If n_ES1_COD > 0 Then
224             If cAcrescimo > 0 Then cur_CTC_Val = Format(CCur(cur_CTC_Val) + (CCur(cur_CTC_Val) * CCur(cAcrescimo) / 100), "###,##0.00")
225             cSql = "select * from cotacao_forn where ctc_cod = " & Val(n_CTC_Num) & " and cg2_cod = " & n_CG2_COD & " and es1_cod = " & Val(n_ES1_COD) & " and ctc_empresa = " & n_emp_cod
226             rs.Open cSql, cn, adOpenForwardOnly, adLockReadOnly
227             If Not rs.EOF Then
228                 acampos1(0, 0) = "CTC_PRECO":   acampos1(0, 1) = gVgPt(cur_CTC_Val)
229                 acampos1(1, 0) = "ctc_qemb":    acampos1(1, 1) = gVgPt(cur_CTC_Qtde)
230                 acampos1(2, 0) = "acrescimo":   acampos1(2, 1) = gVgPt(cur_CTC_Val - cur_CTC_ValNormal)
231                 acampos1(3, 0) = "prazodias":   acampos1(3, 1) = iPrazoDias
232                 cn.Execute Monta_Sql(acampos1, "cotacao_forn", "U", "ctc_cod = " & Val(n_CTC_Num) & " and cg2_cod = " & n_CG2_COD & " and es1_cod = " & Val(n_ES1_COD) & " and ctc_empresa = " & n_emp_cod)
233             Else
234                 acampos2(0, 0) = "CTC_COD":     acampos2(0, 1) = Val(n_CTC_Num)
235                 acampos2(1, 0) = "CG2_COD":     acampos2(1, 1) = n_CG2_COD
236                 acampos2(2, 0) = "ES1_COD":     acampos2(2, 1) = Val(n_ES1_COD)
237                 acampos2(3, 0) = "CTC_PRECO":   acampos2(3, 1) = gVgPt(cur_CTC_Val)
238                 acampos2(4, 0) = "ctc_qemb":    acampos2(4, 1) = gVgPt(cur_CTC_Qtde)
239                 acampos2(5, 0) = "ctc_empresa": acampos2(5, 1) = n_emp_cod
240                 acampos2(6, 0) = "acrescimo":   acampos2(6, 1) = gVgPt(cur_CTC_Val - cur_CTC_ValNormal)
241                 acampos2(7, 0) = "prazodias":   acampos2(7, 1) = iPrazoDias
242                 cn.Execute Monta_Sql(acampos2, "cotacao_forn", "I")
243             End If
244             cn.Execute "update cotacao set ctc_dtfim = " & Formata_Data(Date, "D") & " where ctc_cod = " & Val(n_CTC_Num) & " and ctc_empresa = " & n_emp_cod
245             rs.Close
246         End If
247         DoEvents
248     Next
249     xlw.Close False
250     xl.Application.Quit: nI = 0
251     Set xlw = Nothing
252     Set xl = Nothing
253     If Dir(App.Path & "\Cotacoes", vbDirectory) = "" Then MkDir (App.Path & "\Cotacoes")
254     If Dir(App.Path & "\Cotacoes\Lidas", vbDirectory) = "" Then MkDir (App.Path & "\Cotacoes\Lidas")
255     Plan = Replace(Plan, ".xls", "")
256     FileCopy (Arquivo), (App.Path & "\Cotacoes\Lidas" & "\" & Plan & "Lida.xls")
257     If Dir(Arquivo) <> "" Then
258        Kill (Arquivo)
259     End If
260     Arquivo = App.Path & "\Cotacoes\Lidas" & "\" & Plan & "Lida.xls"
261     MsgBox "Leitura Conclu�da. O arquivo de origem foi movido e renomeado para o caminho:" & vbNewLine & vbNewLine & Arquivo, vbInformation, "Linear Sistemas"
Fim:
262     Screen.MousePointer = 0
263     If rs.State = 1 Then rs.Close
264     lblInfo.Visible = False
265     txtArquivo = ""
266     Arquivo = ""
267     Exit Sub
        '<EhFooter>
Err_XLS:
        If Err.Number = 9 Then
            MsgBox "H� um erro com o arquivo. O Nome interno da Planilha foi alterado. Entre em contato com Suporte T�cnico." & vbNewLine & "Nome do Arquivo: " & Plan & ".xls", vbInformation, "Linear Sistemas"
        Else
            'If nI = 0 Then
                MsgBox "Houve um erro na leitura do arquivo." & vbNewLine & Err.Number & " - " & Err.Description & " na linha: " & Erl, vbInformation, "Linear Sistemas"
            'Else
            '    MsgBox "Houve um erro na leitura do arquivo. - Linha: " & nI, vbInformation, "Linear Sistemas"
            'End If
        End If
        Screen.MousePointer = 0
        lblInfo.Caption = "Importa��o n�o realizada."
        xlw.Close False
        xl.Application.Quit
        Set xlw = Nothing
        Set xl = Nothing
        Exit Sub
        Resume 0
        '</EhFooter>
End Sub

Private Sub cmdSair_Click()
    Unload Me
    End
End Sub

Private Sub Form_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then
        SendKeys "{Tab}", False
        KeyAscii = 0
    End If
    If KeyAscii = 27 Then
        KeyAscii = 0
        cmdSair_Click
    End If
End Sub

Private Sub Form_Load()
        '<EhHeader>
        On Error GoTo Form_Load_Err
        '</EhHeader>
100     Dim sIniFile As String
101     Call Fontes(Me)
102     sIniFile = App.Path & "\sglinx.ini"
103     cServer = sGetINI(sIniFile, "Settings", "Provider", "")
104     If cServer = "" Then
105         cServer = InputBox$("Digite o Nome ou IP da m�quina Servidora de Dados:")
106         writeINI sIniFile, "Settings", "Provider", cServer
107     End If
108     If UCase$(cServer) = UCase$("mysglinxdsn") Then
109         writeINI sIniFile, "Settings", "DSN", "mysglinxdsn"
110         cServer = InputBox$("Digite o Nome ou IP da m�quina Servidora de Dados:")
111         writeINI sIniFile, "Settings", "Provider", cServer
112     End If
113     cNomeBanco = sGetINI(sIniFile, "Settings", "nomebanco", "")
114     If cNomeBanco = "" Then
115         cNomeBanco = InputBox$("Digite o nome do Banco de Dados:")
116         writeINI sIniFile, "Settings", "nomebanco", cNomeBanco
117     End If
118     cPorta = sGetINI(sIniFile, "Settings", "PORTA", "")
119     If cPorta = "" Then
120         cPorta = "3306"
121         writeINI sIniFile, "Settings", "PORTA", cPorta
122     End If
    
123     cLinearCloud = UCase$(sGetINI(sIniFile, "Settings", "LINEARCLOUD", ""))
124     If cLinearCloud = "" Then
125         cLinearCloud = "NAO"
126         writeINI sIniFile, "Settings", "LINEARCLOUD", cLinearCloud
127     End If
    
128     Call LinearCoreNet.Start(0)
    
129     With LinearCoreNet.sglinxini
130         .servidor = cServer
131         .NomeBanco = cNomeBanco
132         .portabanco = cPorta
133         .LinearCloud = IIf(cLinearCloud = "SIM", True, False)
134     End With
    
135     With LinearCoreNet
136         If Not .helper.TestaConexaoPorParametro(.sglinxini.servidor, .sglinxini.NomeBanco, .sglinxini.portabanco, .sglinxini.LinearCloud) Then
137             .Library.Mensagem "Aten��o!!!" & vbNewLine & "Dados de conex�o com o banco de dados inv�lido(s)." & vbNewLine & "Servidor: " & .sglinxini.servidor & vbNewLine & "Banco: " & .sglinxini.NomeBanco & vbNewLine & "Porta: " & .sglinxini.portabanco & vbNewLine & "LinearCloud: " & .sglinxini.LinearCloud
138         End If
139     End With
    
140     Abre_Conexao
    
141     rs.Open "select now() as data", cn, adOpenStatic, adLockReadOnly
142     If Not rs.EOF Then
143         dDataBase = rs!Data
144     End If
145     If rs.State = 1 Then rs.Close
146     Me.BorderStyle = vbFixedSingle
    '<EhFooter>
Form_Load_fim:
        If rs.State = 1 Then rs.Close
        Exit Sub
Form_Load_Err:
        TrataErro Err.Number, Err.Description, Erl, "Menu", "Form_Load"
        Resume Form_Load_fim
        Resume 0
    '</EhFooter>
End Sub

