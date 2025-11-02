USE ProcessosTemporarios;
GO

BEGIN TRANSACTION;


/*--------------------------------------------------------------------------------------------        
Tipo Objeto: Function
Objeto     : 
Objetivo   : Mostrar todas as informações relevantes do processo
Criado em  : 05/04/2025
Palavras-chave: Declaração
----------------------------------------------------------------------------------------------        
Observações : 

----------------------------------------------------------------------------------------------        
Histórico:        
Autor                  IDBug Data       Descrição        
---------------------- ----- ---------- ------------------------------------------------------------        
Marcus Paiva				 05/04/2025 Criação da View
*/
CREATE FUNCTION dbo.infoProcesso(@iDeclaracaoID AS INT)
RETURNS TABLE
AS
RETURN
	SELECT
	td.iDeclaracaoID AS ID,
	td.cReferenciaBraslog AS 'Referencia Braslog', td.cReferenciaCliente AS 'Referencia Cliente',
	CASE
				WHEN LEN(td.cNumeroDeclaracao) > 10 THEN
					LEFT(td.cNumeroDeclaracao, 2) + 'BR' +
					SUBSTRING(td.cNumeroDeclaracao, 3, 9) + '-' +
					RIGHT(td.cNumeroDeclaracao, 1)
				WHEN LEN(td.cNumeroDeclaracao) = 10 THEN
					LEFT(td.cNumeroDeclaracao, 2) + '/' +
					SUBSTRING(td.cNumeroDeclaracao, 3, 7) + '-' +
					RIGHT(td.cNumeroDeclaracao, 1)
			END AS 'Declaração',
	td.dDataRegistroDeclaracao AS 'Data do Registro', td.dDataDesembaracoDeclaracao AS 'Data de Desembaraço',
	LEFT(td.cNumeroDOSSIE, 14) + '-' +
	RIGHT(td.cNumeroDOSSIE, 1) AS 'Nº DOSSIE',
	td.cNumeroProcessoAdministrativo AS 'Nº Processo E-CAC', td.cModal AS Modal, td.cDescricao 'Descriçao da mercadoria', td.cHistorico 'Follow up',
	tcn.cNomeEmpresarial AS 'Razão Social',
	LEFT(tcn.cNumeroInscricao, 2) + '.' +
		SUBSTRING(tcn.cNumeroInscricao, 3, 3) + '.' +
		SUBSTRING(tcn.cNumeroInscricao, 6, 3) + '/' +
		SUBSTRING(tcn.cNumeroInscricao, 9, 4) + '-' +
		RIGHT(tcn.cNumeroInscricao, 2) AS CNPJ,
	LEFT(tce.cNumeroCE,3) + '.' +
	SUBSTRING(tce.cNumeroCE,4,3) + '.' +
	SUBSTRING(tce.cNumeroCE,7,3) + '.' +
	SUBSTRING(tce.cNumeroCE,10,3) + '.' +
	RIGHT(tce.cNumeroCE,3)
	AS 'CE Mercante nº', tce.cStatusCE AS 'Status',
	tco.cContratoTipo AS 'Tipo do Contrato', tco.cNumeroNomeContrato AS 'Nº do Contrato', tco.dContratoDataAssinatura AS 'Data da Assinatura do Contrato',
	tco.dContratoVencimento AS 'Vencimento da Prorrogaçao',
	tco.iNumeroProrrogacao AS 'Nº da Prorrogação',
	ta.cNumeroApolice AS 'Nº da Apolice', ta.dVencimentoGarantia AS 'Data vencimento da Garantia',
	tr.cUnidadeReceitaFederal AS URF, tr.cNumeroRecintoAduaneiro AS RA, tr.cNomeRecinto AS 'Nome do Recinto Alfandegado'
	FROM tDeclaracao td
	LEFT JOIN tCNPJ tcn
	ON tcn.iCNPJID = td.iCNPJID
	LEFT JOIN tCeMercante tce
	ON td.iCEID = tce.iCEID
	LEFT JOIN tContrato tco
	ON td.iContratoID = tco.iContratoID
	LEFT JOIN tApoliceSeguroGarantia ta
	ON td.iApoliceID = ta.iApoliceID
	LEFT JOIN tRecintoAlfandegado tr
	ON td.iRecintoID = tr.iRecintoID
	WHERE td.iDeclaracaoID = @iDeclaracaoID

SELECT @@TRANCOUNT

SELECT * FROM dbo.infoProcesso(10);
DROP function dbo.infoProcesso;

SELECT * FROM tDeclaracao
SELECT * FROM vDeclaracao