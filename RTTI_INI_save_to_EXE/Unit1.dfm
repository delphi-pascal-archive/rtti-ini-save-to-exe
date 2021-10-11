object Form1: TForm1
  Left = 225
  Top = 127
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Exemple RTTI et ini enregistre dans EXE'
  ClientHeight = 404
  ClientWidth = 560
  Color = clSkyBlue
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Visible = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Panel1: TPanel
    Left = 178
    Top = 0
    Width = 382
    Height = 404
    Align = alRight
    Color = clSkyBlue
    TabOrder = 0
    object Memo1: TMemo
      Left = 1
      Top = 169
      Width = 380
      Height = 234
      Align = alClient
      Alignment = taCenter
      Lines.Strings = (
        'Pour tester :'
        'Compile l'#39'EXE (Comp.exe) et utilisez le hors de delphi.'
        'Modifiez vos composants dans le treeview'
        'Ils seront enregistres dans l'#39'EXE'
        'Sauf la Form qui est bride a Caption, Top, Left, Color'
        'et qui est stocke dans un fichier ini dans l'#39'EXE'
        'Dans le memo vous pouvez ecrire ce que vous voulez.')
      TabOrder = 0
    end
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 380
      Height = 168
      Align = alTop
      Color = clSkyBlue
      TabOrder = 1
      object Label1: TLabel
        Left = 17
        Top = 55
        Width = 54
        Height = 16
        Caption = 'Property:'
      end
      object Label2: TLabel
        Left = 14
        Top = 98
        Width = 38
        Height = 16
        Caption = 'Value:'
      end
      object Button3: TButton
        Left = 8
        Top = 128
        Width = 361
        Height = 25
        Caption = 'Exit'
        TabOrder = 0
        OnClick = Button3Click
      end
      object Button1: TButton
        Left = 8
        Top = 8
        Width = 129
        Height = 25
        Caption = 'Load params'
        TabOrder = 1
        OnClick = Button1Click
      end
      object Button2: TButton
        Left = 264
        Top = 8
        Width = 105
        Height = 25
        Caption = 'Apply'
        TabOrder = 2
        OnClick = Button2Click
      end
      object Edit1: TEdit
        Left = 88
        Top = 48
        Width = 281
        Height = 24
        ReadOnly = True
        TabOrder = 3
      end
      object Edit2: TEdit
        Left = 88
        Top = 88
        Width = 281
        Height = 24
        TabOrder = 4
      end
    end
  end
  object TreeView1: TTreeView
    Left = 0
    Top = 0
    Width = 178
    Height = 404
    Align = alClient
    Indent = 19
    TabOrder = 1
    OnClick = TreeView1Click
  end
end
