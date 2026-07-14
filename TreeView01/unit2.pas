unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, StrUtils;

procedure Button_Click(Sender: TObject);
procedure log2(LINENUM_: integer; message_: string);

type
  Unit_ = class(TForm)
  private

  public
    procedure Button2Click(Sender: TObject);
  end;

var
  TextBox1:TEdit;
  Memo_:TMemo;

implementation

procedure log2(LINENUM_: integer; message_: string);
begin
  Memo_.Append(LINENUM_.ToString+message_);
end;

procedure Button_Click(Sender: TObject);
begin
  TextBox1.Text:='OK';
end;

procedure Unit_.Button2Click(Sender: TObject);
begin

end;

end.

