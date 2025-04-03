BEGIN TRANSACTION
USE ProcessosTemporarios;
GO

/*--------------------------------------------------------------------------------------------        
Objeto tipo: Stored Procedure
objeto     : stp_inserirDadosTabelaApoliceGarantia
Objetivo   : Inserir dataset nas colunas da tabela
Projeto    : ProcessosTemporarios
Criado em  : 13/02/2025
Execução   : Insert dataset
Palavras-chave: INSERT INTO
----------------------------------------------------------------------------------------------        
Observações :        

----------------------------------------------------------------------------------------------        
Historico:        
Autor                  IDBug Data			Descrição
---------------------- ----- ---------- ------------------------------------------------------------        
Marcus V. Paiva Silveira					13/02/2025 Criaçao da Procedure*/

--tipo tabela
IF NOT EXISTS (SELECT * FROM sys.types WHERE name = 'dtInserirDadosApoliceGarantia')
BEGIN
	CREATE TYPE dtInserirDadosApoliceGarantia
	AS TABLE
	(
		cNumeroApolice VARCHAR(100),
		dVencimentoGarantia DATE,
		iRecintoID INT
	)
END
GO
------------------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE stp_inserirDadosTabelaApoliceGarantia
@tInserirDados dtInserirDadosApoliceGarantia READONLY
AS BEGIN

	SET NOCOUNT ON;

	BEGIN TRY
		
		BEGIN TRANSACTION

		RAISERROR('Inserindo dados na tabela tApoliceSeguroGarantia...',10,1) WITH NOWAIT
		WAITFOR DELAY '00:00:05'

		INSERT INTO tApoliceSeguroGarantia (cNumeroApolice, dVencimentoGarantia, iRecintoID)
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

	SELECT * FROM tApoliceSeguroGarantia

END
GO
------------------------------------------------------------------------------------------------------------------------------

--Variavel do tipo tabela
DECLARE @t_tempInserirDados dtInserirDadosApoliceGarantia

SET NOCOUNT ON;
INSERT INTO @t_tempInserirDados VALUES
	('02-0775-0995466', '2027-06-17', 5),
	('02-0775-0929867', '2026-06-17', 3),
	('02-0775-0929900', '2026-03-24', 10),
	('02-0775-0990491', '2028-04-28', 9),
	('02-0775-0971950', '2027-10-28', 17),
	('02-0775-0925644', '2028-06-23', 10),
	('0775.22.1.817-7', '2025-04-20', 10),
	('02-0775-0931811', '2026-07-23', 10),
	('02-0775-0929956', '2026-07-23', 7),
	('0775.22.1.816-9', '2025-04-23', 10),
	('02-0775-0917395', '2027-06-02', 6),
	('02-0775-0917390', '2027-06-02', 6),
	('02-0775-0919034', '2027-06-02', 6),
	('02-0775-0920542', '2027-06-02', 6),
	('02-0775-0916249', '2027-07-20', 4),
	('02-0775-0948641', '2027-09-25', 3),
	('0306920239907750984452000', '2025-08-25', 7),
	('0306920239907751014466000', '2025-09-20', 12),
	('0306920239907751029642000', '2025-10-27', 10)

EXEC stp_inserirDadosTabelaApoliceGarantia @tInserirDados = @t_tempInserirDados;
GO
--Fim da Procedure

/*--------------------------------------------------------------------------------------------        
Tipo Objeto: View
Objeto     : vApoliceSeguroGarantia
Objetivo   : Mostrar todas as Apolices associadas ao Recinto Alfandegado, ou seja, o segurado é a RFB do local
Criado em  : 02/04/2025
Palavras-chave: Apolice
----------------------------------------------------------------------------------------------        
Observações : FORMAT (para datas não aceita em VIEW)

----------------------------------------------------------------------------------------------        
Histórico:        
Autor                  IDBug Data       Descrição        
---------------------- ----- ---------- ------------------------------------------------------------        
Marcus Paiva				 02/04/2025 Criação da Views
Marcus Paiva				 02/04/2025 Trocad a seguinte sintaxe FORMAT(ta.dVencimentoGarantia, 'dd/MM/yyyy'),
							 pois VIEWS não aceitam FORMAT
*/
	CREATE OR ALTER VIEW vApoliceSeguroGarantia
	AS
	SELECT ta.cNumeroApolice AS [Número Apólice], ta.dVencimentoGarantia AS [Vencimento Apolice],
	CONCAT(tr.cNomeRecinto,' - ',tr.cCidadeRecinto,'/',
		CASE
			WHEN cEstadoRecinto = 'Bahia' THEN'BA'
			WHEN cEstadoRecinto = 'Ceará' THEN'CE'
			WHEN cEstadoRecinto = 'Maranhão' THEN'MA'
			WHEN cEstadoRecinto = 'Pernambuco' THEN'PE'
			WHEN cEstadoRecinto = 'Rio de Janeiro' THEN'RJ'
			WHEN cEstadoRecinto = 'São Paulo' THEN'SP'
			WHEN cEstadoRecinto = 'Paraná' THEN 'PR'
		END
	) AS [Recinto Alfandegado]
	FROM tApoliceSeguroGarantia ta
	INNER JOIN tRecintoAlfandegado tr
	ON ta.iRecintoID = tr.iRecintoID
	GO
--Fim da View vApoliceSeguroGarantia

SELECT * FROM vApoliceSeguroGarantia
WHERE YEAR([Vencimento Apolice]) = 2025
ORDER BY [Vencimento Apolice]