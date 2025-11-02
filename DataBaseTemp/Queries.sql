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
Observações : FORMAT (para datas não aceita em VIEW), WITH ENCRYPTION, SCHEMABINDING (não visualiza o codigo fonte,
e impede de alterar a estrutura da tabela como colunas, CHEK OPTION (impede que faça alguma alteraçao SQL injection)

----------------------------------------------------------------------------------------------        
Histórico:        
Autor                  IDBug Data       Descrição        
---------------------- ----- ---------- ------------------------------------------------------------        
Marcus Paiva				 02/04/2025 Criação da Views
Marcus Paiva				 02/04/2025 Trocad a seguinte sintaxe FORMAT(ta.dVencimentoGarantia, 'dd/MM/yyyy'),
							 pois VIEWS não aceitam FORMAT
*/
	CREATE OR ALTER VIEW dbo.vApoliceSeguroGarantia
	WITH ENCRYPTION, SCHEMABINDING
	AS
	SELECT td.cReferenciaBraslog AS [Referência Braslog], ta.cNumeroApolice AS [Número Apólice], ta.dVencimentoGarantia AS [Vencimento Apólice],
	CONCAT(tr.cNomeRecinto,' - ',tr.iCidadeID,'/',tc.cNomeCidade) AS [Recinto Alfandegado]
	FROM dbo.tApoliceSeguroGarantia ta
	INNER JOIN dbo.tRecintoAlfandegado tr
	ON ta.iRecintoID = tr.iRecintoID
	INNER JOIN dbo.tDeclaracao td
	ON ta.iApoliceID = td.iApoliceID
	INNER JOIN dbo.tCidade tc
	ON tc.iCidadeID = tr.iCidadeID
	INNER JOIN dbo.tEstado te
	ON te.iEstadoID = tc.iEstadoID
	WITH CHECK OPTION
	GO
--Fim da View vApoliceSeguroGarantia

SELECT * FROM vApoliceSeguroGarantia
WHERE YEAR([Vencimento Apolice]) = 2025
ORDER BY [Vencimento Apolice]

USE ProcessosTemporarios;
GO

BEGIN TRANSACTION;
GO

ALTER TABLE tApoliceSeguroGarantia
ADD dValorSegurado DECIMAL(18,2);
GO

SELECT * FROM tApoliceSeguroGarantia;
GO

SELECT @@TRANCOUNT;

COMMIT;
ROLLBACK;

BEGIN TRANSACTION;

USE ProcessosTemporarios;
GO

SELECT tc.cNomeCidade, te.cEstadoSigla FROM tCidade tc
JOIN tEstado te
ON tc.iEstadoID = te.iEstadoID;

SELECT * FROM tEstado;
SELECT * FROM tCidade;

INSERT INTO tCidade (cNomeCidade, iEstadoID)
VALUES
		('Itararé', 25),
		('São Paulo', 25),
		('Santos', 25),
		('Itupeva', 25),
		('Rio de Janeiro', 19),
		('Santo Antonio dos Lopes', 10),
		('Macaé', 19),
		('Cajamar', 25),
		('Guarulhos', 25),
		('Manaus', 4),
		('Fortaleza', 6),
		('São Luis', 10),
		('Suape', 17),
		('Salvador', 5),
		('Campos dos Goytacazes', 19),
		('Sorocaba', 25),
		('Paranaguá', 16);

BEGIN TRANSACTION
DELETE FROM tCidade;
GO

ALTER SEQUENCE seqCidadeID
RESTART WITH 1;
GO

SELECT @@TRANCOUNT;

COMMIT;


------------------------------
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
Criação    : 15/02/2025
Keywords   : INSERT INTO
----------------------------------------------------------------------------------------------        
Obeservaçao:        

----------------------------------------------------------------------------------------------        
Histórico:        
Autor                  IDBug Data		Descrição
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
	('02295964000130', 'Megasil Comercio De Produtos Agricolas E Servicos De Colheitas Ltda', 'Rua Dom Jose Carlos Aguirre', '1365', 'Vila Ozorio', 'Itarare', 'São Paulo'),
	('02385674000187', 'Dta Engenharia Ltda', 'Rua Jeronimo Da Veiga', '45', 'Jardim Europa', 'São Paulo', 'São Paulo'),
	('05061157000140', 'Bowline Marine & Cargo Consultants Ltda', 'Rua Xv De Novembro', '65', 'Centro', 'Santos', 'São Paulo'),
	('10567976000102', 'Nea - Comercial De Produtos Industriais Ltda', 'Rua Lino Peixoto Amorim', '1000', 'Paineiras', 'Itupeva', 'São Paulo'),
	('11426377000123', 'Mammoet Brasil Guindastes Ltda.', 'Rua Carlos Lisdegno Carlucci', '519', 'Jardim Peir Peri', 'São Paulo', 'São Paulo'),
	('11426377000638', 'Mammoet Brasil Guindastes Ltda.', 'Av Presidente Wilson', '231', 'Centro', 'Rio De Janeiro', 'Rio De Janeiro'),
	('15563826000489', 'Tse S/A', 'Estrada De Acesso A Br 135', 'Null', 'Zona Industrial', 'Santo Antonio Dos Lopes', 'Maranhão'),
	('23955189000171', 'Mitsubishi Power South America Limitada', 'Alameda Santo', '415', 'Cerqueira Cesar', 'São Paulo', 'São Paulo'),
	('29884534000290', 'Marlim Azul Energia S.A.', 'Rua Dos Garçons', 'Null', 'Horto', 'Macaé', 'Rio De Janeiro'),
	('43053081001334', 'Transdata Engenharia E Movimentacao Ltda', 'Avenida Rio Branco', '37', 'Centro', 'Rio De Janeiro', 'Rio De Janeiro'),
	('47098918000693', 'Veolia Water Technologies And Solutions Brasil Tratamento De Aguas Ltda', 'Rua Osasco', '28', 'Parque Industrial Anhanguera', 'Cajamar', 'São Paulo'),
	('51254159000173', 'Karina Plasticos Ltda', 'Avenida Antranig Guerekmezian', '788', 'Jardim Cumbica', 'Guarulhos', 'São Paulo')

EXECUTE stp_inserirDadosTabelaApoliceGarantia @tInserirDados = @t_tempInserirDados;
--FIM da Procedure

/*--------------------------------------------------------------------------------------------        
Tipo Objeto: View
Objeto     : vCNPJ
Objetivo   : Mostrar todos os CNPJ's
Criado em  : 05/04/2025
Palavras-chave: CNPJ
----------------------------------------------------------------------------------------------        
Observações : VARCHAR NULL nao reconhecido, precisou remover os espaços

----------------------------------------------------------------------------------------------        
Histórico:        
Autor                  IDBug Data			Descrição        
---------------------- ----- ----------		--------------------------------------------------
Marcus Paiva				 05/04/2025		Criação da View*/
CREATE OR ALTER VIEW vCNPJ
WITH ENCRYPTION, SCHEMABINDING
AS
SELECT
    tc.cNomeEmpresarial AS [Razão Social],
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
        ELSE 'nº ' + tc.cNumeroLogradouro
    END + ' - ' +
    tc.cBairroLogradouro + ' - ' +
    tci.cNomeCidade + '/' + te.cEstadoSigla AS Endereço
FROM dbo.tCNPJ tc
INNER JOIN dbo.tCidade tci
ON tci.iCidadeID = tc.iCidadeID
INNER JOIN dbo.tEstado te
ON tci.iEstadoID = te.iEstadoID
WITH CHECK OPTION;
GO
--FIM da VIEW tCNPJ

SELECT * FROM vCNPJ;
GO

SELECT * FROM tCNPJ tc
INNER JOIN tCidade tci
ON tc.iCidadeID = tci.iCidadeID;
GO
SELECT * FROM tCidade;
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

BEGIN TRANSACTION;
ALTER TABLE tCNPJ
DROP COLUMN cCidadeLogradouro, cEstadoLogradouro;

ALTER TABLE tCNPJ
ADD iCidadeID INT;


ALTER TABLE tCNPJ
ADD CONSTRAINT FK_tCNPJ_tCidade
FOREIGN KEY (iCidadeID) REFERENCES tCidade(iCidadeID);
COMMIT;
ROLLBACK;
GO

DROP VIEW vCNPJ;

SELECT @@TRANCOUNT;

BEGIN TRANSACTION
UPDATE tCNPJ SET iCidadeID = 1 WHERE iCNPJID = 1;
UPDATE tCNPJ SET iCidadeID = 2 WHERE iCNPJID = 2;
UPDATE tCNPJ SET iCidadeID = 3 WHERE iCNPJID = 3;
UPDATE tCNPJ SET iCidadeID = 4 WHERE iCNPJID = 4;
UPDATE tCNPJ SET iCidadeID = 2 WHERE iCNPJID = 5;
UPDATE tCNPJ SET iCidadeID = 5 WHERE iCNPJID = 6;
UPDATE tCNPJ SET iCidadeID = 6 WHERE iCNPJID = 7;
UPDATE tCNPJ SET iCidadeID = 2 WHERE iCNPJID = 8;
UPDATE tCNPJ SET iCidadeID = 7 WHERE iCNPJID = 9;
UPDATE tCNPJ SET iCidadeID = 5 WHERE iCNPJID = 10;
UPDATE tCNPJ SET iCidadeID = 8 WHERE iCNPJID = 11;
UPDATE tCNPJ SET iCidadeID = 9 WHERE iCNPJID = 12;

SELECT * FROM tCNPJ WHERE iCNPJID = 1


----------------------------------------
BEGIN TRANSACTION

USE ProcessosTemporarios;
GO

SELECT * FROM tContrato;
GO

/*--------------------------------------------------------------------------------------------        
Objeto tipo: Stored Procedure
Objeto     : stp_InsertDataContractTable
Objetivo   : Inserir dataser dentro da tabela tContrato
Projeto    : ProcessosTemporarios
Criação    : 04/04/2025
Keywords   : INSERT INTO
----------------------------------------------------------------------------------------------        
Observação:        

----------------------------------------------------------------------------------------------        
Histórico:        
Autor                  IDBug Data		Descrição
---------------------- ----- ---------- ------------------------------------------------------------        
Marcus V. Paiva Silveira                15/02/2025 Procedure criada */

IF NOT EXISTS (SELECT *  FROM sys.types WHERE NAME = 'dtInsertDataContractTable')
BEGIN
	CREATE TYPE dtInsertDataContractTable
	AS TABLE
	(
		cNumeroNomeContrato VARCHAR(100),
		cContratoTipo VARCHAR(20),
		dContratoDataAssinatura DATE,
		dContratoVencimento DATE,
		iNumeroProrrogacao INT
	)
END
GO

CREATE OR ALTER PROCEDURE stp_inserirDadosNaTabelaContrato
@tInserirDados dtInsertDataContractTable READONLY
AS BEGIN

	SET NOCOUNT ON;

	BEGIN TRY

		BEGIN TRANSACTION

		RAISERROR('Inserindo dados na tabela tContrato...',10,1) WITH NOWAIT;
		WAITFOR DELAY '00:00:05';

		INSERT INTO tContrato (cNumeroNomeContrato, cContratoTipo, dContratoDataAssinatura, dContratoVencimento, iNumeroProrrogacao)
		SELECT * FROM @tInserirDados;

		IF @@ROWCOUNT = 0
			RAISERROR('Dados não foram inseridos corretamente!',10,1);

		COMMIT;

	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0
			ROLLBACK

		EXECUTE stp_ManipulaErro

	END CATCH

	SELECT * FROM tContrato

END
GO
------------------------------------------------------------------------------------------------------------------------------      
DECLARE @t_tempInserirDados dtInsertDataContractTable

SET NOCOUNT ON

INSERT INTO @t_tempInserirDados VALUES
	('3º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-06-24', '2024-11-28', 3),
	('3º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-06-20', '2024-11-28', NULL),
	('3º Aditivo ao Contrato de Comodato', 'Comodato', '2024-10-22', '2024-12-03', 3),
	('4º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-10-24', '2024-12-12', 4),
	('3º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-11-12', '2024-12-20', 3),
	('Contrato de Afretamento por Tempo para Embarcações de Apoio Offshore', 'Afretamento', '2024-05-14', '2024-12-31', NULL),
	('9º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-12-12', '2025-01-21', 9),
	('Relatório Técnico de Envio de motor em Garantia para Collin', 'Reparo', NULL, '2025-01-22', 2),
	('Instrumento Particular de Contrato de Locaçao de Equipamentos nº DH-MEGA17', 'Aluguel', '2020-11-30', '2025-02-04', NULL),
	('Primeiro Aditamento de Contrato nº 01 de Afretamento de Draga a Casco Nu', 'Afretamento', '2024-10-07', '2025-02-18', NULL),
	('5º Termo Aditivo ao Contrato Nº BPCRC-014-2022-PRD', 'Aluguel', '2024-11-15', '2025-03-09',NULL ),
	('5º Termo Aditivo ao Contrato Nº BPCRC-014-2022-PRD', 'Aluguel', '2024-11-15', '2025-03-09',NULL ),
	('9º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-12-20', '2025-03-26', 9),
	('5º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-11-27', '2025-03-30', 5),
	('5º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-11-28', '2025-04-03', 5),
	('5º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-12-04', '2025-04-12', 5),
	('5º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-12-09', '2025-04-19', 5),
	('8º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-12-09', '2025-04-20', 8),
	('18º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-12-18', '2025-04-23', 18),
	('14º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-12-19', '2025-04-23', 14),
	('14º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-12-12', '2025-04-23', 14),
	('15º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-12-12', '2025-04-23', 8),
	('3º Aditivo ao Contrato de Comodato', 'Comodato', '2024-12-18', '2025-04-25', 3),
	('5º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-12-18', '2025-04-28', 5),
	('5º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-12-18', '2025-04-28', 5),
	('5º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-12-18', '2025-04-28', 5),
	('5º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-12-18', '2025-04-29', 5),
	('Laudo de identificaçao de Mercadorias para Exportaçao Temporária', 'Reparo', '2024-03-28', '2025-05-01',NULL ),
	('9º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-11-24', '2025-05-04', 9),
	('12º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-11-28', '2025-05-06', 12),
	('Instrumento Particular de Contrato de Comodato', 'Comodato', '2024-05-13', '2025-05-13',NULL ),
	('5º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-11-07', '2025-05-21', 5),
	('4º Aditivo ao Contrato de Comodato', 'Comodato', '2024-11-27', '2025-05-29', 4),
	('8º Aditivo ao Contrato de Comodato', 'Comodato', '2024-11-29', '2025-06-06', 8),
	('8º Aditivo ao Contrato de Comodato', 'Comodato', '2024-12-04', '2025-06-11', 8),
	('6º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-12-09', '2025-06-21', 6),
	('5º Aditivo ao Contrato de Locaçao', 'Aluguel', '2024-12-12', '2025-06-22', 5),
	('Contrato de Fretamento por Período Embarcações de Apoio Marítimo', 'Afretamento', '2024-09-18', '2025-07-11',NULL ),
	('Lease Agreement (Bare Rental) Addedum 2022208', 'Aluguel', '2024-07-08', '2025-08-21', 1),
	('Contrato', 'Emprestimo', '2023-10-27', '2025-09-01',NULL ),
	('Instrumento Particular de Contrato de Comodato', 'Comodato', '2024-09-11', '2025-09-11',NULL ),
	('Primeiro Aditivo Contratual', 'Comodato', '2024-08-26', '2025-09-20', 1),
	('Lease Agreement (Bare Rental) Addedum 2023099-1', 'Aluguel', NULL, '2025-10-21', 1),
	('Instrumento Particular de Contrato de Locaçao de Equipamentos nº DH-MEGA18', 'Aluguel', '2021-07-07', '2025-10-26',NULL ),
	('1º Termo Aditivo ao Instrumento Particular de Contrato de Locaçao de Equipamentos nº DH-MEGA15', 'Aluguel', '2022-01-11', '2026-02-09', 1),
	('Lease Agreement (Bare Rental) Addedum 2022208', 'Aluguel', '2024-07-08', '2026-02-22',NULL ),
	('Contrato de Emprestimo Agency Agreement', 'Emprestimo', '2024-03-11', '2026-03-10',NULL ),
	('Instrumento Particular de Contrato de Locaçao de Equipamentos nº DH-MEGA20', 'Aluguel', '2022-10-20', '2026-12-28',NULL ),
	('Instrumento Particular de Contrato de Locaçao de Equipamentos nº DH-MEGA19', 'Aluguel', '2022-09-21', '2027-01-01',NULL ),
	('2º Termo Aditivo ao Instrumento Particular de Contrato de Locaçao de Equipamentos nº DH-MEGA7-19', 'Aluguel', '2023-03-03', '2027-08-08', 2),
	('2º Termo Aditivo ao Instrumento Particular de Contrato de Locaçao de Equipamentos nº DH-MEGA6-19', 'Aluguel', '2023-03-03', '2027-08-08', 2),
	('2º Termo Aditivo ao Instrumento Particular de Contrato de Locaçao de Equipamentos nº DH-MEGA16', 'Aluguel', '2023-10-02', '2027-11-25', 1),
	('Instrumento Particular de Contrato de Locaçao de Equipamentos nº DH-MEGA23', 'Aluguel', '2023-09-01', '2027-11-27',NULL ),
	('Instrumento Particular de Contrato de Locaçao de Equipamentos nº DH-MEGA21-22', 'Aluguel', '2023-08-11', '2027-12-01',NULL ),
	('Instrumento Particular de Contrato de Locaçao de Equipamentos nº DH-MEGA24', 'Aluguel', '2024-04-01', '2028-08-16',NULL )

EXECUTE stp_inserirDadosNaTabelaContrato @tInserirDados = @t_tempInserirDados
GO
--FIM da Procedure

/*--------------------------------------------------------------------------------------------        
Tipo Objeto: View
Objeto     : vContrato
Objetivo   : Mostrar todas os Contratos associados ao numero do Processo
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
CREATE OR ALTER VIEW vContrato
WITH ENCRYPTION, SCHEMABINDING
AS
SELECT td.cReferenciaBraslog AS Processo,
tc.iNumeroProrrogacao AS [Número Prorrogação],
tc.cNumeroNomeContrato AS [Contrato Número],
tc.dContratoDataAssinatura AS [Data da Assinatura],
cContratoTipo AS [Tipo de Contrato],
tc.dContratoVencimento AS [Vencimento Contrato]
FROM dbo.tContrato tc
INNER JOIN dbo.tDeclaracao td
ON tc.iContratoID = td.iContratoID
WITH CHECK OPTION;
GO
--Fim da View vContrato

SELECT * FROM vContrato;
GO



---------------------------------
BEGIN TRANSACTION;

USE ProcessosTemporarios;
GO

SELECT * FROM tDeclaracao;
GO

/*--------------------------------------------------------------------------------------------        
Objeto tipo: Stored Procedure
Objeto     : stp_inserirDadosTabelaDeclaracao
objetivo   : Insert dataset in Declaracao table
Projeto    : ProcessosTemporarios
Criação    : 15/02/2025
Keywords   : INSERT INTO
----------------------------------------------------------------------------------------------        
Observação:        

----------------------------------------------------------------------------------------------        
Historico:        
Autor                  IDBug Data		Descrição
---------------------- ----- ---------- ------------------------------------------------------------        
Marcus V. Paiva Silveira                15/02/2025 Procedure criada */

BEGIN TRANSACTION

	BEGIN TRY

	IF NOT EXISTS (SELECT * FROM sys.types WHERE NAME = 'dtInsertDataDeclaracaoTable')
		BEGIN
			CREATE TYPE dtInsertDataDeclaracaoTable
			AS TABLE
			(
				cNumeroDeclaracao VARCHAR(12),
				iCNPJID INT,
				cReferenciaBraslog CHAR(13),
				cReferenciaCliente VARCHAR(100),
				dDataRegistroDeclaracao DATE,
				dDataDesembaracoDeclaracao DATE,
				iCEID INT,
				iRecintoID INT,
				cNumeroDOSSIE CHAR(15),
				cNumeroProcessoAdministrativo VARCHAR(100),
				iContratoID INT,
				iApoliceID INT,
				cModal VARCHAR(15)
			)
		END

		COMMIT

	END TRY
	BEGIN CATCH		
		
		IF @@TRANCOUNT > 0
			ROLLBACK;

		EXEC stp_ManipulaErro;

	END CATCH;
GO

CREATE OR ALTER PROCEDURE stp_inserirDadosNaTabelaDeclaracao
@tInserirDados dtInsertDataDeclaracaoTable READONLY
AS BEGIN

	SET NOCOUNT ON

	BEGIN TRANSACTION

	BEGIN TRY

		RAISERROR('Inserindo dados na tabela tDeclaraçao...',10,1) WITH NOWAIT;
		WAITFOR DELAY '00:00:02';

		INSERT INTO tDeclaracao
		(
			cNumeroDeclaracao,
			iCNPJID,
			cReferenciaBraslog,
			cReferenciaCliente,
			dDataRegistroDeclaracao,
			dDataDesembaracoDeclaracao,
			iCEID,
			iRecintoID,
			cNumeroDOSSIE,
			cNumeroProcessoAdministrativo,
			iContratoID,
			iApoliceID,
			cModal
		)
		SELECT * FROM @tInserirDados;

		IF @@ROWCOUNT = 0
		BEGIN
			RAISERROR('Dados nao foram inseridos com sucesso!',10,1);
			ROLLBACK;
			RETURN;
		END

		DECLARE @iNumeroColunas INT = (SELECT COUNT(COLUMN_NAME) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tDeclaracao');
		DECLARE @iContador INT = 1;
		DECLARE @cNomeColuna VARCHAR(50);

		WHILE @iContador <= @iNumeroColunas
		BEGIN
			
			SET @cNomeColuna = (SELECT NAME FROM sys.columns WHERE OBJECT_ID = OBJECT_ID('tDeclaracao') AND column_id = @iContador);
			RAISERROR('Populando coluna %s na tabela tDeclaracao...',10,1,@cNomeColuna) WITH NOWAIT;
			WAITFOR DELAY '00:00:02';

			SET @iContador += 1;

		END

		RAISERROR('Todos os dados foram inseridos com sucesso!',10,1) WITH NOWAIT;
		WAITFOR DELAY '00:00:05';

		COMMIT;

	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0
			ROLLBACK

		EXECUTE stp_ManipulaErro;

	END CATCH;

	SELECT * FROM tDeclaracao;

END
GO

DECLARE @t_tempInserirDados dtInsertDataDeclaracaoTable

SET NOCOUNT ON
INSERT INTO @t_tempInserirDados VALUES
	('2213721580', 5, 'I-22/0968-MBG', NULL, '2022-07-19', '2022-07-27', 1, 4, '202200158843967', NULL, 1, NULL, 'MARÍTIMO'),
	('2406902926', 5, 'I-24/0271-MBG', 'CABOS E CONTRAPESO', '2024-04-02', '2024-04-04', 2, 3, '202400232144540', NULL, 3, NULL, 'MARÍTIMO'),
	('2215388101', 5, 'I-22/1149-MBG', NULL, '2022-08-10', '2022-08-12', 3, 4, '202200161707530', NULL, 4, NULL, 'MARÍTIMO'),
	('2211469948', 5, 'I-22/0680-MBG', 'CC3800-1', '2022-06-17', '2022-06-29', 4, 5, '202200155225677', NULL, 1, 1, 'MARÍTIMO'),
	('2411169727', 2, 'I-24/1100-DTE', 'DRAGA FENFORD', '2024-05-27', '2024-05-27', NULL, 8, '202400238873528', NULL, 6, NULL, 'MEIOS PRÓPRIOS'),
	('2111602972', 5, 'I-21/0721-MBG', 'LTM1500-8.1', '2021-06-17', '2021-06-21', 5, 3, '202100109389832', NULL, 7, 2, 'MARÍTIMO'),
	('240010523748', 12, 'E-24/0208-KRN', 'EXP TEMPORARIA', '2024-06-24', '2024-06-25', NULL, 12, '202400242169252', NULL, 8, NULL, 'AÉREO'),
	('2102189170', 1, 'I-20/1533-MEG', 'FORRAGEIRA + PLATAFORMA', '2021-02-03', '2021-02-04', 6, 11, '202100097363944', NULL, 9, NULL, 'MARÍTIMO'),
	('2412607809', 2, 'I-24/1261-DTE', 'DRAGA ELBE', '2024-06-14', '2024-06-18', NULL, 1, '202400241046459', NULL, 10, NULL, 'MEIOS PRÓPRIOS'),
	('240003252912', 4, 'E-24/0052-NEA', NULL, '2024-02-27', '2024-02-28', NULL, 13, '202400227845285', NULL, 11, NULL, 'AÉREO'),
	('240000198208', 4, 'E-24/0004-NEA', NULL, '2024-01-05', '2024-01-12', NULL, 13, '202400222101024', NULL, 11, NULL, 'AÉREO'),
	('2105759393', 6, 'I-21/0343-MBG', 'EXP-MUSA-12521', '2021-03-24', '2021-03-26', 7, 10, '202100103816828', NULL, 7, 3, 'MARÍTIMO'),
	('2306782082', 5, 'I-23/0175-MBG', 'REP. DOMINICANA', '2023-04-10', '2023-04-13', 8, 9, '202300188957138', NULL, 14, NULL, 'MARÍTIMO'),
	('2308248563', 5, 'I-23/0432-MBG', 'REP. LINHA DE EIXO', '2023-04-28', '2023-05-10', 9, 9, '202300191329045', NULL, 14, 4, 'MARÍTIMO'),
	('2221403214', 5, 'I-22/1173-MBG', 'EXPO-CHL-BRL-034', '2022-10-28', '2022-11-08', 10, 17, '202200171178807', NULL, 14, 5, 'MARÍTIMO'),
	('2225612292', 5, 'I-22/1955-MBG', 'CC 2800-1', '2022-12-26', '2023-01-19', 11, 10, '202200177717807', NULL, 14, 6, 'MARÍTIMO'),
	('2117258092', 6, 'I-21/1420-MBG', 'CKE1100G-2', '2021-09-17', '2021-09-20', 12, 10, '202100119574713', NULL, 18, 7, 'MARÍTIMO'),
	('1801413543', 6, 'I-17/2116-MBG', 'LINHA DE EIXO + POWER PACK', '2018-01-22', '2018-02-19', 13, 10, '201800018270352', '10711.720099/2018-34', 19, 8, 'MARÍTIMO'),
	('1905629534', 6, 'I-19/0083-MBG', 'GUINDASTE CC 2800-1', '2019-03-28', '2019-04-09', 14, 7, '201900038644169', '10120.004639/0319-51', 20, 9, 'MARÍTIMO'),
	('1906086887', 6, 'I-19/0142-MBG', 'CONTAINER OFICINA', '2019-04-04', '2019-04-09', 15, 7, '201900038679949', '10120.004638/0319-14', 20, NULL, 'MARÍTIMO'),
	('2117294706', 6, 'I-21/1419-MBG', 'CC2800-1', '2021-09-10', '2021-09-20', 16, 10, '202100119592274', NULL, 22, 10, 'MARÍTIMO'),
	('2406046760', 5, 'I-24/0252-MBG', 'JIB', '2024-03-20', '2024-03-25', 17, 3, '202400230765378', NULL, 3, NULL, 'MARÍTIMO'),
	('2210462397', 5, 'I-22/0623-MBG', 'CKE1100G2 - KOBELCO', '2022-06-02', '2022-06-28', 18, 6, '202200151499195', NULL, 14, 11, 'MARÍTIMO'),
	('2210427150', 5, 'I-22/0631-MBG', 'LR1300', '2022-06-02', '2022-06-28', 19, 6, '202200151629293', NULL, 14, 12, 'MARÍTIMO'),
	('2210450267', 5, 'I-22/0621-MBG', 'CK1100 (KOBELCO)', '2022-06-02', '2022-06-28', 20, 6, '202200151434298', NULL, 14, 13, 'MARÍTIMO'),
	('2210475103', 5, 'I-22/0630-MBG', 'RT890E', '2022-06-02', '2022-06-29', 21, 6, '202200151564345', NULL, 14, 14, 'MARÍTIMO'),
	('240006359556', 9, 'E-24/0119-MRL', NULL, '2024-04-17', '2024-05-01', NULL, 12, '202400233843302', NULL, 28, NULL, 'AÉREO'),
	('2104031884', 5, 'I-21/0242-MBG', 'MID POINTS', '2021-03-01', '2021-03-08', NULL, 14, '202100101144776', '13032.193464/2021-68', 7, NULL, 'AÉREO'),
	('1908940648', 5, 'I-19/0475-MBG', 'PENOANT', '2019-05-20', '2019-06-06', NULL, 14, '201900042372208', '10120.004974/0519-84', 30, NULL, 'AÉREO'),
	('2410910580', 11, 'I-24/1022-VEO', 'Aquaforce 7500', '2024-05-23', '2024-05-23', NULL, 12, '202400238478718', NULL, 31, NULL, 'AÉREO'),
	('230002563884', 5, 'E-23/0033-MBG', '001/23', '2023-02-16', '2023-02-22', NULL, 10, '202300183358937', NULL, 14, NULL, 'AÉREO'),
	('2210492504', 5, 'I-22/0632-MBG', 'PEÇAS SPMT', '2022-06-02', '2022-06-29', 22, 6, '202200151601747', NULL, 33, NULL, 'MARÍTIMO'),
	('2119044286', 6, 'I-21/1596-MBG', 'MOITAO CC2800', '2021-10-05', '2021-10-06', 23, 10, '202100123107563', NULL, 34, NULL, 'MARÍTIMO'),
	('2106758145', 5, 'I-21/0555-MBG', 'ATUADRO CC2800', '2021-04-08', '2021-04-14', NULL, 14, '202100105179086', NULL, 34, NULL, 'AÉREO'),
	('2213762170', 5, 'I-22/0809-MBG', NULL, '2022-07-20', '2022-07-28', 24, 4, '202200158856694', NULL, 36, 15, 'MARÍTIMO'),
	('2216549737', 5, 'I-22/0688-MBG', 'SPMT (REP. DOMINICANA)', '2022-08-25', '2022-09-22', 25, 3, '202200163555567', NULL, 14, 16, 'MARÍTIMO'),
	('2422306844', 2, 'I-24/2191-DTE', 'DRAGA LINDWAY', '2024-10-11', '2024-10-14', NULL, 18, '202400256103291', NULL, 38, NULL, 'MEIOS PRÓPRIOS'),
	('2316367940', 10, 'I-23/0861-TRA', 'ADM TEMP M18000', '2023-08-21', '2023-08-30', 26, 7, '202300205397590', NULL, 39, 17, 'MARÍTIMO'),
	('2420073435', 7, 'I-24/1189-TOY', 'TRN030', '2024-09-16', '2024-09-18', NULL, 2, '202400252826140', NULL, 40, NULL, 'AÉREO'),
	('2425413366', 11, 'I-24/1826-VEO', 'PILOT TEST PETROBRÁS', '2024-11-19', '2024-11-19', 27, 19, '202400261377728', NULL, 31, NULL, 'MARÍTIMO'),
	('2319009484', 8, 'I-23/1919-MIT', 'TL 58415', '2023-09-26', '2023-10-09', NULL, 12, '202300209954280', NULL, 42, 18, 'AÉREO'),
	('2321191189', 10, 'I-23/1722-TRA', 'PPU + SPTM', '2023-10-26', '2023-11-13', 28, 10, '202300214163318', NULL, 43, 19, 'MARÍTIMO'),
	('2119807018', 1, 'I-21/1334-MEG', 'WS21-1', '2021-10-15', '2021-10-26', 29, 11, '202100116268220', NULL, 44, NULL, 'MARÍTIMO'),
	('1802261224', 1, 'I-17/1964-MEG', 'US17-2', '2018-02-05', '2018-02-09', 30, 11, '201800018565140', '10010.005227/0118-79', 45, NULL, 'MARÍTIMO'),
	('2418067180', 10, 'I-24/1778-TRA', 'MOITÃO', '2024-08-22', '2024-08-26', 31, 9, '202400249262029', NULL, 39, NULL, 'MARÍTIMO'),
	('2310336557', 3, 'I-24/0782-BWL', 'ADM TEMP', '2024-05-15', '2024-05-22', NULL, 19, '202400237510057', NULL, 47, NULL, 'AÉREO'),
	('2225695775', 1, 'I-22/1926-MEG', 'PFWS22-4', '2022-12-27', '2022-12-30', 32, 16, '202200177701960', NULL, 48, NULL, 'MARÍTIMO'),
	('2300245000', 1, 'I-22/1689-MEG', 'WS22-3VEICULO', '2023-01-04', '2023-01-09', 33, 16, '202300178529346', NULL, 49, NULL, 'MARÍTIMO'),
	('1102552358', 1, 'I-10/1287-MEG', 'DIETHELM WS 102', '2011-02-09', '2011-02-14', NULL, 15, NULL, '10314.002198/2011-47', 50, NULL, 'MEIOS PRÓPRIOS'),
	('1102548903', 1, 'I-10/1199-MEG', 'DIETHELM WS 101', '2011-02-09', '2011-02-14', NULL, 15, NULL, '10314.002197/2011-01', 51, NULL, 'MEIOS PRÓPRIOS'),
	('1919661001', 1, 'I-19/1042-MEG', 'PFWS19-2', '2019-10-23', '2019-10-25', 34, 11, '201900055854940', '10010.079669/0919-44', 52, NULL, 'MARÍTIMO'),
	('2323396780', 1, 'I-23/1812-MEG', 'ADM', '2023-11-28', '2023-11-29', 35, 16, '202300217735169', NULL, 53, NULL, 'MARÍTIMO'),
	('2323376321', 1, 'I-23/1653-MEG', 'WS23-1', '2023-01-27', '2023-12-01', 36, 16, '202300217734367', NULL, 54, NULL, 'MARÍTIMO'),
	('2417609524', 1, 'I-24/0785-MEG', 'WS24-1', '2024-08-16', '2024-08-21', 37, 16, '202400248810936', NULL, 55, NULL, 'MARÍTIMO')

EXECUTE stp_inserirDadosNaTabelaDeclaracao @tInserirDados = @t_tempInserirDados;

DROP PROCEDURE stp_inserirDadosNaTabelaDeclaracao;--deletar procedure
DROP TYPE dtInsertDataDeclaracaoTable;--deletar tipo
DELETE FROM tDeclaracao;--Deletar dados dentro da tabela
ALTER SEQUENCE seqDeclaracaoID RESTART WITH 1;--Reiniciar Sequence

SELECT * FROM tDeclaracao;



SELECT * FROM vDeclaracao
GO
SELECT * FROM tDeclaracao;
SELECT TOP 1 * FROM vDeclaracao

--Falta Descriçao da Mercadoria - 05/04/2025
BEGIN TRANSACTION
ALTER TABLE tDeclaracao
ADD cDescricao VARCHAR(MAX)
COMMIT
ROLLBACK

--Falta Histórico do Processo - 05/04/2025
BEGIN TRANSACTION
ALTER TABLE tDeclaracao
ADD cHistorico VARCHAR(MAX)
SELECT * FROM tDeclaracao
COMMIT
ROLLBACK


--Incluir historico por ID
SELECT @@TRANCOUNT

BEGIN TRANSACTION

UPDATE tDeclaracao
SET cHistorico =
	CASE iDeclaracaoID
		WHEN 2 THEN
			'29/11/2024 - Reexportado através dos processos E-24/0418-MBG' + CHAR(13) + CHAR(10) + 
			'27/11/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'01/11/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'29/10/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'28/10/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'22/10/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'21/10/2024 - Solciitado prorrogaçao por mais 1 mes' + CHAR(13) + CHAR(10) + 
			'14/10/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'09/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'03/07/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'02/07/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'25/06/2024 - Solicitado prorrogação por mais 4 meses, numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'10/06/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'03/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'29/05/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'27/05/2024 - Enviado Numerario e RPR, ag retorno' + CHAR(13) + CHAR(10) + 
			'21/05/2024 - Solicitado prorrogação por mais 1 mes' + CHAR(13) + CHAR(10) + 
			'07/05/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'30/04/2024 - Processo incluído no controle'
		WHEN 3 THEN
			'29/11/2024 - Reexportado através do processo E-24/0406-MBG' + CHAR(13) + CHAR(10) + 
			'27/11/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'01/11/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'29/10/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'28/10/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'22/10/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'21/10/2024 - Solciitado prorrogaçao por mais 1 mes' + CHAR(13) + CHAR(10) + 
			'14/10/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'30/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'13/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'11/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'10/06/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'04/06/2024 - Prorrogação por mais 5 meses' + CHAR(13) + CHAR(10) + 
			'03/06/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'15/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'12/01/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'12/01/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'04/01/2024 - Numerario e RPR enviados, agr retorno' + CHAR(13) + CHAR(10) + 
			'03/01/2024 - Solicitado prorrogação por mais 4 meses' + CHAR(13) + CHAR(10) + 
			'28/12/2023 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'21/11/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'10/07/2023 - Juntada efetuada através do DOSSIE' + CHAR(13) + CHAR(10) + 
			'28/06/2023 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'20/06/2023 - Numerario e TR enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'19/06/2023 - Informado que será prorrogado por 6 meses' + CHAR(13) + CHAR(10) + 
			'18/05/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'22/09/2022 - Processo incluido no controle'
		WHEN 4 THEN
			'29/11/2024 - Reexportado através dos processos E-24/0419-MBG' + CHAR(13) + CHAR(10) + 
			'25/11/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'19/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'13/11/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'11/11/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'07/11/2024 - Solcicitado prorrogaçao por mais 1 mes' + CHAR(13) + CHAR(10) + 
			'30/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'20/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'14/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'04/06/2024 - Prorrogação por mais 5 meses, ag retorno' + CHAR(13) + CHAR(10) + 
			'03/06/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'30/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'19/12/2023 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'01/12/2023 - Enviado RPR, TR e Numerario, ag retorno' + CHAR(13) + CHAR(10) + 
			'22/11/2023 - Solicitado renovação por mais 6 meses' + CHAR(13) + CHAR(10) + 
			'26/10/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'28/07/2022 - Processo incluido no controle'
		WHEN 5 THEN
			'26/12/2024 - Reexportaçao através do processo E-24/0425-DTE' + CHAR(13) + CHAR(10) + 
			'01/11/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'25/06/2024 - Processo incluído no controle'
		WHEN 6 THEN
			'26/12/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'20/12/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'19/12/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'25/11/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'21/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'19/11/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'14/11/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'12/11/2024 - Solicitado prorrogação por mais 1 mes' + CHAR(13) + CHAR(10) + 
			'30/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'21/08/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'21/08/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'07/08/2024 - Numerario enviado, ag numerario' + CHAR(13) + CHAR(10) + 
			'05/08/2024 - Solicitado prorrogação por mais 3 meses' + CHAR(13) + CHAR(10) + 
			'25/07/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'25/06/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'21/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'19/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'10/06/2024 - Enviado Numerario, ag retorno' + CHAR(13) + CHAR(10) + 
			'04/06/2024 -Solicitado prorrogação por mais 2 meses' + CHAR(13) + CHAR(10) + 
			'03/06/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'30/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'19/04/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'12/04/2024 - Dcos recebidos' + CHAR(13) + CHAR(10) + 
			'05/04/2024 - Numerario e TR enviados' + CHAR(13) + CHAR(10) + 
			'04/04/2024 - Informado que será prorrogado por mais 2 meses' + CHAR(13) + CHAR(10) + 
			'22/03/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'23/02/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'18/09/2023 - Juntada efetuada pelo DOSSIE' + CHAR(13) + CHAR(10) + 
			'04/09/2023 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'27/07/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'21/07/2023 - Juntada da Apolice efetuada' + CHAR(13) + CHAR(10) + 
			'20/07/2023 - Juntada efetuada sem Apolice, através do DOSSIE' + CHAR(13) + CHAR(10) + 
			'18/07/2023 - Recebido docs, exceto Apolice' + CHAR(13) + CHAR(10) + 
			'27/06/2023 - Numerario, TR e RPR enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'21/06/2023 - Informado que será prorrogado por 2 meses' + CHAR(13) + CHAR(10) + 
			'01/06/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'22/03/2023 - Recebido Apolice, juntado ao DOSSIE' + CHAR(13) + CHAR(10) + 
			'21/03/2023 - Juntada efetuada, ag Apolice' + CHAR(13) + CHAR(10) + 
			'21/03/2023 - Docs recebidos exceto Apolice.' + CHAR(13) + CHAR(10) + 
			'01/02/2023 - Enviado Numerario, RPR e TR, aguardando retorno' + CHAR(13) + CHAR(10) + 
			'26/01/2023 - Informado que a prorrogação será até 08/2023' + CHAR(13) + CHAR(10) + 
			'24/01/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'20/12/2022 - Juntada efetuada no DOSSIE' + CHAR(13) + CHAR(10) + 
			'19/12/2022 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'22/11/2022 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'25/10/2022 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'25/06/2021 - Processo incluido no controle'
		WHEN 7 THEN
			'26/12/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'18/12/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'18/12/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'27/11/2024 - Informado que será reimportado' + CHAR(13) + CHAR(10) + 
			'27/11/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'28/10/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'23/10/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'23/10/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'09/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'11/07/2024 - Processo incluído no controle'
		WHEN 8 THEN
			'26/12/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'23/03/2021 - Processo incluido no controle'
		WHEN 9 THEN
			'26/12/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'14/10/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'14/10/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'07/10/2024 - Solicitado prorrogaçao por mais 3 meses, numerario e RPR enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'14/08/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'22/07/2024 - Processo incluído no controle'
		WHEN 10 THEN
			'29/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'27/11/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'27/11/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'18/10/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'09/10/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'04/10/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'14/08/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'15/04/2024 - Processo incluído no controle'
		WHEN 11 THEN
			'29/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'27/11/2024 - Cobrado novamente, docs recebidos' + CHAR(13) + CHAR(10) + 
			'18/10/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'09/10/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'04/10/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'14/08/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'16/02/2024 - Processo incluido no controle'
		WHEN 12 THEN
			'26/12/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'23/12/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'29/11/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'28/11/2024 - Solicitado prorrogaçao por mais 3 mese' + CHAR(13) + CHAR(10) + 
			'27/11/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'26/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'22/11/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'14/11/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'12/11/2024 - Solicitado prorrogaçao por mais 1 mes' + CHAR(13) + CHAR(10) + 
			'30/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'26/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'26/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'14/06/2024 - Enviado Numerario, ag retorno' + CHAR(13) + CHAR(10) + 
			'13/06/2024 - Solicitado prorrogação por mais 5 meses' + CHAR(13) + CHAR(10) + 
			'03/06/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'30/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'26/04/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'19/04/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'05/04/2024 - Numerario e RPR enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'04/04/2024 - Informado que será prorrogado por mais 2 meses' + CHAR(13) + CHAR(10) + 
			'28/02/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'25/10/2023 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'23/10/2023 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'06/10/2023 - RPR, TR e Numerario enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'03/10/2023 - Solicitado prorrogação por mais 6 meses' + CHAR(13) + CHAR(10) + 
			'30/08/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'25/07/2023 - Juntada efetuada atraves do DOSSIE' + CHAR(13) + CHAR(10) + 
			'21/07/2023 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'27/06/2023 - Enviado Numerario, TR e RPR, ag retorno' + CHAR(13) + CHAR(10) + 
			'22/06/2023 - Solicitado renovação por 3 meses' + CHAR(13) + CHAR(10) + 
			'01/06/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'23/03/2023 - Juntada efetuada através do DOSSIE' + CHAR(13) + CHAR(10) + 
			'20/03/2023 - Recebido documentação' + CHAR(13) + CHAR(10) + 
			'28/02/2023 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'31/01/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'25/03/2022 - Juntada anexada através do DOSSIE' + CHAR(13) + CHAR(10) + 
			'17/02/2022 - Solicitado prorrogação por 12 meses, TR, RAT e Numerário enviados, aguardando retorno' + CHAR(13) + CHAR(10) + 
			'27/01/2022 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'24/09/2021 - Recebido documentos, juntada efetuada pelo DOSSIE' + CHAR(13) + CHAR(10) + 
			'20/09/2021 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'27/08/2021 - Cobrado novamente, solicitado prorrogação por 6 meses, TR e Numerario enviados, aguardando retorno' + CHAR(13) + CHAR(10) + 
			'27/07/2021 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'11/05/2021 - Processo incluído no controle'
		WHEN 13 THEN
			'29/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'27/11/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'25/11/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'22/11/2024 - Solicitado prorrogaçao por mais 4 meses' + CHAR(13) + CHAR(10) + 
			'30/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'30/08/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'29/08/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'22/08/2024 - Numerario e RPR enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'21/08/2024 - Prorrogação por mais 3 meses' + CHAR(13) + CHAR(10) + 
			'14/08/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'02/07/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'25/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'25/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'17/06/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'13/06/2024 - Prorrogaçao por mais 2 meses' + CHAR(13) + CHAR(10) + 
			'30/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'28/03/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'27/03/2024 - Recebido docs' + CHAR(13) + CHAR(10) + 
			'13/03/2024 - Enviado Numerario e RPR, ag retorno' + CHAR(13) + CHAR(10) + 
			'12/03/2024 - Solicitado prorrogação por mais 3 meses' + CHAR(13) + CHAR(10) + 
			'01/02/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'27/10/2023 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'26/10/2023 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'06/10/2023 - RPR e Numerario enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'03/10/2023 - Solicitado prorrogação por mais 5 meses' + CHAR(13) + CHAR(10) + 
			'30/08/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'11/07/2023 - Processo incluido no controle'
		WHEN 14 THEN
			'29/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'28/11/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'25/11/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'22/11/2024 - Solicitado prorrogaçao por mais 4 meses' + CHAR(13) + CHAR(10) + 
			'07/10/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'03/09/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'29/08/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'22/08/2024 - Numerario e RPR enviados' + CHAR(13) + CHAR(10) + 
			'21/08/2024 - Solicitado prorrogaçao por mais 3 meses' + CHAR(13) + CHAR(10) + 
			'14/08/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'05/07/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'24/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'17/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'17/06/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'13/06/2024 - Prorrogação por mais 2 meses' + CHAR(13) + CHAR(10) + 
			'10/06/2024 - Cobrado procedimento' + CHAR(13) + CHAR(10) + 
			'03/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'29/05/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'24/05/2024 - RPR e Numerario enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'21/05/2024 - Solicitado prorrogação por mais 1 mes' + CHAR(13) + CHAR(10) + 
			'08/05/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'05/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'04/12/2023 - Juntada efetuada, aguardando apolice.' + CHAR(13) + CHAR(10) + 
			'10/11/2023 - Solicitado prorrogação por mais 6 meses, Numerario, TR e RPR enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'06/10/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'12/06/2023 - Processo incluido no controle'
		WHEN 15 THEN
			'10/12/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'03/12/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'29/11/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'27/11/2024 - Solicitado prorrogaçao por mais 4 meses' + CHAR(13) + CHAR(10) + 
			'27/11/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'11/11/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'08/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'04/11/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'22/10/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'21/10/2024 - Solciitado prorrogaçao por mais 1 mes' + CHAR(13) + CHAR(10) + 
			'14/10/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'30/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'13/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'11/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'10/06/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'04/06/2024 - Prorrogação por mais 5 meses' + CHAR(13) + CHAR(10) + 
			'03/06/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'15/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'12/04/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'11/04/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'03/04/2024 - Enviado Numerario e RPR' + CHAR(13) + CHAR(10) + 
			'01/04/2024 - Informado que será prorrogado por mais 2 meses' + CHAR(13) + CHAR(10) + 
			'22/03/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'14/02/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'03/11/2023 - Juntada da Apolice efetuada' + CHAR(13) + CHAR(10) + 
			'26/10/2023 - Apolice atualizada recebida' + CHAR(13) + CHAR(10) + 
			'11/10/2023 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'06/10/2023 - Recebido docs exceto Apolice atualizada' + CHAR(13) + CHAR(10) + 
			'21/08/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'02/01/2023 - Processo incluido no controle'
		WHEN 16 THEN
			'17/12/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'16/12/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'29/11/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'28/11/2024 - Solicitado prorrogaçao por mais 4 meses' + CHAR(13) + CHAR(10) + 
			'25/11/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'19/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'19/11/2024 - Recebido documentos' + CHAR(13) + CHAR(10) + 
			'24/10/2024 - Enviado numerario, ag retorno' + CHAR(13) + CHAR(10) + 
			'23/10/2024 - Solciitado prorrogaçao por mais 1 mes' + CHAR(13) + CHAR(10) + 
			'30/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'19/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'19/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'10/06/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'04/06/2024 - Prorrogação por mais 5 meses' + CHAR(13) + CHAR(10) + 
			'03/06/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'30/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'15/01/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'12/01/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'05/01/2024 - RPR e Numerario enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'04/01/2024 - Solicitado prorrogação por mais 5 meses' + CHAR(13) + CHAR(10) + 
			'28/12/2023 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'21/11/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'17/07/2023 - Juntada efetuada através do DOSSIE' + CHAR(13) + CHAR(10) + 
			'17/07/2023 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'20/06/2023 - Numerario, TR e RPR enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'19/06/2023 - Informado que será prorrogado por 6 meses' + CHAR(13) + CHAR(10) + 
			'18/05/2023  - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'03/03/2023 - Processo incluido no controle'
		WHEN 17 THEN
			'18/12/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'18/12/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'29/11/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'28/11/2024 - Solicitado prorrogaçao por mais 4 meses' + CHAR(13) + CHAR(10) + 
			'25/11/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'19/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'19/11/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'22/10/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'21/10/2024 - Solciitado prorrogaçao por mais 1 mes' + CHAR(13) + CHAR(10) + 
			'30/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'20/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'19/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'10/06/2024 - Enviado RPR, ag retorno' + CHAR(13) + CHAR(10) + 
			'04/06/2024 - Solicitado prorrogação por mais 5 meses' + CHAR(13) + CHAR(10) + 
			'03/06/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'30/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'19/04/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'19/04/2024 - Documentação recebida' + CHAR(13) + CHAR(10) + 
			'03/04/2024 - Numerario, RPR e TR enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'01/04/2024 - Informado que será prorrogado por mais 2 meses' + CHAR(13) + CHAR(10) + 
			'22/03/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'23/02/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'19/10/2023 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'18/10/2023 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'02/10/2023 - Enviado numerario, TR e RPR, ag retorno' + CHAR(13) + CHAR(10) + 
			'29/09/2023 - Cobrado novamente, respondido que será prorrogado por mais 6 meses' + CHAR(13) + CHAR(10) + 
			'21/08/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'14/08/2023 - Juntada efetuada pelo DOSSIE' + CHAR(13) + CHAR(10) + 
			'04/08/2023 - Recebido docs' + CHAR(13) + CHAR(10) + 
			'31/07/2023 - Numerario, RPR e TR enviados, agr retorno' + CHAR(13) + CHAR(10) + 
			'26/07/2023 - Informad que será prorrogado por mais 2 meses' + CHAR(13) + CHAR(10) + 
			'26/06/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'09/03/2023 - Juntada efetuada no DOSSIE' + CHAR(13) + CHAR(10) + 
			'06/03/2023 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'01/02/2023 - Enviado Numerario, RPR e TR, aguardando retorno' + CHAR(13) + CHAR(10) + 
			'26/01/2023 - Informado que a prorrogação será até 08/2023' + CHAR(13) + CHAR(10) + 
			'24/01/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'15/03/2022 - Juntada anexada através do DOSSIE' + CHAR(13) + CHAR(10) + 
			'17/02/2022 - Solicitado prorrogação por 12 meses, TR, RAT e Numerário enviados, aguardando retorno' + CHAR(13) + CHAR(10) + 
			'19/01/2022 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'29/10/2021 - Processo incluido no controle'
		WHEN 18 THEN
			'23/12/2024 - Juntada efetuada, docs recebidos' + CHAR(13) + CHAR(10) + 
			'29/11/2024 - Enviado Numerario, ag retorno' + CHAR(13) + CHAR(10) + 
			'27/11/2024 - Solicitado prorrogaçao por mais 4 meses' + CHAR(13) + CHAR(10) + 
			'27/11/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'28/10/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'25/10/2024 - Despacho' + CHAR(13) + CHAR(10) + 
			'22/08/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'12/08/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'07/08/2024 - Enviado Numerario, ag retorno' + CHAR(13) + CHAR(10) + 
			'05/08/2024 - Solicitado prorrogação por mais 4 meses' + CHAR(13) + CHAR(10) + 
			'25/06/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'21/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'19/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'17/06/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'11/06/2024 - Prorrogação por mais 2 meses' + CHAR(13) + CHAR(10) + 
			'03/06/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'30/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'23/01/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'12/01/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'05/01/2024 - RPR, Numerario e TR enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'04/01/2023 - Solicitado prorrogação por mais 5 meses' + CHAR(13) + CHAR(10) + 
			'28/12/2023 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'01/12/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'31/07/2023 - Apolice juntada' + CHAR(13) + CHAR(10) + 
			'27/07/2023 - Recebido Apolice' + CHAR(13) + CHAR(10) + 
			'21/07/2023 - Juntada efetuada sem Apolice' + CHAR(13) + CHAR(10) + 
			'18/07/2023 - Docs recebidos, exceto Apolice' + CHAR(13) + CHAR(10) + 
			'27/06/2023 - Numerario, TR e RPR enviados' + CHAR(13) + CHAR(10) + 
			'21/06/2023 - Solicitado renovação por 6 meses' + CHAR(13) + CHAR(10) + 
			'01/06/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'09/02/2023 - Despacho de encaminhamento' + CHAR(13) + CHAR(10) + 
			'24/01/2023 - Juntada efetuada DOSSIE  e E-CAC, Apolice recebida' + CHAR(13) + CHAR(10) + 
			'23/01/2023 - Docs recebidos, exceto APOLICE, juntada efetuada, aguardando APOLICE' + CHAR(13) + CHAR(10) + 
			'02/01/2023 - Enviado Numerario, RPR e TR equivalente a 6 meses, aguardando retorno' + CHAR(13) + CHAR(10) + 
			'25/11/2022 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'07/11/2022 - Despacho Decisorio' + CHAR(13) + CHAR(10) + 
			'14/10/2022 - Despacho de Encaminhamento' + CHAR(13) + CHAR(10) + 
			'12/07/2022 - Juntada efetuada no e-CAC e no DOSSIE.' + CHAR(13) + CHAR(10) + 
			'08/07/2022 - Cobrado os documentos para seguir com o pedido de prorrogação.' + CHAR(13) + CHAR(10) + 
			'06/06/2022 - Solicitado prorrogação por mais 6 meses, docs enviados, aguardando retorno' + CHAR(13) + CHAR(10) + 
			'24/05/2022 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'18/02/2022 - Juntada efetuada no e-cac e através do DOSSIE da DI' + CHAR(13) + CHAR(10) + 
			'17/02/2022 - Recebido docs' + CHAR(13) + CHAR(10) + 
			'04/02/2022 - Solicitado prorrogação por 5 meses, TR e RAT enviados' + CHAR(13) + CHAR(10) + 
			'27/01/2022 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'27/12/2021 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'22/11/2021 - Recebido docs, juntada efeuada através do E-CAC e DOSSIE' + CHAR(13) + CHAR(10) + 
			'17/11/2021 - Cobrado documentos novamente' + CHAR(13) + CHAR(10) + 
			'20/10/2021 - Solicitado renovação por 3 meses, Numerario e TR enviados, aguardando retorno' + CHAR(13) + CHAR(10) + 
			'27/09/2021 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'23/07/2021 - Docs recebidos, aguardando APOLICE, juntada efetuada através do E-CAC e DOSSIE sem APOLICE, recebido APOLICE, juntada efetuada' + CHAR(13) + CHAR(10) + 
			'06/07/2021 - Solicitado prorrogação por 4 meses, Numerário e TR enviados, aguardando docs' + CHAR(13) + CHAR(10) + 
			'25/06/2021 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'25/05/2021 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'18/01/2021 - Recebido docs, juntada enviada pelo E-CAC' + CHAR(13) + CHAR(10) + 
			'13/01/2021 - Cobrado docs' + CHAR(13) + CHAR(10) + 
			'23/12/2020 - Solicitada prorrogação por 6 meses, Numerario e TR enviados' + CHAR(13) + CHAR(10) + 
			'24/11/2020 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'16/09/2020 - Recebido documentos, Juntada Enviada pelo E-CAC, aguardando parecer da Receita' + CHAR(13) + CHAR(10) + 
			'14/09/2020 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'10/09/2020 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'27/08/2020 - Solicitado prorrogação ate 23/01/2021, TR  e Numerário enviados' + CHAR(13) + CHAR(10) + 
			'24/08/2020 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'20/07/2020 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'15/05/2020 - Juntada enviada' + CHAR(13) + CHAR(10) + 
			'11/05/2020 - Cobrado documentação' + CHAR(13) + CHAR(10) + 
			'18/03/2020 - Cobrado qual procedimennto será adotado' + CHAR(13) + CHAR(10) + 
			'16/01/2020 - Juntada feita pelo E-CAC' + CHAR(13) + CHAR(10) + 
			'07/01/2020 - Cobrado documentação' + CHAR(13) + CHAR(10) + 
			'23/12/2019 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'28/11/2019 - Cobrado qual procedimento a ser adotado. ' + CHAR(13) + CHAR(10) + 
			'16/07/2019 - Juntada protocolada no e-CAC.' + CHAR(13) + CHAR(10) + 
			'05/07/2019 - Recebido documentação para prosseguir com a prorrogação.' + CHAR(13) + CHAR(10) + 
			'24/06/2019 - Cobrado documentação.' + CHAR(13) + CHAR(10) + 
			'06/06/2019 - Enviado numerário, aguardando deposito e documentos para prosseguir com a prorrogação.' + CHAR(13) + CHAR(10) + 
			'03/06/2019 - Recebido a informação que será prorrogado por 6 meses.' + CHAR(13) + CHAR(10) + 
			'30/05/2018 - Cobrado qual procedimento a ser adotado. ' + CHAR(13) + CHAR(10) + 
			'18/01/2019 - Processo enviado para o faturamento.' + CHAR(13) + CHAR(10) + 
			'17/01/2019 - Juntada enviada e aguardando aprovação.' + CHAR(13) + CHAR(10) + 
			'16/01/2019 - Recebida copia autenticada do contrato de serviço.' + CHAR(13) + CHAR(10) + 
			'09/01/2019 - Recebida copia da documentação.' + CHAR(13) + CHAR(10) + 
			'07/01/2019 - Cobrado documentação para prosseguir com a prorrogação. ' + CHAR(13) + CHAR(10) + 
			'03/01/2019 - Cobrado documentação para prosseguir com a prorrogação.' + CHAR(13) + CHAR(10) + 
			'02/01/2019 - Cobrado documentação para prosseguir com a prorrogação.' + CHAR(13) + CHAR(10) + 
			'21/12/2018 - Enviado numerário e TR ao cliente. Agdo retorno.' + CHAR(13) + CHAR(10) + 
			'10/12/2018 - O cliente mudou de ideia, o processo será prorrogado por mais 6 meses.' + CHAR(13) + CHAR(10) + 
			'04/12/2018 - Recebida a informação que o material será reexportado. Enviado e-mail para o setor de exportação para providências. ' + CHAR(13) + CHAR(10) + 
			'03/12/2018 - Enviado numerario para nacionalização de dois itens.' + CHAR(13) + CHAR(10) + 
			'03/12/2018 - Cobrado qual procedimento será adotado.' + CHAR(13) + CHAR(10) + 
			'22/11/2018 - Cobrado qual procedimento será adotado.' + CHAR(13) + CHAR(10) + 
			'26/09/2018- 2ª Prorrogação enviada ao faturamento' + CHAR(13) + CHAR(10) + 
			'26/09/2018 - Agdo aceite de juntada da 1ª prorrogação e 2ª prorrogação ' + CHAR(13) + CHAR(10) + 
			'26/09/2018 - Documentos juntados ao processo. Agdo aceite de juntada' + CHAR(13) + CHAR(10) + 
			'24/09/2018 - Pagamento de darfs e icms' + CHAR(13) + CHAR(10) + 
			'19/09/2018 -Recebemos documentos e numerário' + CHAR(13) + CHAR(10) + 
			'18/09/2018 - Cobrado  envio dos documentos e transferencia do numerario' + CHAR(13) + CHAR(10) + 
			'11/09/2018 - Cobrado  envio dos documentos e transferencia do numerario' + CHAR(13) + CHAR(10) + 
			'31/08/2018 - Enviado numerario e TR assinado. Agdo documentos e envio dos numerários' + CHAR(13) + CHAR(10) + 
			'27/08/2018 - Informado que será prorrogado por 3 meses;' + CHAR(13) + CHAR(10) + 
			'22/08/2018 - Cobrado procedimento será adotado ' + CHAR(13) + CHAR(10) + 
			'17/07/2018 - Prorrogação faturada' + CHAR(13) + CHAR(10) + 
			'11/07/2018- Documentos juntados no processo. Agd aceite de juntada' + CHAR(13) + CHAR(10) + 
			'11/07/2018 - Cobrado vias originais ou autenticadas dos documentos e envio da garantia conforme TR corrigido' + CHAR(13) + CHAR(10) + 
			'10/07/2018 - Cobrado vias originais ou autenticadas dos documentos e envio da garantia conforme TR corrigido' + CHAR(13) + CHAR(10) + 
			'06/07/2018 - Recebido documentos por e-mail' + CHAR(13) + CHAR(10) + 
			'03/07/2018 - Solicitação da seguradora referente aos documentos ' + CHAR(13) + CHAR(10) + 
			'03/07/2018 - Dinheiro do numerário em conta ' + CHAR(13) + CHAR(10) + 
			'21/06/2018 - Enviado Numerário. Agdo transferência do numerário e Documentos' + CHAR(13) + CHAR(10) + 
			'07/05/2019 - Informado que o procedimento a ser adotado será prorrogação por 3 meses' + CHAR(13) + CHAR(10) + 
			'04/05/2018 - Cobrado procedimento a ser adotado ' + CHAR(13) + CHAR(10) + 
			'16/04/2018 - Processo Incluso no Controle' + CHAR(13) + CHAR(10) + 
			'* Considerado o prazo do Contrato de Locação, 7 meses a contar da data de assinatura (Cláusula 06 Contrato), até 11/07/2018.' + CHAR(13) + CHAR(10) + 
			'* Fiscal Concedeu o regime até 19/09/2018, 7 meses a contar do desembaraço.'
		WHEN 19 THEN
			'23/12/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'23/12/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'25/11/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'22/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'22/11/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'14/11/2024 - Numerario enviado ag retorno' + CHAR(13) + CHAR(10) + 
			'12/11/2024 - Soclitiado prorrogaçao por mais 1 mes' + CHAR(13) + CHAR(10) + 
			'30/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'23/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'21/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'14/06/2024 - Enviado numerario, ag retorno' + CHAR(13) + CHAR(10) + 
			'11/06/2024 - Solicitado prorrogação por mais 5 meses' + CHAR(13) + CHAR(10) + 
			'03/06/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'30/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'23/11/2023 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'22/11/2023 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'27/10/2023 - Numerario e RPR foi enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'26/10/2023 - Cobrado novamente, informado que será prorrogado por mais 7 meses' + CHAR(13) + CHAR(10) + 
			'29/09/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'19/09/2023 - Juntada efetuada pelo DOSSIE' + CHAR(13) + CHAR(10) + 
			'18/09/2023 - Recebido docs' + CHAR(13) + CHAR(10) + 
			'05/09/2023 - Enviado Numerario e RPR, ag retorno' + CHAR(13) + CHAR(10) + 
			'30/08/2023 - SOlicitado prorrogação por mais 2 meses' + CHAR(13) + CHAR(10) + 
			'27/07/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'24/07/2023 - Apolice recebida e juntada' + CHAR(13) + CHAR(10) + 
			'21/07/2023 - Juntada efetuada sem apolice' + CHAR(13) + CHAR(10) + 
			'18/07/2023 - Docs recebidos, exceto Apolice' + CHAR(13) + CHAR(10) + 
			'27/06/2023 - Numerario, TR e RPR enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'21/06/2023 - Solicitado prorrogação por 2 meses' + CHAR(13) + CHAR(10) + 
			'01/06/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'24/01/2023 - Juntada efetuada DOSSIE  e E-CAC, Apolice recebida' + CHAR(13) + CHAR(10) + 
			'23/01/2023 - Docs recebidos, exceto APOLICE, juntada efetuada, aguardando APOLICE' + CHAR(13) + CHAR(10) + 
			'10/01/2023 - Informado que será prorrogado por 6 meses, numerario, RPR e TR enviados, aguardando retorno' + CHAR(13) + CHAR(10) + 
			'25/11/2022 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'20/01/2022 - Juntada efetuada no E-CAC e DOSSIE' + CHAR(13) + CHAR(10) + 
			'03/01/2022 - Informado que será prorrogado por 12 meses' + CHAR(13) + CHAR(10) + 
			'28/12/2021 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'23/11/2021 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'23/07/2021 - Docs recebidos, aguardando APOLICE, juntada efetuada através do E-CAC e DOSSIE sem APOLICE, APOLICE recebida, doc juntado' + CHAR(13) + CHAR(10) + 
			'06/07/2021 - Solicitado prorrogação por 6 meses, TR e Numerario enviados' + CHAR(13) + CHAR(10) + 
			'25/06/2021 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'25/05/2021 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'04/05/2021 - Esteiras do guindaste com defeito e foram reexportadas, DI 21/0585528-7 para novas esteiras, acopladas ao guindaste' + CHAR(13) + CHAR(10) + 
			'08/02/2021 - Despacho Decisorio' + CHAR(13) + CHAR(10) + 
			'21/01/2021 - Docs recebidos, juntada feita no E-CAC' + CHAR(13) + CHAR(10) + 
			'13/01/2021 - Cobrado docs' + CHAR(13) + CHAR(10) + 
			'23/12/2020 - Informado que será prorrogado por 6 meses, TR e Numerario enviados' + CHAR(13) + CHAR(10) + 
			'23/11/2020 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'15/09/2020 - Despacho Decisorio' + CHAR(13) + CHAR(10) + 
			'09/09/2020 - E-CAC com erro (antivirus analisando constantemente), documentos feitos pelo SVA, e protocolo fisicamente junto a RECEITA' + CHAR(13) + CHAR(10) + 
			'27/08/2020 - Solicitado prorrogação ate 23/01/2021, TR  e Numerário enviados' + CHAR(13) + CHAR(10) + 
			'17/08/2020 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'10/07/2020 - Cobrado qual procedimento deverá ser adotado' + CHAR(13) + CHAR(10) + 
			'18/06/2020 - Despacho Decisorio' + CHAR(13) + CHAR(10) + 
			'08/06/2020 - Juntada enviada pelo E-CAC' + CHAR(13) + CHAR(10) + 
			'28/05/2020 - TR e Numerario enviados, aguardando documentos' + CHAR(13) + CHAR(10) + 
			'27/05/2020 - Cobrado novamente, será prorrogado por mais 3 meses' + CHAR(13) + CHAR(10) + 
			'09/04/2020 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'29/11/2019 - Juntada protocolada no e-CAC.' + CHAR(13) + CHAR(10) + 
			'25/11/2019 - Recebido a documentação para inicio da prorrogação.' + CHAR(13) + CHAR(10) + 
			'14/11/2019 - Cobrado qual procedimento será adotado.' + CHAR(13) + CHAR(10) + 
			'31/10/2019 - Enviado o numerário e aguardando documentação para inicio da prorrogação.' + CHAR(13) + CHAR(10) + 
			'29/10/2019 - Recebido a informação que será prorrogado por 6 meses.' + CHAR(13) + CHAR(10) + 
			'09/10/2019 - Juntada enviada no e-CAC.' + CHAR(13) + CHAR(10) + 
			'08/10/2019 - Recebido os documentos para inicio da prorrogação.' + CHAR(13) + CHAR(10) + 
			'07/10/2019 - Cobrado documentação para inicio da prorrogação.' + CHAR(13) + CHAR(10) + 
			'02/10/2019 - Cobrado documentação para inicio da prorrogação.' + CHAR(13) + CHAR(10) + 
			'19/09/2019 - Enviando TR e numerario.' + CHAR(13) + CHAR(10) + 
			'13/09/2019 - Inormado que será prorrogado por dois meses.' + CHAR(13) + CHAR(10) + 
			'29/08/2019 - Cobrado qual procedimento será adotado.' + CHAR(13) + CHAR(10) + 
			'24/06/2019 - Processo Incluso no controle'
		WHEN 20 THEN
			'19/12/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'17/12/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'25/11/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'22/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'22/11/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'14/11/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'12/11/2024 - SOlicitado renovaçao por mais 1 mes' + CHAR(13) + CHAR(10) + 
			'30/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'21/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'19/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'14/06/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'11/06/2024 - Solicitado prorrogação por mais 5 meses' + CHAR(13) + CHAR(10) + 
			'03/06/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'30/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'15/01/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'12/01/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'05/01/2024 - RPR e Numerario enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'04/01/2024 - Solicitado prorrogação por mais 5 meses' + CHAR(13) + CHAR(10) + 
			'28/12/2023 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'01/12/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'21/07/2023 - Juntada efetuada pelo DOSSIE' + CHAR(13) + CHAR(10) + 
			'18/07/2023 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'26/06/2023 - Solicitado renovação por 6 meses, numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'01/06/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'19/01/2023 - Juntada efetuada no E-CAC e PORTAL UNICO' + CHAR(13) + CHAR(10) + 
			'11/01/2023 - Recebidos docs' + CHAR(13) + CHAR(10) + 
			'02/01/2023 - Enviado numerario equivalente a 6 meses, aguardando retorno' + CHAR(13) + CHAR(10) + 
			'25/11/2022 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'20/01/2022 - Juntada efetuada através do E-CAC e DOSSIE' + CHAR(13) + CHAR(10) + 
			'03/01/2022 - Informado que será prorrogado por 12 meses' + CHAR(13) + CHAR(10) + 
			'28/12/2021 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'23/11/2021 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'21/07/2021 - Recebido docs, juntada efetuada pelo e E-CAC e DOSSIE' + CHAR(13) + CHAR(10) + 
			'06/07/2021 - Solicitado prorrogação por 6 meses, TR e Numerario enviados' + CHAR(13) + CHAR(10) + 
			'25/06/2021 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'25/05/2021 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'23/04/2021 - Docs recebidos, juntada efetuada pelo E-CAC e DOSSIE' + CHAR(13) + CHAR(10) + 
			'16/04/2021 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'30/03/2021 - Solcitado Prorrogação por 3 meses, Numerario enviado, ag docs' + CHAR(13) + CHAR(10) + 
			'25/03/2021 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'22/02/2021 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'04/02/2021 - Despacho Decisorio' + CHAR(13) + CHAR(10) + 
			'21/01/2021 - Docs recebidos, juntada efetuada no E-CAC' + CHAR(13) + CHAR(10) + 
			'13/01/2021 - Cobrado docs' + CHAR(13) + CHAR(10) + 
			'30/12/2020 - Solicitado prorrogação por mais 3 meses, Numerario enviado' + CHAR(13) + CHAR(10) + 
			'29/12/2020 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'23/11/2020 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'30/09/2020 - Despacho Decisorio' + CHAR(13) + CHAR(10) + 
			'09/09/2020 - Juntada enviada pelo E-CAC' + CHAR(13) + CHAR(10) + 
			'27/08/2020 - Solicitado prorrogação ate 23/01/2021, TR  e Numerário enviados' + CHAR(13) + CHAR(10) + 
			'17/08/2020 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'10/07/2020 - Cobrado qual procedimento deverá ser adotado' + CHAR(13) + CHAR(10) + 
			'16/06/2020 - Despacho Decisorio' + CHAR(13) + CHAR(10) + 
			'08/06/2020 - Juntada enviada pelo E-CAC' + CHAR(13) + CHAR(10) + 
			'28/05/2020 - TR e numerario enviados, aguardando documentos' + CHAR(13) + CHAR(10) + 
			'27/05/2020 - Cobrado novamente, informado que será prorrogado por mais 3 meses' + CHAR(13) + CHAR(10) + 
			'09/04/2020 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'29/11/2019 - Juntada enviada no e-CAC.' + CHAR(13) + CHAR(10) + 
			'25/11/2019 -Recebido os documentos para inicio da prorrogação.' + CHAR(13) + CHAR(10) + 
			'14/11/2019 - Cobrado documentos para inicio da prorrogação.' + CHAR(13) + CHAR(10) + 
			'31/10/2019 - Enviado o numerário e aguardando documentação para inicio da prorrogação.' + CHAR(13) + CHAR(10) + 
			'29/10/2019 - Recebido a informação que será prorrogado por 6 meses.' + CHAR(13) + CHAR(10) + 
			'09/10/2019 - Juntada enviada no e-CAC.' + CHAR(13) + CHAR(10) + 
			'08/10/2019 - Recebido os documentos para inicio da prorrogação.' + CHAR(13) + CHAR(10) + 
			'07/10/2019 - Cobrado documentação para inicio da prorrogação.' + CHAR(13) + CHAR(10) + 
			'02/10/2019 - Cobrado documentação para inicio da prorrogação.' + CHAR(13) + CHAR(10) + 
			'19/09/2019 - Enviando TR e numerario.' + CHAR(13) + CHAR(10) + 
			'13/09/2019 - Inormado que será prorrogado por dois meses.' + CHAR(13) + CHAR(10) + 
			'29/08/2019 - Cobrado qual procedimento será adotado.' + CHAR(13) + CHAR(10) + 
			'16/05/2019 - Processo Incluso no controle'
		WHEN 21 THEN
			'19/12/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'18/12/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'25/11/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'25/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'22/11/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'14/11/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'11/11/2024 - Solicitado prorrogaçao por mais 1 mes' + CHAR(13) + CHAR(10) + 
			'30/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'21/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'19/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'14/06/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'11/06/2024 - Soclitiado prorrogação por mais 5 meses' + CHAR(13) + CHAR(10) + 
			'03/06/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'30/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'22/03/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'14/03/2024 - Docs recedibos' + CHAR(13) + CHAR(10) + 
			'11/03/2024 - Informado que será prorrogado por mais 3 meses, numerario, RPR e TR enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'01/03/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'25/01/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'20/10/2023 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'18/10/2023 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'06/10/2023 - TR, RPR e Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'03/10/2023 - Informado que será prorrogado por mais 5 meses' + CHAR(13) + CHAR(10) + 
			'29/09/2023 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'30/08/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'21/07/2023 - Juntada efetuada através do DOSSIE' + CHAR(13) + CHAR(10) + 
			'19/07/2023 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'27/06/2023 - Numerario, TR e RPR enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'22/06/2023 - Solicitado prorrogação por 3 meses' + CHAR(13) + CHAR(10) + 
			'01/06/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'19/01/2023 - Juntada efetuada através do DOSSIÊ' + CHAR(13) + CHAR(10) + 
			'12/01/2023 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'02/01/2023 - Enviado Numerario, RPR e TR equivalente a 6 meses, aguardando retorno' + CHAR(13) + CHAR(10) + 
			'25/11/2022 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'21/01/2022 - Juntada anexada ao DOSSIE' + CHAR(13) + CHAR(10) + 
			'03/01/2022 - Informado que será renovado por 12 meses' + CHAR(13) + CHAR(10) + 
			'28/12/2021 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'23/11/2021 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'29/10/2021 - Processo incluido no controle'
		WHEN 22 THEN
			'23/12/2024 - Juntada efetuada, docs recebidos' + CHAR(13) + CHAR(10) + 
			'29/11/2024 - Enviado numerario, ag retorno' + CHAR(13) + CHAR(10) + 
			'27/11/2024 - Solicitado prorrogaçao por mais 4 meses' + CHAR(13) + CHAR(10) + 
			'27/11/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'25/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'22/11/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'14/11/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'12/11/2024 - Solicitado prorrogaçao por mais 1 mes' + CHAR(13) + CHAR(10) + 
			'30/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'25/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'25/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'17/06/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'11/06/2024 - Prorrogaçao por mais 5 meses' + CHAR(13) + CHAR(10) + 
			'03/06/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'30/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'08/04/2024 - Processo incluído no controle'
		WHEN 23 THEN
			'26/12/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'23/12/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'28/10/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'27/09/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'27/09/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'09/09/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'05/08/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'28/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'27/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'14/06/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'13/06/2024 - Solicitado prorrogação por mais 3 meses' + CHAR(13) + CHAR(10) + 
			'03/06/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'30/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'27/12/2023 - Juntada efetuada.' + CHAR(13) + CHAR(10) + 
			'30/11/2023 - Numerario e RPR enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'22/11/2023 - Informado que será prorrogado por mais 6 meses' + CHAR(13) + CHAR(10) + 
			'30/10/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'27/06/2023 - Juntada efetuada através do DOSSIE' + CHAR(13) + CHAR(10) + 
			'27/06/2023 - Doctos recebidos' + CHAR(13) + CHAR(10) + 
			'01/06/2023 - Solicitado prorrogação por 6 meses, TR, RAT  e Numerario enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'26/04/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'28/07/2022 - Processo incluido no controle'
			WHEN 24 THEN
			'26/12/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'23/12/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'28/10/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'27/09/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'27/09/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'09/09/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'05/08/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'28/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'27/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'17/06/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'13/06/2024 - Prorrogação por mais 3 meses' + CHAR(13) + CHAR(10) + 
			'30/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'26/12/2023 - Juntada efetuada.' + CHAR(13) + CHAR(10) + 
			'30/11/2023 - Numerario e RPR enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'22/11/2023 - Solicitado prorrogação por mais 6 meses' + CHAR(13) + CHAR(10) + 
			'30/10/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'27/06/2023 - Juntada efetuada através do DOSSIE' + CHAR(13) + CHAR(10) + 
			'26/06/2023 - Documentação recebida' + CHAR(13) + CHAR(10) + 
			'01/06/2023 - Solicitado prorrogação por 6 meses, Numerario, TR e RAT enviados, aguardando retorno' + CHAR(13) + CHAR(10) + 
			'26/04/2023 - Cobrado procediment a ser adotado' + CHAR(13) + CHAR(10) + 
			'28/07/2022 - Processo incluido no controle'
		WHEN 25 THEN
			'26/12/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'23/12/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'28/10/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'27/09/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'27/09/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'09/09/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'05/08/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'28/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'27/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'14/06/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'13/06/2024 - Solicitado prorrogação por mais 3 meses' + CHAR(13) + CHAR(10) + 
			'30/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'26/12/2023 - Juntada efetuada.' + CHAR(13) + CHAR(10) + 
			'22/11/2023 - Informado que será prorrogado por mais 6 meses, Numerario e RPR enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'30/10/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'28/06/2023 - Juntada efetuada através do DOSSIE' + CHAR(13) + CHAR(10) + 
			'28/06/2023 - Recebido documentos' + CHAR(13) + CHAR(10) + 
			'27/06/2023 - Cobrado retorno' + CHAR(13) + CHAR(10) + 
			'01/06/2023 - Solicitado prorrogação por 6 meses, Numerario, TR e RAT enviados, aguardando retorno' + CHAR(13) + CHAR(10) + 
			'26/04/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'28/07/2022 - Processo incluido no controle'
		WHEN 26 THEN
			'26/12/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'23/12/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'08/11/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'28/09/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'27/09/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'09/09/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'05/08/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'28/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'27/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'14/06/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'13/06/2024 - Solicitado prorrogação por mais 3 meses' + CHAR(13) + CHAR(10) + 
			'30/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'28/12/2023 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'22/12/2023 - Recebido docs' + CHAR(13) + CHAR(10) + 
			'30/11/2023 - Numerario e RPR enviados, ag retorno[' + CHAR(13) + CHAR(10) + 
			'22/11/2023 - Solicitado prorrogaçção por mais 6 meses' + CHAR(13) + CHAR(10) + 
			'30/10/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'03/07/2023 - Juntada efetuada através do DOSSIE, Apolice recebida em 30/06 a noite' + CHAR(13) + CHAR(10) + 
			'28/06/2023 - Docs recebidos, exceto APOLICE. Anexado ao DOSSIE o que foi recebido' + CHAR(13) + CHAR(10) + 
			'27/06/2023 - Cobrado retorno' + CHAR(13) + CHAR(10) + 
			'01/06/2023 - Solicitado prorrogação por 6 meses, Numerario, TR e RAT enviados, aguardando retorno' + CHAR(13) + CHAR(10) + 
			'26/04/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'28/07/2022 - Processo incluido no controle'
		WHEN 27 THEN
			'15/05/2024 - Processo incluído no controle'
		WHEN 28 THEN
			'10/12/2024 - Despacho' + CHAR(13) + CHAR(10) + 
			'04/12/2024 - Juntada efetuda' + CHAR(13) + CHAR(10) + 
			'25/11/2024 - Solicitado prorrogaçao por mais 6 meses, ag retorno' + CHAR(13) + CHAR(10) + 
			'18/11/2024 - Despacho' + CHAR(13) + CHAR(10) + 
			'13/11/2024 - Intimaçao' + CHAR(13) + CHAR(10) + 
			'06/11/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'01/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'30/10/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'18/10/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'17/10/2024 - Solicitado renovaçao por mais 1 mes' + CHAR(13) + CHAR(10) + 
			'14/10/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'09/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'04/07/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'02/07/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'25/06/2024 - Solicitado prorrogaçao por mais 4 meses, numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'10/06/2024 - Cobrado procedimento' + CHAR(13) + CHAR(10) + 
			'05/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'29/05/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'24/05/2024 - Enviado Numerario e RPR, ag retorno' + CHAR(13) + CHAR(10) + 
			'21/05/2024 - Solicitadoprorrogação por mais 1 mes' + CHAR(13) + CHAR(10) + 
			'08/05/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'05/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'04/01/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'03/01/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'08/11/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'14/07/2023 - Despacho decisorio' + CHAR(13) + CHAR(10) + 
			'03/07/2023 - Juntada efetuada através do DOSSIÊ' + CHAR(13) + CHAR(10) + 
			'28/06/2023 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'20/06/2023 - Numerario e TR enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'19/06/2023 - Informado que será prorrogado por 6 meses' + CHAR(13) + CHAR(10) + 
			'09/05/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'21/03/2023 - Despacho Decisorio' + CHAR(13) + CHAR(10) + 
			'01/03/2023 - Juntada efetuada atravé do DOSSIE' + CHAR(13) + CHAR(10) + 
			'28/02/2023 - Cobrado retorno, recebido documentação' + CHAR(13) + CHAR(10) + 
			'08/02/2023 - Solicitado prorrogação, enviado numerário, aguardando retorno' + CHAR(13) + CHAR(10) + 
			'10/01/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'22/03/2022 - Despacho Decisorio' + CHAR(13) + CHAR(10) + 
			'16/02/2022 - Juntada anexada através do DOSSIE' + CHAR(13) + CHAR(10) + 
			'08/02/2022 - Solicitado prorrogação por 12 meses, solicitação de numerário enviada, ag retorno' + CHAR(13) + CHAR(10) + 
			'05/01/2022 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'14/09/2021 - Despacho Decisorio' + CHAR(13) + CHAR(10) + 
			'30/08/2021 - Docs recebidos, docs anexados ao DOSSIE' + CHAR(13) + CHAR(10) + 
			'06/08/2021 - Solicitado renovação por 6 meses, enviado numerário, ag docs' + CHAR(13) + CHAR(10) + 
			'13/07/2021 Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'11/05/2021 - Processo incluído no controle'
		WHEN 29 THEN
			'10/12/2024 - Despacho' + CHAR(13) + CHAR(10) + 
			'04/12/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'25/11/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'22/11/2024 - Cobrado renovaçao por mais 6 meses' + CHAR(13) + CHAR(10) + 
			'18/11/2024 - Despacho' + CHAR(13) + CHAR(10) + 
			'14/11/2024 - Intimaçao' + CHAR(13) + CHAR(10) + 
			'06/11/2024 - Initmaçao' + CHAR(13) + CHAR(10) + 
			'06/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'30/10/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'18/10/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'17/10/2024 - Solciitado prorrogaçao por mais 1 mes' + CHAR(13) + CHAR(10) + 
			'14/10/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'09/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'08/07/2024 - Despacho decisorio' + CHAR(13) + CHAR(10) + 
			'05/07/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'02/07/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'25/06/2024 - Solicitado prorrogação por mais 4 meses, numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'08/05/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'05/02/2024 - Juntada efetuada, despacho decisorio' + CHAR(13) + CHAR(10) + 
			'30/01/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'19/01/2024 - RPR e Numerario enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'17/01/2024 - Solicitado prorrogação por mais 5 meses' + CHAR(13) + CHAR(10) + 
			'15/01/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'01/12/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'18/08/2023 - Despacho Decisorio' + CHAR(13) + CHAR(10) + 
			'03/08/2023 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'26/07/2023 - Recebido docs' + CHAR(13) + CHAR(10) + 
			'10/07/2023 - Enviado numerario, ag retorno' + CHAR(13) + CHAR(10) + 
			'04/07/2023 - Informado que será prorrogado por 6 meses' + CHAR(13) + CHAR(10) + 
			'15/06/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'17/02/2023 - Intimação respondida, Despacho Decisorio' + CHAR(13) + CHAR(10) + 
			'10/02/2023 - Intimação' + CHAR(13) + CHAR(10) + 
			'31/01/2023 - Juntada efetuada no ECAC e DOSSIE' + CHAR(13) + CHAR(10) + 
			'19/01/2023 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'02/01/2022 - Informado que será renovado por 6 meses, Numerário enviado, aguardando retorno' + CHAR(13) + CHAR(10) + 
			'07/12/2022 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'09/02/2022 - Despacho Decisorio' + CHAR(13) + CHAR(10) + 
			'03/02/2022 - Juntada efetuada pelo E-CAC e DOSSIE' + CHAR(13) + CHAR(10) + 
			'01/02/2022 - Recebido documentação' + CHAR(13) + CHAR(10) + 
			'19/01/2022 - Cobrado procedimento a ser adotado, solicitado prorrogação por 12 meses, numerário enviado, aguardando retorno' + CHAR(13) + CHAR(10) + 
			'16/08/2021 - Despacho Decisorio' + CHAR(13) + CHAR(10) + 
			'05/08/2021 -Docs recebidos, Juntada efetuada pelo E-CAC e DOSSIE' + CHAR(13) + CHAR(10) + 
			'15/07/2021 - Solicitado prorrogação por 6 meses, solicitação de Numerario enviado, aguardando retorno' + CHAR(13) + CHAR(10) + 
			'07/06/2021 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'08/02/2021 - Despacho Decisorio' + CHAR(13) + CHAR(10) + 
			'03/02/2021 - Docs recebidos, juntada efetuada pelo E-CAC' + CHAR(13) + CHAR(10) + 
			'01/02/2021 - Cobrado docs' + CHAR(13) + CHAR(10) + 
			'30/12/2020 - Solicitado prorrogação por 6 meses, Numerario enviado' + CHAR(13) + CHAR(10) + 
			'07/12/2020 - Cobrado procedimento' + CHAR(13) + CHAR(10) + 
			'10/09/2020 - Despacho Decisorio' + CHAR(13) + CHAR(10) + 
			'03/09/2020 - Juntada enviada pelo E-CAC' + CHAR(13) + CHAR(10) + 
			'31/08/2020 - Cobrado documentos' + CHAR(13) + CHAR(10) + 
			'12/08/2020 - Solicitado prorrogação de 5 meses, TR e Numerário enviados, aguardando Transferencia e documentos.' + CHAR(13) + CHAR(10) + 
			'08/07/2020 - Cobrado qual procedimento deverá ser adotado' + CHAR(13) + CHAR(10) + 
			'09/06/2020 - Depacho Decisorio' + CHAR(13) + CHAR(10) + 
			'04/06/2020 - Protocolo da Juntada Enviada' + CHAR(13) + CHAR(10) + 
			'01/06/2020 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'28/05/2020 - TR e Numerario enviados, aguardando documentação' + CHAR(13) + CHAR(10) + 
			'27/05/2020 - Cobrado novamente, informado que será prorrogado por mais 3 meses' + CHAR(13) + CHAR(10) + 
			'06/04/2020 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'09/12/2019 - Despacho decisório' + CHAR(13) + CHAR(10) + 
			'29/11/2019 - Juntada enviada no e-CAC. ' + CHAR(13) + CHAR(10) + 
			'25/11/2019 - Cobrado docutamação para inicio da prorrogação.' + CHAR(13) + CHAR(10) + 
			'14/11/2019 - Cobrado qual procedimento será adotado.' + CHAR(13) + CHAR(10) + 
			'31/10/2019 - Enviado o numerário e aguardando documentação para inicio da prorrogação.' + CHAR(13) + CHAR(10) + 
			'29/10/2019 - Recebido a informação que será prorrogado por 6 meses.' + CHAR(13) + CHAR(10) + 
			'19/07/2019 - Processo Incluso no controle'
		WHEN 30 THEN
			'23/05/2024 - Processo incluído no controle'
		WHEN 31 THEN
			'21/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'21/11/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'07/11/2024 - Informado que será prorrogado por mais 6 meses, ag retorno' + CHAR(13) + CHAR(10) + 
			'30/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'20/09/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'20/09/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'16/09/2024 - Solicitado prorrogaçao por mais 2 meses, RPR enivado, ag retorno' + CHAR(13) + CHAR(10) + 
			'09/09/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'25/07/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'19/07/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'19/07/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'17/07/2024 - RPR enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'16/07/2024 - Solicitado prorrogaçao por mais 2 meses' + CHAR(13) + CHAR(10) + 
			'05/07/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'03/06/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'19/01/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'17/01/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'05/01/2024 - RPR enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'04/01/2024 - Solicitado prorrogação por mais 6 meses' + CHAR(13) + CHAR(10) + 
			'28/12/2023 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'21/11/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'20/10/2023 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'19/10/2023 - Recebido Aditivo' + CHAR(13) + CHAR(10) + 
			'11/10/2023 - RPR enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'10/10/2023 - Informado que será renovado por 3 meses' + CHAR(13) + CHAR(10) + 
			'29/09/2023 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'21/08/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'08/03/2023 - Processo incluido no controle'
		WHEN 32 THEN
			'29/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'28/11/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'25/11/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'21/11/2024 - Solicitado prorrogaçao por mais 6 meses' + CHAR(13) + CHAR(10) + 
			'30/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'28/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'27/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'17/06/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'13/06/2024 - Porrogação por mais 5 meses' + CHAR(13) + CHAR(10) + 
			'30/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'29/12/2023 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'22/12/2023 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'01/12/2023 - Enviado RPR e Numerario, ag retorno' + CHAR(13) + CHAR(10) + 
			'22/11/2023 - Solicitado prorrogação por mais 6 meses' + CHAR(13) + CHAR(10) + 
			'30/10/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'28/06/2023 - Juntada efetuada pelo DOSSIE' + CHAR(13) + CHAR(10) + 
			'15/06/2023 - Enviado documentação' + CHAR(13) + CHAR(10) + 
			'01/06/2023 - Solicitado prorrogação por 6 meses, Numerario enviado, aguardando retorno' + CHAR(13) + CHAR(10) + 
			'26/04/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'28/07/2022 - Processo incluido no controle'
		WHEN 33 THEN
			'03/12/2024 - Juntada efetuda' + CHAR(13) + CHAR(10) + 
			'25/11/2024 - Solicitado prorrogacao por mais 6 meses, numerario enviado ag retorno' + CHAR(13) + CHAR(10) + 
			'06/11/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'04/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'29/10/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'18/10/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'17/10/2024 - Solicitado prorrogaçao por mais 1 mes' + CHAR(13) + CHAR(10) + 
			'09/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'05/07/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'05/07/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'25/06/2024 - Solicitado prorrogação por mais 4 meses, numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'10/06/2024 - Cobrado procedimento' + CHAR(13) + CHAR(10) + 
			'06/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'05/05/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'27/05/2024 - Solicitado renovação por mais 1 nes, ag retorno' + CHAR(13) + CHAR(10) + 
			'08/05/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'15/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'05/01/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'05/01/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'08/11/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'06/07/2023 - Juntada efetuada através do DOSSIE' + CHAR(13) + CHAR(10) + 
			'27/06/2023 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'19/06/2023 - Informado que será prorrogado por 6 meses, Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'09/05/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'05/04/2023 - Juntada efetuada pelo DOSSIE' + CHAR(13) + CHAR(10) + 
			'04/04/2023 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'15/03/2023 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'14/03/2023 - Cobrado novamente, informado que será prorrogado por mais 3 meses' + CHAR(13) + CHAR(10) + 
			'08/02/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'06/04/2022 - Juntada anexada ao DOSSIE' + CHAR(13) + CHAR(10) + 
			'31/03/2022 - Cobrado documentos novamente' + CHAR(13) + CHAR(10) + 
			'14/03/2022 - Solicitado renovação por 12 meses, numerário enviado' + CHAR(13) + CHAR(10) + 
			'09/03/2022 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'04/02/2022 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'29/10/2021 - Processo incluido no controle'
		WHEN 34 THEN
			'10/12/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'03/12/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'25/11/2024 - Solicitado prorrogaçao por mais 6 meses, numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'18/11/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'11/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'11/11/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'22/10/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'21/10/2024 - Solciitado prorrogaçao por mais 1 mes' + CHAR(13) + CHAR(10) + 
			'14/10/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'30/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'11/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'07/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'29/05/2024 - Solicitado prorrogação por mais 1 mes, ag retorno' + CHAR(13) + CHAR(10) + 
			'15/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'11/01/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'09/01/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'04/01/2024 - Numerario e RPR enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'03/01/2024 - Informado que será prorrogado por mais 4 meses' + CHAR(13) + CHAR(10) + 
			'28/12/2023 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'21/11/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'10/07/2023 - Juntada efetuada através do DOSSIE' + CHAR(13) + CHAR(10) + 
			'07/07/2023 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'20/06/2023 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'19/06/2023 - Informado que será prorrogado por 6 meses' + CHAR(13) + CHAR(10) + 
			'18/05/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'06/04/2023 - Juntada efetuada no DOSSIE' + CHAR(13) + CHAR(10) + 
			'04/04/2023 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'15/03/2023 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'14/03/2023 - Cobrado novamente, Informado que será prorrogado por 3 meses' + CHAR(13) + CHAR(10) + 
			'16/02/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'11/04/2022 - Juntada anexada ao DOSSIE' + CHAR(13) + CHAR(10) + 
			'07/04/2022 - Informado que será prorrogado por 12 meses, numerário enviado, aguardando retorno' + CHAR(13) + CHAR(10) + 
			'28/03/2022 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'14/02/2022 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'13/10/2021 - Recebido documentos, e anexados ao DOSSIE' + CHAR(13) + CHAR(10) + 
			'05/10/2021 - Cobrado novamente, solicitado prorrogação por 6 meses, Numerario enviado, aguardando retorno' + CHAR(13) + CHAR(10) + 
			'27/09/2021 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'16/08/2021 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'26/04/2021 - Processo incluido no controle'
		WHEN 35 THEN
			'17/12/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'16/12/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'29/11/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'28/11/2024 - Solicitado prorrogaçao por mais 6 meses' + CHAR(13) + CHAR(10) + 
			'25/11/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'21/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'21/11/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'14/11/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'12/11/2024 - Solicitado prorrogaçao por mais 1 mes' + CHAR(13) + CHAR(10) + 
			'30/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'21/08/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'12/08/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'07/08/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'05/08/2024 - Solicitado prorrogação por mais 3 meses' + CHAR(13) + CHAR(10) + 
			'25/06/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'21/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'19/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'17/06/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'11/06/2024 - Prorrogação por mais 2 meses' + CHAR(13) + CHAR(10) + 
			'03/06/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'30/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'22/12/2023 - Juntada efetuada.' + CHAR(13) + CHAR(10) + 
			'01/12/2023 - RPR e Numerario enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'22/11/2023 - Solicitado renovação por mais 6 meses' + CHAR(13) + CHAR(10) + 
			'26/10/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'21/06/2023 - Juntada efetuada através do DOSSIE' + CHAR(13) + CHAR(10) + 
			'21/06/2023 - Recebido Apolice' + CHAR(13) + CHAR(10) + 
			'16/06/2023 - Recbido documentação exceto Apolice' + CHAR(13) + CHAR(10) + 
			'02/06/2023 - Solicitado prorrogação por 6 meses, TR, RPR e Numerário enviados, agr retorno' + CHAR(13) + CHAR(10) + 
			'01/06/2023 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'03/05/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'22/09/2022 - Processo incluido no controle'
		WHEN 36 THEN
			'18/12/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'17/12/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'29/11/2024 - Enviado numerario, ag retorno' + CHAR(13) + CHAR(10) + 
			'28/11/2024 - Solicitado prorrogaçao por mais 6 meses' + CHAR(13) + CHAR(10) + 
			'25/11/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'22/11/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'22/11/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'14/11/2024 - Numerairo enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'12/11/2024 - Solicitado prorrogaçao por mais 1 mes' + CHAR(13) + CHAR(10) + 
			'30/09/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'22/08/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'12/08/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'07/08/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'05/08/2024 - Solicitado prorrogação por mais 3 meses' + CHAR(13) + CHAR(10) + 
			'25/06/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'21/06/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'19/06/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'17/06/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'11/06/2024 - Prorrogaçao por mais 2 meses' + CHAR(13) + CHAR(10) + 
			'03/06/2024 - Cobrado novamente' + CHAR(13) + CHAR(10) + 
			'30/04/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'21/09/2023 - Juntada efetuada pelo DOSSIE' + CHAR(13) + CHAR(10) + 
			'21/09/2023 - Recebido docs' + CHAR(13) + CHAR(10) + 
			'31/07/2023 - Enviado numerario, TR e RPR., ag retorno' + CHAR(13) + CHAR(10) + 
			'26/07/2023 - Informado que sera prorrogado por mais 12 meses' + CHAR(13) + CHAR(10) + 
			'26/06/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'04/10/2022 - Processo incluido no controle'
		WHEN 37 THEN
			'29/10/2024 - Processo incluído no controle'
		WHEN 38 THEN
			'21/08/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'21/08/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'01/07/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'26/06/2024 - Solicitado prorrogação por mais 12 meses' + CHAR(13) + CHAR(10) + 
			'25/06/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'06/10/2023 - Processo incluido no controle'
		WHEN 39 THEN
			'23/09/2024 - Processo incluído no controle'
		WHEN 40 THEN
			'29/11/2024 - Processo incluído no controle'
		WHEN 41 THEN
			'18/09/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'16/09/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'02/09/2024 - Numerario, RPR e TR enviados, ag retorno' + CHAR(13) + CHAR(10) + 
			'15/08/2024 - Solicitado prorrogaçao por mais 12 meses' + CHAR(13) + CHAR(10) + 
			'14/08/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'19/10/2023 - Processo incluido no controle'
		WHEN 42 THEN
			'21/10/2024 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'15/10/2024 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'02/09/2024 - Numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'22/08/2024 - Solicitado prorrogaçao por mais 12 meses' + CHAR(13) + CHAR(10) + 
			'22/08/2024 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'29/12/2023 - Processo incluido no controle'
		WHEN 43 THEN
			'03/11/2021 - Processo incluido no controle'
		WHEN 44 THEN
			'31/01/2022 - Despacho Decisorio' + CHAR(13) + CHAR(10) + 
			'24/01/2022 - Juntada efetuada ao DOSSIE e E-CAC' + CHAR(13) + CHAR(10) + 
			'24/01/2022 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'11/01/2022 - Solicitado prorrogação por 48 meses (4 anos), aguardando retorno dos documentos' + CHAR(13) + CHAR(10) + 
			'13/12/2021 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'13/08/2021 - Despacho de encaminhamento' + CHAR(13) + CHAR(10) + 
			'22/02/2018 - Recebido Despacho Decisório - Venc. 09/02/2022' + CHAR(13) + CHAR(10) + 
			'20/02/2018 - Processo Incluso no controle'
		WHEN 45 THEN
			'30/09/2024 - Processo incluído no controle'
		WHEN 46 THEN
			'25/06/2024 - Processo incluído no controle'
		WHEN 47 THEN
			'06/10/2023 - Processo incluido no controle'
		WHEN 48 THEN
			'06/10/2023 - Processo incluido no controle'
		WHEN 49 THEN
			'03/04/2023 - Despacho Decisorio' + CHAR(13) + CHAR(10) + 
			'29/03/2023 - Juntada efetuada no E-CAC' + CHAR(13) + CHAR(10) + 
			'07/03/2023 - Documentação recebida' + CHAR(13) + CHAR(10) + 
			'02/03/2023 - Informado que sera prorrogado por 52 meses, ag documentos, numerario revisado enviado' + CHAR(13) + CHAR(10) + 
			'10/02/2023 - Informado que será prorrogado por 40 meses, numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'08/02/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'15/03/2021 - Despacho' + CHAR(13) + CHAR(10) + 
			'10/03/2021 - Juntada feita pelo E-CAC' + CHAR(13) + CHAR(10) + 
			'17/02/2021 - Solicitado prorrogação por mais 24 meses, enviado Numerario, ag docs' + CHAR(13) + CHAR(10) + 
			'08/02/2021 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'08/08/2019 - Nova Concessão de Adm. Temporária_Venc. 08/04/2021.' + CHAR(13) + CHAR(10) + 
			'06/06/2019 - Processo de admissão temporaria em andamento.' + CHAR(13) + CHAR(10) + 
			'01/04/2019 - recebido copia da documentação para uma nova admissão temporaria.' + CHAR(13) + CHAR(10) + 
			'18/01/2019 - COMUNICADO - CIÊNCIA ELETRÔNICA POR DECURSO DE PRAZO.' + CHAR(13) + CHAR(10) + 
			'27/12/2018 - Processo deferido. Venc 14/05/2019 - PROCESSO JÁ ATINGIU OS 100 MESES.' + CHAR(13) + CHAR(10) + 
			'26/12/2018- 6ª Prorrogação enviada para o faturamento' + CHAR(13) + CHAR(10) + 
			'21/12/2018 - Juntada Aceita.' + CHAR(13) + CHAR(10) + 
			'20/12/2018 - Enviado pelo e-CAC o pedido de prorrogação.' + CHAR(13) + CHAR(10) + 
			'17/12/2018 - Recebido o 6º aditivo e contrato de prestação original.' + CHAR(13) + CHAR(10) + 
			'29/11/2018 - Enviada solicitação de numerario, aguardando documentação para prosseguir com a prorrogação por 4 meses.' + CHAR(13) + CHAR(10) + 
			'23/11/2018 - Informado que pode ser prorrogado por 4 meses, aguardando documentação para prosseguir com a pororrogação.' + CHAR(13) + CHAR(10) + 
			'22/11/2018 - Cobrado qual procedimento será adotado.' + CHAR(13) + CHAR(10) + 
			'14/11/2018 - Cobrado qual procedimento será adotado.' + CHAR(13) + CHAR(10) + 
			'26/12/2017 - Deferido pedido de Prorrogação - Venc.14/01/2019                                                     22/12/2017 - Recebido Aceite da Juntada - Ag. Analise da RFB' + CHAR(13) + CHAR(10) + 
			'22/12/2017 - Protocolado Pedido de Prorrogação - Ag. Aceite da Juntada' + CHAR(13) + CHAR(10) + 
			'25/02/16 - Recebido protocolo do pleito e deferimento' + CHAR(13) + CHAR(10) + 
			'22/01 - Protocolado pedido de prorrogação' + CHAR(13) + CHAR(10) + 
			'02/09 - Despacho decisório recebido' + CHAR(13) + CHAR(10) + 
			'22/01/2014 - Protocolado pedido de prorrogação, aguardando analise / deferimento do pedido;' + CHAR(13) + CHAR(10) + 
			'04/02- Despacho decisório recebido' + CHAR(13) + CHAR(10) + 
			'23/01/2014 - Protocolado pedido de prorrogação, aguardando analise / deferimento do pedido;' + CHAR(13) + CHAR(10) + 
			'13/02 - Deferido pedido de prorrogação;' + CHAR(13) + CHAR(10) + 
			'19/01 - Protocolado pedido de prorrogação, aguardando analise / deferimento do pedido;' + CHAR(13) + CHAR(10) + 
			'18/01 - Enviado pedido prorrogação ao EADI Santo André (Trovão);' + CHAR(13) + CHAR(10) + 
			'12/01 - Recebemos aditivo contratual, providenciando envio do pedido de prorrogação à Inspetoria;' + CHAR(13) + CHAR(10) + 
			'05/01 - Confirmada a remessa de numerario, providenciando pagamento dos DARFs;' + CHAR(13) + CHAR(10) + 
			'27/12 - Enviada solicitação de numerario' + CHAR(13) + CHAR(10) + 
			'15/11 - Confirmada prorrogação por 12 meses, providenciando calculo do processo;' + CHAR(13) + CHAR(10) + 
			'04/11 - Questionado a MEGASIL quanto ao procedimento a ser adotado para o processo;' + CHAR(13) + CHAR(10) + 
			'05/04/2011 - Prazo correto Concedido pela RFB  até 13/02/2012' + CHAR(13) + CHAR(10) + 
			'15/03/2011 - Prazo da Admissão concedido pela RFB  menor que o do Contrato  , estamos verificando como reverter junto a RFB de Santo Andre ' + CHAR(13) + CHAR(10) + 
			'09/02/2011 - DI registrada, aguardando desembaraço'
		WHEN 50 THEN
			'25/04/2023 - Despacho Decisorio' + CHAR(13) + CHAR(10) + 
			'14/04/2023 - Resposta a intimação' + CHAR(13) + CHAR(10) + 
			'11/04/2023 - Intimação' + CHAR(13) + CHAR(10) + 
			'28/03/2023 - Juntada efetuada pelo E-CAC' + CHAR(13) + CHAR(10) + 
			'07/03/2023 - Recebido documentos' + CHAR(13) + CHAR(10) + 
			'02/03/2023 - Informado que sera prorrogado por 52 meses, ag documentos, numerario revisado enviado' + CHAR(13) + CHAR(10) + 
			'10/02/2023 - Informado que será prorrogado por 40 meses, numerario enviado, ag retorno' + CHAR(13) + CHAR(10) + 
			'08/02/2023 - Cobrado procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'15/03/2021 - Despacho Decisorio' + CHAR(13) + CHAR(10) + 
			'10/03/2021 - Juntada efetuada no E-CAC' + CHAR(13) + CHAR(10) + 
			'17/02/2021 - Solicitado prorrogação por mais 24 meses, enviado Numerario, ag docs' + CHAR(13) + CHAR(10) + 
			'08/02/2021 - Cobrado Procedimento a ser adotado' + CHAR(13) + CHAR(10) + 
			'08/08/2019 - Nova Concessão de Adm. Temporária_Venc. 08/04/2021.' + CHAR(13) + CHAR(10) + 
			'06/06/2019 - Processo de admissão temporaria em andamento.' + CHAR(13) + CHAR(10) + 
			'01/04/2019 - recebido copia da documentação para uma nova admissão temporaria.' + CHAR(13) + CHAR(10) + 
			'27/12/2018 - Processo deferido. Venc 14/05/2019. PROCESSO JÁ ATINGIU OS 100 MESES.' + CHAR(13) + CHAR(10) + 
			'26/12/2018- 6ª Prorrogação enviada para o faturamento' + CHAR(13) + CHAR(10) + 
			'20/12/2018 - Juntada aceita.' + CHAR(13) + CHAR(10) + 
			'20/12/2018 - Enviado pelo e-CAC o pedido de prorrogação.' + CHAR(13) + CHAR(10) + 
			'17/12/2018 - Recebido o 6º aditivo e contrato de prestação original.' + CHAR(13) + CHAR(10) + 
			'29/11/2018 - Enviada solicitação de numerario, aguardando documentação para prosseguir com a prorrogação por 4 meses.' + CHAR(13) + CHAR(10) + 
			'23/11/2018 - Informado que pode ser prorrogado por 4 meses, aguardando documentação para prosseguir com a pororrogação.' + CHAR(13) + CHAR(10) + 
			'22/11/2018 - Cobrado qual procedimento será adotado.' + CHAR(13) + CHAR(10) + 
			'14/11/2018 - Cobrado qual procedimento será adotado. Recebido os modelos de contrato.' + CHAR(13) + CHAR(10) + 
			'26/12/2017 - Deferido pedido de Prorrogação - Venc.14/01/2019                                                   22/12/2017 - Recebido Aceite da Juntada - Ag. Analise da RFB' + CHAR(13) + CHAR(10) + 
			'22/12/2017 - Protocolado Pedido de Prorrogação - Ag. Aceite da Juntada' + CHAR(13) + CHAR(10) + 
			'25/02/16 - Despacho decisório recebido' + CHAR(13) + CHAR(10) + 
			'11/02/2016 - Recebido descho decisório de deferimento pleito prorrogação' + CHAR(13) + CHAR(10) + 
			'12/01/2016 - Protocolado pedido de prorrogação' + CHAR(13) + CHAR(10) + 
			'11/09 - Despacho decisório recebido' + CHAR(13) + CHAR(10) + 
			'05/02/2014 - Protocolado pedido de prorrogação, aguardando analise / deferimento do pedido;' + CHAR(13) + CHAR(10) + 
			'13/02 - Deferido pedido de prorrogação;' + CHAR(13) + CHAR(10) + 
			'19/01 - Protocolado pedido de prorrogação, aguardando analise / deferimento do pedido;' + CHAR(13) + CHAR(10) + 
			'18/01 - Enviado pedido prorrogação ao EADI Santo André (Trovão);' + CHAR(13) + CHAR(10) + 
			'12/01 - Recebemos aditivo contratual, providenciando envio do pedido de prorrogação à Inspetoria;' + CHAR(13) + CHAR(10) + 
			'05/01 - Confirmada a remessa de numerario, providenciando pagamento dos DARFs;' + CHAR(13) + CHAR(10) + 
			'27/12 - Enviada solicitação de numerario;' + CHAR(13) + CHAR(10) + 
			'15/11 - Confirmada prorrogação por 12 meses, providenciando calculo do processo;' + CHAR(13) + CHAR(10) + 
			'04/11 - Questionado a MEGASIL quanto ao procedimento a ser adotado para o processo;' + CHAR(13) + CHAR(10) + 
			'05/04/2011 - Prazo correto Concedido pela RFB  até 13/02/2012' + CHAR(13) + CHAR(10) + 
			'15/03/2011 - Prazo da Admissão concedido pela RFB  menor que o do Contrato  , estamos verificando como reverter junto a RFB de Santo Andre ' + CHAR(13) + CHAR(10) + 
			'09/02/2011 - DI registrada, aguardando desembaraço'
		WHEN 51 THEN
			'28/11/2023 - Despacho Decisorio' + CHAR(13) + CHAR(10) + 
			'14/11/2023 - Juntada efetuada' + CHAR(13) + CHAR(10) + 
			'03/10/2023 - Docs recebidos' + CHAR(13) + CHAR(10) + 
			'02/10/2023 - Enviado Nunerario e RPR, ag retorno' + CHAR(13) + CHAR(10) + 
			'29/09/2023 - Cobrado procedimento a ser adotado, informado que será prorrogado por mais 48 meses' + CHAR(13) + CHAR(10) + 
			'13/08/2021 - Despacho de Encaminhamento' + CHAR(13) + CHAR(10) + 
			'25/11/2019 - Despacho de Encaminhamento' + CHAR(13) + CHAR(10) + 
			'12/11/2019 - Processo incluido no controle'
		WHEN 52 THEN
			'25/03/2024 - Processo incluído no controle'
		WHEN 53 THEN
			'25/03/2024 - Processo incluído no controle'
		WHEN 54 THEN
			'30/09/2024 - Processo incluído no controle'

	ELSE cHistorico
END
WHERE iDeclaracaoID BETWEEN 2 AND 54;


SELECT * from tDeclaracao WHERE cReferenciaBraslog = 'I-17/1964-MEG';
SELECT cHistorico FROM tDeclaracao WHERE iDeclaracaoID = 2; --visualizar no modo text para saber se houve quebra de linha correta


COMMIT;
ROLLBACK;

SELECT @@TRANCOUNT

BEGIN TRANSACTION

UPDATE tDeclaracao
SET cDescricao =
	CASE iDeclaracaoID
		WHEN 1 THEN
		'DISTRIBUIDOR DE CARGA METALICO, FABRICANTE MAMMOET LIFTING AND TRANSPORT SAS, MODELO: HEB300- S235, ANO DE FABRICACAO: 2020, USADO,NUMERO DE EQUIPAMENTO: 200812-001; 200812-002; 200812-003; 200812-004; 200812-005; 200812-006; 200812-009; 200812-010.'
		WHEN 2 THEN
		'CABOS DE AÇO, GALVANIZADO PARA GUINDASTE'
		WHEN 3 THEN
		'DISTRIBUIDOR DE CARGA METALICO 3XHEB 500 LG, FABRICANTE SERVICIOS DE ELEVACION Y TRANSPORTE- MAMMOET CHILE Y CIA LTDA, MODELO:15104519-ENGDWG-F001-0, ANO DE FABRICACAO: 2022, USADO, NÚMERO DE EQUIPAMENTO: NA.'
		WHEN 4 THEN
		'GUINDASTE AUTOPROPELIDO SOBRE ESTEIRAS, NOVO, MARCA TEREX-DEMAG, MODELO CC 38.650-1, NÚMERO DE SÉRIE 36254, ANO DE FABRICAÇÃO 2022, NÚMERO DA FROTA 003380, COMPUTADORIZADO, ACIONADO POR MOTOR DIESEL, CAPACIDADE DE 650 TONELADAS, SUPERLIFT, CONTRAPESOS, COM TODOS ACESSÓRIOS PARA SEU FUNCIONAMENTO, DESMONTADO PARCIALMENTE PARA MANUSEIO E TRANSPORTE.'
		WHEN 5 THEN
		'NOME DO NAVIO: KENFORD TIPO DE NAVIO: DRAGA DE SUCÇÃO TRANSPORTADORA DE ARRASTO. IMO: 8821826 BANDEIRA: BELIZE, CLASSE: DRAGA DE ARRASTO I HULL MACH, CLASSIFICAÇÃO: BUREAU VERITAS, DISTINTIVO DE CHAMADA V3BE2, CONSTRUÇÃO: 1990, PAÍSES BAIXOS. ESTÁ EQUIPADO COM SALA DE MÁQUINAS, COM SALA DE BOMBAS DE PROA, NO DEPÓSITO DE TINTA, COM SALA DE AR-CONDICIONADO, COM SALA DO LEME, COM TREMONHA E NA PONTE. O NAVIO ESTÁ EQUIPADO COM UMA ACOMODAÇÃO PARA 14 PESSOAS. DIMENSÕES: COMPRIMENTO TOTAL: 81,8M, COMPRIMENTO ENTRE PERPENDICULARES: 76,95M, LARGURA MOLDADA: 14,00M, PROFUNDIDADE MOLDADA NA MEIA-NAU: 6,30M, CALADO DE VERÃO:4,20M, CALADO DA DRAGA:5,25M, ALTURA:24M, TONELAGEM (T): TONELAGEM BRUTA:2172, TONELAGEM LÍQUIDA:664, PESO MORTO:3369 TONELADAS, CAPACIDADE DA TREMONHA (PARTE SUPERIOR DA ARMAÇÃO):2500 M3, TUBO DE SUCÇÃO DE TRILHAMENTO:1 COM DIÂMETRO DE 800 MM, TUBO DE DESCARGA PARA A TREMONHA: DIÂMETRO 800 MM, TUBO DE DESCARGA PARA TERRA: DIÂMETRO 650 MM, PROFUNDIDADE DE DRAGAGEM: 25M, VELOCIDADE MÁXIMA:10 NÓS, POTÊNCIA TOTAL INSTALADA DO MOTOR DIESEL: 1956 KW, MOTORES PRINCIPAIS:2 MOTORES A DIESEL BOLNES DE 7 CILINDROS, TIPO 7DNL 190/600, CADA UM COM POTÊNCIA NOMINAL DE 978 KW/1330 HP, A 600 RPM, CADA UM ACIONANDO 1 HÉLICE DE PASSO FIXO POR MEIO DE UMA CAIXA DE REDUÇÃO MASON. GERADOR AUXILIAR: 2 MOTOR DIESEL CATERPILLAR DE 4 CILINDROS, TIPO CAT 3304(B) DI-T, COM POTÊNCIA NOMINAL DE 80KW A 1.500 RPM, ACIONANDO 1 GERADOR. GERADOR DE EMERGÊNCIA: N/A, HÉLICES: 2 HÉLICES DE PASSO FIXO DE BRONZE COM 4 PÁS EM BOCAIS FIXOS. PROPULSOR DE PROA: 1 MOTOR PRINCIPAL BOLNES, GERADORES ACIONADOS (494KW) E HÉLICE DE PASSO FIXO NO TÚNEL. BOMBA DE DRAGAGEM: 1 BOMBA DE PAREDE SIMPLES VOSTA,TIPO IHC 150-42,5-75, ACIONADA POR UM MOTOR A DIESEL DE 978KW/1330HP, 600RPM, FABRICADO EM BOLNES POR MEIO DE UMA CAIXA DE REDUÇÃO TIPO CEGONHA. BOMBA DE REFORÇO: 1 BOMBA DE PAREDE SIMPLES VOSTA, TIPO IHC 175-37,5-75, ACIONADA POR UM MOTOR DIESEL DE 932 KW/1258 HP, 1800 RPM, CATERPILLAR 3512 DI-TA, POR MEIO DE UMA CAIXA DE REDUÇÃO (STORK). BOMBAS DE JATO DÁGUA: 2 BOMBAS GIW DE 1250M3/H, CADA UMA COM 8 BAR, ACIONADAS POR 1 MOTOR DIESEL CATERPILLAR 3412, MARCA HGT 1-300315-180KW. CAPACIDADE DO TANQUE: ÓLEO COMBUSTÍVEL: 269,0 M3 ÓLEOS LUBRIFICANTES 5,6 M3 ÁGUA DOCE: 55,7 T GUINDASTES DE CONVÉS: 1 GUINDASTE HIDRÁULICO PALFINGER, SWL,990 QUILOGRAMAS A 7M E 1 GUINDASTE ELÉTRICO, SWL, 990 QUILOGRAMAS A 6M.ACOMODAÇÃO: A ACOMODAÇÃO CONSISTE EM 3 BELICHES. APARELHOS SALVA-VIDAS:2 BOTES SALVA-VIDAS PARA 16 PESSOAS CADA, 2 BOTES SALVA VIDAS PARA 8 PESSOAS CADA, 1 BARCO MOB COM MOTOR DE POPA DE 25 HP, VÁRIOS OUTROS EQUIPAMENTOS.'
		WHEN 6 THEN
		'CAMINHÃO GUINDASTE SOBRE PNEU COM LANÇA TELESCÓPICA ATÉ 50 METROS, ADITIVO ESPECIAL CONECTADO JIB ATÉ 91 METROS, CAPACIDADE MÁXIMA DE ELEVAÇÃO 500 TONELADAS, COM 8 EIXOS TOTAIS SENDO 2 EIXOS FIXOS + 6 EIXOS DIRECIONÁVEIS, PARCIALMENTE DESMONTADO PARA TRANSPORTE E MANUSEIO, COM PEÇAS E ACESSÓRIOS PARA MONTAGEM E OPERAÇÃO. MARCA LIEBHERR, MODELO LTM1500-8.1, USADO, ANO DE FABRICAÇÃO 2017, NUMERO DE SÉRIE 095381.'
		WHEN 7 THEN
		'UNIDADE DE ACIONAMENTO EXTRUSORA E20 3F/1,1KW/I=16, DE MATERIAL EM AÇO, MODELO: M332.00256, NUMERO DE SERIE: 2021.3888.010.004, FABRICANTE: COLLIN LAB & PILOT SOLUTIONS GMBH'
		WHEN 8 THEN
		'DIVERSOS EQUIPAMENTOS CONFORME DI'
		WHEN 9 THEN
		'DRAGA TSHD DE SUCÇÃO EM MOVIMENTO, M/V ELBE, CONSTRUÍDA EM 2007 NO ESTALEIRO BEN KIEN SHIPYARD, VIETNAM, REGISTRADA NO PORTO DE SLIEDRECH, DE BANDEIRA DOS PAISES BAIXOS, IMO NUMERO 9452842, INDICATIVO PBMK, A EMBARCAÇÃO ESTÁ EQUIPADO COM UM SISTEMA DE SUCÇÃO DE REBOQUE, DESPEJO E DESCARGA DE AREIA E LODO. ESTÁ EQUIPADA DE SALA DE MÁQUINAS, SALA DE BOMBA, LOJA DE TINTAS, QUARTO COM AR CONDICIONADO, SALA DE LEME, SALA DE HIDRÁULICA, 2 HOPPER (1 A BOMBORDO E 1 A ESTIBORDO), SALA DE CONVERSOR, SALA DE GERADOR, DE EMERGÊNCIA E PONTE. O NAVIO É EQUIPADO COM UM ALOJAMENTO PARA 13 PESSOAS. DRAGA AVALIADA EM 5.000.000,00 DIMENSÕES: COMPRIMENTO SOBRE TUDO: 77,15 M COMPRIMENTO PERPENDICULARES: 71,80 M BOCA MOLDADA: 15,00 M PROFUNDIDADE MEIA NAU MOLDADO: 5,70 M PROJECTO DE VERÃO: 4,45 M DRAGA PROJECTO: 6,10 M ALTURA: 28,85 M TONELAGEM (T): TONELAGEM BRUTA: 2472 TONELAGEM LIQUIDA: 741 PESO MORTO: 3341 MT CAPACIDADE HOPPER (TOPO DA BRAÇOLA): 2.800 M3 TUBO DE SUCÇÃO EM MOVIMENTO: 1 COM 800 MILÍMETROS DE DIÂMETRO TUBO DE DESCARGA PARA HOPER: 800 MILÍMETROS DE DIÂMETRO TUBO DE DESCARGA PARA TERRA: 600 MILÍMETROS DE DIÂMETRO PROFUNDIDADE DE DRAGAGEM: 30M VELOCIDADE MÁXIMA: 10,3 NÓS TOTAL DE ENERGIA A DIESEL INSTALADOS: 2.529 KW MOTORES PRICIPAIS: 2 MOTORES DIESEL DE 12 CILINDROS, MITSUBISHI, TIPO S12RMPTK, CADA UM DE 940 KW NOMINAL DE 1,600 RPM, DIRIGINDO UMA HÉLICE DE PASSO FIXO ATRAVÉS DE UMA CAIXA REDUTORA MASON. MOTORES AUXILIARES: 3 MOTORES DIESEL DE 6 CILINDROS, JOHN DEERE, TIPO 6090AFM85, DE 192KW NOMINAL DE 1,500 RPM, DE UNICA DIREÇÃO. MOTOR DE EMERGÊNCIA: 1 MOTOR DIESEL DE 6 CILINDROS, MITSUBISHI,TIPO 6D16T DE 106 KW NOMINAL DE 1500 RPM, DE UNICA DIREÇÃO. HÉLICES: 2 HÉLICES DE 5 PÁS DE BRONZE DE PASSO E BICOS FIXOS. MOTOR PROA: 1 MOTOR DIESEL, MITSUBSHI, HÉLICE DE PASSO FIXO CONDUZIDO EM TÚNEL DE 360KW. BOMBA DE DRAGAGEM: 1 BOMBA PARA DRAGAGEM VOSTA, TIPO VL 750, IMPULSIONADA POR UM MOTOR A DIESEL DE 870 KW MITSUBISHI, VIA CAIXA DE REDUÇÃO STORK. BOMBA DE MOVIMENTO: 1 BOMBA DE MOVIMENTO VOSTA, TIPO VL 750, IMPULSIONADA POR UM MOTOR A DIESEL DE 870 KW MITSUBISHI, VIA CAIXA DE REDUÇÃO STORK. BOMBAS DE JATO DE ÁGUA: 1 BOMBA GIW DE 2300 M3/H, DE 8 BAR, IMPULSIONADA POR UM MOTOR DIESEL, MITSHUBISHI DE 634 KW, COM REDUÇÃO VIA CAIXA MASON. CAPACIDADE DOS TANQUES DE: ÓLEO COMBUSTÍVEL: 219,0 M3 ÓLEOS LUBRIFICANTES: 13,0 M3 ÁGUA DOCE: 91,0 M3 GUINDASTES: 2 GRUAS HIDRÁULICAS PALFINGER, TIPO SWM, DE 7 TON ATÉ 10M. ACOMODAÇÕES: AS ACOMODAÇÕES CONSISTEM DE 5 DECKS. MEIOS DE SALVAÇÃO: 2 BOTES SALVA-VIDAS PARA CADA 16 PESSOAS, 1 BARCO MOB COM MOTOR DE POPA DE 25 HP.'
		WHEN 10 THEN
		'DIVERSOS EQUIPAMENTOS CONFORME DI'
		WHEN 11 THEN
		'DIVERSOS EQUIPAMENTOS CONFORME DUE'
		WHEN 12 THEN
		'CONJUNTO DE TRILHA ESTREITA USADO PARA GUINDASTE TEREX DEMAG CC 2800 - 1 COM TODAS AS PEÇAS E ACESSÓRIOS PARA MONTAGEM E OPERAÇÃO, MARCA: TEREX DEMAG, MODELO: CC 2800-1, SEM NÚMERO DE SERIE, ANO DE FABRICAÇÃO 2006. UMA SEÇAO DE JIB/LANÇA DE 12 METROS USADA PARA GUINDASTE TEREX-DEMAG CC 2800-1 COM TODAS AS PEÇAS E ACESSÓRIOS PARA MONTAGEM E OPERAÇÃO, MARCA: TEREX DEMAG, MODELO: CC 2800-1, SEM NUMERO DE SÉRIE, ANO DE FABRICAÇÃO 2006.0'
		WHEN 13 THEN
		'POWER PACK DE MOVIMENTO RETILÍNEO (CILINDROS), MARCA GOLDHOFER AKTIENGESELLSCHAFT, MODELO PFV-490/60-31, NÚMERO DE SÉRIE 61402, FROTA 302920, ANO DE FABRICAÇÃO 2016, USADO, COM DISPOSITIVOS E FERRAMENTAS DE MONTAGEM E ACESSÓRIOS NECESSÁRIOS PARA OPERAÇÃO.'
		WHEN 14 THEN
		'VEÍCULO AUTOPROPELIDO PARA TRANSPORTE A DE GRANDES ESTRUTURAS EM CURTAS DISTÂNCIAS, COM 6 LINHAS DE EIXO, ANO DE FABRICAÇÃO 2016, USADO, COM CADA LINHA DE EIXO COMPOSTA POR 8 PNEUS (TOTAL DO CONJUNTO 48 PNEUS),COMPLETA, COM
		DISPOSITIVOS E FERRAMENTAS DE MONTAGEM E ACESSÓRIOS NECESSÁRIOS PARA OPERAÇÃO (PARCIALMENTE DESMONTADO PARA MANUSEIO E TRANSPORTE). NÚMERO DE SÉRIE WG0PST061G0061401 E FROTA 302919 E MARCA GOLDHOFER
		AKTIENGESELLSCHAFT, MODELO: PST/SL 6-12X08.'
		WHEN 15 THEN
		'CAMINHÃO GUINDASTE SOBRE PNEU COM LANÇA TELESCÓPICA ATÉ 60 METROS, ADITIVO ESPECIAL CONECTADO JIB ATÉ 88 METROS, CAPACIDADE MÁXIMA DE ELEVAÇÃO 220 TONELADAS, COM 5 EIXOS TOTAIS DIRECIONÁVEIS,PARCIALMENTE DESMONTADO PARA TRANSPORTE E MANUSEIO, COM PEÇAS E ACESSÓRIOS PARA MONTAGEM E OPERAÇÃO. MARCA LIEBHERR, MODELO LTM-1220 5.2, USADO, ANO DE FABRICAÇÃO 2012, NÚMERO DE SÉRIE 045767, CHASSIS NO.: W09585700DEL05385.'
		WHEN 16 THEN
		'SEÇÕES DE LANÇA PARA GUINDASTE CC2800-1, USADAS, TIPO (S7) 2724-22-03/ 2724-22-04, COMPLETAS COM PENDENTES E PINOS PARA MONTAGEM. MARCA: TEREX DEMAG, MODELO: CC 2800-1, NÚMERO DE SERIE 62240, CAPACIDADE DA LANÇA 600
		TON, FLEET NUMBER: 1169, ANO DE FABRICAÇÃO 2008, USADO.'
		WHEN 17 THEN
		'PARTE DE GUINDASTE AUTOPROPELIDO CC2800, SENDO: MOITÃO 200T, CABO DE 28MM, 5 ROLDANAS, MARCA 5321322, MODELO HF-280200-00001, NUMERO DE SERIE 63078-2, ANO DE FABRICAÇÃO 2007 - USADO.'
		WHEN 18 THEN
		'DIVERSOS EQUIPAMENTOS CONFORME DI'
		WHEN 19 THEN
		'GUINDASTE AUTOPROPELIDO SOBRE ESTEIRAS, MARCA TEREX-DEMAG, MODELO CC2800-I, NUMERO DE SERIE 62277, ANO DE FABRICAÇÃO 2008, USADO, NUMERO DA FROTA 1331, OMPUTADORIZADO, ACIONADO POR MOTOR DIESEL, CAPACIDADE DE 600 TONELADAS, SUPERLIFT, CONTRA-PESOS,COM TODOS ACESSÓRIOS PARA SEU FUNCIONAMENTO, DESMONTADO PARCIALMENTE PARA MANUSEIO E TRANSPORTE.'
		WHEN 20 THEN
		'DIVERSOS EQUIPAMENTOS CONFROME DI'
		WHEN 21 THEN
		'SEÇÃO DE LANÇA DE 12 METROS USADA PARA GUINDASTE TEREX-DEMAG CC 2800 - 1 COM TODAS AS PEÇAS E ACESSÓRIOS PARA MONTAGEM E OPERAÇÃO, MARCA: TEREX DEMAG, TIPO: 12 METER MAIN BOOM INSERT 2724-20-01, NUMERO DE SÉRIE 62277, FLEET NUMBER 1331, ANO DE FABRICAÇÃO 2008 - USADO.'
		WHEN 22 THEN
		'LANÇA AUXILIAR MECÂNICA PARA AUMENTAR O COMPRIMENTO, ALTURA E RAIO DO GUINDASTE, USADO, CAPACIDADE: 90 TONS, MARCA: GROVE, MODELO: RT 890E, ANO DE FABRICAÇÃO 2012, NÚMERO DE EQUIPAMENTO/SÉRIE: 232649.'
		WHEN 23 THEN
		'GUINDASTE AUTOPROPELIDO SOBRE ESTEIRAS, MARCA KOBELCO, MODELO CKE1100 G-2 , NÚMERO DE SERIE GK06-05004, ANO DE FABRICAÇÃO 2016 - USADO, NÚMERO DA FROTA 2678, COMPUTADORIZADO, ACIONADO POR MOTOR DIESEL, CAPACIDADE DE 110 TONELADAS, CONTRA-PESOS, COM TODOS ACESSÓRIOS PARA SEU FUNCIONAMENTO ATÉ 28 METROS DE LANÇA, DESMONTADO PARCIALMENTE PARA MANUSEIO E TRANSPORTE.'
		WHEN 24 THEN
		'GUINDASTE AUTOPROPULSADO SOB ESTEIRAS, MARCA LIEBHERR, MODELO LR1300-W, SERIE 138128, ANO 2010 - USADO, NUMERO DE FROTA 1844, COM CAPACIDADE TOTAL DE ELEVAÇÃO MÁXIMA DE 300 TONELADAS, INTEIRAMENTE DESMONTADO PARA MANUSEIO E TRANSPORTE, COM TODOS OS SEUS ACESSÓRIOS PARA SEU FUNCIONAMENTO ATÉ 65 METROS DE LANÇA, COMPOSTODE: CORPO PRINCIPAL, ESTEIRAS, CONTRAPESOS, LANÇA PRINCIPAL , DISPOSITIVOS E FERRAMENTAS DE
		MONTAGEM E IÇAMENTO E DEMAIS ACESSÓRIOS NECESSÁRIOS A OPERAÇÃO DO EQUIPAMENTO'
		WHEN 25 THEN
		'GUINDASTE AUTOPROPELIDO SOBRE ESTEIRAS, MARCA KOBELCO, MODELO CK1100 , NÚMERO DE SERIE GH04-03371, ANO DE FABRICAÇÃO 2014 - USADO, NÚMERO DA FROTA 2611, COMPUTADORIZADO, ACIONADO POR MOTOR DIESEL, CAPACIDADE DE 110 TONELADAS, CONTRA-PESOS, COM TODOS ACESSÓRIOS PARA SEU FUNCIONAMENTO ATÉ 28 METROS DE LANÇA, DESMONTADO PARCIALMENTE PARA MANUSEIO E TRANSPORTE.'
		WHEN 26 THEN
		'CAMINHÃO GUINDASTE SOBRE PNEU COM LANÇA TELESCÓPICA ATÉ 50 METROS, CAPACIDADE MÁXIMA DE ELEVAÇÃO 90 TONELADAS, COM 2 EIXOS TOTAIS SENDO 2 EIXOS DIRECIONÁVEIS, PRONTO PARA MANUSEIO E OPERAÇÃO. MARCA GROVE, MODELO RT890E, USADO, ANO DE FABRICAÇÃO 2012, NUMERO DE SÉRIE 232649, FROTA 2144.'
		WHEN 27 THEN
		'DIVERSOS EQUIPAMENTOS CONFORME DUE'
		WHEN 28 THEN
		'CONJUNTO TENSOR PARA LANÇA DE 108 METROS, TIPO SSL/LSL, MARCA TEREX, SEM NUMERO DE SERIE , ANO DE FABRICAÇÃO 2008'
		WHEN 29 THEN
		'PARTE DO GUINDASTE TEREX DEMAG - ANO DE FABRICAÇÃO 2018, SEM NUMERO DE SERIE'
		WHEN 30 THEN
		'UNIDADE MÓVEL DE PRODUÇÃO DE ÁGUA POTÁVEL, AUTÓNOMA E DE GRANDE CAPACIDADE (15 M3/H), ADAPTADO AO CONTEXTO DE EMERGÊNCIA HUMANITÁRIA PARA DISTRIBUIÇÃO DIRETA ÀS PESSOAS AFETADAS POPULAÇÃO E/OU EM CAMPOS DE REFUGIADOS, EQUIPADO COM MEMBRANAS DE ULTRAFILTRAÇÃO COM LIMITE DE CORTE DE 0,04 ?M, ELIMINA TODOS OS COLÓIDES E BACTÉRIAS, ASSIM COMO A MAIORIA DOS VÍRUS POTENCIALMENTE PRESENTES NA ÁGUA BRUTA, PROCEDIMENTO É COMPLETADO POR UM TRATAMENTO DE CARVÃO ATIVADO GRANULAR PARA TRATAR COR, ODOR E ALGUMA POLUIÇÃO COMPLEXA E COMPLETADO PELA INJEÇÃO DE CLORO PARA FINALIZAR A DESINFECÇÃO E GARANTIR A PERSISTÊNCIA NA ÁGUA DISTRIBUÍDA. MARCA: VEOLIA MODELO: AF7500UF SÉRIE: FV/UF/7500/1 ANO DE FABRICAÇÃO: 2019 USADO.'
		WHEN 31 THEN
		'MACACO HIDRAULICO PARA ELEVAÇÃO DE DUPLA AÇÃO, MARCA MAMMOET, MODELO JA-CL-DA-300-2, SERIE/SAP. 5266666 / 5266667 /5266669 / 5266671 / 5266673 / 5266674 / 5266675 / 5266676, CAPACIDADE DE 300 TONELADAS, ANO DE FABRICAÇÃO 2009. INCLUINDO SEUSACESSORIOS, DESMONTADO PARA MANUSEIO E TRANSPORTE'
		WHEN 32 THEN
		'DISPOSITIVO ESPECIAL PARA CONEXÃO FÍSICA DE GRUPOS DE LINHA DE EIXO, MODELO CO-BL-SCH-BX-2, ANO DE FABRICAÇÃO 2007 - USADO, FROTA Nº 5601638, COR VERMELHO. UTILIZADO EM VEICULO AUTOPROPELIDO PARA TRANSPORTE A PEQUENA DISTANCIA DE ESTRUTURA DE GRANDE DIMENSÃO.'
		WHEN 33 THEN
		'PARTE DE GUINDASTE AUTOPROPELIDO CC2800, SENDO: MOITÃO 200T, CABO DE 28MM, 5 ROLDANAS, MARCA 5321322, MODELO HF-280200-00001, NUMERO DE SERIE 63078-2, ANO DE FABRICAÇÃO 2007 - USADO.'
		WHEN 34 THEN
		'CONJUNTO USADO, DE ATUADOR HIDROELÉTRICA DESMONTADO PARA CILINDRO ESTABILIZADOR DO CONJUNTO DE TRILHA ESTREITA PARA GUINDASTE CC-2800'
		WHEN 35 THEN
		'POWER PACK DE MOVIMENTO RETILÍNEO (CILINDROS), MARCA SCHEUERLE FAHRZEUGFABRIK GMBH, MODELO PPU Z350DC, NÚMERO DE SÉRIE W09913XXX6PS17973, FROTA 303793, ANO DE FABRICAÇÃO 2006, USADO, COM DISPOSITIVOS E FERRAMENTAS DE MONTAGEM E ACESSÓRIOS NECESSÁRIOS PARA OPERAÇÃO.'
		WHEN 36 THEN
		'POWER PACK DE MOVIMENTO RETILÍNEO (CILINDROS), MARCA SCHEUERLE FAHRZEUGFABRIK GMBH, MODELO PPU Z350DC, NÚMERO DE SÉRIE W09932XX88PS17574, FROTA 303764, ANO DE FABRICAÇÃO 2009, USADO, COM DISPOSITIVOS E FERRAMENTAS DE MONTAGEM E ACESSÓRIOS NECESSÁRIOS PARA OPERAÇÃO.'
		WHEN 37 THEN
		'NOME DA LINDWAY EMBARCAÇÃO: TIPO DE EMBARCAÇÃO: DRAGAS AUTOTRANSPORTADORAS DE ARRASTO E SUCÇÃO IMO: 8402773 BANDEIRA:BELIZE CLASSE:*A1, SERVIÇO DE DRAGAGEM, © , *AMS, *ACCU CLASSIFICAÇÃO: AMERICAN BUREAU OF SHIPPING CÓDIGO INDICATIVO: V3NR7 CONSTRUÇÃO: 1985, EUA, EQUIPADO COM PRAÇA DE MÁQUINAS,
		SALA DE BOMBAS DE PROA, PAIOL DE TINTAS, SALA DE AR CONDICIONADO, SALA DE LEME, TREMONHA, PONTE. O NAVIO ESTÁ EQUIPADO COM UMA ACOMODAÇÃO PARA 24 PESSOAS.DIMENSÕES:COMPRIMENTO TOTAL: 93,88 METROS COMPRIMENTO ENTRE PERPENDICULARES: 84,73 METROS BOCA MOLDADA: 16,76 METROS PROFUNDIDADE MOLDADA A MEIA-NAU: 7,47 METROS CALADO DE VERÃO: 6,05 METROS CALADO DE DRAGAGEM: 6,05 METROS ALTURA: 24,99 METROS TONELAGEM (T):TONELAGEM BRUTA: 3498 TONELAGEM LÍQUIDA: 1049 PORTE BRUTO: 4096,6 TN CAPACIDADE DA TREMONHA (TOPO DA BRAÇOLA): 2893 M3 TUBO DE ARRASTO DE SUCÇÃO: 2 COM DIÂMETRO DE 711 MILÍMETROS TUBO DE DESCARGA PARA TREMONHA: DIÂMETRO DE 711 MILÍMETROS
		TUBO DE DESCARGA PARA A COSTA: DIÂMETRO DE 711 MILÍMETROS PROFUNDIDADE DE DRAGAGEM: 24,4 METROS VELOCIDADE MÁXIMA: 12,75 NÓS POTÊNCIA TOTAL INSTALADA DO DIESEL: 11739 KW MOTORES PRINCIPAIS:2 MOTORES À DIESEL GENERAL ELECTRIC DE 16 CILINDROS, TIPO 16V250MDB, CADA UM COM POTÊNCIA NOMINAL DE 4035 KW / 5412HP, A 1000 RPM, CADA UM ACIONANDO 1 HÉLICE DE PASSO FIXO POR MEIO DE UMA CAIXA DE REDUÇÃO MASON. GERADOR AUXILIAR:3 MOTORES CATERPILLAR À DIESEL DE 6 CILINDROS, TIPO CAT C18, POTÊNCIA NOMINAL DE 546,5 KW A 1.800 RPM, ACIONANDO 1 GERADOR.DE
		EMERGÊNCIA:1 MOTOR CATERPILLAR À DIESEL DE 8 CILINDROS, TIPO CAT 3408, POTÊNCIA NOMINAL DE 208 KW A 1.800 RPM, ACIONANDO 1 GERADOR.HÉLICES:2 HÉLICES DE PASSO CONTROLÁVEL DE BRONZE COM 4 PÁS.IMPULSOR DE PROA: 1 SCHOTTEL S-300-L, ACIONADO POR MOTOR DE 370 KW E HÉLICE DE PASSO FIXO EM TÚNEL.BOMBA DE DRAGAGEM: 2 BOMBAS GIW WBC 26X28-64, SINGLE WALLED, ACIONADAS PELO MOTOR PRINCIPAL POR MEIO DE UMA CAIXA DE REDUÇÃO. BOMBA DE RECALQUE: 1 BOMBA, SINGLE WALLED, VOSTA, TIPO IHC 175-37,5-75, ACIONADA POR UM MOTOR DIESEL DE 932KW/1258HP, 1800RPM
		CATERPILLAR 3512 DL-TA, ATRAVÉS DE UMA CAIXA DE REDUÇÃO STORK.BOMBAS DE ÁGUA A JATO:2 BOMBAS GIW LCC-H 250-660, ACIONADAS POR 1 GERADORÀ DIESEL CATERPILLAR 3512, 1652 KWCAPACIDADE DOS TANQUES:ÓLEO COMBUSTÍVEL: 1161,108 M³ ÓLEOS LUBRIFICANTES: 23,03 M³ ÁGUA DOCE: 125,65 T GUINDASTES DE CONVÉS: 1 GUINDASTE HIDRÁULICO APPLETON MARINE DE 3 TONELADAS, SWL (CARGA DE TRABALHO SEGURA) 990 KG 1 GUINDASTE HIDRÁULICO APPLETON MARINE DE 20 TONELADAS, SWL 990 KG ACOMODAÇÃO:A ACOMODAÇÃO É COMPOSTA POR 4 CONVESES.'
		WHEN 38 THEN
		'GUINDASTE AUTOPROPULSADO SOBRE ESTEIRA, MARCA: MANITOWOC MODELO: M18000, CAPACIDADE DE ELEVAÇÃO: 750 TONELADAS, NÚMERO DE SÉRIE: 1800-1036, USADO ANO DE FABRICAÇÃO: 2007, COMPUTADORIZADO, ACIONADO POR MOTOR DIESEL
		, COM SUPERESTRUTURA, LANÇA PRINCIPAL, LANÇA MASTRO, SUPERLIFT MAXER COM TODOS OS ACESSÓRIOS PARA SEU FUNCIONAMENTO, PARCIALMENTE DESMONTADO PARA MANUSEIO E TRANSPORTE.'
		WHEN 39 THEN
		'DIVERSOS EQUIPAMENTOS CONFORME DI'
		WHEN 40 THEN
		'COMBINACAO DE MAQUINAS PARA DESAERACAO (SEPARACAO DE FASES LIQUIDA E GASOSA) COM MEMBRANAS CONTATORAS CONTENDO 1 BOMBA CENTRIFUGA MONOBLOCO, 1 BOMBA DE VACUO, 1 GERADOR DE NITROGENIO, 1 COMPRESSOR DE AR, 1 REFIGERADOR PARA AR COMPRIMIDO. MEDIDOR
		DE VAZAO, PRESSOSTATO, SENSOR DE TEMPERATURA, TRANSMISSOR DE PRESSAO, ANALISADOR DE OXIGENIO DISSOLVIDO, VALVULAS DOS TIPOS ESFERA, BORBOLETA, SOLENOIDE E RETENCAO. 2 CARCACAS DE MEMBRANA, ONDE OS ELEMENTOS MECANICOS SAO INTERLIGADOS POR TUBULACOES
		DE PVC-U PODENDO SER COLADOS OU PARAFUSADOS E OS DISPOSITIVOS ELETRICOS SAO INTERLIGADOS ATRAVES DE CABOS A UM PAINEL CENTRAL.MONTADOS SOBRE UMA BASE (FRAME) METALICA QUE CONTA COM SUPORTES PARA ALGUNS ITENS, DISPOSTOS EM UMA MONTAGEM PERMANENTE ALOCADA EM CONTAINER PARA USO NA REMOCAO DE GASES DISSOLVIDOS EM AGUA DE PROCESSO DE PETROLIFERA. NÚMERO CONTAINER:JKCU101043722G1 ANO FABRICAÇÃO: 2016 - USADO.'
		WHEN 41 THEN
		'DIVERSOS EQUIPAMENTOS CONFORME DI'
		WHEN 42 THEN
		'DIVERSOS EQUIPAMENTOS CONFORME DI'
		WHEN 43 THEN
		'DIVERSOS EQUIPAMENTOS CONFORME DI'
		WHEN 44 THEN
		'DIVERSOS EQUIPAMENTOS CONFORME DI'
		WHEN 45 THEN
		'PARTE DE GUINDASTE, SENDO: MOITÃO EM AÇO DE 600TON, USADO, MARCA: MANITOWOC, MODELO: M18000, NÚMERO DE SÉRIE: 0864160, ANO DE FABRICAÇÃO: 2009'
		WHEN 46 THEN
		'EQUIPAMENTO PARA TESTES DE VIBRACOES EM BERCO MARITIMO DE AMARRACAO DE EMBARCACOES, MARCA: BOLLARDSCAN, COMPOSTO POR UNIDADE DE ROCESSAMENTO DE DADOS, CAMERA DIGITAL, SENSORES, CABEAMENTOS E CONECTORES. COM SOFTWARE INTEGRADO. EQUIPAMENTO SEMIDESMONTADO NAS SEGUINTES PARTES INDENTIFICADAS: BOLLARDSCAN ITENS NR(S): BOLL-LPT 001 / BOLMPAN 001 / BOLL MSOFF 001 / BOLLMPHW 002 / BOLL-ACC 622B01 /BOLL-MAG080A131 / BOLLCAB508BR01AC / BOLL-CCOUP 779680-01 /BOLL- COUPHOU 781425-01 / BOLL- HAM086D20 / BOLLHAMCA
		426-2094 / BOLL-DIGICAM. SERIAL NR(S): LAPTOP: CF53-SBWHDCA / DONGLE: 1645072556 / ACELEROMETROS: LW 067391 (R); LW 063161 (Y) E LW 067402 (B) / CABO DO ACOPLADOR: 1EDCDF1 / ACOPLADOR: 1EEC665 / HAMMER SN 47723 / PONTAS: NONE / CABO: NONE / CABO: NONE / CAMERA: VIVICAM090/ USADO / ANO DE FABRICAÇÃO: 2021.'
		WHEN 47 THEN
		'DIVERSOS EQUIPAMENTOS CONFORME DI'
		WHEN 48 THEN
		'FORRAGEIRA AUTOPROPELIDA PARA SILAGEM COM POTÊNCIA DE 408CV/300 KW , CILINDRADA 11.900 CM3, MARCA DEUTZFAHR, MODELO GIGANT 400, NÚMERO DE SÉRIE 65-05-000117, USADA - ANO DE FABRICAÇÃO 1997.'
		WHEN 49 THEN
		'COLHEITADEIRA AUTOPROPELIDA PARA CEREAIS E FORRAGENS, USADA, MARCA: DEUTZ-FAHR MODELO: GIGANT 400, N DE SÉRIE: 65-05-000146, FABRICADA EM 1998.'
		WHEN 50 THEN
		'COLHEITADEIRA AUTOPROPELIDA PARA CEREAIS E FORRAGENS, USADA, MARCA: DEUTZ-FAHR MODELO: GIGANT 400, N DE SÉRIE: 65-05-000074, FABRICADA EM 1996.'
		WHEN 51 THEN
		'DIVERSOS EQUIPAMENTOS CONFORME DI'
		WHEN 52 THEN
		'DIVERSOS EQUIPAMENTOS CONFORME DI'
		WHEN 53 THEN
		'DIVERSOS EQUIPAMENTOS CONFORME DI'
		WHEN 54 THEN
		'DIVERSOS EQUIPAMENTOS CONFORME DI'
		ELSE cHistorico
END
WHERE iDeclaracaoID BETWEEN 1 AND 54;

/*--------------------------------------------------------------------------------------------        
Objeto tipo: Stored Procedure
Objeto     : stp_atualizarDados
objetivo   : Atualizar dados da tabela de um processeo específico
Projeto    : ProcessosTemporarios
Criação    : 03/05/2025
Keywords   : UPDATE
----------------------------------------------------------------------------------------------        
Observação:        

----------------------------------------------------------------------------------------------        
Historico:        
Autor                  IDBug Data		Descrição
---------------------- ----- ---------- ------------------------------------------------------------        
Marcus V. Paiva Silveira                03/05/2025 Procedure criada */

CREATE OR ALTER PROCEDURE stp_atualizarDados
	--tDeclaracao
    @iDeclaracaoID INT,
    @cReferenciaBraslog CHAR(13) = NULL,
    @cReferenciaCliente VARCHAR(100) = NULL,
    @cNumeroDeclaracao VARCHAR(12) = NULL,
    @dDataRegistroDeclaracao DATE = NULL,
    @dDataDesembaracoDeclaracao DATE = NULL,
    @cNumeroDOSSIE CHAR(15) = NULL,
    @cNumeroProcessoAdministrativo VARCHAR(100) = NULL,
    @cModal VARCHAR(15) = NULL,
    @cDescricao VARCHAR(MAX) = NULL,
    @cHistorico VARCHAR(MAX) = NULL,
	--tCNPJ
    @cNomeEmpresarial VARCHAR(100) = NULL,
	@cNumeroInscricao CHAR(14) = NULL,
	--tCeMercante
	@cNumeroCE CHAR(15) = NULL,
	@cStatusCE VARCHAR(15) = NULL,
	--tContrato
	@cNumeroNomeContrato VARCHAR(100) = NULL,
	@dContratoDataAssinatura DATE = NULL,
	@dContratoVencimento DATE = NULL,
	@iNumeroProrrogacao INT = NULL,
	--tApoliceSeguroGarantia
	@cNumeroApolice VARCHAR(100) = NULL,
	@dVencimentoGarantia DATE = NULL,
	--tRecintoAlfandegado
	@cUnidadeReceitaFederal CHAR(7) = NULL,
	@cNumeroRecintoAduaneiro CHAR(7) = NULL,
	@cNomeRecinto VARCHAR(255) = NULL
AS
BEGIN
    --SET NOCOUNT ON;
    BEGIN TRANSACTION;

	BEGIN TRY

		--atualiza tDeclaracao
		UPDATE tDeclaracao
		SET cReferenciaBraslog = ISNULL(@cReferenciaBraslog, cReferenciaBraslog),
			cReferenciaCliente = ISNULL(@cReferenciaCliente, cReferenciaCliente),
			cNumeroDeclaracao = ISNULL(@cNumeroDeclaracao, cNumeroDeclaracao),
			dDataRegistroDeclaracao = ISNULL(@dDataRegistroDeclaracao, dDataRegistroDeclaracao),
			dDataDesembaracoDeclaracao = ISNULL(@dDataDesembaracoDeclaracao, dDataDesembaracoDeclaracao),
			cNumeroDOSSIE = ISNULL(@cNumeroDOSSIE, cNumeroDOSSIE),
			cNumeroProcessoAdministrativo = ISNULL(@cNumeroProcessoAdministrativo, cNumeroProcessoAdministrativo),
			cModal = ISNULL(@cModal, cModal),
			cDescricao = ISNULL(@cDescricao, cDescricao),
			cHistorico = ISNULL(@cHistorico, cHistorico)
		WHERE iDeclaracaoID = @iDeclaracaoID;

		----atualiza tCNPJ
		UPDATE tCNPJ
		SET cNomeEmpresarial = ISNULL(@cNomeEmpresarial, cNomeEmpresarial),
			cNumeroInscricao = ISNULL(@cNumeroInscricao, cNumeroInscricao)
		FROM tCNPJ
		JOIN tDeclaracao
		ON tDeclaracao.iCNPJID = tCNPJ.iCNPJID
		WHERE tDeclaracao.iDeclaracaoID = @iDeclaracaoID;

		--atualiza tCeMercante
		UPDATE tCeMercante
		SET cNumeroCE = ISNULL(@cNumeroCE, cNumeroCE),
			cStatusCE = ISNULL(@cStatusCE, cStatusCE)
		FROM tCeMercante
		JOIN tDeclaracao
		ON tDeclaracao.iCEID = tCeMercante.iCEID
		WHERE tDeclaracao.iDeclaracaoID = @iDeclaracaoID;

		--atualiza tContrato
		UPDATE tContrato
		SET cNumeroNomeContrato = ISNULL(@cNumeroNomeContrato, cNumeroNomeContrato),
			dContratoDataAssinatura = ISNULL(@dContratoDataAssinatura, dContratoDataAssinatura),
			dContratoVencimento = ISNULL(@dContratoVencimento, dContratoVencimento),
			iNumeroProrrogacao = ISNULL(@iNumeroProrrogacao, iNumeroProrrogacao)
		FROM tContrato
		JOIN tDeclaracao
		ON tDeclaracao.iContratoID = tContrato.iContratoID
		WHERE tDeclaracao.iDeclaracaoID = @iDeclaracaoID;

		--atualiza tApoliceSeguroGarantia
		UPDATE tApoliceSeguroGarantia
		SET cNumeroApolice = ISNULL(@cNumeroApolice, cNumeroApolice),
			dVencimentoGarantia = ISNULL(@dVencimentoGarantia, dVencimentoGarantia)
		FROM tApoliceSeguroGarantia
		JOIN tDeclaracao
		ON tDeclaracao.iApoliceID = tApoliceSeguroGarantia.iApoliceID
		WHERE tDeclaracao.iDeclaracaoID = @iDeclaracaoID;

		--atualiza tRecintoAlfandegado
		UPDATE tRecintoAlfandegado
		SET cUnidadeReceitaFederal = ISNULL(@cUnidadeReceitaFederal, cUnidadeReceitaFederal),
			cNumeroRecintoAduaneiro = ISNULL(@cNumeroRecintoAduaneiro, cNumeroRecintoAduaneiro),
			cNomeRecinto = ISNULL(@cNomeRecinto, cNomeRecinto)
		FROM tRecintoAlfandegado
		JOIN tDeclaracao
		ON tDeclaracao.iRecintoID = tRecintoAlfandegado.iRecintoID
		WHERE tDeclaracao.iDeclaracaoID = @iDeclaracaoID;

		COMMIT;

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK

		RAISERROR('Não foi possível atualizar',10,1) WITH NOWAIT

	END CATCH

END;
GO

	SELECT * FROM dbo.infoProcesso(59);
	SELECT * FROM tDeclaracao;
	SELECT * FROM tDeclaracao WHERE iDeclaracaoID = 59;


	BEGIN TRANSACTION
	SELECT @@TRANCOUNT

	EXECUTE stp_atualizarDados
			@iDeclaracaoID = 59,
			@cReferenciaBraslog = 'I-25/1001-MBG'

	ROLLBACK

	INSERT INTO tDeclaracao (
	cNumeroDeclaracao,
	iCNPJID,
	cReferenciaBraslog,
	cReferenciaCliente,
	dDataRegistroDeclaracao,
	dDataDesembaracoDeclaracao,
	iCEID,
	iRecintoID,
	cNumeroDOSSIE,
	cNumeroProcessoAdministrativo,
	iContratoID,
	iApoliceID,
	cModal,
	cDescricao,
	cHistorico
)
SELECT
	'111111111111',
	iCNPJID,
	'I-25/1000-MBG',
	cReferenciaCliente,
	dDataRegistroDeclaracao,
	dDataDesembaracoDeclaracao,
	iCEID,
	iRecintoID,
	cNumeroDOSSIE,
	cNumeroProcessoAdministrativo,
	iContratoID,
	iApoliceID,
	cModal,
	cDescricao,
	cHistorico
FROM tDeclaracao
WHERE iDeclaracaoID = 19;


BEGIN TRANSACTION;
GO

USE ProcessosTemporarios;
GO

ALTER TABLE tDeclaracao
ADD IsAtivo BIT NOT NULL DEFAULT 1;

SELECT @@TRANCOUNT

SELECT * FROM tDeclaracao;
SELECT * FROM tTipoRegimeAduaneiro;

ALTER TABLE tDeclaracao
ADD iRegimeAduaneiroID INT;
UPDATE tDeclaracao
SET iRegimeAduaneiroID = 3;
GO

ALTER TABLE tDeclaracao
ADD CONSTRAINT FK_tDeclaracao_tTipoRegimeAduaneiro
FOREIGN KEY (iRegimeAduaneiroID) REFERENCES tTipoRegimeAduaneiro(iRegimeAduaneiroID);
GO


COMMIT;


-------------------------------
BEGIN TRANSACTION;

USE ProcessosTemporarios;
GO

/*--------------------------------------------------------------------------------------------        
Objeto tipo: Stored Procedure
Objeto     : stp_insertDataStateTable
objetivo   : Insert dataset in tEstado
Projeto    : ProcessosTemporarios
Criação    : 08/04/2025
Keywords   : INSERT INTO
----------------------------------------------------------------------------------------------        
Observação:        

----------------------------------------------------------------------------------------------        
Historico:        
Autor                  IDBug Data		Descrição
---------------------- ----- ---------- ------------------------------------------------------------        
Marcus V. Paiva Silveira                08/04/2025 Procedure created */

BEGIN TRANSACTION

	BEGIN TRY

	IF NOT EXISTS (SELECT * FROM sys.types WHERE NAME = 'dtInsertDataStateTable')
		BEGIN
			CREATE TYPE dtInsertDataStateTable
			AS TABLE
			(
				cNomeEstado VARCHAR(100),
				cEstadoSigla CHAR(2)
			)
		END

		COMMIT

	END TRY
	BEGIN CATCH		
		
		IF @@TRANCOUNT > 0
			ROLLBACK;

		--EXEC stp_ManipulaErro;

	END CATCH;
GO

CREATE OR ALTER PROCEDURE stp_insertDataStateTable
@tInserirDados dtInsertDataStateTable READONLY
AS BEGIN

	SET NOCOUNT ON

	BEGIN TRANSACTION

	BEGIN TRY

		RAISERROR('Inserindo dados na tabela tEstado...',10,1) WITH NOWAIT;
		WAITFOR DELAY '00:00:02';

		INSERT INTO tEstado
		(
			cNomeEstado,
			cEstadoSigla
		)
		SELECT * FROM @tInserirDados;

		IF @@ROWCOUNT = 0
		BEGIN
			RAISERROR('Dados nao foram inseridos com sucesso!',10,1);
			ROLLBACK;
			RETURN;
		END

		DECLARE @iNumeroColunas INT = (SELECT COUNT(COLUMN_NAME) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tEstado');
		DECLARE @iContador INT = 1;
		DECLARE @cNomeColuna VARCHAR(50);

		WHILE @iContador <= @iNumeroColunas
		BEGIN
			
			SET @cNomeColuna = (SELECT NAME FROM sys.columns WHERE OBJECT_ID = OBJECT_ID('tEstado') AND column_id = @iContador);
			RAISERROR('Populando coluna %s na tabela tEstado...',10,1,@cNomeColuna) WITH NOWAIT;
			WAITFOR DELAY '00:00:02';

			SET @iContador += 1;

		END

		RAISERROR('Todos os dados foram inseridos com sucesso!',10,1) WITH NOWAIT;
		WAITFOR DELAY '00:00:05';

		COMMIT;

	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0
			ROLLBACK

		--EXECUTE stp_ManipulaErro;

	END CATCH;

	SELECT * FROM tEstado;

END
GO

DECLARE @t_tempInserirDados dtInsertDataStateTable

SET NOCOUNT ON
INSERT INTO @t_tempInserirDados VALUES
	('Acre', 'AC'),
('Alagoas', 'AL'),
('Amapá', 'AP'),
('Amazonas', 'AM'),
('Bahia', 'BA'),
('Ceará', 'CE'),
('Distrito Federal', 'DF'),
('Espírito Santo', 'ES'),
('Goiás', 'GO'),
('Maranhão', 10),
('Mato Grosso', 'MT'),
('Mato Grosso do Sul', 'MS'),
('Minas Gerais', 'MG'),
('Pará', 'PA'),
('Paraíba', 'PB'),
('Paraná', 'PR'),
('Pernambuco', 'PE'),
('Piauí', 'PI'),
('Rio de Janeiro', 'RJ'),
('Rio Grande do Norte', 'RN'),
('Rio Grande do Sul', 'RS'),
('Rondônia', 'RO'),
('Roraima', 'RR'),
('Santa Catarina', 'SC'),
('São Paulo', 'SP'),
('Sergipe', 'SE'),
('Tocantins', 'TO');

EXECUTE stp_insertDataStateTable @tInserirDados = @t_tempInserirDados;

DROP PROCEDURE stp_inserirDadosNaTabelaDeclaracao;--deletar procedure
DROP TYPE dtInsertDataDeclaracaoTable;--deletar tipo
DELETE FROM tDeclaracao;--Deletar dados dentro da tabela
ALTER SEQUENCE seqDeclaracaoID RESTART WITH 1;--Reiniciar Sequence

SELECT * FROM tEstado;


-------------------------------------
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


SELECT @@TRANCOUNT
GO

USE ProcessosTemporarios;
GO

BEGIN TRANSACTION
GO

EXEC sp_rename 'tCeMercante', 'tLogistica';
GO

ALTER TABLE tCeMercante
NOCHECK CONSTRAINT ALL;

ALTER TABLE tLogistica
ADD dValorCapatazias DECIMAL(18,2);

SELECT
    fk.name AS FK_Name,
    OBJECT_NAME(fk.parent_object_id) AS TableName,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable
FROM sys.foreign_keys AS fk
WHERE fk.referenced_object_id = OBJECT_ID('tCeMercante');


SELECT name, object_id
FROM sys.triggers
WHERE parent_id = OBJECT_ID('tCeMercante');


SELECT DISTINCT v.name AS ViewName
FROM sys.views v
JOIN sys.sql_expression_dependencies d
    ON v.object_id = d.referencing_id
WHERE d.referenced_entity_name = 'tCeMercante';

-- Lista todas as tabelas do schema dbo
SELECT name 
FROM sys.tables
WHERE name LIKE '%Logistica%';

ALTER TABLE tDeclaracao NOCHECK CONSTRAINT FK_DECLARACAO_CE_ID;

DROP VIEW vCeMercante;

SELECT * FROM tLogistica;

ALTER TABLE tLogistica
ADD
	cConhecimentoEmbarque VARCHAR(50),
    dDataEmbarque DATE,
    cCidadeEmbarque VARCHAR(100),
    cPaisEmbarque VARCHAR(100),
    dDataChegadaBrasil DATE,
    mValorAFRMMSuspenso DECIMAL(18,2),
    mFrete DECIMAL(18,2),
    mOutrasDespesas DECIMAL(18,2),
    cTaxaMercanteStatus CHAR(3),
	mTaxaMercanteValor DECIMAL(5,2);

EXEC sp_rename 'tLogistica.iCEID', 'iLogisticaID', 'COLUMN';

COMMIT;
ROLLBACK;



---------------------------
BEGIN TRANSACTION
USE ProcessosTemporarios;
GO

/*--------------------------------------------------------------------------------------------        
Objeto tipo: Stored Procedure
Objeto     : stp_inserirDadosTabelaRecintoAlfandegado
Objetivo   : Inserir dados na tabela tRecintoAlfandegado 
Projeto    : ProcessosTemporarios
Criação    : 04/02/2025
Execução   : Insert dataset
Palavras-chave: INSERT INTO
----------------------------------------------------------------------------------------------        
Observations :        

----------------------------------------------------------------------------------------------        
Historico:        
Autor                  IDBug  Data			Descrição
Marcus Vinicius	     		  08/02/2025	Inserir dataset como parametro
Marcus Vinicius		   00001  11/02/2025	A tabela UDTT e a tabela original foram criadas com as mesmas colunas e parâmetros,
											porém, está exibindo a mensagem truncated in table 'tempdb.dbo.#A3D0A620' (truncado na tabela 'tempdb.dbo.#A3D0A620').
---------------------- ----- ---------- ------------------------------------------------------------        
Marcus V. Paiva Silveira      04/02/2025 Procedure criada */

--Tipo tabela
IF NOT EXISTS (SELECT * FROM sys.types WHERE name = 'dtInserirDados')
BEGIN
	CREATE TYPE dtInserirDados
	AS TABLE
	(
			cNumeroRecintoAduaneiro CHAR(7),
			cNomeRecinto VARCHAR(500),
			cCidadeRecinto VARCHAR(100),
			cEstadoRecinto VARCHAR(100),
			cUnidadeReceitaFederal CHAR(7)
	)
END
GO

CREATE OR ALTER PROCEDURE stp_inserirDadosTabelaRecintoAlfandegado
@tInserirDados dtInserirDados READONLY
AS
BEGIN

	SET NOCOUNT ON

	BEGIN TRY

		BEGIN TRANSACTION

		RAISERROR('Inserindo dados na tabela tRecintoAlfandegado...',10,1) WITH NOWAIT
		WAITFOR DELAY '00:00:05'

		INSERT INTO tRecintoAlfandegado
		(
			cNumeroRecintoAduaneiro,
			cNomeRecinto,
			cCidadeRecinto,
			cEstadoRecinto,
			cUnidadeReceitaFederal
		)
		SELECT 
			cNumeroRecintoAduaneiro, 
			cNomeRecinto,
			cCidadeRecinto, 
			cEstadoRecinto, 
			cUnidadeReceitaFederal
		FROM @tInserirDados;
		

		IF @@ROWCOUNT = 0
			RAISERROR('Dados não foram inseridos',10,1);

		COMMIT;

	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0
			ROLLBACK;

		EXEC stp_ManipulaErro;

	END CATCH

	SELECT * FROM tRecintoAlfandegado;
END
GO

--Variavel tipo tabela
DECLARE @t_tempInserirDados dtInserirDados;

INSERT INTO @t_tempInserirDados VALUES
	(2931605, 'Inst.Por.Fluv.Alf-Uso Privativo-Chibatao Nav. Com-Manaus/Am', 'Porto de Manaus', 'PORTO de MANAUS', 0227600),
	(8943209, 'Eadi-Lachmann Terminais Ltda.-Sao Bernardo Do Campo/Sp', 'São Paulo', 'SÃO PAULO', 0817900),
	(3911301, 'Porto de Fortaleza - Cia. Docas do Ceara - Porto Maritimo ALF.', 'Fortaleza', 'Ceará', 0317900),
	(3931301, 'Aurora Terminais e Serviços Ltda.', 'São Luís', 'Maranhão', 0317903),
	(4931304, 'Inst. Port. Uso Publ. - Suata Serv. Log. Ltda.', 'Ipojuca', 'Pernambuco', 0417902),
	(4931305, 'Inst. Port. Uso Publ. - Atlântico Terminais S. A.', 'Porto de Suape', 'Pernambuco', 0417902),
	(5921301, 'Porto de Salvador - Codeba - Porto Marit. Alf. - Uso Publico', 'Salvador', 'Bahia', 0517800),
	(5921304, 'Inst. Port. Uso Público - Intermarítima Terminais Ltda.', 'Salvador', 'Bahia', 0517800),
	(7301402, 'Tmult - Porto do Açú Operações S.A.', 'Campos dos Goytacazes', 'Rio de Janeiro', 0710400),
	(7920001, 'Pátio do Porto Do Rio de Janeiro', 'Rio de Janeiro', 'Rio de Janeiro', 0717600),
	(7921302, 'ICTSI Rio Brasil Terminal 1 S.A.', 'Rio de Janeiro', 'Rio de Janeiro', 0717600),
	(7921303, 'Inst. Port. Mar. Alf. Uso Publ. Cons. Mult Rio-T.II - Porto Rj', 'Rio de Janeiro', 'Rio de Janeiro', 0717600),
	(8813201, 'EADI - Aurora Terminais e Serviços Ltda.', 'Sorocaba', 'São Paulo', 0811000),
	(8911101, 'Concessionária do Aeroporto Internacional de Guarulhos S.A.', 'Guarulhos', 'São Paulo', 0817600),
	(8931359, 'Brasil Terminal Portuário S.A.', 'Santos', 'São Paulo', 0817800),
	(8943204, 'EADI - Embragem - Av.Mackenzie, 137, Jaguare', 'São Paulo', 'São Paulo', 0817900),
	(8943208, 'EADI Santo Andre Terminal de Cargas Ltda.', 'São Paulo', 'São Paulo', 0815500),
	(8943213, 'Aurora Terminais e Serviços Ltda.', 'São Paulo', 'São Paulo', 0817900),
	(9801303, 'TCP - Terminal de Conteineres de Paranagua S/A', 'Paranaguá', 'Paraná', 0917800)

EXEC stp_inserirDadosTabelaRecintoAlfandegado @tInserirDados = @t_tempInserirDados;

--Fim da Procedure

-- 00001 - resolver o erro de tabela truncada inserindo manualmente passo a passo. Foi resolvido: excluí a tabela type e a recriei, os dados foram inseridos com sucesso.
SELECT @@TRANCOUNT --há transação aberta

--Tabela orginal, dados são inseridos
INSERT INTO tRecintoAlfandegado
( cNumeroRecintoAduaneiro,
			cNomeRecinto,
			cCidadeRecinto,
			cEstadoRecinto,
			cUnidadeReceitaFederal)
VALUES
(3911301, 'Porto de Fortaleza - Cia. Docas do Ceara - Porto Maritimo ALF.', 'Fortaleza', 'Ceará', 0317900),
(5921301, 'Porto de Salvador - Codeba - Porto Marit. Alf. - Uso Publico', 'Salvador', 'Bahia', 0517800)

DROP PROCEDURE stp_inserirDadosTabelaRecintoAlfandegado --drop procedure que contem a variavel tipo tabela

DROP TYPE dtInserirDados;--deletar tipo tabela

CREATE TYPE dtInserirDados --criar de novo o tipo tabela
AS TABLE
(
		cNumeroRecintoAduaneiro CHAR(7),
		cNomeRecinto VARCHAR(500),
		cCidadeRecinto VARCHAR(100),
		cEstadoRecinto VARCHAR(100),
		cUnidadeReceitaFederal CHAR(7)
)

SELECT LEN('Porto de Fortaleza - Cia. Docas do Ceara - Porto Maritimo ALF.') -- verificar tamanho da string
--Fim do teste


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
CREATE OR ALTER VIEW vRecintoAlfandegado
WITH ENCRYPTION, SCHEMABINDING
AS
SELECT td.cReferenciaBraslog AS [Referencia Braslog], CONCAT(tr.cNomeRecinto,' - ', tr.cCidadeRecinto,'/',
	CASE
		WHEN tr.cEstadoRecinto = 'Bahia' THEN'BA'
		WHEN tr.cEstadoRecinto = 'Ceará' THEN'CE'
		WHEN tr.cEstadoRecinto = 'Maranhão' THEN10
		WHEN tr.cEstadoRecinto = 'Pernambuco' THEN'PE'
		WHEN tr.cEstadoRecinto = 'Rio de Janeiro' THEN'RJ'
		WHEN tr.cEstadoRecinto = 'São Paulo' THEN'SP'
		WHEN tr.cEstadoRecinto = 'Paraná' THEN 'PR'
		WHEN tr.cEstadoRecinto = 'Amazonas' THEN 'AM'
	END) AS [Recinto Alfandegado], tr.cUnidadeReceitaFederal AS [URF de Despacho], tr.cNumeroRecintoAduaneiro AS [Código do Recinto]
	FROM dbo.tRecintoAlfandegado tr
INNER JOIN dbo.tDeclaracao td
ON tr.iRecintoID = td.iRecintoID
WITH CHECK OPTION
GO
--Fim da View

SELECT * FROM vRecintoAlfandegado
GO

BEGIN TRANSACTION
	UPDATE tRecintoAlfandegado
	SET cEstadoRecinto = 'Amazonas', cCidadeRecinto = 'Manaus'
	WHERE iRecintoID = 1;
	
IF @@ROWCOUNT > 0
	COMMIT;
ELSE
	ROLLBACK;
GO

BEGIN TRANSACTION
	UPDATE tRecintoAlfandegado
	SET cEstadoRecinto = 'São Paulo'
	WHERE iRecintoID = 2;
	
IF @@ROWCOUNT > 0
	COMMIT;
ELSE
	ROLLBACK;
GO

SELECT* FROM tRecintoAlfandegado
GO

DROP VIEW vApoliceSeguroGarantia;
GO

DROP VIEW vRecintoAlfandegado;
GO

BEGIN TRANSACTION;
ALTER TABLE tRecintoAlfandegado
DROP COLUMN cCidadeRecinto, cEstadoRecinto;

ALTER TABLE tRecintoAlfandegado
ADD iCidadeID INT;


ALTER TABLE tRecintoAlfandegado
ADD CONSTRAINT FK_tRecinto_tCidade
FOREIGN KEY (iCidadeID) REFERENCES tCidade(iCidadeID);
COMMIT;
ROLLBACK;
GO

SELECT @@TRANCOUNT

--Adicionar 0 a esquerda de todos URF
BEGIN TRANSACTION
UPDATE tRecintoAlfandegado
SET cUnidadeReceitaFederal = '0' + cUnidadeReceitaFederal
WHERE LEFT(cUnidadeReceitaFederal, 1) != '0';

USE ProcessosTemporarios;
GO

BEGIN TRANSACTION
GO

ALTER TABLE tRecintoAlfandegado
ADD cNomeUnidadeReceitaFederal VARCHAR(200)
GO

SELECT * FROM tRecintoAlfandegado;


------------------------------
USE ProcessosTemporarios;
GO

BEGIN TRANSACTION;
GO

COMMIT;
ROLLBACK;

SELECT @@TRANCOUNT

INSERT INTO tTipoRegimeAduaneiro (cNomeRegimeAduaneiro)
VALUES
	 ('Suspensão Total'),
    ('Utilização Economica'),
    ('Exportação Temporária'),
    ('Entreposto Aduaneiro');


SELECT * FROM tTipoRegimeAduaneiro ORDER BY iRegimeAduaneiroID;