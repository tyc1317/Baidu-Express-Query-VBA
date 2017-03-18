VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Sheet1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
' SUMMARY:
'Baidu-Express-Query-VBA
'�ٶȿ���˵��Ų�ѯ�ӿ�-Excelͨ��VBA����
'------
'������Դ:https://github.com/mo10/Baidu-Express-Query
'
'��Excel���������������������ݣ����ǱȽϼ򵥱���ձ���ճ�Ӧ�ó�����
'����ͨ����ʵ��ʵʱ����������Ϣ��Excel�У�������ٶ�����������״̬���򻯲ֹܼ��ۺ���Ա�Զ����������ݸ��ٹ�����
'�����ٶ�������ͳһ������ѯ�ӿڣ�ʵ��С������С���������϶��������˾��ͳһ��������Ϣ���¹��ܡ�
'
'ͬʱ����Excelǿ��ĺ괦��������ʵ�ֶ������ķ���ɸѡ���鵼��������Sheet�����Excel�ļ��Ĺ������ܡ��������Ʒ�����ർ������ģ��ṩһ��СС�Ĳο���
'
'AUTHOR:
'logintan@foxmail.com
'
'http://blog.tanyucheng.cn/
'mailto:logintan@foxmail.com?subject=your+code+stinks
Private Sub Worksheet_SelectionChange(ByVal Target As Range)
    '��ݵ����к�
    Dim expressNumColNum As Integer
    expressNumColNum = 1
    If Target.Column = expressNumColNum Then '���������Ϣ��ѯ
        Call queryExpressInfo
    ElseIf Target.Address = "$G$1" Then '���������Ϣ��ѯ
        Call batchQueryExpressInfo
    ElseIf Target.Address = "$H$1" Then '���鵼�����µ�Sheet
        Call expSheets
    ElseIf Target.Address = "$I$1" Then '���鵼������Ӧ���ļ�
        Call expFiles
    End If

End Sub

'��ѯ����������Ϣ����ǰѡ�У�
Sub queryExpressInfo()
    Dim actRowNum As Integer
    actRowNum = ActiveCell.Row
    
    Set winHttp = CreateObject("WinHttp.WinHttpRequest.5.1")
    
    queryPrevious winHttp
    queryDo actRowNum, winHttp
End Sub

'����������Ϣ��������಻����50��ÿ�Σ�
Sub batchQueryExpressInfo()
    Dim beginRow, endRow As Integer
    On Error Resume Next
    beginRow = Application.InputBox("��ʼ��", "�������·�Χ����:begin", , , , , , 2)
    
    endRow = Application.InputBox("������", "�������·�Χ����:" & beginRow & "-?", , , , , , 2)
    
    If beginRow <= 1 Then
        MsgBox "��ʼ���������󣬱����������Ҵ���1"
    ElseIf endRow <= 1 Or endRow - beginRow < 0 Then
        MsgBox "�������������󣬱����������Ҵ�����ʼ��"
    ElseIf endRow - beginRow > 50 Then
        MsgBox "ÿ���������·�Χ���ܳ���50��"
    Else
        
        '��ݵ����к�
        Dim expressNumColNum As Integer
        expressNumColNum = 1
        Set masterSheet = Sheets("Master")
        Set winHttp = CreateObject("WinHttp.WinHttpRequest.5.1")
        queryPrevious winHttp
        For i = beginRow To endRow
            Dim actRowIndex As Integer
            actRowIndex = i
            queryDo actRowIndex, winHttp
        Next
        MsgBox endRow - beginRow & " ��������¼�������"
    End If
    
End Sub

Sub expSheets()

    Dim rowCounts As Integer
    Dim expressCompanyNameColNum As Integer
    expressCompanyNameColNum = 2 '��ݹ�˾������
    
    Set masterSheet = Sheets("Master")
    rowCounts = masterSheet.Cells(2, expressCompanyNameColNum).CurrentRegion.Rows.Count '��ȡB2���ڵ�Ԫ���������ݿ��ж����У�����ͷ��
    
    
    'ͳ��B�У���ݹ�˾�У���B2��ʼ����B[rowCounts]�в��ظ����ݵĸ���,���������ֵ�����keyΨһ�ķ����ﵽͳ��Ч��
    Set tempDict = CreateObject("scripting.dictionary")
    tempArr = masterSheet.Range(masterSheet.Cells(2, expressCompanyNameColNum), masterSheet.Cells(rowCounts, expressCompanyNameColNum)) '�ӵ�2�п�ʼ���ų���ͷ
    For Each c In tempArr
        If c <> "" Then
            tempDict(c) = ""
        Else
            '���ǿ�ݹ�˾��Ϊ�յ������
            tempDict("��") = ""
        End If
    Next
    
    
    '����Ҫ���ǵ���Ӧ��ݹ�˾�Ѿ����ڵ������ʾ�������"˳������"�Ѿ����ڣ���������Sheet����Ϊ "˳������(1)"����������
    Set tempSheetDict = CreateObject("scripting.dictionary")
    
    '������Sheets��������ȡ����
    For i = 1 To Sheets.Count
        tempSheetDict(Sheets(i).Name) = ""
    Next

    Application.ScreenUpdating = False
    Application.DisplayAlerts = False
        

    '���� B �� �ؼ��ִ������ݿ�ʼ
    For Each Key In tempDict
        
        Dim sName As String
        
        If tempSheetDict.Exists(Key) Then
            Dim num As Integer
            num = 1
            Do While tempSheetDict.Exists(Key & "(" & num & ")")
                num = num + 1
            Loop
            sName = Key & "(" & num & ")"
        Else
            sName = Key
        End If
        
        Sheets.Add After:=Sheets(Sheets.Count)
        Set lastSheet = Sheets(Sheets.Count)
        lastSheet.Name = sName

        
        '���Ʊ�ͷ �����洦����һ�б�ͷ����
        lastSheet.Range("A1:E1").Value = masterSheet.Range("A1:E1").Value
        
        
        Dim tempRow As Integer
        tempRow = 2 '���������±����кż�¼
        
        For i = 2 To rowCounts Step 1 '�ӵڶ��п�ʼ����
            If (Key = "��" And masterSheet.Cells(i, expressCompanyNameColNum).Value = "") Or masterSheet.Cells(i, expressCompanyNameColNum).Value = Key Then
                'Copy���ݣ�
                
                lastSheet.Cells(tempRow, 1).NumberFormatLocal = "@"  '��ݵ�����������Ҫ����Ϊ�ı���ʽ
                lastSheet.Range("A" & tempRow & ":E" & tempRow).Value = masterSheet.Range("A" & i & ":E" & i).Value
                
                tempRow = tempRow + 1
            End If
        Next
    Next
    
    Application.DisplayAlerts = True
    Application.ScreenUpdating = True

End Sub


Sub expFiles()

    Dim xPath As String '�����ļ���·��
     
    xPath = Application.ActiveWorkbook.Path '�͵�ǰ�ļ�ͬһĿ¼
    
   
    Dim rowCounts As Integer
    Dim expressCompanyNameColNum As Integer
    expressCompanyNameColNum = 2 '��ݹ�˾������
    
    Set masterSheet = Sheets("Master")
    rowCounts = masterSheet.Cells(2, expressCompanyNameColNum).CurrentRegion.Rows.Count '��ȡB2���ڵ�Ԫ���������ݿ��ж����У�����ͷ��
    
    
    
    
    'ͳ��B�У���ݹ�˾�У���B2��ʼ����B[rowCounts]�в��ظ����ݵĸ���,���������ֵ�����keyΨһ�ķ����ﵽͳ��Ч��
    Set tempDict = CreateObject("scripting.dictionary")
    tempArr = masterSheet.Range(masterSheet.Cells(2, expressCompanyNameColNum), masterSheet.Cells(rowCounts, expressCompanyNameColNum)) '�ӵ�2�п�ʼ���ų���ͷ
    For Each c In tempArr
        If c <> "" Then
            tempDict(c) = ""
        Else
            '���ǿ�ݹ�˾��Ϊ�յ������
            tempDict("��") = ""
        End If
    Next
    
    
    Application.ScreenUpdating = False
    Application.DisplayAlerts = False
        

    '���� B �� �ؼ��ִ������ݿ�ʼ
    For Each Key In tempDict
    
        Set tempXl = New Excel.Application
        Set tempXl = CreateObject("Excel.Application")
        Set tempXlB = tempXl.Workbooks.Add
        Set tempXLBS = tempXlB.Worksheets.Add
        
        tempXLBS.Name = Key

        
        '���Ʊ�ͷ �����洦����һ�б�ͷ����
        tempXLBS.Range("A1:E1").Value = masterSheet.Range("A1:E1").Value
        
        
        Dim tempRow As Integer
        tempRow = 2 '���������±����кż�¼
        
        For i = 2 To rowCounts Step 1 '�ӵڶ��п�ʼ����
            If (Key = "��" And masterSheet.Cells(i, expressCompanyNameColNum).Value = "") Or masterSheet.Cells(i, expressCompanyNameColNum).Value = Key Then
                'Copy���ݣ�
                
                tempXLBS.Cells(tempRow, 1).NumberFormatLocal = "@"  '��ݵ�����������Ҫ����Ϊ�ı���ʽ
                tempXLBS.Range("A" & tempRow & ":E" & tempRow).Value = masterSheet.Range("A" & i & ":E" & i).Value
                
                tempRow = tempRow + 1
            End If
        Next
        
        tempXlB.SaveAs Filename:=xPath & "\" & Key & ".xlsx"
        tempXlB.Close False
        tempXl.Quit
    Next
    
    Application.DisplayAlerts = True
    Application.ScreenUpdating = True

End Sub


'���߲�ѯǰ�ò���
Function queryPrevious(winHttp As Variant)
    With winHttp
        On Error Resume Next
        '����һ�ΰٶ���ҳ��winHttp ��ȡ��ӦCookies��Ϣ
        URL_BAIDU = "https://www.baidu.com/"
        .Open "GET", URL_BAIDU, False
        .Option(6) = False '.Option(6) = False����ǲ����ٵģ���ֹ��ҳ�ض��򣬷���Ļ���½֮����ҳ����ת���Ǿ͵ò���������Ҫ��cookie��
        .setRequestHeader "Connection", "Keep-Alive"
        .setRequestHeader "Cache-Control", "no-cache"
        .setRequestHeader "Accept", "text/html, application/xhtml+xml, */*"
        .setRequestHeader "Accept-Encoding", "deflate"
        .setRequestHeader "Accept-Language", "zh-CN,zh;q=0.8,de-CH;q=0.6,de;q=0.4"
        .setRequestHeader "Pragma", "no-cache"
        .setRequestHeader "Upgrade-Insecure-Requests", "1"
        .setRequestHeader "Host", "www.baidu.com"
        .setRequestHeader "Content-Type", "text/html;"
        .setRequestHeader "Referer", "https://www.baidu.com/"
        .setRequestHeader "User-Agent", "Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.98 Safari/537.36"
        .send
    End With
    
End Function

'�������߲�ѯ�ӿڣ�ִ�о���������Ϣ��ѯ��ִ�д˺���ǰ��Ҫ�ȵ��� ���߲�ѯǰ�ò��裺queryPrevious��
Function queryDo(actRowNum As Integer, winHttp As Variant)

    Set masterSheet = Sheets("Master")
    Dim URL_BAIDU, URL_BAIDU_EXPRESS, rspText, lastUpdateTime
    
    Dim expressNum As String
    '��ݵ����к�
    Dim expressNumColNum As Integer
    
    expressNumColNum = 1
    
    expressNum = masterSheet.Cells(actRowNum, expressNumColNum).Value '��ȡ��ݵ���
    If expressNum <> "" And actRowNum > 1 Then '��ݵ��Ų�Ϊ�գ��ų���һ�б�ͷ��������
        URL_BAIDU_EXPRESS = "https://sp0.baidu.com/9_Q4sjW91Qh3otqbppnN2DJv/pae/channel/data/asyncqury?cb=&com=&appid=4001&nu=" & expressNum & "&vcode=&token=&_=" & DateDiff("s", "01/01/1970 00:00:00", Now()) & "021"
        
        With winHttp
            On Error Resume Next
            .Open "GET", URL_BAIDU_EXPRESS, False
            .Option(6) = False
            .setRequestHeader "Connection", "Keep-Alive"
            .setRequestHeader "Cache-Control", "no-cache"
            .setRequestHeader "Accept", "text/html, application/xhtml+xml, */*"
            .setRequestHeader "Accept-Encoding", "deflate"
            .setRequestHeader "Accept-Language", "zh-CN,zh;q=0.8,de-CH;q=0.6,de;q=0.4"
            .setRequestHeader "Pragma", "no-cache"
            .setRequestHeader "Upgrade-Insecure-Requests", "1"
            .setRequestHeader "Host", "sp0.baidu.com"
            .setRequestHeader "Content-Type", "text/html;"
            .setRequestHeader "Referer", "https://www.baidu.com/"
            .setRequestHeader "User-Agent", "Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.98 Safari/537.36"
            .send
            
            rspText = .responsetext
            'Debug.Print rspText
            
        End With
        
         'ͨ������htmlfile���󣬶������ӿڷ��ص�Json���ݽ��н���
        Dim objHTML, objJSy, objWin As Object
        Set objHTML = CreateObject("htmlfile")
        Set objWin = objHTML.parentWindow
        
        Dim expressCompanyNameColNum, expressStateColNum, lastUpdateTimeColNum, expressContextColNum As Integer
        
        expressCompanyNameColNum = 2 '��ݹ�˾������
        expressStateColNum = 3 '����״̬��
        lastUpdateTimeColNum = 4 '������ʱ����
        expressContextColNum = 5 '����������̬��
            
        lastUpdateTime = Format(Date, "yyyy��m��d��") & " " & Format(time, "HH:mm:ss") '�Ե�ǰϵͳʱ��Ϊ������ʱ��
        
        
        '�����ӿڷ��ؽ����ʽ
        
        '{
        '  "msg":"",                  #��ѯ״̬��Ϣ,��ѯ�ɹ�ʱΪ��
        '  "status":"0",              #��ѯ״̬,0Ϊ�ɹ�
        '  "error_code":"0",          #��ѯ״̬,0Ϊ�ɹ�
        '  "data":{
        '    "notice":"������Ϣ�����ʵʱͬ�����Ѻ�ʱX��XʱXX��",
        '     "com":"yunda",          #��ݹ�˾Ӣ��
        '     "company":{...},        #��ݹ�˾��Ϣ
        '     "source":{...},         #������Դ
        '     "kuaidiSource":{...},   #��ݽӿ���Դ
        '     "info":{
        '      "status":"1",           #��ѯ״̬?
        '      "com":"yunda",          #��ݹ�˾Ӣ��
        '      "state":"0",            #ǩ��״̬?
        '       "context":{
        '        {
        '          "time":"1482000831",      #��ݶ�̬���� ʱ���
        '          "desc":"��X,����������X"   #�����¼�����
        '        },
        '        {...}
        '      },
        '      "_source_com":"yunda",       #������Դ��˾
        '      "_support_from":"partner"    #û������
        '    }
        '  }
        '}
        
        objWin.execScript "var json = " & rspText, "JScript"     '����һ��JS��������JSON��������
        objWin.execScript "var code = json.status;", "JScript"
        objWin.execScript "var msg = json.msg;", "JScript"
        objWin.execScript "var companyName = json.data.company.fullname;", "JScript"
        masterSheet.Cells(actRowNum, expressCompanyNameColNum).Value = objWin.companyName
        masterSheet.Cells(actRowNum, lastUpdateTimeColNum).Value = lastUpdateTime
        If objWin.code = 0 Then
            objWin.execScript "var desc = json.data.info.context[0].desc;", "JScript"
            objWin.execScript "var time = json.data.info.context[0].time;", "JScript"
            objWin.execScript "var infoStatus = json.data.info.status;", "JScript"
            
            objWin.execScript "var infoState = json.data.info.state;", "JScript"
           
            If objWin.infoState = 3 Then
                masterSheet.Cells(actRowNum, expressStateColNum).Value = "�Ѿ�ǩ��"
            ElseIf objWin.infoState = 0 Then
                masterSheet.Cells(actRowNum, expressStateColNum).Value = "������"
            Else
                masterSheet.Cells(actRowNum, expressStateColNum).Value = objWin.infoState
            End If
            
            masterSheet.Cells(actRowNum, expressContextColNum).Value = objWin.companyName & ":(" & Format(19 + 70 * 365 + (8 * 3600 + Left(objWin.time, 10)) / 86400, "yyyyMMDD HH:mm:ss") & ")" & objWin.desc
            
        Else
            If objWin.code = -3 Or objWin.code = -2 Then
                masterSheet.Cells(actRowNum, expressStateColNum).Value = "��������Ϣ"
            Else
                masterSheet.Cells(actRowNum, expressStateColNum).Value = objWin.code
            End If
            masterSheet.Cells(actRowNum, expressContextColNum).Value = objWin.msg
        End If
        'If masterSheet.Cells(actRowNum, expressStateColNum).Value <> "" And masterSheet.Cells(actRowNum, expressContextColNum).Value <> "" Then
        '    MsgBox masterSheet.Cells(actRowNum, expressContextColNum).Value
        'End If
    End If
End Function