BEGIN TRANSACTION

USE ProcessosTemporarios;
GO

SELECT * FROM tCNPJ;
GO

/*--------------------------------------------------------------------------------------------        
Objeto tipo: Stored Procedure
Objeto     : stp_inserirDadosTabelaCNPJ
Objetivo   : Inserir um dataset na tCNPJs
Projeto    : ProcessosTemporarios
Cria��o    : 15/02/2025
Keywords   : INSERT INTO
----------------------------------------------------------------------------------------------        
Obeserva�ao:        

----------------------------------------------------------------------------------------------        
Hist�rico:        
Autor                  IDBug Data		Descri��o
---------------------- ----- ---------- ------------------------------------------------------------        
Marcus V. Paiva Silveira                15/02/2025 Procedure criada */

IF NOT EXISTS (SELECT * FROM sys.types WHERE NAME = 'dtInsertDataCNPJTable')
BEGIN
	CREATE TYPE dtInsertDataCNPJTable
	AS TABLE
	(
		cNumeroInscricao CHAR(14),
		cNomeEmpresarial VARCHAR(100),
		cLogradouro VARCHAR(100),
		cNumeroLogradouro VARCHAR(10),
		cBairroLogradouro VARCHAR(50),
		cCidadelogradouro VARCHAR(50),
		cEstadoLogradouro VARCHAR(50)
	)
END
GO

CREATE OR ALTER PROCEDURE stp_inserirDadosTabelaApoliceGarantia
@tInserirDados dtInsertDataCNPJTable READONLY
AS BEGIN

	SET NOCOUNT ON;

	BEGIN TRY

		BEGIN TRANSACTION;

		RAISERROR('Inserindo os dados na tabela tCNPJ...',10,1) WITH NOWAIT;
		WAITFOR DELAY '00:00:05';

		INSERT INTO tCNPJ
		(
			cNumeroInscricao,
			cNomeEmpresarial,
			cLogradouro,
			cNumeroLogradouro,
			cBairroLogradouro,
			cCidadelogradouro,
			cEstadoLogradouro
		)
		SELECT * FROM @tInserirDados;

		IF @@ROWCOUNT = 0
			RAISERROR('Dados nao foram inseridos com sucesso!',10,1);

		COMMIT;

	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0
			ROLLBACK

		EXECUTE stp_ManipulaErro;

	END CATCH

	SELECT * FROM tCNPJ

END
GO

DECLARE @t_tempInserirDados dtInsertDataCNPJTable;

SET NOCOUNT ON;
INSERT INTO @t_tempInserirDados VALUES
	('02295964000130', 'Megasil Comercio De Produtos Agricolas E Servicos De Colheitas Ltda', 'Rua Dom Jose Carlos Aguirre', '1365', 'Vila Ozorio', 'Itarare', 'S�o Paulo'),
	('02385674000187', 'Dta Engenharia Ltda', 'Rua Jeronimo Da Veiga', '45', 'Jardim Europa', 'S�o Paulo', 'S�o Paulo'),
	('05061157000140', 'Bowline Marine & Cargo Consultants Ltda', 'Rua Xv De Novembro', '65', 'Centro', 'Santos', 'S�o Paulo'),
	('10567976000102', 'Nea - Comercial De Produtos Industriais Ltda', 'Rua Lino Peixoto Amorim', '1000', 'Paineiras', 'Itupeva', 'S�o Paulo'),
	('11426377000123', 'Mammoet Brasil Guindastes Ltda.', 'Rua Carlos Lisdegno Carlucci', '519', 'Jardim Peir Peri', 'S�o Paulo', 'S�o Paulo'),
	('11426377000638', 'Mammoet Brasil Guindastes Ltda.', 'Av Presidente Wilson', '231', 'Centro', 'Rio De Janeiro', 'Rio De Janeiro'),
	('15563826000489', 'Tse S/A', 'Estrada De Acesso A Br 135', 'Null', 'Zona Industrial', 'Santo Antonio Dos Lopes', 'Maranh�o'),
	('23955189000171', 'Mitsubishi Power South America Limitada', 'Alameda Santo', '415', 'Cerqueira Cesar', 'S�o Paulo', 'S�o Paulo'),
	('29884534000290', 'Marlim Azul Energia S.A.', 'Rua Dos Gar�ons', 'Null', 'Horto', 'Maca�', 'Rio De Janeiro'),
	('43053081001334', 'Transdata Engenharia E Movimentacao Ltda', 'Avenida Rio Branco', '37', 'Centro', 'Rio De Janeiro', 'Rio De Janeiro'),
	('47098918000693', 'Veolia Water Technologies And Solutions Brasil Tratamento De Aguas Ltda', 'Rua Osasco', '28', 'Parque Industrial Anhanguera', 'Cajamar', 'S�o Paulo'),
	('51254159000173', 'Karina Plasticos Ltda', 'Avenida Antranig Guerekmezian', '788', 'Jardim Cumbica', 'Guarulhos', 'S�o Paulo')

EXECUTE stp_inserirDadosTabelaApoliceGarantia @tInserirDados = @t_tempInserirDados;
--FIM da Procedure

/*--------------------------------------------------------------------------------------------        
Tipo Objeto: View
Objeto     : vCNPJ
Objetivo   : Mostrar todos os CNPJ's
Criado em  : 05/04/2025
Palavras-chave: CNPJ
----------------------------------------------------------------------------------------------        
Observa��es : VARCHAR NULL nao reconhecido, precisou remover os espa�os

----------------------------------------------------------------------------------------------        
Hist�rico:        
Autor                  IDBug Data			Descri��o        
---------------------- ----- ----------		--------------------------------------------------
Marcus Paiva				 05/04/2025		Cria��o da View*/
CREATE OR ALTER VIEW vCNPJ
WITH ENCRYPTION, SCHEMABINDING
AS
SELECT
    tc.cNomeEmpresarial AS [Raz�o Social],
    LEFT(tc.cNumeroInscricao, 2) + '.' +
    SUBSTRING(tc.cNumeroInscricao, 3, 3) + '.' +
    SUBSTRING(tc.cNumeroInscricao, 6, 3) + '/' +
    SUBSTRING(tc.cNumeroInscricao, 9, 4) + '-' +
    RIGHT(tc.cNumeroInscricao, 2) AS CNPJ,
    tc.cLogradouro + ' - ' +
    CASE 
        WHEN tc.cNumeroLogradouro IS NULL 
             OR LTRIM(RTRIM(tc.cNumeroLogradouro)) = '' 
             OR LOWER(LTRIM(RTRIM(tc.cNumeroLogradouro))) = 'null' 
        THEN 'S/N'
        ELSE 'n� ' + tc.cNumeroLogradouro
    END + ' - ' +
    tc.cBairroLogradouro + ' - ' +
    tc.cCidadeLogradouro + '/' +
    CASE
        WHEN tc.cEstadoLogradouro = 'S�o Paulo' THEN 'SP'
        WHEN tc.cEstadoLogradouro = 'Rio de Janeiro' THEN 'RJ'
        WHEN tc.cEstadoLogradouro = 'Maranh�o' THEN 'MA'
        WHEN tc.cEstadoLogradouro = 'Pernambuco' THEN 'PE'
        WHEN tc.cEstadoLogradouro = 'Paran�' THEN 'PR'
        WHEN tc.cEstadoLogradouro = 'Amazonas' THEN 'AM'
    END AS Endere�o
FROM dbo.tCNPJ tc
WITH CHECK OPTION;
GO
--FIM da VIEW tCNPJ

SELECT * FROM vCNPJ;
GO

BEGIN TRANSACTION;
UPDATE tCNPJ
SET cNomeEmpresarial = 'NEA - Comercial De Produtos Industriais Ltda'
WHERE cNomeEmpresarial = 'Nea - Comercial De Produtos Industriais Ltda'
COMMIT

BEGIN TRANSACTION;
UPDATE tCNPJ
SET cNomeEmpresarial = 'DTA Engenharia Ltda'
WHERE cNomeEmpresarial = 'Dta Engenharia Ltda'
COMMIT
ROLLBACK

BEGIN TRANSACTION;
UPDATE tCNPJ
SET cNomeEmpresarial = 'TSE S/A'
WHERE cNomeEmpresarial = 'Tse S/A'
COMMIT
ROLLBACK

BEGIN TRANSACTION
UPDATE tCNPJ
SET cNomeEmpresarial = REPLACE(cNomeEmpresarial, ' DE ', ' de ')
COMMIT
ROLLBACK

BEGIN TRANSACTION
UPDATE tCNPJ
SET cNomeEmpresarial = REPLACE(cNomeEmpresarial, ' And ', ' and ')
COMMIT
ROLLBACK

BEGIN TRANSACTION
UPDATE tCNPJ
SET cNomeEmpresarial = REPLACE(cNomeEmpresarial, ' E ', ' e ')
COMMIT
ROLLBACK

BEGIN TRANSACTION
UPDATE tCNPJ
SET cNomeEmpresarial = REPLACE(cNomeEmpresarial, 'Limitada', 'Ltda')
COMMIT
ROLLBACK

SELECT @@TRANCOUNT;