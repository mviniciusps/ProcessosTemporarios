/*--------------------------------------------------------------------------------------------
Tipo Objeto		: Stored Procedure
Nome Objeto		: stp_ManipulaErro
Objetivo		: Usa a area CATCH para capturar qualquer erro que acontece em qualqur momento
				  do codigo, dentro d tLOGEventos
Projeto			: ProcessosTemporarios          
Criação			: 09/11/2025
Execução		: CATCH dentro da procedure
Palavra-chave   : Error, treat, catch, warn
----------------------------------------------------------------------------------------------
Observação		:        

----------------------------------------------------------------------------------------------
Histórico		:        
Autor						IDBug Data       Descrição
----------------------		----- ---------- -------------------------------------------------
Marcus V. Paiva Silveira		  09/11/2025 Procedure criada */

CREATE OR ALTER PROCEDURE stp_ManipulaErro
	AS
	BEGIN

		SET NOCOUNT ON

		DECLARE @iEventoId INT = 0,
				@cMensagem VARCHAR(512),
				@ErrorNumber INT = ERROR_NUMBER(),
				@ErrorMessage VARCHAR(200) = ERROR_MESSAGE(),
				@ErrorSeverity TINYINT = ERROR_SEVERITY(),
				@ErrorState TINYINT = ERROR_STATE(),
				@ErrorProcedure VARCHAR(128) = ERROR_PROCEDURE(),
				@ErrorLine INT = ERROR_LINE();
		
		--Seta a mensagem de erro
		SET @cMensagem = FORMATMESSAGE('MsgId %d. %s. Severidade %d. Status %d. Procedure %s. Linha %d.', @ErrorNumber, @ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine);

		SET @iEventoId = NEXT VALUE FOR seqiEventoId

		--Realiza a gravação em uma tabela
		INSERT INTO tLogEventos(iEventoId, cMensagemEvento) VALUES (@iEventoId, @cMensagem);

		SELECT 
			@iEventoId AS CodigoEvento,
			@cMensagem AS Mensagem,
			@ErrorNumber AS NumeroErro,
			@ErrorSeverity AS Severidade,
			@ErrorProcedure AS ProcedureOrigem,
			@ErrorLine AS LinhaErro;

		RETURN @iEventoId;
		
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
		DECLARE	@ColunasTabela TABLE (ID INT IDENTITY(1,1),NomeColuna VARCHAR(MAX));
		DECLARE @TipoColuna TABLE (ID INT IDENTITY(1,1),TipoColuna VARCHAR(MAX));
		DECLARE @Coluna NVARCHAR(MAX), @Tipo VARCHAR(MAX),
				@Contador INT = 0;
		

		--Area para processamento/calculo
		BEGIN TRANSACTION

		BEGIN TRY
			
			--Insere os valores em tabelas temporarias distintas, separando pelo carcatere |
			INSERT INTO @ColunasTabela(NomeColuna)
			SELECT LTRIM(RTRIM(VALUE))
			FROM STRING_SPLIT(@cNomeColunas, '|');

			INSERT INTO @TipoColuna(TipoColuna)
			SELECT LTRIM(RTRIM(VALUE))
			FROM STRING_SPLIT(@cTipoColunas, '|');

			--Inicia o SQL setando o sequence
			SET @Sql = '
			IF NOT EXISTS (SELECT 1 FROM sys.sequences WHERE name = ''' + @cSequenceNome + ''')
			BEGIN
				CREATE SEQUENCE ' + @cSequenceNome + '
					AS INT
					START WITH 1
					INCREMENT BY 1;
			END';

			EXEC (@Sql);

			--Seta (apaga anterior e reescreve query) SQL criando a tabela com o nome atribuído a variavel
			SET @Sql = 'IF OBJECT_ID(''' + @cNomeTabela + ''',''U'') IS NULL
			BEGIN
				CREATE TABLE ' + @cNomeTabela + ' (';	
			
			--Cursor para iterar sobre as linhas das tabelas emporárias
			DECLARE Cur CURSOR FOR
				SELECT c.NomeColuna, t.TipoColuna
				FROM @ColunasTabela c
				JOIN @TipoColuna t ON c.ID = t.ID
				ORDER BY c.ID;
			
			--Abre o cursor, passando para a proxima linha
			OPEN cur;
			FETCH NEXT FROM Cur INTO @Coluna, @Tipo;

			--Status do cursor, enquanto for 0 achou dado
			WHILE @@FETCH_STATUS = 0
			BEGIN
		
				RAISERROR( 'Adicionando coluna: %s', 0, 1, @Coluna) WITH NOWAIT;
				WAITFOR DELAY '00:00:02';

				--Conta quantas colunas foram adicionadas
				SET @Contador += 1;

				--Se o contador for 1, entao seta o sequence para a primeira coluna
				IF @Contador = 1
					SET @Sql += @Coluna + '	' + @Tipo + ' DEFAULT(NEXT VALUE FOR ' + 
					@cSequenceNome + '), ';
				ELSE
					SET @Sql += @Coluna + ' ' + @Tipo + ', ';

				--Cursor para a proxima linha
				FETCH NEXT FROM cur INTO @Coluna, @Tipo;

			END

			--Fecha o cursor
			CLOSE cur;
			DEALLOCATE cur;

			--Ajusta o SQL gerado dentro do WHILE
			SET @Sql = LEFT(@Sql, LEN(@Sql)-1) + '); END';
			PRINT 'Sql final:' + @Sql;

			EXEC(@Sql);

			EXEC('SELECT * FROM ' + @cNomeTabela);

			COMMIT TRANSACTION;

		END TRY
		BEGIN CATCH

			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION;

			EXECUTE stp_ManipulaErro;

		END CATCH;

	END
GO