/*--------------------------------------------------------------------------------------------
Tipo Objeto		: Trigger
Nome Objeto		: tgr_tDeclaracao_insert
Objetivo		: Trigger DML Calcular impostos ao inserir os dados necessários
Projeto			: ProcessosTemporarios          
Criação			: 09/11/2025
Execução		: Ao inserir o valo aduaneiro
Palavra-chave   : trigger, insert
----------------------------------------------------------------------------------------------
Observação		: AFTER -> Será executada após a inserção dos dados na mesma tabela
				  
				  
----------------------------------------------------------------------------------------------
Histórico		:        
Autor						IDBug Data       Descrição
----------------------		----- ---------- -------------------------------------------------
Marcus V. Paiva Silveira		  09/11/2025 Trigger criada */

CREATE OR ALTER TRIGGER TRG_VALORES_CALCULO_ADUANEIRO
ON tValoresCalculoAduaneiro
AFTER INSERT
AS BEGIN

	SET NOCOUNT ON

	BEGIN TRY

		DECLARE @iNumeroAdicoes INT,
				@iContador INT = 1,
				@mTaxaSiscomex DECIMAL(18,2) = 115.67,
				@iValoresCalculoAduaneiroId INT;

		SELECT
			@iValoresCalculoAduaneiroId = iValoresCalculoAduaneiroId,
			@iNumeroAdicoes = mAdicoes
		FROM inserted;

		WHILE @iContador <= @iNumeroAdicoes
			BEGIN

				IF @iContador <= 2
					SET @mTaxaSiscomex += 38.56;
				ELSE IF @iContador BETWEEN 3 AND 5
					SET @mTaxaSiscomex += 30.85;
				ELSE IF @iContador BETWEEN 6 AND 10
					SET @mTaxaSiscomex += 23.14;
				ELSE IF @iContador BETWEEN 11 AND 20
					SET @mTaxaSiscomex += 11.80;
				ELSE IF @iContador BETWEEN 21 AND 50
					SET @mTaxaSiscomex += 5.90;
				ELSE
					SET @mTaxaSiscomex += 2.95;

				SET @iContador += 1;
			END

		UPDATE tValoresCalculoAduaneiro
		SET mTaxaSiscomex = @mTaxaSiscomex
		WHERE iValoresCalculoAduaneiroId = @iValoresCalculoAduaneiroId;

	END TRY
		BEGIN CATCH

			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION;

			EXECUTE stp_ManipulaErro;

		END CATCH;
END
GO