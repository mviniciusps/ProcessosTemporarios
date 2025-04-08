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

/*--------------------------------------------------------------------------------------------        
Tipo Objeto: View
Objeto     : vDeclaracao
Objetivo   : Mostrar todas as informações relevantes do processo
Criado em  : 05/04/2025
Palavras-chave: Declaração
----------------------------------------------------------------------------------------------        
Observações : 

----------------------------------------------------------------------------------------------        
Histórico:        
Autor                  IDBug Data       Descrição        
---------------------- ----- ---------- ------------------------------------------------------------        
Marcus Paiva				 05/04/2025 Criação da View
*/
CREATE OR ALTER VIEW vDeclaracao
WITH ENCRYPTION, SCHEMABINDING
AS
	SELECT UPPER(LEFT(tc.cNomeEmpresarial, CHARINDEX(' ',tc.cNomeEmpresarial))) AS Cliente,
	LEFT(td.cNumeroDeclaracao,2) + '/' +
	SUBSTRING(td.cNumeroDeclaracao,3,7) + '-' +
	RIGHT(td.cNumeroDeclaracao,1) AS [Declaração de Importação],
	td.cReferenciaBraslog AS [Referencia Braslog],
	ISNULL(td.cReferenciaCliente,'') AS [Referencia Cliente],
	tce.cStatusCE AS AFRMM,
	LEFT(tce.cNumeroCE,3) + '.' +
	SUBSTRING(tce.cNumeroCE,4,3) + '.' +
	SUBSTRING(tce.cNumeroCE,7,3) + '.' +
	SUBSTRING(tce.cNumeroCE,10,3) + '.' +
	RIGHT(tce.cNumeroCE,3)
	AS [Número do CE Mercante],
	tco.cNumeroNomeContrato AS Contrato,
	tco.dContratoVencimento AS [Prazo solicitado],
	td.dDataRegistroDeclaracao AS [Data Registro],
	td.dDataDesembaracoDeclaracao AS [Data Desembaraço],
	tr.cNomeRecinto AS [Unidade Desembaraço],
	 tc.cNomeEmpresarial AS [Razão Social],
		LEFT(tc.cNumeroInscricao, 2) + '.' +
		SUBSTRING(tc.cNumeroInscricao, 3, 3) + '.' +
		SUBSTRING(tc.cNumeroInscricao, 6, 3) + '/' +
		SUBSTRING(tc.cNumeroInscricao, 9, 4) + '-' +
		RIGHT(tc.cNumeroInscricao, 2) AS CNPJ,
	ISNULL(td.cNumeroProcessoAdministrativo,'') AS [E-CAC],
	LEFT(td.cNumeroDOSSIE,14) + '-' +
	RIGHT(td.cNumeroDOSSIE,1) AS DOSSIE
	FROM dbo.tDeclaracao td
	INNER JOIN dbo.tCNPJ tc
	ON td.iCNPJID = tc.iCNPJID
	INNER JOIN dbo.tCeMercante tce
	ON tce.iCEID = td.iCEID
	INNER JOIN dbo.tContrato tco
	ON tco.iContratoID = td.iContratoID
	INNER JOIN dbo.tRecintoAlfandegado tr
	ON tr.iRecintoID = td.iRecintoID
	WITH CHECK OPTION
GO
--FIM da VIEW vDeclaracao

SELECT * FROM vDeclaracao
GO

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