/*--------------------------------------------------------------------------------------------        
Tipo Objeto: View
Objeto     : vTelaPrincipalAtivos
Objetivo   : Tela principalAtivos, lista com todos os processos não arquivados
Criado em  : 01/02/2026
Palavras-chave: Declaracaçao
----------------------------------------------------------------------------------------------        
Observações :  Apenas mostrar Nome do Importador/Exportador, numero da Declaraçao, Referencia
               da Braslog, Referencia do Importador/Exportador, Prazo do regime atual;
----------------------------------------------------------------------------------------------        
Histórico:        
Autor                  IDBug Data       Decrição        
---------------------- ----- ---------- ------------------------------------------------------------        
Marcus Paiva				 01/02/2026 Criação da View
*/
CREATE OR ALTER VIEW dbo.vTelaPrincipalAtivos
WITH SCHEMABINDING
AS
    SELECT
        tn.cNomeEmpresa       AS cNomeCliente,
        td.cNumeroDeclaracao  AS Declaracao,
        tp.cReferenciaBraslog AS [Referencia Braslog],
        tp.cReferenciaCliente AS [Referencia Cliente],
        (
            SELECT TOP (1) tpr.dVencimentoProrrogacao
            FROM dbo.tDeclaracaoItem tdi2
            JOIN dbo.tProrrogacao tpr
                ON tpr.iDeclaracaoItemId = tdi2.iDeclaracaoItemId
            WHERE tdi2.iDeclaracaoId = td.iDeclaracaoId
        ) AS Prazo
    FROM dbo.tProcesso tp
    JOIN dbo.tDeclaracao td 
        ON td.iDeclaracaoId = tp.iDeclaracaoId
    JOIN dbo.tCnpj tn 
        ON tn.iCnpjId = td.iCnpjId
    WHERE tp.bIsAtivo = 1;
GO

/*--------------------------------------------------------------------------------------------        
Tipo Objeto: View
Objeto     : vTelaPrincipalArquivados
Objetivo   : Tela principalArquivados, lista com todos os processos não arquivados
Criado em  : 01/02/2026
Palavras-chave: Declaracaçao
----------------------------------------------------------------------------------------------        
Observações :  Apenas mostrar Nome do Importador/Exportador, numero da Declaraçao, Referencia
               da Braslog, Referencia do Importador/Exportador, Prazo do regime atual;
----------------------------------------------------------------------------------------------        
Histórico:        
Autor                  IDBug Data       Decrição        
---------------------- ----- ---------- ------------------------------------------------------------        
Marcus Paiva				 01/02/2026 Criação da View
*/
CREATE OR ALTER VIEW dbo.vTelaPrincipalArquivados
WITH SCHEMABINDING
AS
    SELECT
        tn.cNomeEmpresa       AS cNomeCliente,
        td.cNumeroDeclaracao  AS Declaracao,
        tp.cReferenciaBraslog AS [Referencia Braslog],
        tp.cReferenciaCliente AS [Referencia Cliente],
        (
            SELECT TOP (1) tpr.dVencimentoProrrogacao
            FROM dbo.tDeclaracaoItem tdi2
            JOIN dbo.tProrrogacao tpr
                ON tpr.iDeclaracaoItemId = tdi2.iDeclaracaoItemId
            WHERE tdi2.iDeclaracaoId = td.iDeclaracaoId
        ) AS Prazo
    FROM dbo.tProcesso tp
    JOIN dbo.tDeclaracao td 
        ON td.iDeclaracaoId = tp.iDeclaracaoId
    JOIN dbo.tCnpj tn 
        ON tn.iCnpjId = td.iCnpjId
    WHERE tp.bIsAtivo = 0;
GO