/*--------------------------------------------------------------------------------------------        
Tipo Objeto: View
Objeto     : vDeclaracao
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
CREATE OR ALTER VIEW vDeclaracao
WITH ENCRYPTION, SCHEMABINDING
AS
    SELECT 
        dbo.tDeclaracao.iDeclaracaoID AS ID,  -- Qualifiquei com dbo
        UPPER(LEFT(dbo.tCNPJ.cNomeEmpresarial, CHARINDEX(' ', dbo.tCNPJ.cNomeEmpresarial))) AS Cliente,
        CASE
            WHEN LEN(dbo.tDeclaracao.cNumeroDeclaracao) > 10 THEN
                LEFT(dbo.tDeclaracao.cNumeroDeclaracao, 2) + 'BR' +
                SUBSTRING(dbo.tDeclaracao.cNumeroDeclaracao, 3, 9) + '-' +
                RIGHT(dbo.tDeclaracao.cNumeroDeclaracao, 1)
            WHEN LEN(dbo.tDeclaracao.cNumeroDeclaracao) = 10 THEN
                LEFT(dbo.tDeclaracao.cNumeroDeclaracao, 2) + '/' +
                SUBSTRING(dbo.tDeclaracao.cNumeroDeclaracao, 3, 7) + '-' +
                RIGHT(dbo.tDeclaracao.cNumeroDeclaracao, 1)
        END AS [Declaração de Importação],
        dbo.tDeclaracao.cReferenciaBraslog AS [Referencia Braslog],
        ISNULL(dbo.tDeclaracao.cReferenciaCliente, '') AS [Referencia Cliente],
        dbo.tContrato.dContratoVencimento AS [Prazo solicitado]
    FROM dbo.tDeclaracao
    INNER JOIN dbo.tCNPJ ON dbo.tDeclaracao.iCNPJID = dbo.tCNPJ.iCNPJID
    INNER JOIN dbo.tContrato ON dbo.tContrato.iContratoID = dbo.tDeclaracao.iContratoID
WITH CHECK OPTION
GO
--FIM da VIEW vDeclaracao