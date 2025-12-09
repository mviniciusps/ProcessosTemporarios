/*--------------------------------------------------------------------------------------------
Tipo Objeto		: Trigger
Nome Objeto		: TRG_CARACTERES_ESPECIAIS
Objetivo		: Trigger DML para evitar a inserção de caracteres especiais em campos específicos
                  da tabela tDeclaracaoItem.
Projeto			: ProcessosTemporarios          
Criação			: 08/12/2025
Execução		: Ao inserir ou alterar registros em todas as tabelas 
Palavra-chave   : trigger, insert, update
----------------------------------------------------------------------------------------------
Observação		: AFTER INSERT -> Será executada após a inserção dos dados na mesma tabela
                  AFTER UPDATE -> Será executada após a atualização dos dados na mesma tabela
----------------------------------------------------------------------------------------------
Histórico		:        
Autor						IDBug Data       Descrição
----------------------		----- ---------- -------------------------------------------------
Marcus V. Paiva Silveira		  08/12/2025 Trigger criada */

CREATE OR ALTER TRIGGER TRG_CARACTERES_ESPECIAIS
ON tDeclaracaoItem
AFTER INSERT
AS BEGIN

    SET NOCOUNT ON

    BEGIN TRY

        DECLARE @dDataSelic DATE;
        DECLARE @mTaxaSelicAcumulada DECIMAL(18,2);
        DECLARE @iDeclaracaoId INT;
        DECLARE @mSeguro DECIMAL(18,2);
        DECLARE @mFrete DECIMAL(18,2);
        DECLARE @mValorFob DECIMAL(18,2);

        SELECT
            @iDeclaracaoId = iDeclaracaoId
        FROM inserted;

        -- ...existing code for later implementation...

    END TRY
    BEGIN CATCH

        -- ...existing code for error handling...

    END CATCH

END
GO

BEGIN TRANSACTION
SELECT @@TRANCOUNT
COMMIT