unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  StrUtils, Unit2;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button13: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Cmd_ClearTextBox: TButton;
    Cmd_ClearTreeView: TButton;
    Cmd_AddDateInToNode: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit4: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Memo1: TMemo;
    TreeView1: TTreeView;
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Cmd_ClearTextBoxClick(Sender: TObject);
    procedure Cmd_ClearTreeViewClick(Sender: TObject);
    procedure Cmd_AddDateInToNodeClick(Sender: TObject);
    procedure ComboBox1EditingDone(Sender: TObject);
    procedure Edit4EditingDone(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure TreeView1SelectionChanged(Sender: TObject);
  private

  public
    constructor Create(TheOwner: TComponent); override;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}
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

procedure TForm1.Button1Click(Sender: TObject);
var
  P_TempoData: P_TRecordData;
begin
  New(P_TempoData);

  P_TempoData^.CustomName := ComboBox2.Text;
  P_TempoData^.CustomID := StrToInt(edit4.Text);

  if(Treeview1.Selected <> nil) then
  begin
    TreeView1.Items.AddChildObject(TreeView1.Selected, 'Node Text', P_TempoData);
  end;

  if(Treeview1.Selected = nil) then
  begin
    TreeView1.Items.AddChildObject(nil, 'Node Text', P_TempoData);
  end;
end;

procedure TForm1.Button10Click(Sender: TObject);
var
  TargetNode: TTreeNode;
  s:string;
begin

  s:=Edit1.Text;
  if ComboBox1.Text = '\' then s  := StringReplace(s, ComboBox1.Text, '/',[rfReplaceAll, rfIgnoreCase]);


  //TargetNode := FindNodeByPath(TreeView1, 'Root\Folder\Subfolder', '\');
  TargetNode := TreeView1.Items.FindNodeWithTextPath(s);

  if TargetNode <> nil then
  begin
    TargetNode.ExpandParents;
    TargetNode.Selected := True;
    TreeView1.SetFocus;
  end
  else
    log2({$I %LINENUM%},' case path not found!');

end;

procedure TForm1.Button11Click(Sender: TObject);
var
  P_TempoData: P_TRecordData;
  TextPath: String;
  s:string;
  S_Step:string;
  i:integer;
  h:integer;
  l:integer;
  TargetNode: TTreeNode;
  StepNode: TTreeNode;
begin
  TextPath := Edit1.Text;

  TargetNode := TreeView1.Items.FindNodeWithTextPath(Edit1.Text);

  if TargetNode <> nil then
  begin
    log2({$I %LINENUM%},' case found path!');
    //TargetNode.ExpandParents;
    //TargetNode.Selected := True;
    //TreeView1.SetFocus;
    if (TargetNode.Data <> nil) then
    begin
      P_TempoData:=TargetNode.Data;
      Dispose(P_TempoData);
      TargetNode.Data:=nil;
    end;

    New(P_TempoData);
    P_TempoData^.CustomName := ComboBox2.Text;
    P_TempoData^.CustomID := StrToInt(edit4.Text);
    TargetNode.Data:= P_TempoData;
    log2({$I %LINENUM%},' Succeed!');
  end;

  if TargetNode = nil then
  begin
    log2({$I %LINENUM%},' case path not found!');
    h:=high(TextPath.Split(ComboBox1.Text));
    l:=low(TextPath.Split(ComboBox1.Text));
    i:=l;
    S_Step:='';
    StepNode:=nil;
    for s in TextPath.Split(ComboBox1.Text) do       //PathDelim
    begin
      S_Step:=S_Step+s;
      log2({$I %LINENUM%},' S_Step: '+S_Step);
      TargetNode := TreeView1.Items.FindNodeWithTextPath(S_Step);
      if TargetNode <> nil then
      begin
        StepNode:= TargetNode;
        if i=h then
        begin
          if (TargetNode.Data <> nil) then
          begin
            P_TempoData:=TargetNode.Data;
            Dispose(P_TempoData);
            TargetNode.Data:=nil;
          end;
          New(P_TempoData);
          P_TempoData^.CustomName := ComboBox2.Text;
          P_TempoData^.CustomID := StrToInt(edit4.Text);
          TargetNode.Data:= P_TempoData;
          log2({$I %LINENUM%},' Break!');
          break;
        end;
      end;
      if TargetNode = nil then
      begin
        if i=h then
        begin
          New(P_TempoData);
          P_TempoData^.CustomName := ComboBox2.Text;
          P_TempoData^.CustomID := StrToInt(edit4.Text);
          //Treeview1.Selected:=TreeView1.Items.AddChildObject(TargetNode, s, P_TempoData);
          StepNode:=TreeView1.Items.AddChildObject(StepNode, s, P_TempoData);
          log2({$I %LINENUM%},' Succeed!');
          break;
        end;
        if i<>h then
        begin
          //Treeview1.Selected:=TreeView1.Items.AddChild(TargetNode, s);
          StepNode:=TreeView1.Items.AddChild(StepNode, s);
        end;
      end;
      i:=i+1;
      S_Step:=S_Step+'/';
    end;
  end;



end;

procedure TForm1.Button13Click(Sender: TObject);
begin
  TreeView1.Selected := FindNodeWithPath_(TreeView1,Edit1.Text, ComboBox1.Text);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  log2({$I %LINENUM%},' Count: '+TreeView1.Items.Count.ToString);
  log2({$I %LINENUM%},' TopLvlCount: '+TreeView1.Items.TopLvlCount.ToString);
  log2({$I %LINENUM%},' Items.SelectionCount: '+TreeView1.Items.SelectionCount.ToString);
  log2({$I %LINENUM%},' Indent: '+TreeView1.Indent.ToString);
  log2({$I %LINENUM%},' SelectionCount: '+TreeView1.SelectionCount.ToString);
  if(Treeview1.Selected <> nil) then
    log2({$I %LINENUM%},' AbsoluteIndex: '+TreeView1.Selected.AbsoluteIndex.ToString);
  if(Treeview1.Selected = nil) then
    log2({$I %LINENUM%},' Selected: nil');
  if(Treeview1.Selected <> nil) then
  log2({$I %LINENUM%},' HasChildren: '+TreeView1.Selected.HasChildren.ToInteger.ToString);

  if(Treeview1.Selected <> nil) then
  if(Treeview1.Selected.Parent <> nil) then
    log2({$I %LINENUM%},' Parent.AbsoluteIndex: '+TreeView1.Selected.Parent.AbsoluteIndex.ToString);

  if(Treeview1.Selected <> nil) then
  if(Treeview1.Selected.Parent <> nil) then
    log2({$I %LINENUM%},' This is Child node' )
  else
    log2({$I %LINENUM%},' This is Root node' );

  if (Treeview1.Selected <> nil) then
  if (Treeview1.Selected.Data <> nil) then
  begin
    if GetTypeKind(Treeview1.Selected.Data) = GetTypeKind(P_TRecordData) then  log2({$I %LINENUM%},' Type: P_TRecordData');
    if GetTypeKind(Treeview1.Selected.Data) = GetTypeKind(TRecordData) then  log2({$I %LINENUM%},' Type: TRecordData');
    log2({$I %LINENUM%},' CustomName: '+P_TRecordData(Treeview1.Selected.Data)^.CustomName );
    log2({$I %LINENUM%},' CustomID: '+P_TRecordData(Treeview1.Selected.Data)^.CustomID.ToString );
  end
  else
  begin
    log2({$I %LINENUM%},' Not TMyNodeData');
  end;

  if (Treeview1.Selected <> nil) then
  if (Treeview1.Selected.Data = nil) then
    log2({$I %LINENUM%},' Selected.Data: nil');

end;

procedure TForm1.Button3Click(Sender: TObject);
var
  CurrentNode: TTreeNode;
  P_TempoData: P_TRecordData;
begin
  CurrentNode := TreeView1.Items.GetFirstNode;

  while CurrentNode <> nil do
  begin
    if CurrentNode.Data = nil then   log2({$I %LINENUM%},' ['+CurrentNode.Text+']: nil');
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

procedure TForm1.Button4Click(Sender: TObject);
begin
  TreeView1.Items.Add(nil, IntToStr(TreeView1.Items.GetLastNode.Index+1)+ ' Root');
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  if(Treeview1.Selected <> nil) then
  if(Treeview1.Selected.Parent = nil) then
    TreeView1.Items.AddChild(TreeView1.Items[TreeView1.Selected.AbsoluteIndex],IntToStr(TreeView1.Items[TreeView1.Selected.AbsoluteIndex].GetLastChild.Index+1)+' Child in root node');
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  if(Treeview1.Selected <> nil) then
  if(Treeview1.Selected.Parent <> nil) then
    TreeView1.Items.AddChild(TreeView1.Items[TreeView1.Selected.AbsoluteIndex], IntToStr(TreeView1.Items[TreeView1.Selected.AbsoluteIndex].GetLastChild.Index+1)+' Child in child node');
end;

procedure TForm1.Cmd_ClearTextBoxClick(Sender: TObject);
begin
  Memo_.Clear;
end;

procedure TForm1.Cmd_ClearTreeViewClick(Sender: TObject);
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

procedure TForm1.Cmd_AddDateInToNodeClick(Sender: TObject);
var
  P_TempoData: P_TRecordData;
begin
  if(Treeview1.Selected <> nil) then
  begin
    if (TreeView1.Selected.Data <> nil) then
    begin
      P_TempoData:=TreeView1.Selected.Data;
      Dispose(P_TempoData);
      TreeView1.Selected.Data:=nil;
    end;
    P_TempoData:=nil;
    New(P_TempoData);
    P_TempoData^.CustomName := ComboBox2.Text;
    P_TempoData^.CustomID := StrToInt(edit4.Text);
    TreeView1.Selected.Data:= P_TempoData;
  end;

  //Dispose(TMyNodeDataPtr);
end;

procedure TForm1.ComboBox1EditingDone(Sender: TObject);
begin
  if(Treeview1.Selected <> nil) then Edit2.Text  := GetTextPath__(Treeview1.Selected,ComboBox1.Text);
  if(Treeview1.Selected = nil) then Edit2.Text  := '';

  if ComboBox1.Text = '\' then Edit1.Text  := StringReplace(Edit1.Text, '/', ComboBox1.Text,[rfReplaceAll, rfIgnoreCase]);
  if ComboBox1.Text = '/' then Edit1.Text  := StringReplace(Edit1.Text, '\', ComboBox1.Text,[rfReplaceAll, rfIgnoreCase]);
end;

procedure TForm1.Edit4EditingDone(Sender: TObject);
begin
  edit4.Text := StrToInt(edit4.Text).ToString;
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
var
  CurrentNode: TTreeNode;
begin
  if (Treeview1.Selected <> nil) then
  if (Treeview1.Selected.Data <> nil) then
  begin
    if GetTypeKind(Treeview1.Selected.Data) = GetTypeKind(P_TRecordData) then  log2({$I %LINENUM%},' Type: P_TRecordData');
    if GetTypeKind(Treeview1.Selected.Data) = GetTypeKind(TRecordData) then  log2({$I %LINENUM%},' Type: TRecordData');
    log2({$I %LINENUM%},' CustomName: '+P_TRecordData(Treeview1.Selected.Data)^.CustomName );
    log2({$I %LINENUM%},' CustomID: '+P_TRecordData(Treeview1.Selected.Data)^.CustomID.ToString );
  end
  else
  begin
    log2({$I %LINENUM%},' Empty Data');
  end;

  if(Treeview1.Selected <> nil) then
  if(Treeview1.Selected.Parent <> nil) then
  begin
    CurrentNode:=Treeview1.Selected.Parent;
    if CurrentNode= nil then log2({$I %LINENUM%},' Parent: nil');
    if CurrentNode <> nil then log2({$I %LINENUM%},' Parent: '+CurrentNode.Text);
    log2({$I %LINENUM%},' Text: '+Treeview1.Selected.Text);
    log2({$I %LINENUM%},' Index:'+Treeview1.Selected.Index.ToString);
    log2({$I %LINENUM%},' AlphaSort: '+Treeview1.Selected.AlphaSort.ToInteger.ToString);
    log2({$I %LINENUM%},' GetTextPath: '+Treeview1.Selected.GetTextPath);
    log2({$I %LINENUM%},' Parent.Text: '+Treeview1.Selected.Parent.Text);
    log2({$I %LINENUM%},' Parent.Index:'+Treeview1.Selected.Parent.Index.ToString);
    log2({$I %LINENUM%},' Parent.AlphaSort: '+Treeview1.Selected.Parent.AlphaSort.ToInteger.ToString);
    log2({$I %LINENUM%},' Parent.GetTextPath: '+Treeview1.Selected.Parent.GetTextPath);
    //Treeview1.Selected.Parent.GetPrev
    //log2({$I %LINENUM%},' '+Treeview1.Items[Treeview1.Parent.Index].Text);
  end
  else
  begin
    log2({$I %LINENUM%},' Text: '+Treeview1.Selected.Text);
    log2({$I %LINENUM%},' Index:'+Treeview1.Selected.Index.ToString);
    log2({$I %LINENUM%},' AlphaSort: '+Treeview1.Selected.AlphaSort.ToInteger.ToString);
    log2({$I %LINENUM%},' GetTextPath: '+Treeview1.Selected.GetTextPath);
  end;

  if(Treeview1.Selected <> nil) then
  if(Treeview1.Selected.Parent <> nil) then
  begin
    ////Edit2.Text:=Treeview1.Selected.Parent.Text+'/'+Treeview1.Selected.Text;
    ////Edit2.Text:=Treeview1.Selected.GetPrev.Text+'/'+Treeview1.Selected.Text;
    ////Edit2.Text:=Treeview1.Selected.Parent.GetTextPath+'/'+Treeview1.Selected.Text;
    //Edit2.Text:=Treeview1.Selected.GetTextPath;
    ////Edit2.Text  := StringReplace(Edit2.Text, '/', ComboBox1.Text,[rfReplaceAll, rfIgnoreCase]);
  end
  else
  begin
    //Edit2.Text:=Treeview1.Selected.Text;
  end;

  if(Treeview1.Selected <> nil) then Edit2.Text  := GetTextPath__(Treeview1.Selected,ComboBox1.Text);
  if(Treeview1.Selected = nil) then Edit2.Text  := '';

end;

constructor TForm1.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  TextBox1:= Edit1;
  Memo_:=Memo1;

  MyData.CustomName := 'Hello';
  MyData.CustomID := 123;

  //showmessage('TForm1.Create');
end;

end.

