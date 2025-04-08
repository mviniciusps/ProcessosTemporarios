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