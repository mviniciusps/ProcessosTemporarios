BEGIN TRANSACTION

USE ProcessosTemporarios;
GO

SELECT * FROM tCeMercante;
GO

/*--------------------------------------------------------------------------------------------        
Objeto tipo: Stored Procedure
Objeto     : stp_inserirDadosTabelaCEMercante
Objetivo   : Inserir dataset na tabela tCeMercante
projeto    : ProcessosTemporarios
criação    : 13/02/2025
Keywords   : INSERT INTO
----------------------------------------------------------------------------------------------        
Observação :        

----------------------------------------------------------------------------------------------        
Histórico:        
Autor						IDBug Data			Descrição
----------------------		----- ----------	------------------------------------------------------------        
Marcus V. Paiva Silveira      13/02/2025		Procedure criada */

--table type
IF NOT EXISTS (SELECT * FROM sys.types WHERE name = 'dtInserirDadosCeMercante')
BEGIN
	CREATE TYPE dtInserirDadosCeMercante
	AS TABLE
	(
		cStatusCE VARCHAR(15),
		cNumeroCE CHAR(15)
	)
END
GO
------------------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE stp_inserirDadosTabelaCeMercante
@tInserirDados dtInserirDadosCeMercante READONLY
AS BEGIN

	SET NOCOUNT ON;

	BEGIN TRY
		
		BEGIN TRANSACTION

		RAISERROR('Inserindo dados na tabela tCeMercante...',10,1) WITH NOWAIT
		WAITFOR DELAY '00:00:05'

		INSERT INTO tCeMercante (cStatusCE, cNumeroCE)
		SELECT * FROM @tInserirDados

		IF @@ROWCOUNT = 0
			RAISERROR('Os dados não foram inseridos corretamente',10,1);

		COMMIT;

	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0
			ROLLBACK

		EXEC stp_ManipulaErro

	END CATCH

	SELECT * FROM tCeMercante

END
GO
------------------------------------------------------------------------------------------------------------------------------

--variable type table
DECLARE @t_tempInserirDados dtInserirDadosCeMercante

SET NOCOUNT ON;
INSERT INTO @t_tempInserirDados VALUES
	('SUSPENSA', '072205154296309'),
	('SUSPENSA', '072405061514983'),
	('SUSPENSA', '072205156943263'),
	('SUSPENSA', '102205138266757'),
	('PAGA', '072105117508099'),
	('PAGA', '152005271192929'),
	('PAGA', '132105065072039'),
	('SUSPENSA', '132305053620239'),
	('SUSPENSA', '132305077973964'),
	('SUSPENSA', '162205256553652'),
	('SUSPENSA', '132205315120298'),
	('SUSPENSA', '132105211325331'),
	('SUSPENSA', '131705281227807'),
	('SUSPENSA', '131905052962183'),
	('PAGA', '131905052962345'),
	('SUSPENSA', '132105211325412'),
	('SUSPENSA', '072405055138258'),
	('SUSPENSA', '102205119780521'),
	('SUSPENSA', '102205119780440'),
	('SUSPENSA', '102205119780602'),
	('SUSPENSA', '102205119780793'),
	('SUSPENSA', '102205119780874'),
	('SUSPENSA', '132105237986793'),
	('SUSPENSA', '072205154324450'),
	('SUSPENSA', '072205188517243'),
	('SUSPENSA', '132305195841804'),
	('SUSPENSA', '152405318106469'),
	('SUSPENSA', '132305267830013'),
	('SUSPENSA', '152105242416074'),
	('SUSPENSA', '151805001998909'),
	('SUSPENSA', '132405221117348'),
	('SUSPENSA', '152205303647231'),
	('SUSPENSA', '152205303646693'),
	('PAGA', '151905198851634'),
	('SUSPENSA', '152305262872308'),
	('SUSPENSA', '152305251570810'),
	('SUSPENSA', '152405220231060')
	
EXEC stp_inserirDadosTabelaCeMercante @tInserirDados = @t_tempInserirDados;
GO
--FIM da Procedure stp_inserirDadosTabelaCeMercante

/*--------------------------------------------------------------------------------------------        
Tipo Objeto: View
Objeto     : vCeMercante
Objetivo   : Mostrar todas os CE's associados ao numero do Processo, e DI
Criado em  : 04/04/2025
Palavras-chave: Contrato
----------------------------------------------------------------------------------------------        
Observações : ISNULL(CAST(tc.iNumeroProrrogacao AS VARCHAR),'') - para nao mostrar valores nulos, caso contrario mostra 0 ou 1900

----------------------------------------------------------------------------------------------        
Histórico:        
Autor                  IDBug Data       Descrição        
---------------------- ----- ---------- ------------------------------------------------------------        
Marcus Paiva				 05/04/2025 Criação da View
*/
CREATE OR ALTER VIEW dbo.vCeMercante
WITH ENCRYPTION, SCHEMABINDING
AS
SELECT td.cReferenciaBraslog AS [Referencia Braslog],
LEFT(td.cNumeroDeclaracao,2) + '/' +
SUBSTRING(td.cNumeroDeclaracao,3,7) + '-' +
RIGHT(td.cNumeroDeclaracao,1) AS [Declaração de Importação],
LEFT(tc.cNumeroCE,3) + '.' +
SUBSTRING(tc.cNumeroCE,4,3) + '.' +
SUBSTRING(tc.cNumeroCE,7,3) + '.' +
SUBSTRING(tc.cNumeroCE,10,3) + '.' +
RIGHT(tc.cNumeroCE,3)
AS [Número do CE Mercante],
tc.cStatusCE AS 'Status'
FROM dbo.tCeMercante tc
INNER JOIN dbo.tDeclaracao td
ON tc.iCEID = td.iCEID
WITH CHECK OPTION
GO
--FIM da VIEW vCeMercante

SELECT * FROM vCeMercante
GO