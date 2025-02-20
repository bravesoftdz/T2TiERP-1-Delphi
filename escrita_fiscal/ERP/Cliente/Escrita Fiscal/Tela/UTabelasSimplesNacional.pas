{ *******************************************************************************
  Title: T2Ti ERP
  Description: Janela de Cadastro das Tabelas do Simples Nacional

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
unit UTabelasSimplesNacional;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, DB, DBClient, Menus, StdCtrls, ExtCtrls, Buttons, Grids,
  DBGrids, JvExDBGrids, JvDBGrid, JvDBUltimGrid, ComCtrls, SimplesNacionalCabecalhoVO,
  SimplesNacionalCabecalhoController, Tipos, Atributos, Constantes, LabeledCtrls, JvToolEdit,
  Mask, JvExMask, JvBaseEdits, Math, StrUtils, ActnList, Generics.Collections,
  RibbonSilverStyleActnCtrls, ActnMan, ToolWin, ActnCtrls;

type
  [TFormDescription(TConstantes.MODULO_ESCRITA_FISCAL, 'Tabelas Simples Nacional')]

  TFTabelasSimplesNacional = class(TFTelaCadastro)
    DSTabelasSimplesNacionalDetalhe: TDataSource;
    CDSTabelasSimplesNacionalDetalhe: TClientDataSet;
    PanelMestre: TPanel;
    PageControlItens: TPageControl;
    tsItens: TTabSheet;
    PanelItens: TPanel;
    GridDetalhe: TJvDBUltimGrid;
    ComboBoxAnexo: TLabeledComboBox;
    EditVigenciaInicial: TLabeledDateEdit;
    EditVigenciaFinal: TLabeledDateEdit;
    ComboboxTabela: TLabeledComboBox;
    CDSTabelasSimplesNacionalDetalheID: TIntegerField;
    CDSTabelasSimplesNacionalDetalheID_SIMPLES_NACIONAL_CABECALHO: TIntegerField;
    CDSTabelasSimplesNacionalDetalheFAIXA: TIntegerField;
    CDSTabelasSimplesNacionalDetalheVALOR_INICIAL: TFMTBCDField;
    CDSTabelasSimplesNacionalDetalheVALOR_FINAL: TFMTBCDField;
    CDSTabelasSimplesNacionalDetalheALIQUOTA: TFMTBCDField;
    CDSTabelasSimplesNacionalDetalheIRPJ: TFMTBCDField;
    CDSTabelasSimplesNacionalDetalheCSLL: TFMTBCDField;
    CDSTabelasSimplesNacionalDetalheCOFINS: TFMTBCDField;
    CDSTabelasSimplesNacionalDetalhePIS_PASEP: TFMTBCDField;
    CDSTabelasSimplesNacionalDetalheCPP: TFMTBCDField;
    CDSTabelasSimplesNacionalDetalheICMS: TFMTBCDField;
    CDSTabelasSimplesNacionalDetalheIPI: TFMTBCDField;
    CDSTabelasSimplesNacionalDetalheISS: TFMTBCDField;
    procedure FormCreate(Sender: TObject);
    procedure GridDblClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    procedure GridParaEdits; override;
    procedure LimparCampos; override;
    procedure ControlaBotoes; override;

    // Controles CRUD
    function DoInserir: Boolean; override;
    function DoEditar: Boolean; override;
    function DoExcluir: Boolean; override;
    function DoSalvar: Boolean; override;

    procedure ConfigurarLayoutTela;
  end;

var
  FTabelasSimplesNacional: TFTabelasSimplesNacional;

implementation

uses ULookup, Biblioteca, UDataModule, SimplesNacionalDetalheVO;
{$R *.dfm}

{$REGION 'Controles Infra'}
procedure TFTabelasSimplesNacional.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TSimplesNacionalCabecalhoVO;
  ObjetoController := TSimplesNacionalCabecalhoController.Create;

  inherited;
end;

procedure TFTabelasSimplesNacional.LimparCampos;
begin
  inherited;
  CDSTabelasSimplesNacionalDetalhe.EmptyDataSet;
end;

procedure TFTabelasSimplesNacional.ConfigurarLayoutTela;
begin
  PanelEdits.Enabled := True;

  if StatusTela = stNavegandoEdits then
  begin
    PanelMestre.Enabled := False;
    PanelItens.Enabled := False;
  end
  else
  begin
    PanelMestre.Enabled := True;
    PanelItens.Enabled := True;
  end;
end;

procedure TFTabelasSimplesNacional.ControlaBotoes;
begin
  inherited;

  BotaoImprimir.Visible := False;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFTabelasSimplesNacional.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditVigenciaInicial.SetFocus;
  end;
end;

function TFTabelasSimplesNacional.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditVigenciaFinal.SetFocus;
  end;
end;

function TFTabelasSimplesNacional.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TSimplesNacionalCabecalhoController(ObjetoController).Exclui(IdRegistroSelecionado);
    except
      Result := False;
    end;
  end
  else
  begin
    Result := False;
  end;

  if Result then
    TSimplesNacionalCabecalhoController(ObjetoController).Consulta(Filtro, Pagina);
end;

function TFTabelasSimplesNacional.DoSalvar: Boolean;
var
  TabelasSimplesNacionalDetalhe: TSimplesNacionalDetalheVO;
begin
  DecimalSeparator := '.';
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TSimplesNacionalCabecalhoVO.Create;

      TSimplesNacionalCabecalhoVO(ObjetoVO).VigenciaInicial := EditVigenciaInicial.Date;
      TSimplesNacionalCabecalhoVO(ObjetoVO).VigenciaFinal := EditVigenciaFinal.Date;
      TSimplesNacionalCabecalhoVO(ObjetoVO).Anexo := ComboBoxAnexo.Text;
      TSimplesNacionalCabecalhoVO(ObjetoVO).Tabela := ComboboxTabela.Text;

      // Detalhes
      TSimplesNacionalCabecalhoVO(ObjetoVO).ListaSimplesNacionalDetalheVO := TObjectList<TSimplesNacionalDetalheVO>.Create;
      CDSTabelasSimplesNacionalDetalhe.DisableControls;
      CDSTabelasSimplesNacionalDetalhe.First;
      while not CDSTabelasSimplesNacionalDetalhe.Eof do
      begin
        TabelasSimplesNacionalDetalhe := TSimplesNacionalDetalheVO.Create;
        TabelasSimplesNacionalDetalhe.Id := CDSTabelasSimplesNacionalDetalheID.AsInteger;
        TabelasSimplesNacionalDetalhe.IdSimplesNacionalCabecalho := TSimplesNacionalCabecalhoVO(ObjetoVO).Id;
        TabelasSimplesNacionalDetalhe.Faixa := CDSTabelasSimplesNacionalDetalheFAIXA.AsInteger;
        TabelasSimplesNacionalDetalhe.ValorInicial := CDSTabelasSimplesNacionalDetalheVALOR_INICIAL.AsFloat;
        TabelasSimplesNacionalDetalhe.ValorFinal := CDSTabelasSimplesNacionalDetalheVALOR_FINAL.AsFloat;
        TabelasSimplesNacionalDetalhe.Aliquota := CDSTabelasSimplesNacionalDetalheALIQUOTA.AsFloat;
        TabelasSimplesNacionalDetalhe.Irpj := CDSTabelasSimplesNacionalDetalheIRPJ.AsFloat;
        TabelasSimplesNacionalDetalhe.Csll := CDSTabelasSimplesNacionalDetalheCSLL.AsFloat;
        TabelasSimplesNacionalDetalhe.Cofins := CDSTabelasSimplesNacionalDetalheCOFINS.AsFloat;
        TabelasSimplesNacionalDetalhe.PisPasep := CDSTabelasSimplesNacionalDetalhePIS_PASEP.AsFloat;
        TabelasSimplesNacionalDetalhe.Cpp := CDSTabelasSimplesNacionalDetalheCPP.AsFloat;
        TabelasSimplesNacionalDetalhe.Icms := CDSTabelasSimplesNacionalDetalheICMS.AsFloat;
        TabelasSimplesNacionalDetalhe.Ipi := CDSTabelasSimplesNacionalDetalheIPI.AsFloat;
        TabelasSimplesNacionalDetalhe.Iss := CDSTabelasSimplesNacionalDetalheISS.AsFloat;

        TSimplesNacionalCabecalhoVO(ObjetoVO).ListaSimplesNacionalDetalheVO.Add(TabelasSimplesNacionalDetalhe);

        CDSTabelasSimplesNacionalDetalhe.Next;
      end;
      CDSTabelasSimplesNacionalDetalhe.EnableControls;

      if StatusTela = stInserindo then
        Result := TSimplesNacionalCabecalhoController(ObjetoController).Insere(TSimplesNacionalCabecalhoVO(ObjetoVO))
      else if StatusTela = stEditando then
      begin
        if TSimplesNacionalCabecalhoVO(ObjetoVO).ToJSONString <> TSimplesNacionalCabecalhoVO(ObjetoOldVO).ToJSONString then
        begin
          Result := TSimplesNacionalCabecalhoController(ObjetoController).Altera(TSimplesNacionalCabecalhoVO(ObjetoVO), TSimplesNacionalCabecalhoVO(ObjetoOldVO));
        end
        else
          Application.MessageBox('Nenhum dado foi alterado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      end;
    except
      Result := False;
    end;
  end;
  DecimalSeparator := ',';
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFTabelasSimplesNacional.GridDblClick(Sender: TObject);
begin
  inherited;
  ConfigurarLayoutTela;
end;

procedure TFTabelasSimplesNacional.GridParaEdits;
var
  TabelasSimplesNacionalDetalheEnumerator: TEnumerator<TSimplesNacionalDetalheVO>;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    ObjetoVO := ObjetoController.VO<TSimplesNacionalCabecalhoVO>(IdRegistroSelecionado);
    if StatusTela = stEditando then
      ObjetoOldVO := ObjetoController.VO<TSimplesNacionalCabecalhoVO>(IdRegistroSelecionado);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditVigenciaInicial.Date := TSimplesNacionalCabecalhoVO(ObjetoVO).VigenciaInicial;
    EditVigenciaFinal.Date := TSimplesNacionalCabecalhoVO(ObjetoVO).VigenciaFinal;
    ComboBoxAnexo.Text := TSimplesNacionalCabecalhoVO(ObjetoVO).Anexo;
    ComboboxTabela.Text := TSimplesNacionalCabecalhoVO(ObjetoVO).Tabela;

    // Detalhes
    TabelasSimplesNacionalDetalheEnumerator := TSimplesNacionalCabecalhoVO(ObjetoVO).ListaSimplesNacionalDetalheVO.GetEnumerator;
    try
      with TabelasSimplesNacionalDetalheEnumerator do
      begin
        while MoveNext do
        begin
          CDSTabelasSimplesNacionalDetalhe.Append;
          CDSTabelasSimplesNacionalDetalheID.AsInteger := Current.Id;
          CDSTabelasSimplesNacionalDetalheID_SIMPLES_NACIONAL_CABECALHO.AsInteger := Current.IdSimplesNacionalCabecalho;
          CDSTabelasSimplesNacionalDetalheFAIXA.AsInteger := Current.Faixa;
          CDSTabelasSimplesNacionalDetalheVALOR_INICIAL.AsFloat := Current.ValorInicial;
          CDSTabelasSimplesNacionalDetalheVALOR_FINAL.AsFloat := Current.ValorFinal;
          CDSTabelasSimplesNacionalDetalheALIQUOTA.AsFloat := Current.Aliquota;
          CDSTabelasSimplesNacionalDetalheIRPJ.AsFloat := Current.Irpj;
          CDSTabelasSimplesNacionalDetalheCSLL.AsFloat := Current.Csll;
          CDSTabelasSimplesNacionalDetalheCOFINS.AsFloat := Current.Cofins;
          CDSTabelasSimplesNacionalDetalhePIS_PASEP.AsFloat := Current.PisPasep;
          CDSTabelasSimplesNacionalDetalheCPP.AsFloat := Current.Cpp;
          CDSTabelasSimplesNacionalDetalheICMS.AsFloat := Current.Icms;
          CDSTabelasSimplesNacionalDetalheIPI.AsFloat := Current.Ipi;
          CDSTabelasSimplesNacionalDetalheISS.AsFloat := Current.Iss;
          CDSTabelasSimplesNacionalDetalhe.Post;
        end;
      end;
    finally
      TabelasSimplesNacionalDetalheEnumerator.Free;
    end;

    TSimplesNacionalCabecalhoVO(ObjetoVO).ListaSimplesNacionalDetalheVO := Nil;
    if Assigned(TSimplesNacionalCabecalhoVO(ObjetoOldVO)) then
      TSimplesNacionalCabecalhoVO(ObjetoOldVO).ListaSimplesNacionalDetalheVO := Nil;
  end;

  ConfigurarLayoutTela;
end;
{$ENDREGION}

end.
