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
											porém, está exibindo a mensagem "truncated in table 'tempdb.dbo.#A3D0A620'" (truncado na tabela 'tempdb.dbo.#A3D0A620').
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

-- 00001 - try to solve the truncated table error using a step by step way, (it was solved, excluded the type table and do it again, datas inserted succesfully)
SELECT @@TRANCOUNT --is there transaction opened?

--Original table, datas are inserted
INSERT INTO tRecintoAlfandegado
( cNumeroRecintoAduaneiro,
			cNomeRecinto,
			cCidadeRecinto,
			cEstadoRecinto,
			cUnidadeReceitaFederal)
VALUES
(3911301, 'Porto de Fortaleza - Cia. Docas do Ceara - Porto Maritimo ALF.', 'Fortaleza', 'Ceará', 0317900),
(5921301, 'Porto de Salvador - Codeba - Porto Marit. Alf. - Uso Publico', 'Salvador', 'Bahia', 0517800)

DROP PROCEDURE stp_inserirDadosTabelaRecintoAlfandegado --drop procedure that contains the type table

DROP TYPE dtInserirDados;--drop type table

CREATE TYPE dtInserirDados --create again type table
AS TABLE
(
		cNumeroRecintoAduaneiro CHAR(7),
		cNomeRecinto VARCHAR(500),
		cCidadeRecinto VARCHAR(100),
		cEstadoRecinto VARCHAR(100),
		cUnidadeReceitaFederal CHAR(7)
)

SELECT LEN('Porto de Fortaleza - Cia. Docas do Ceara - Porto Maritimo ALF.') -- verify this one text length
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
AS
SELECT CONCAT(tr.cNomeRecinto,' - ', tr.cCidadeRecinto,'/',
	CASE
		WHEN tr.cEstadoRecinto = 'Bahia' THEN'BA'
		WHEN tr.cEstadoRecinto = 'Ceará' THEN'CE'
		WHEN tr.cEstadoRecinto = 'Maranhão' THEN'MA'
		WHEN tr.cEstadoRecinto = 'Pernambuco' THEN'PE'
		WHEN tr.cEstadoRecinto = 'Rio de Janeiro' THEN'RJ'
		WHEN tr.cEstadoRecinto = 'São Paulo' THEN'SP'
		WHEN tr.cEstadoRecinto = 'Paraná' THEN 'PR'
		WHEN tr.cEstadoRecinto = 'Amazonas' THEN 'AM'
	END) AS [Recinto Alfandegado], tr.cUnidadeReceitaFederal AS [URF de Despacho], tr.cNumeroRecintoAduaneiro AS [Código do Recinto] FROM tRecintoAlfandegado tr
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