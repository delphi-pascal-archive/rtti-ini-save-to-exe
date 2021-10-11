unit Unit1;

// Structure Exe du début vers la fin :
// ************************************
// -> EXE d'origine
//    -> Données Composants
//       -> Position du début des données Composants
//          -> Fichier Ini
//             -> Position de début du fichier Ini
//                -> Marqueur CloseExe

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, StrUtils, TypInfo, ShellAPI, ExtCtrls, IniFiles;

type
  TForm1 = class(TForm)
    Button1     : TButton;
    Button2     : TButton;
    Button3     : TButton;
    Memo1       : TMemo;
    Edit1       : TEdit;
    Edit2       : TEdit;
    Label1      : TLabel;
    Label2      : TLabel;
    Panel1      : TPanel;
    Panel2      : TPanel;
    TreeView1   : TTreeView;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure TreeView1Click(Sender: TObject);
    procedure GetObjectInfo(Objet: TObject; Tree: TTreeNode);
    procedure SetObjectInfo(StrObjet: string; Objet: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
    Form1       : TForm1;
    lpBuffer    : array[0..MAX_PATH] of Char ;

const
    EndBal      : AnsiString  = 'CloseExe';
    NameTemp    : AnsiString  = 'ExeTMP.exe';
    CompTemp    : AnsiString  = 'CompTMP.txt';
    IniTemp     : AnsiString  = 'IniTMP.ini';

implementation

{$R *.dfm}

//Envoyer les nouvelles infos au composant
procedure TForm1.Button2Click(Sender: TObject);
begin
    if Edit1.Text <> EmptyStr then
        SetObjectInfo(Edit1.Text+'="'+Edit2.Text+'"', nil);
end;

//Fermer sans enregistrer
procedure TForm1.Button3Click(Sender: TObject);
begin
    Application.Terminate;
end;

//Enregistrement des composants
procedure SaveTool(DirFile: string; Components: array of TComponent);
var
  FileStream    : TFileStream;
  I             : Integer;
begin
    FileStream:=TFileStream.Create(DirFile, fmCreate);
    try
        for I := Low(Components) to High(Components) do
            FileStream.WriteComponent(Components[I]);
    finally
        FileStream.Free;
    end;
end;

//Ouverture des composants
procedure OpenTool(DirFile: string; Components: array of TComponent);
var
  FileStream    : TFileStream;
  I             : Integer;
begin
    FileStream:=TFileStream.Create(DirFile, fmOpenRead);
    try
        for I := Low(Components) to High(Components) do
            FileStream.ReadComponent(Components[I]);
    finally
        FileStream.Free;
    end;
end;

//Enregistrement des paramètres dans l'exe
procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
    MemoryStream    : TMemoryStream;
    FileStream      : TMemoryStream;
    MemoryStreamEnd : TMemoryStream;
    EndBalStr       : AnsiString;
    Pos             : Int64;
    MemIniFile      : TMemIniFile;
begin
    FileStream      := TMemoryStream.Create;
    MemoryStreamEnd := TMemoryStream.Create;
    MemoryStream    := TMemoryStream.Create;
    try
        SaveTool(lpBuffer+CompTemp, [TreeView1, Edit1, Edit2, Panel1, Panel2,
            Label1, Label2, Button1, Button2, Button3, Memo1]);
        FileStream.LoadFromFile(lpBuffer+CompTemp);
        MemoryStream.LoadFromFile(Application.ExeName);
        MemoryStream.Position := MemoryStream.Size - Length(EndBal);
        SetLength(EndBalStr, Length(EndBal));
        MemoryStream.ReadBuffer(EndBalStr[1], Length(EndBal));
        if EndBalStr = EndBal then
        begin
            MemoryStream.Position := MemoryStream.Size - Length(EndBal) - SizeOf(Pos);
            MemoryStream.ReadBuffer(Pos, SizeOf(Pos));
            MemoryStream.Position := Pos - SizeOf(Pos);
            MemoryStream.ReadBuffer(Pos, SizeOf(Pos));
            MemoryStream.Position := 0;
            MemoryStreamEnd.CopyFrom(MemoryStream, Pos);
        end
        else
        begin
            MemoryStream.Position := 0;
            MemoryStreamEnd.CopyFrom(MemoryStream, 0);
        end;
        FileStream.Position := 0;
        Pos := MemoryStreamEnd.Size;
        MemoryStreamEnd.CopyFrom(FileStream, 0);
        DeleteFile(lpBuffer+CompTemp);
        MemoryStreamEnd.WriteBuffer(Pos, SizeOf(Pos));
        MemIniFile:=TMemIniFile.Create(lpBuffer+IniTemp);
        try
            MemIniFile.WriteInteger('Form1', 'Top', Form1.Top);
            MemIniFile.WriteInteger('Form1', 'Left', Form1.Left);
            MemIniFile.WriteString ('Form1', 'Caption', Form1.Caption);
            MemIniFile.WriteInteger('Form1', 'Color', Form1.Color);
            MemIniFile.UpdateFile;
        finally
            MemIniFile.Free;
        end;
        FileStream.Clear;
        FileStream.LoadFromFile(lpBuffer+IniTemp);
        FileStream.Position := 0;
        Pos := MemoryStreamEnd.Size;
        MemoryStreamEnd.CopyFrom(FileStream, 0);
        DeleteFile(lpBuffer+IniTemp);
        MemoryStreamEnd.WriteBuffer(Pos, SizeOf(Pos));
        MemoryStreamEnd.WriteBuffer(EndBal[1], Length(EndBal));
        MemoryStreamEnd.SaveToFile(lpBuffer+NameTemp);
    finally
        MemoryStream.Free;
        FileStream.Free;
        MemoryStreamEnd.Free;
    end;
    {$IFDEF UNICODE}
    ShellExecute( 0, nil, PChar(lpBuffer+string(NameTemp)), PChar('"'+Application.ExeName+'"'), nil, SW_HIDE);
    {$ELSE}
    ShellExecute( 0, nil, PChar(lpBuffer+NameTemp), PChar('"'+Application.ExeName+'"'), nil, SW_HIDE);
    {$ENDIF}
end;

//Récupération des paramètres dans l'exe
procedure TForm1.FormCreate(Sender: TObject);
var
    MemoryStream    : TMemoryStream;
    MemoryComp      : TMemoryStream;
    EndBalStr       : AnsiString;
    Pos             : Int64;
    MemIniFile      : TMemIniFile;
begin
    GetTempPath(MAX_PATH, @lpBuffer);
    MemoryStream:=TMemoryStream.Create;
    try
        MemoryStream.LoadFromFile(Application.ExeName);
        MemoryStream.Position := MemoryStream.Size - Length(EndBal);
        SetLength(EndBalStr, Length(EndBal));
        MemoryStream.ReadBuffer(EndBalStr[1], Length(EndBal));
        if EndBalStr = EndBal then
        begin
            MemoryStream.Position := MemoryStream.Size - Length(EndBal) - SizeOf(Pos);
            MemoryStream.ReadBuffer(Pos, SizeOf(Pos));
            MemoryStream.Position := Pos;
            MemoryComp:=TMemoryStream.Create;
            try
                MemoryComp.CopyFrom(MemoryStream, MemoryStream.Size - Pos - Length(EndBal) - SizeOf(Pos));
                MemoryComp.SaveToFile(lpBuffer+IniTemp);
            finally
                MemoryComp.Free;
            end;
            MemIniFile:=TMemIniFile.Create(lpBuffer+IniTemp);
            try
                Form1.Top       := MemIniFile.ReadInteger('Form1', 'Top', Form1.Top);
                Form1.Left      := MemIniFile.ReadInteger('Form1', 'Left', Form1.Left);
                Form1.Caption   := MemIniFile.ReadString ('Form1', 'Caption', Form1.Caption);
                Form1.Color     := MemIniFile.ReadInteger('Form1', 'Color', Form1.Color);
            finally
                MemIniFile.Free;
            end;
            DeleteFile(lpBuffer+IniTemp);
            MemoryStream.Position := Pos - SizeOf(Pos);
            MemoryStream.ReadBuffer(Pos, SizeOf(Pos));
            MemoryStream.Position := Pos;
            MemoryComp:=TMemoryStream.Create;
            try
                MemoryComp.CopyFrom(MemoryStream, MemoryStream.Size - Pos - Length(EndBal) - SizeOf(Pos) - SizeOf(Pos));
                MemoryComp.SaveToFile(lpBuffer+CompTemp);
            finally
                MemoryComp.Free;
            end;
            OpenTool(lpBuffer+CompTemp, [TreeView1, Edit1, Edit2, Panel1, Panel2,
                Label1, Label2, Button1, Button2, Button3, Memo1]);
            DeleteFile(lpBuffer+CompTemp);
        end;
    finally
        MemoryStream.Free;
    end;
end;

//Modification des propriétées des composants
procedure TForm1.SetObjectInfo(StrObjet: string; Objet: TObject);
var
    ListStrings : TStringList;
    ListTrie    : TStringList;
    I           : Integer;
    Temp        : string;
    ObjetStr    : TObject;
    vFont       : TObject;
begin
    ListStrings := TStringList.Create;
    ListTrie    := TStringList.Create;
    try
        {$IF RTLVersion >= 21}
        ListTrie.StrictDelimiter:=True;
        {$IFEND}
        ListTrie.Delimiter := '=';
        ListTrie.DelimitedText := StrObjet;
        ListStrings.AddStrings(ListTrie);
        if ListStrings.Count > 2 then
        begin
            for I := ListStrings.Count - 1 downto 2 do
            begin
                ListStrings.Strings[1]:=ListStrings.Strings[1]+'='+ListStrings.Strings[I];
                ListStrings.Delete(I);
            end;
        end;
        ListTrie.Clear;
        ListTrie.Delimiter := '.';
        ListTrie.DelimitedText := ListStrings.Strings[0];
        Temp := ListStrings.Strings[1];
        ListStrings.Clear;
        ListStrings.AddStrings(ListTrie);
        ListStrings.Add(Temp);
        if FindGlobalComponent(ListStrings.Strings[0]) <> nil then
            ObjetStr := TObject(FindGlobalComponent(ListStrings.Strings[0]))
        else
            ObjetStr := TObject(FindComponent(ListStrings.Strings[0]));
        if (Objet = nil) and (ObjetStr = nil) then
            Exit;
        if Objet <> nil then
            ObjetStr := Objet;
        if ListStrings.Count = 3 then
        begin
            if IsPublishedProp(ObjetStr, ListStrings.Strings[1]) then
                if GetPropInfo(ObjetStr.ClassInfo, ListStrings.Strings[1]) <> nil then
                    case PropType(ObjetStr, ListStrings.Strings[1]) of
                        tkSet,
                        tkString,
                        tkWString,
                        tkLString,
                        {$IF RTLVersion >= 21}
                        tkUString,
                        {$IFEND}
                        tkEnumeration,
                        tkUnknown       :   begin
                                                if UpperCase(GetPropInfo(ObjetStr.ClassInfo, ListStrings.Strings[1]).Name) <> 'NAME' then
                                                    SetPropValue(ObjetStr, ListStrings.Strings[1], ListStrings.Strings[2]);
                                            end;
                        tkInteger       :   case AnsiIndexStr(UpperCase(GetPropInfo(ObjetStr.ClassInfo, ListStrings.Strings[1]).PropType^.Name), ['TCOLOR', 'TCURSOR', 'TSHORTCUT']) of
                                                0   :   SetOrdProp(ObjetStr, ListStrings.Strings[1], StringToColor(ListStrings.Strings[2]));
                                                1   :   SetOrdProp(ObjetStr, ListStrings.Strings[1], StringToCursor(ListStrings.Strings[2]));
                                                2   :   SetOrdProp(ObjetStr, ListStrings.Strings[1], StrToIntDef(ListStrings.Strings[2],0));
                                                -1  :   SetOrdProp(ObjetStr, ListStrings.Strings[1], StrToIntDef(ListStrings.Strings[2],0));
                                             end;
                        tkFloat         :   SetFloatProp(ObjetStr,ListStrings.Strings[1], StrToFloatDef(ListStrings.Strings[2], 0));
                        tkClass         :   ;//SetObjectProp(Instance1,PropName,GetObjectProp(Instance2,PropName);
                        tkMethod        :   ;//SetMethodProp(Instance1,PropName,GetMethodProp(Instance2,PropName));
                        tkChar          :   ;
                        tkWChar         :   ;
                        tkVariant       :   ;
                        tkArray         :   ;
                        tkRecord        :   ;
                        tkInterface     :   ;
                        tkInt64         :   ;
                        tkDynArray      :   ;
                        {$IF RTLVersion >= 21}
                        tkClassRef      :   ;
                        tkPointer       :   ;
                        tkProcedure     :   ;
                        {$IFEND}
                        else
                            SetPropValue(ObjetStr, ListStrings.Strings[1], ListStrings.Strings[2]);
                    end;
        end
        else
        begin
            vFont:=GetObjectProp(ObjetStr, GetPropInfo(ObjetStr.ClassInfo, ListStrings.Strings[1]).Name);
            if vFont <> nil then
                SetObjectInfo(Copy(StrObjet, Pos('.', StrObjet)+1, Length(StrObjet)), vFont);
        end;
    finally
        ListTrie.Free;
        ListStrings.Free;
    end;
end;

//Récupération des propriétées des composants
procedure TForm1.GetObjectInfo(Objet: TObject; Tree: TTreeNode);
var
    PData       : PTypeData;
    PListe      : PPropList;
    NbProps     : Integer;
    I           : Integer;
    Method      : TMethod;
    TreeChild   : TTreeNode;
    vFont       : TObject;
    vStyle      : TObject;
    vIcon       : TICON;
    vStrings    : TStrings;
begin
    PData := GetTypeData(PTypeInfo(Objet.ClassInfo));
    NbProps := PData^.PropCount;
    New(PListe);
    GetPropInfos(PTypeInfo(Objet.ClassInfo), PListe);
    if NbProps <> 0 then
        SortPropList(PListe, NbProps);
    for I := 0 to NbProps -1 do
    begin
        TreeChild := TreeView1.Items.AddChild(Tree, PListe^[I]^.Name);
        TreeChild.ImageIndex := -1;
        Tree.ImageIndex := -1;
        case PListe^[I]^.PropType^.Kind of
            tkInteger       :   case AnsiIndexStr(UpperCase(PListe^[I]^.PropType^.Name), ['TCOLOR', 'TCURSOR', 'TSHORTCUT']) of
                                    0   :   TreeView1.Items.AddChild(TreeChild, ColorToString(GetOrdProp(Objet, PListe^[I])));
                                    1   :   TreeView1.Items.AddChild(TreeChild, CursorToString(GetOrdProp(Objet, PListe^[I])));
                                    2   :   TreeView1.Items.AddChild(TreeChild, GetPropValue(Objet, PListe^[I].Name));
                                    -1  :   TreeView1.Items.AddChild(TreeChild, GetPropValue(Objet, PListe^[I].Name));
                                end;
            tkFloat         :   TreeView1.Items.AddChild(TreeChild, FormatFloat('0.0000000', GetFloatProp(Objet, PListe^[I])));
            tkMethod        :   begin
                                    Method := GetMethodProp(Objet, PListe^[I]);
                                    if (Method.Code <> nil) and (Method.Data <> nil) then
                                        TreeView1.Items.AddChild(TreeChild, TObject(Method.Data).MethodName(Method.Code));
                                end;
            tkClass         :   begin
                                    vFont := GetObjectProp(Objet, PListe^[I]^.Name);
                                    if vFont <> nil then
                                        case AnsiIndexStr(UpperCase(PListe^[I]^.PropType^.Name), ['TICON', 'TSTRINGS']) of
                                            0   :   begin
                                                        vIcon := TIcon(vFont);
                                                        if vIcon.Empty then
                                                            TreeView1.Items.AddChild(TreeChild, 'Empty')
                                                        else
                                                            TreeView1.Items.AddChild(TreeChild, 'TIcon');
                                                    end;
                                            1   :   begin
                                                        vStrings := TStrings(vFont);
                                                        if vStrings.Count = 0 then
                                                            TreeView1.Items.AddChild(TreeChild, 'Empty')
                                                        else
                                                            TreeView1.Items.AddChild(TreeChild, 'TStrings');
                                                    end;
                                            -1  :   GetObjectInfo(vFont, TreeChild);
                                        end
                                    else
                                        TreeView1.Items.AddChild(TreeChild, '');
                                end;
            tkSet,
            tkString,
            tkWString,
            tkLString,
            {$IF RTLVersion >= 21}
            tkUString,
            {$IFEND}
            tkEnumeration,
            tkUnknown       :   case AnsiIndexStr(UpperCase(PListe^[I]^.PropType^.Name), ['TSTYLE']) of
                                    0   :   begin
                                                vStyle:=GetObjectProp(Objet, PListe^[I]^.Name);
                                                if vStyle <> nil then
                                                    TreeView1.Items.AddChild(TreeChild, GetPropValue(Objet, PListe^[I].Name))
                                                else
                                                    TreeView1.Items.AddChild(TreeChild, '')
                                            end;
                                    -1  :   TreeView1.Items.AddChild(TreeChild, GetPropValue(Objet, PListe^[I].Name));
                                end;
            tkChar          :   TreeView1.Items.AddChild(TreeChild,GetPropValue(Objet, PListe^[I].Name));
            tkWChar         :   TreeView1.Items.AddChild(TreeChild,GetPropValue(Objet, PListe^[I].Name));
            tkVariant       :   ShowMessage('tkVariant = '+PListe^[I]^.Name);
            tkArray         :   ShowMessage('tkArray = '+PListe^[I]^.Name);
            tkRecord        :   ShowMessage('tkRecord = '+PListe^[I]^.Name);
            tkInterface     :   ShowMessage('tkInterface = '+PListe^[I]^.Name);
            tkInt64         :   ShowMessage('tkInt64 = '+PListe^[I]^.Name);
            tkDynArray      :   ShowMessage('tkDynArray = '+PListe^[I]^.Name);
            {$IF RTLVersion >= 21}
            tkClassRef      :   ShowMessage('tkClassRef = '+PListe^[I]^.Name);
            tkPointer       :   ShowMessage('tkPointer = '+PListe^[I]^.Name);
            tkProcedure     :   ShowMessage('tkProcedure = '+PListe^[I]^.Name);
            {$IFEND}
        end;
    end;
    Dispose(PListe);
end;

//Mettre la propriété dans edit
procedure TForm1.TreeView1Click(Sender: TObject);
var
    SelNode     : TTreeNode;
    NodeParent  : TTreeNode;
begin
    Edit1.Clear;
    Edit2.Clear;
    if TreeView1.Selected = nil then
        Exit;
    SelNode := TreeView1.Selected;
    NodeParent := SelNode.Parent;
    if SelNode.Count = 0 then
    begin
        if NodeParent.Parent <> nil then
        begin
            Edit1.Text := NodeParent.Parent.Text+'.'+SelNode.Parent.Text;
            Edit2.Text := TreeView1.Selected.Text
        end
        else
            Edit1.Text := SelNode.Parent.Text+'.'+TreeView1.Selected.Text;
        if NodeParent.Parent <> nil then
        begin
            NodeParent := NodeParent.Parent;
            while NodeParent.Parent <> nil do
            begin
                NodeParent := NodeParent.Parent;
                Edit1.Text := NodeParent.Text+'.'+Edit1.Text;
            end;
        end;
    end;
end;

//Charger le treeview
procedure TForm1.Button1Click(Sender: TObject);
var
    MyTreeNode1 : TTreeNode;
    I           : Integer;
    List        : TStringList;
begin
    TreeView1.Items.Clear;
    List := TStringList.Create;
    try
        List.Add(Self.Name);
        for I := 0 to ComponentCount - 1 do
            List.Add(Components[I].Name);
        for I := 0 to List.Count - 1 do
        begin
            MyTreeNode1 := TreeView1.Items.Add(nil, List.Strings[I]);
            if FindGlobalComponent(List.Strings[I]) <> nil then
                GetObjectInfo(FindGlobalComponent(List.Strings[I]), MyTreeNode1)
            else
                GetObjectInfo(FindComponent(List.Strings[I]), MyTreeNode1);
        end;
    finally
        List.Free;
    end;
end;

end.

