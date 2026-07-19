unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  StrUtils, Unit2, simpleipc, Types;

type

  { TForm1 }

  TForm1 = class(TForm)
    Cmd_AddData1: TButton;
    Cmd_Root: TButton;
    Cmd_ClearTextBox: TButton;
    Cmd_ClearTextBox1: TButton;
    Cmd_Free: TButton;
    Cmd_AddData: TButton;
    Cmd_Create: TButton;
    Cmd_ChildInRoot: TButton;
    Cmd_ChildInChild: TButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Memo1: TMemo;
    TreeView1: TTreeView;
    procedure Cmd_AddData1Click(Sender: TObject);
    procedure Cmd_AddDataClick(Sender: TObject);
    procedure Cmd_ChildInChildClick(Sender: TObject);
    procedure Cmd_ChildInRootClick(Sender: TObject);
    procedure Cmd_ClearTextBox1Click(Sender: TObject);
    procedure Cmd_CreateClick(Sender: TObject);
    procedure Cmd_FreeClick(Sender: TObject);
    procedure Cmd_ClearTextBoxClick(Sender: TObject);
    procedure Cmd_RootClick(Sender: TObject);
    procedure ComboBox1EditingDone(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure TreeView1SelectionChanged(Sender: TObject);
  private

  public
    constructor Create(TheOwner: TComponent); override;
    procedure ClearTree();
    procedure FreeTree();
    procedure CreateTree(s_:string);
    procedure SendMessage_(s:String);
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}
procedure TForm1.SendMessage_(s:String);
var
  IPCClient: TSimpleIPCClient;
  CandidateIDs: array[0..3] of string;// Or array of string for older FPC versions
  SrvID: string;
begin

  // List of IDs you expect or want to test for
  //CandidateIDs := ['ServerOne', 'ServerTwo', 'AppInstance_123', 'MyServerID'];
  CandidateIDs[0]:='MessageLogConsole20';
  CandidateIDs[1]:='MessageLogConsole50';
  CandidateIDs[2]:='MessageLogConsole100';
  CandidateIDs[3]:='MessageLogConsole200';

  IPCClient := TSimpleIPCClient.Create(nil);
  try
    for SrvID in CandidateIDs do
    begin
      IPCClient.ServerID := SrvID;
      //IPCClient.Global := True; // Match the Global setting of your servers

      if IPCClient.ServerRunning then
      begin
        IPCClient.Active:=true;
        IPCClient.Connect;
        IPCClient.SendStringMessage(s);
        break;
      end;
    end;
  finally
    IPCClient.Disconnect;
    IPCClient.Active:=false;
    IPCClient.Free;
  end;

end;

procedure TForm1.CreateTree(s_:string);
var
  P_TempoData: P_TRecordData;
  TextPath: String;
  S_Step:string;
  i:integer;
  h:integer;
  l:integer;
  TargetNode: TTreeNode;
  StepNode: TTreeNode;
  s:string;
  Words: TStringArray;
begin
  TextPath := s_;
  Words:=TextPath.Split(ComboBox1.Text);

  TargetNode := TreeView1.Items.FindNodeWithTextPath(s_);

  if TargetNode <> nil then
  begin
    Log2({$I %LINENUM%},' case found path!');
    //TargetNode.ExpandParents;
    //TargetNode.Selected := True;
    //TreeView1.SetFocus;
    h:=high(TextPath.Split(ComboBox1.Text));
    l:=low(TextPath.Split(ComboBox1.Text));
    if (TargetNode.Data <> nil) then
    begin
      P_TempoData:=TargetNode.Data;
      Dispose(P_TempoData);
      TargetNode.Data:=nil;
    end;

    New(P_TempoData);
    P_TempoData^.Name_ := Edit3.Text;
    P_TempoData^.Str_ := Edit4.Text;
    TargetNode.Data:= P_TempoData;
    Log2({$I %LINENUM%},' Succeed!');
    exit;
  end;

  if TargetNode = nil then
  begin
    Log2({$I %LINENUM%},' case path not found!');
    h:=high(TextPath.Split(ComboBox1.Text));
    l:=low(TextPath.Split(ComboBox1.Text));
    //log2({$I %LINENUM%},' h= '+h.ToString);
    //log2({$I %LINENUM%},' l='+ l.ToString);
    i:=l;
    S_Step:='';
    StepNode:=nil;
    for s in TextPath.Split(ComboBox1.Text) do       //PathDelim
    begin
      S_Step:=S_Step+s;
      Log2({$I %LINENUM%},' S_Step: '+S_Step);
      TargetNode := TreeView1.Items.FindNodeWithTextPath(S_Step);
      if TargetNode <> nil then
      begin
        Log2({$I %LINENUM%},' Found!');
        StepNode:= TargetNode;
        if (i) = h then
        begin
          if (TargetNode.Data <> nil) then
          begin
            P_TempoData:=TargetNode.Data;
            Dispose(P_TempoData);
            TargetNode.Data:=nil;
          end;
          New(P_TempoData);
          P_TempoData^.Name_ := Edit3.Text;
          P_TempoData^.Str_ := Edit4.Text;
          Log2({$I %LINENUM%},' Add data to node');
          TargetNode.Data:= P_TempoData;
          Log2({$I %LINENUM%},' Break!');
          break;
        end;
      end;
      if TargetNode = nil then
      begin
        Log2({$I %LINENUM%},' Not found!');
        if i=h then
        begin
          New(P_TempoData);
          P_TempoData^.Name_ := Edit3.Text;
          P_TempoData^.Str_ := Edit4.Text;
          StepNode:=TreeView1.Items.AddChildObject(StepNode, s,P_TempoData);
          Log2({$I %LINENUM%},' Creat node + add data');
          Log2({$I %LINENUM%},' Succeed!');
          break;
        end;
        if i<>h then
        begin
          StepNode:=TreeView1.Items.AddChild(StepNode, s);
          Log2({$I %LINENUM%},' Creat node only');
          Log2({$I %LINENUM%},' Succeed!');
        end;
      end;
      i:=i+1;
      S_Step:=S_Step+'/';
    end;
  end;

end;

procedure TForm1.FreeTree();
var
  CurrentNode: TTreeNode;
  P_TempoData: P_TRecordData;
begin
  CurrentNode := TreeView1.Items.GetFirstNode;

  while CurrentNode <> nil do
  begin
    if CurrentNode.Data = nil then log2({$I %LINENUM%},' ['+CurrentNode.Text+']: nil');
    if CurrentNode.Data <> nil then
    begin
      log2({$I %LINENUM%},' ['+CurrentNode.Text+']: Free memory');
      P_TempoData:=CurrentNode.Data;
      Dispose(P_TempoData);
      CurrentNode.Data:=nil;
    end;
    CurrentNode := CurrentNode.GetNext;
  end;
end;

procedure TForm1.ClearTree();
var
  CurrentNode: TTreeNode;
  P_TempoData: P_TRecordData;
begin
CurrentNode := TreeView1.Items.GetFirstNode;

  while CurrentNode <> nil do
  begin
    if CurrentNode.Data <> nil then
    begin
      P_TempoData:=CurrentNode.Data;
      Dispose(P_TempoData);
      CurrentNode.Data:=nil;
    end;
    CurrentNode := CurrentNode.GetNext;
  end;

  TreeView1.Items.Clear
end;

function GetTextPath__(TargetNode: TTreeNode; const PathDelim_:string = '/'): string;
var
  CurrentNode: TTreeNode;
  s:string = '';
begin

  if (TargetNode <> nil) then
  begin
    CurrentNode:=TargetNode;
    s:=CurrentNode.Text;
    CurrentNode:=CurrentNode.Parent;
    while CurrentNode <> nil do
    begin
      s:=CurrentNode.Text+PathDelim_+s;
      CurrentNode:=CurrentNode.Parent;
    end;
  end;

 Result:=s;

end;

function FindNodeWithPath_(ATreeView: TTreeView; TextPath: String; const PathDelim_:string = '/'): TTreeNode;
var
  s: String;
begin
  Result := nil;
  for s in TextPath.Split(PathDelim_) do
  begin
    if (Result = nil) then
    begin
      if s = '' then Result := ATreeView.Items.FindTopLvlNode(PathDelim_)
      else Result := ATreeView.Items.FindTopLvlNode(s);
    end
    else
    begin
      Result.Expanded := true;
      Result := Result.FindNode(s);
    end;
  end;
end;

procedure TForm1.Cmd_ClearTextBoxClick(Sender: TObject);
begin
  Memo_.Clear;
  SendMessage_('clear');
  //CreateTree('root');
  //CreateTree('root\sub01');
  //CreateTree('root\sub01\sub');
end;

procedure TForm1.Cmd_RootClick(Sender: TObject);
begin
  TreeView1.Items.Add(nil,Edit1.Text);
end;

procedure TForm1.ComboBox1EditingDone(Sender: TObject);
var
  s:string;
begin
  if(Treeview1.Selected <> nil) then Edit2.Text  := GetTextPath__(Treeview1.Selected,ComboBox1.Text);
  if(Treeview1.Selected = nil) then Edit2.Text  := '';

  s:=Edit1.Text;
  if ComboBox1.Text = '/' then
    Edit1.Text := StringReplace(s, '\', ComboBox1.Text, [rfReplaceAll, rfIgnoreCase]);
  if ComboBox1.Text = '\' then
    Edit1.Text := StringReplace(s, '/', ComboBox1.Text, [rfReplaceAll, rfIgnoreCase]);
end;

procedure TForm1.Cmd_FreeClick(Sender: TObject);
begin
  FreeTree();
end;

procedure TForm1.Cmd_ClearTextBox1Click(Sender: TObject);
begin
  ClearTree();
end;

procedure TForm1.Cmd_CreateClick(Sender: TObject);
begin
  CreateTree(Edit1.Text);
end;

procedure TForm1.Cmd_AddData1Click(Sender: TObject);
begin
  if (Treeview1.Selected <> nil) then
  begin
    TreeView1.Items.AddChild(Treeview1.Selected, Edit1.Text);
  end;
end;

procedure TForm1.Cmd_AddDataClick(Sender: TObject);
var
  P_TempoData: P_TRecordData;
begin
  if (Treeview1.Selected <> nil) then
  begin
    if (Treeview1.Selected.Data <> nil) then
    begin
      P_TempoData:=Treeview1.Selected.Data;
      Dispose(P_TempoData);
      Treeview1.Selected.Data:=nil;
    end;
    New(P_TempoData);
    P_TempoData^.Name_ := Edit3.Text;
    P_TempoData^.Str_ := Edit4.Text;

    SendMessage_({$I %LINE%}+' Add data to node');
    Treeview1.Selected.Data:= P_TempoData
  end;
end;

procedure TForm1.Cmd_ChildInChildClick(Sender: TObject);
begin
  if (Treeview1.Selected <> nil) then
  if (Treeview1.Selected.Parent<>nil) then
  begin;
    TreeView1.Items.AddChild(Treeview1.Selected, Edit1.Text);
  end;
end;

procedure TForm1.Cmd_ChildInRootClick(Sender: TObject);
begin
  if (Treeview1.Selected <> nil) then
  if (Treeview1.Selected.Parent=nil) then
  begin;
    TreeView1.Items.AddChild(Treeview1.Selected, Edit1.Text);
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  CurrentNode: TTreeNode;
  P_TempoData: P_TRecordData;
begin

  CurrentNode := TreeView1.Items.GetFirstNode;

  while CurrentNode <> nil do
  begin
    if CurrentNode.Data <> nil then
    begin
      P_TempoData:=CurrentNode.Data;
      Dispose(P_TempoData);
      CurrentNode.Data:=nil;
    end;
    CurrentNode := CurrentNode.GetNext;
  end;

end;

procedure TForm1.TreeView1SelectionChanged(Sender: TObject);
//var
//  CurrentNode: TTreeNode;
begin
  if (Treeview1.Selected <> nil) then
  if (Treeview1.Selected.Data <> nil) then
  begin
    if GetTypeKind(Treeview1.Selected.Data) = GetTypeKind(P_TRecordData) then  log2({$I %LINENUM%},' Type: P_TRecordData');
    if GetTypeKind(Treeview1.Selected.Data) = GetTypeKind(TRecordData) then  log2({$I %LINENUM%},' Type: TRecordData');
    log2({$I %LINENUM%},' Name_: '+P_TRecordData(Treeview1.Selected.Data)^.Name_ );
    log2({$I %LINENUM%},' Str_: '+P_TRecordData(Treeview1.Selected.Data)^.Str_ );
  end
  else
  begin
    log2({$I %LINENUM%},' Empty Data');
  end;

  //if(Treeview1.Selected <> nil) then
  //if(Treeview1.Selected.Parent <> nil) then
  //begin
  //  CurrentNode:=Treeview1.Selected.Parent;
  //  if CurrentNode= nil then log2({$I %LINENUM%},' Parent: nil');
  //  if CurrentNode <> nil then log2({$I %LINENUM%},' Parent: '+CurrentNode.Text);
  //  log2({$I %LINENUM%},' Text: '+Treeview1.Selected.Text);
  //  log2({$I %LINENUM%},' Index:'+Treeview1.Selected.Index.ToString);
  //  log2({$I %LINENUM%},' AlphaSort: '+Treeview1.Selected.AlphaSort.ToInteger.ToString);
  //  log2({$I %LINENUM%},' GetTextPath: '+Treeview1.Selected.GetTextPath);
  //  log2({$I %LINENUM%},' Parent.Text: '+Treeview1.Selected.Parent.Text);
  //  log2({$I %LINENUM%},' Parent.Index:'+Treeview1.Selected.Parent.Index.ToString);
  //  log2({$I %LINENUM%},' Parent.AlphaSort: '+Treeview1.Selected.Parent.AlphaSort.ToInteger.ToString);
  //  log2({$I %LINENUM%},' Parent.GetTextPath: '+Treeview1.Selected.Parent.GetTextPath);
  //  //Treeview1.Selected.Parent.GetPrev
  //  //log2({$I %LINENUM%},' '+Treeview1.Items[Treeview1.Parent.Index].Text);
  //end
  //else
  //begin
  //  log2({$I %LINENUM%},' Text: '+Treeview1.Selected.Text);
  //  log2({$I %LINENUM%},' Index:'+Treeview1.Selected.Index.ToString);
  //  log2({$I %LINENUM%},' AlphaSort: '+Treeview1.Selected.AlphaSort.ToInteger.ToString);
  //  log2({$I %LINENUM%},' GetTextPath: '+Treeview1.Selected.GetTextPath);
  //end;
  //
  //if(Treeview1.Selected <> nil) then
  //if(Treeview1.Selected.Parent <> nil) then
  //begin
  //  ////Edit2.Text:=Treeview1.Selected.Parent.Text+'/'+Treeview1.Selected.Text;
  //  ////Edit2.Text:=Treeview1.Selected.GetPrev.Text+'/'+Treeview1.Selected.Text;
  //  ////Edit2.Text:=Treeview1.Selected.Parent.GetTextPath+'/'+Treeview1.Selected.Text;
  //  //Edit2.Text:=Treeview1.Selected.GetTextPath;
  //  ////Edit2.Text  := StringReplace(Edit2.Text, '/', ComboBox1.Text,[rfReplaceAll, rfIgnoreCase]);
  //end
  //else
  //begin
  //  //Edit2.Text:=Treeview1.Selected.Text;
  //end;

  if(Treeview1.Selected <> nil) then Edit2.Text  := GetTextPath__(Treeview1.Selected,ComboBox1.Text);
  if(Treeview1.Selected = nil) then Edit2.Text  := '';

end;

constructor TForm1.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  Memo_:=Memo1;

  MyData.Name_ := 'Test';
  MyData.Str_ := 'Hello';
  MyData.Int_ := 123;


  //showmessage('TForm1.Create');
end;

end.

