{ *******************************************************************************
  Title: T2Ti ERP
  Description: Janela de Lotes de Lan�amentos do M�dulo Cont�bil

  The MIT License

  Copyright: Copyright (C) 2010 T2Ti.COM

  Permission is hereby granted, free of charge, to any person
  obtaining a copy of this software and associated documentation
  files (the "Software"), to deal in the Software without
  restriction, including without limitation the rights to use,
  copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the
  Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
  OTHER DEALINGS IN THE SOFTWARE.

  The author may be contacted at:
  t2ti.com@gmail.com</p>

  @author Albert Eije (alberteije@gmail.com)
  @version 1.0
  ******************************************************************************* }
unit UContabilLote;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, DB, DBClient, Menus, StdCtrls, ExtCtrls, Buttons, Grids,
  DBGrids, JvExDBGrids, JvDBGrid, JvDBUltimGrid, ComCtrls, ContabilLoteVO,
  ContabilLoteController, Tipos, Atributos, Constantes, LabeledCtrls, Mask, JvExMask,
  JvToolEdit, JvMaskEdit, JvExStdCtrls, JvEdit, JvValidateEdit, JvBaseEdits, Math, StrUtils;

type
  [TFormDescription(TConstantes.MODULO_CONTABILIDADE, 'Lote de Lan�amentos')]

  TFContabilLote = class(TFTelaCadastro)
    EditDescricao: TLabeledEdit;
    BevelEdits: TBevel;
    EditDataInclusao: TLabeledDateEdit;
    EditDataLiberacao: TLabeledDateEdit;
    ComboBoxLiberado: TLabeledComboBox;
    ComboBoxProgramado: TLabeledComboBox;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GridParaEdits; override;
    procedure ControlaBotoes; override;
    procedure ControlaPopupMenu; override;

    // Controles CRUD
    function DoInserir: Boolean; override;
    function DoEditar: Boolean; override;
    function DoExcluir: Boolean; override;
    function DoSalvar: Boolean; override;
  end;

var
  FContabilLote: TFContabilLote;

implementation

uses ULookup, Biblioteca, UDataModule;
{$R *.dfm}

{$REGION 'Controles Infra'}
procedure TFContabilLote.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TContabilLoteVO;
  ObjetoController := TContabilLoteController.Create;
  inherited;
end;

procedure TFContabilLote.ControlaBotoes;
begin
  inherited;

  BotaoImprimir.Visible := False;
end;

procedure TFContabilLote.ControlaPopupMenu;
begin
  inherited;

  MenuImprimir.Visible := False;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFContabilLote.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditDescricao.SetFocus;
  end;
end;

function TFContabilLote.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditDescricao.SetFocus;
  end;
end;

function TFContabilLote.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TContabilLoteController(ObjetoController).Exclui(IdRegistroSelecionado);
    except
      Result := False;
    end;
  end
  else
  begin
    Result := False;
  end;

  if Result then
    TContabilLoteController(ObjetoController).Consulta(Filtro, Pagina);
end;

function TFContabilLote.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      ObjetoVO := TContabilLoteVO.Create;

      TContabilLoteVO(ObjetoVO).Descricao := EditDescricao.Text;
      TContabilLoteVO(ObjetoVO).Liberado := IfThen(ComboBoxLiberado.ItemIndex = 0, 'S', 'N');
      TContabilLoteVO(ObjetoVO).Programado := IfThen(ComboBoxProgramado.ItemIndex = 0, 'S', 'N');
      TContabilLoteVO(ObjetoVO).DataInclusao := EditDataInclusao.Date;
      TContabilLoteVO(ObjetoVO).DataLiberacao := EditDataLiberacao.Date;

      if StatusTela = stInserindo then
        Result := TContabilLoteController(ObjetoController).Insere(TContabilLoteVO(ObjetoVO))
      else if StatusTela = stEditando then
      begin
        if TContabilLoteVO(ObjetoVO).ToJSONString <> TContabilLoteVO(ObjetoOldVO).ToJSONString then
        begin
          TContabilLoteVO(ObjetoVO).Id := IdRegistroSelecionado;
          Result := TContabilLoteController(ObjetoController).Altera(TContabilLoteVO(ObjetoVO), TContabilLoteVO(ObjetoOldVO));
        end
        else
          Application.MessageBox('Nenhum dado foi alterado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      end;
    except
      Result := False;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFContabilLote.GridParaEdits;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    ObjetoVO := ObjetoController.VO<TContabilLoteVO>(IdRegistroSelecionado);
    if StatusTela = stEditando then
      ObjetoOldVO := ObjetoController.VO<TContabilLoteVO>(IdRegistroSelecionado);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditDescricao.Text := TContabilLoteVO(ObjetoVO).Descricao;
    ComboBoxLiberado.ItemIndex := AnsiIndexStr(TContabilLoteVO(ObjetoVO).Liberado, ['S', 'N']);
    ComboBoxProgramado.ItemIndex := AnsiIndexStr(TContabilLoteVO(ObjetoVO).Programado, ['S', 'N']);
    EditDataInclusao.Date := TContabilLoteVO(ObjetoVO).DataInclusao;
    EditDataLiberacao.Date := TContabilLoteVO(ObjetoVO).DataLiberacao;
  end;
end;
{$ENDREGION}

end.
