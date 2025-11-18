/*--------------------------------------------------------------------------------------------
Tipo Objeto		: Trigger
Nome Objeto		: TRG_VALORES_TAXA_SISCOMEX
Objetivo		: Trigger DML Calcular setar taxa siscomex na coluna mTaxaSiscomex ao inserir
				  os dados necessários
Projeto			: ProcessosTemporarios          
Criação			: 09/11/2025
Execução		: Ao inserir o numero de adiçoes
Palavra-chave   : trigger, insert
----------------------------------------------------------------------------------------------
Observação		: AFTER -> Será executada após a inserção dos dados na mesma tabela
				  
				  
----------------------------------------------------------------------------------------------
Histórico		:        
Autor						IDBug Data       Descrição
----------------------		----- ---------- -------------------------------------------------
Marcus V. Paiva Silveira		  09/11/2025 Trigger criada */

CREATE OR ALTER TRIGGER TRG_VALORES_TAXA_SISCOMEX
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

/*--------------------------------------------------------------------------------------------
Tipo Objeto		: Trigger
Nome Objeto		: TRG_VALORES_DECLARACAO_ITEM
Objetivo		: Trigger DML para preenchimento automático através do cálculo com valores
				  prévios
Projeto			: ProcessosTemporarios          
Criação			: 13/11/2025
Execução		: Ao inserir os campos que nao precisam de calculo (DI, NCM, Taxa Selic, Numero
				  Prorrogação, ValorFOB, Peso Líquido, Taxa de Cambio);
Palavra-chave   : trigger, insert
----------------------------------------------------------------------------------------------
Observação		: AFTER -> Será executada após a inserção dos dados na mesma tabela
				  
				  
----------------------------------------------------------------------------------------------
Histórico		:        
Autor						IDBug Data       Descrição
----------------------		----- ---------- -------------------------------------------------
Marcus V. Paiva Silveira		  09/11/2025 Trigger criada */

CREATE OR ALTER TRIGGER TRG_VALORES_DECLARACAO_ITEM
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

		SELECT * FROM tValoresCalculoAduaneiro;
		SELECT * FROM tDeclaracaoItem;
		SELECT * FROM tDeclaracao;
		SELECT * FROM tLogistica;

		SELECT * FROM tDeclaracao td JOIN tValoresCalculoAduaneiro tv WHERE td.

	END TRY
	BEGIN CATCH

	END CATCH

END
GO

BEGIN TRANSACTION
SELECT @@TRANCOUNT
COMMIT