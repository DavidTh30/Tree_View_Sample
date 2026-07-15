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
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
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
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
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

function FindNodeWithPath_(ATreeView: TTreeView; TextPath: String): TTreeNode;
var
  s: String;
begin
  Result := nil;
  for s in TextPath.Split('/') do       //PathDelim
  begin
    if (Result = nil) then
    begin
      if s = '' then Result := ATreeView.Items.FindTopLvlNode('/')
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
begin

  if(Treeview1.Selected <> nil) then
  begin
    TreeView1.Items.AddChildObject(TreeView1.Selected, 'Node Text', MyData);
  end;

  if(Treeview1.Selected = nil) then
  begin
    TreeView1.Items.AddChildObject(nil, 'Node Text', MyData);
  end;
end;

procedure TForm1.Button10Click(Sender: TObject);
var
  TargetNode: TTreeNode;
begin

  //TargetNode := FindNodeByPath(TreeView1, 'Root\Folder\Subfolder', '\');
  TargetNode := TreeView1.Items.FindNodeWithTextPath(Edit1.Text);

  if TargetNode <> nil then
  begin
    TargetNode.ExpandParents;
    TargetNode.Selected := True;
    TreeView1.SetFocus;
  end
  else
    ShowMessage('Path not found!');

end;

procedure TForm1.Button11Click(Sender: TObject);
var
  TextPath: String;
  TMyNodeDataPtr: PTMyNodeData;
  s:string;
  i:integer;
  h:integer;
  l:integer;
begin
  TextPath := Edit1.Text;
  New(TMyNodeDataPtr);
  TMyNodeDataPtr:=@MyData;
  //TMyNodeDataPtr^.Create;
  TMyNodeDataPtr^.CustomName := 'Data1234';
  TMyNodeDataPtr^.CustomID:=133;

  h:=high(TextPath.Split('/'));
  l:=low(TextPath.Split('/'));
  i:=l;
  for s in TextPath.Split('/') do       //PathDelim
  begin
    if i=h then Treeview1.Selected:=TreeView1.Items.AddChildObject(Treeview1.Selected, s, TMyNodeDataPtr^);
    if i<>h then Treeview1.Selected:=TreeView1.Items.AddChild(Treeview1.Selected, s);
    i:=i+1;
  end;

  //Dispose(TMyNodeDataPtr);
end;

procedure TForm1.Button13Click(Sender: TObject);
begin
  TreeView1.Selected := FindNodeWithPath_(TreeView1,Edit1.Text);
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
  if (Assigned(Treeview1.Selected.Data)) then
  if TypeInfo(Treeview1.Selected.Data) = TypeInfo(TMyNodeData.ClassInfo) then
  //if TypeInfo(Treeview1.Selected.Data) = TypeInfo(PTMyNodeData) then
  begin
    log2({$I %LINENUM%},' CustomName: '+TMyNodeData(Treeview1.Selected.Data).CustomName );
    log2({$I %LINENUM%},' CustomID: '+TMyNodeData(Treeview1.Selected.Data).CustomID.ToString );
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
begin
  CurrentNode := TreeView1.Items.GetFirstNode;

  while CurrentNode <> nil do
  begin
    if CurrentNode.Data = nil then   log2({$I %LINENUM%},' ['+CurrentNode.Text+']: nil');
    if CurrentNode.Data <> nil then
    begin
      log2({$I %LINENUM%},' ['+CurrentNode.Text+']: Free memory');
      TMyNodeData(CurrentNode.Data).Free;
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

procedure TForm1.Button7Click(Sender: TObject);
begin
  Memo_.Clear;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  TreeView1.Items.Clear
end;

procedure TForm1.Button9Click(Sender: TObject);
var
  MyData2: TMyNodeData;
  TMyNodeDataPtr: PTMyNodeData;
begin
  MyData2:= TMyNodeData.Create;
  MyData2.CustomName := 'Hello';
  MyData2.CustomID := 123;

  New(TMyNodeDataPtr);
  TMyNodeDataPtr^:= MyData2;
  //TMyNodeDataPtr:= @MyData2;

  //TMyNodeDataPtr^.CustomName := 'Hello';
  //TMyNodeDataPtr^.CustomID := 123;

  if(Treeview1.Selected <> nil) then
  begin
    TreeView1.Selected.Data:= TMyNodeDataPtr^;
  end;

  Dispose(TMyNodeDataPtr);
  //MyData2.Free;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  CurrentNode: TTreeNode;
  Cleanup:boolean;
begin
  Cleanup:=false;
  CurrentNode := TreeView1.Items.GetFirstNode;

  while CurrentNode <> nil do
  begin
    if CurrentNode.Data <> nil then
    begin
      Cleanup:=true;
    end;
    CurrentNode := CurrentNode.GetNext;
  end;

  if Cleanup then
  if MyData <>  nil then
  if @MyData <>  nil then
  if Assigned(TMyNodeData(MyData)) then
  if @TMyNodeData(MyData)<>nil then
  begin
    MyData.Free;

  end;
end;

procedure TForm1.TreeView1SelectionChanged(Sender: TObject);
begin
  if(Treeview1.Selected <> nil) then
  if(Treeview1.Selected.Data <> nil) then
  if (Assigned(Treeview1.Selected.Data)) then
  if TypeInfo(Treeview1.Selected.Data) = TypeInfo(TMyNodeData.ClassInfo) then
  //if TypeInfo(Treeview1.Selected.Data) = TypeInfo(TMyNodeData) then
  //if TypeInfo(Treeview1.Selected.Data) = TypeInfo(PTMyNodeData) then
  begin
    log2({$I %LINENUM%},' CustomName: '+TMyNodeData(Treeview1.Selected.Data).CustomName);
    log2({$I %LINENUM%},' CustomID: '+TMyNodeData(Treeview1.Selected.Data).CustomID.ToString );
  end;
  if(Treeview1.Selected <> nil) then
  if(Treeview1.Selected.Parent <> nil) then
  begin
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
    //Edit2.Text:=Treeview1.Selected.Parent.Text+'/'+Treeview1.Selected.Text;
    //Edit2.Text:=Treeview1.Selected.GetPrev.Text+'/'+Treeview1.Selected.Text;
    //Edit2.Text:=Treeview1.Selected.Parent.GetTextPath+'/'+Treeview1.Selected.Text;
    Edit2.Text:=Treeview1.Selected.GetTextPath;
  end
  else
  begin
    Edit2.Text:=Treeview1.Selected.Text;
  end;
end;

constructor TForm1.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  TextBox1:= Edit1;
  Memo_:=Memo1;

  MyData := TMyNodeData.Create;
  MyData.CustomName := 'Hello';
  MyData.CustomID := 123;

  //showmessage('TForm1.Create');
end;

end.

