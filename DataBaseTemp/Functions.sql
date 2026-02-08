/*--------------------------------------------------------------------------------------------        
Tipo Objeto: Function
Objeto Nome: informacoesCadastroPorProcesso
Objetivo   : Mostrar todas as informações relevantes do processo
Criado em  : 05/02/2026
Palavras-chave: Declaração
----------------------------------------------------------------------------------------------        
Observações : 

----------------------------------------------------------------------------------------------        
Histórico:        
Autor                  IDBug Data       Descrição        
---------------------- ----- ---------- ------------------------------------------------------------        
Marcus Paiva				 05/02/2026 Criação da Função
*/
CREATE OR ALTER FUNCTION informacoesCadastroPorProcesso(@iDeclaracaoId INT)
RETURNS TABLE
AS
RETURN

	SELECT
		tc.iCnpjId AS IdCnpj,
		tc.cCnpj AS CNPJ,
		tc.cNomeEmpresa AS RazaoSocial,
		tr.cNomeRecinto AS RecintoAduaneiro,
		tu.cNomeUnidadeReceitaFederal AS URF,
		td.cNumeroDeclaracao AS Declaracao,
		tv.dDataRegistro AS DataRegistroDeclaracao,
		tl.cConhecimentoEmbarque AS ConhecimentoEmbarque,
		tl.dDataChegadaBrasil AS DataChegadaBrasil,
		tce.cNumeroCe AS CEMercante,
		SUM(tdi.mPesoLiquido) AS PesoLiquido,
		tci.cNomeCidadeExterior AS CidadeEmbarque,
		td.cNumeroDossie AS Dossie,
		td.cNumeroProcessoAdministrativo AS ECAC
	FROM tDeclaracao td
	INNER JOIN tCNPJ tc 
		ON tc.iCnpjId = td.iCnpjId
	LEFT JOIN tRecinto tr 
		ON td.iRecintoId = tr.iRecintoId
	LEFT JOIN tUrf tu 
		ON tr.iUrfId = tu.iUrfId
	LEFT JOIN tValoresCalculoAduaneiro tv 
		ON td.iValoresCalculoAduaneiroId = tv.iValoresCalculoAduaneiroId
	LEFT JOIN tLogistica tl 
		ON td.iLogisticaId = tl.iLogisticaId
	LEFT JOIN tCeMercante tce 
		ON tl.iCeId = tce.iCeId
	LEFT JOIN tDeclaracaoItem tdi 
		ON td.iDeclaracaoId = tdi.iDeclaracaoId
	LEFT JOIN tCidadeExterior tci 
		ON tl.iCidadeExteriorId = tci.iCidadeExteriorId
	WHERE td.iDeclaracaoId = @iDeclaracaoId
	GROUP BY
		tc.iCnpjId,
		tc.cCnpj,
		tc.cNomeEmpresa,
		tr.cNomeRecinto,
		tu.cNomeUnidadeReceitaFederal,
		td.cNumeroDeclaracao,
		tv.dDataRegistro,
		tl.cConhecimentoEmbarque,
		tl.dDataChegadaBrasil,
		tce.cNumeroCe,
		tci.cNomeCidadeExterior,
		td.cNumeroDossie,
		td.cNumeroProcessoAdministrativo;

/*--------------------------------------------------------------------------------------------        
Tipo Objeto: Function
Objeto Nome: contratosPorDeclaracao
Objetivo   : Mostrar todos os contratos por Declaraçao
Criado em  : 08/02/2026
Palavras-chave: Declaração, Contrato
----------------------------------------------------------------------------------------------        
Observações : 

----------------------------------------------------------------------------------------------        
Histórico:        
Autor                  IDBug Data       Descrição        
---------------------- ----- ---------- ------------------------------------------------------------        
Marcus Paiva				 08/02/2026 Criação da Função
*/
CREATE OR ALTER FUNCTION contratosPorDeclaracao(@iDeclaracaoId INT)
RETURNS TABLE
AS
RETURN

	SELECT
        tco.iContratoId AS idContrato,
        tco.cNomeContrato AS NumeroContrato,
        tco.dContratoVencimento AS VencimentoContrato
    FROM tContratoDeclaracao tcd
    JOIN tContrato tco 
        ON tcd.iContratoId = tco.iContratoId
    WHERE tcd.iDeclaracaoId = @iDeclaracaoId;

/*--------------------------------------------------------------------------------------------        
Tipo Objeto: Function
Objeto Nome: informacoesGeraisPorProrrogacaoProcesso
Objetivo   : Mostrar de forma geral o periodo e os tributos da prorrogacao atual
Criado em  : 08/02/2026
Palavras-chave: Vencimento, Tributos
----------------------------------------------------------------------------------------------        
Observações : 

----------------------------------------------------------------------------------------------        
Histórico:        
Autor                  IDBug Data       Descrição        
---------------------- ----- ---------- ------------------------------------------------------------        
Marcus Paiva				 08/02/2026 Criação da Função
*/
CREATE OR ALTER FUNCTION informacoesGeraisPorProrrogacaoProcesso(@iDeclaracaoId INT)
RETURNS TABLE
AS
RETURN
	
	SELECT 
    tp.iProrrogacao AS Prorrogacao,
    tp.dDataProrrogacao AS InicioProrrogacao,
    tp.dVencimentoProrrogacao AS VencimentoProrrogacao,
    tde.dDataDesembaraco AS InicioRegime,
    SUM(
        ISNULL(td.mIiValor, 0) +
        ISNULL(td.mIpiValor, 0) +
        ISNULL(td.mPisValor, 0) +
        ISNULL(td.mCofinsValor, 0) +
        ISNULL(td.mIcmsValor, 0)
    ) AS Impostos
	FROM tDeclaracao tde
	LEFT JOIN tDeclaracaoItem td
		ON tde.iDeclaracaoId = td.iDeclaracaoId
	LEFT JOIN tProrrogacao tp
		ON tp.iDeclaracaoItemId = td.iDeclaracaoItemId
	WHERE tde.iDeclaracaoId = @iDeclaracaoId
	GROUP BY
		tp.iProrrogacao,
		tp.dDataProrrogacao,
		tp.dVencimentoProrrogacao,
		tde.dDataDesembaraco;