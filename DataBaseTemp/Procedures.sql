/*--------------------------------------------------------------------------------------------
Tipo Objeto		: Stored Procedure
Nome Objeto		: stp_ManipulaErro
Objetivo		: Usa a area CATCH para capturar qualquer erro que acontece em qualqur momento
				  do codigo, dentro d tLOGEventos
Projeto			: ProcessosTemporarios          
Criação			: 01/02/2025
Execução		: CATCH dentro da procedure
Palavra-chave   : Error, treat, catch, warn
----------------------------------------------------------------------------------------------
Observação		:        

----------------------------------------------------------------------------------------------
Histórico		:        
Autor						IDBug Data       Descrição
----------------------		----- ---------- -------------------------------------------------
Marcus V. Paiva Silveira		  01/02/2025 Procedure created */

CREATE OR ALTER PROCEDURE stp_ManipulaErro
	AS
	BEGIN

		SET NOCOUNT ON

		DECLARE @nRetorno INT = 0;
		DECLARE @niIDEvento INT = 0,
				@cMensagem VARCHAR(MAX),
				@nErrorNumber INT,
				@nErrorMessage VARCHAR(200),
				@nErrorSeverity TINYINT,
				@nErrorState TINYINT,
				@nErrorProcedure VARCHAR(128),
				@nErrorLine INT;

		BEGIN TRY

			RETURN @nRetorno;

		END TRY
		BEGIN CATCH
		
			SET @nErrorNumber = ERROR_NUMBER();
			SET @nErrorMessage = ERROR_MESSAGE();
			SET @nErrorSeverity = ERROR_SEVERITY();
			SET @nErrorState = ERROR_STATE();
			SET @nErrorProcedure = ERROR_PROCEDURE();
			SET @nErrorLine = ERROR_LINE();

			SET @cMensagem = FORMATMESSAGE('MessageID %d. %s. Severity %d. Status %d.
				Procedure %s. Line %d.',
				@nErrorNumber, @cMensagem, @nErrorSeverity, @nErrorState, @nErrorProcedure,
				@nErrorLine);

			SET @niIDEvento = NEXT VALUE FOR seqIIDEvento;

			INSERT INTO tLOGEventos (iIDEvento, cMensagem)
			VALUES (@niIDEvento, @cMensagem);

			SET @nRetorno = @niIDEvento;

			RETURN @nRetorno;

		END CATCH;
	END
GO

/*--------------------------------------------------------------------------------------------        
Tipo Objeto		: Stored Procedure
Objeto Nome		: stp_BackupProcessosTemporarios
Objetivo		: Backup no diretório C:\Backup
Projeto			: ProcessosTemporarios
Criação			: 04/02/2025
Execução		: Deve ser executado toda noite
Palavra-chave	: Backup
----------------------------------------------------------------------------------------------        
Observações		:

----------------------------------------------------------------------------------------------        
Histórico		:
Autor					 IDBug	Data		Descrição
----------------------   -----	----------	--------------------------------------------------
Marcus V. Paiva Silveira        04/02/2025  Procedure created */

CREATE OR ALTER PROCEDURE stp_BackupProcessosTemporarios
	AS
	BEGIN
	
		DECLARE @cArquivoBackup VARCHAR(100);

		SET @cArquivoBackup = 'C:\Backup\ProcessosTemporarios_' + FORMAT(GETDATE(), 'DDMM') +
			'.bkp';

		BACKUP DATABASE ProcessosTemporarios
		TO DISK = @cArquivoBackup
		WITH STATS = 1, INIT;

	END
GO

/*--------------------------------------------------------------------------------------------        
Tipo Objeto		: Stored Procedure
Objeto Nome		: stp_CriaTabela
Objetivo		: Criaçao de tabelas dinamicamente, evitando scripts grandes
Projeto			: ProcessosTemporarios
Criação			: 29/10/2025
Execução		: Na confecção do banco
Palavra-chave   : Create
----------------------------------------------------------------------------------------------        
Observação		:        

----------------------------------------------------------------------------------------------        
Histórico		:        
Autor                  IDBug Data		Descrição
---------------------- ----- ---------- ------------------------------------------------------
Marcus V. Paiva Silveira				29/10/2025 - Stored criada
*/
USE ProcessosTemporarios;
GO

CREATE OR ALTER PROCEDURE stp_CriaTabela
	@cSequenceNome VARCHAR(50),
	@cNomeTabela VARCHAR(50),
	@cNomeColunas VARCHAR(MAX),
	@cTipoColunas VARCHAR(MAX)
	AS
	BEGIN

		--Configuração da sessão
		SET NOCOUNT ON;

		--Declaraçao das variáveis
		DECLARE @Sql VARCHAR(MAX) = '';
		DECLARE @ColunasTabela TABLE (ID INT IDENTITY(1,1),NomeColuna VARCHAR(MAX));
		DECLARE @TipoColuna TABLE (ID INT IDENTITY(1,1),TipoColuna VARCHAR(MAX));
		DECLARE @Coluna NVARCHAR(MAX), @Tipo VARCHAR(MAX);
		DECLARE @Contador INT = 0;

		--Area para processamento/calculo
		BEGIN TRANSACTION

		BEGIN TRY

			INSERT INTO @ColunasTabela(NomeColuna)
			SELECT LTRIM(RTRIM(VALUE))
			FROM STRING_SPLIT(@cNomeColunas, '|');

			INSERT INTO @TipoColuna(TipoColuna)
			SELECT LTRIM(RTRIM(VALUE))
			FROM STRING_SPLIT(@cTipoColunas, '|');

			SET @Sql = '
			IF NOT EXISTS (SELECT 1 FROM sys.sequences WHERE name = ''' + @cSequenceNome + ''')
			BEGIN
				CREATE SEQUENCE ' + @cSequenceNome + '
					AS INT
					START WITH 1
					INCREMENT BY 1;
			END';

			EXEC (@Sql);

			SET @Sql = 'IF OBJECT_ID(''' + @cNomeTabela + ''',''U'') IS NULL
			BEGIN
				CREATE TABLE ' + @cNomeTabela + ' (';	

			DECLARE Cur CURSOR FOR
				SELECT c.NomeColuna, t.TipoColuna
				FROM @ColunasTabela c
				JOIN @TipoColuna t ON c.ID = t.ID
				ORDER BY c.ID;

			OPEN cur;
			FETCH NEXT FROM Cur INTO @Coluna, @Tipo;

			WHILE @@FETCH_STATUS = 0
			BEGIN
		
				RAISERROR( 'Adicionando coluna: %s', 0, 1, @Coluna) WITH NOWAIT;
				WAITFOR DELAY '00:00:02';

				SET @Contador += 1;

				IF @Contador = 1
					SET @Sql += @Coluna + '	' + @Tipo + ' DEFAULT(NEXT VALUE FOR ' + 
					@cSequenceNome + '), ';
				ELSE
					SET @Sql += @Coluna + ' ' + @Tipo + ', ';

				FETCH NEXT FROM cur INTO @Coluna, @Tipo;

			END

			CLOSE cur;
			DEALLOCATE cur;

			SET @Sql = LEFT(@Sql, LEN(@Sql)-1) + '); END';
			PRINT 'Sql final:' + @Sql;

			EXEC(@Sql);

			EXEC('SELECT * FROM ' + @cNomeTabela);

			COMMIT TRANSACTION;

		END TRY
		BEGIN CATCH

			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION;

			DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
			RAISERROR('Erro: %s', 16, 1, @ErrorMessage);

		END CATCH;

	END
GO