BEGIN TRANSACTION
/*--------------------------------------------------------------------------------------------        
Objetc type: Store Procedure
object name: stp_ManipulaErro
Objetive   : It uses in CATCH area to catch any errors that it can happen anytime
             and store in tLOGEventos table
Project    : ProcessosTemporarios          
Creation   : 01/02/2025
Execution  : It should be execute on catch area
Keywords   : Error, treat, catch, warn
----------------------------------------------------------------------------------------------        
Observation :        

----------------------------------------------------------------------------------------------        
History:        
Author                  IDBug Date      Description        
---------------------- ----- ---------- ------------------------------------------------------------        
Marcus V. Paiva Silveira               01/02/2025 Procedure created */

CREATE OR ALTER PROCEDURE stp_ManipulaErro
AS
BEGIN
	--session configuration area
	SET NOCOUNT ON

	--declare variables
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

		SET @cMensagem = FORMATMESSAGE('MessageID %d. %s. Severity %d. Status %d. Procedure %s. Line %d.', @nErrorNumber, @cMensagem, @nErrorSeverity, @nErrorState, @nErrorProcedure, @nErrorLine);

		SET @niIDEvento = NEXT VALUE FOR seqIIDEvento;

		INSERT INTO tLOGEventos (iIDEvento, cMensagem)
		VALUES (@niIDEvento, @cMensagem);

		SET @nRetorno = @niIDEvento;

		RETURN @nRetorno;

	END CATCH;
END
GO

/*--------------------------------------------------------------------------------------------        
Object type: Store Procedure
Object     : stp_BackupProcessosTemporarios
Objective  : Backup on folder C:\Backup
Project    : ProcessosTemporarios
Creation   : 04/02/2025
Execution  : procedure must be execute everyday at night
Keywords   : Backup
----------------------------------------------------------------------------------------------        
Observations :        

----------------------------------------------------------------------------------------------        
History:        
Author                  IDBug Date      Description        
---------------------- ----- ---------- ------------------------------------------------------------        
Marcus V. Paiva Silveira               04/02/2025 Procedure created */

CREATE OR ALTER PROCEDURE stp_BackupProcessosTemporarios
AS
BEGIN
	
	DECLARE @cArquivoBackup VARCHAR(100);

	SET @cArquivoBackup = 'C:\Backup\ProcessosTemporarios_' + FORMAT(GETDATE(), 'DDMM') + '.bkp';

	BACKUP DATABASE ProcessosTemporarios
	TO DISK = @cArquivoBackup
	WITH STATS = 1, INIT;

END
GO

EXECUTE stp_BackupProcessosTemporarios;