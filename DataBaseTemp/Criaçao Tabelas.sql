/*------------------------------------------------------------
Author   : Marcus Paiva
DataBase : ProcessosTemporarios
Objective: Transferir os dados de controle da planilha
Date	 : 26/10/2025
------------------------------------------------------------*/
	CREATE DATABASE ProcessosTemporarios
	ON
	(
		NAME = ProcessosTemporarios_dados,
		FILENAME = 'C:\Dados\ProcessosTemporarios.mdf',
		SIZE = 100MB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 10MB
	)
	LOG ON
	(
		NAME = ProcessosTemporarios_log,
		FILENAME = 'C:\Log\ProcessosTemporarios.ldf',
		SIZE = 50MB,
		MAXSIZE = 1GB,
		FILEGROWTH = 5MB
	);
	GO

	USE ProcessosTemporarios;
	GO
--------------------------------------------------------------------------


-------------------------------------------------------------------------- BEGIN tRegimeAduaneiro
--START CREATING tRegimeAduaneiro TABLE

--sequence as id for table
CREATE SEQUENCE seqRegimeAduaneiro
	AS INT
	START WITH 1
	INCREMENT BY 1;
GO

--creating tRegimeAduaneiro table
SET NOCOUNT ON

BEGIN TRANSACTION

	BEGIN TRY

	DECLARE @NomeTabela NVARCHAR(50) = 'tRegimeAduaneiro';
	DECLARE @ColunasTabela TABLE (Coluna NVARCHAR(50), Tipo NVARCHAR(100));
	DECLARE @SqlComando NVARCHAR(MAX) = '';

	--Set columns
	INSERT INTO @ColunasTabela (Coluna, Tipo)
	VALUES
	('iRegimeAduaneiroID', 'INT NOT NULL DEFAULT(NEXT VALUE FOR seqRegimeAduaneiro)'),
	('cNomeRegimeAduaneiro', 'VARCHAR(50) NOT NULL');

	--Command CREATE TABLE
	SET @SqlComando = 'CREATE TABLE ' + @NomeTabela + ' (';

	DECLARE @Coluna NVARCHAR(50), @Tipo NVARCHAR(100);

	DECLARE Cur CURSOR FOR
		SELECT Coluna, Tipo FROM @ColunasTabela;

	OPEN cur;
	FETCH NEXT FROM Cur INTO @Coluna, @Tipo;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		--Add Column Message
		RAISERROR( 'Adding column: %s', 0, 1, @Coluna) WITH NOWAIT;

		WAITFOR DELAY '00:00:05';

		--Add to SQL
		SET @SqlComando += @Coluna + ' ' + @Tipo + ', ';

		FETCH NEXT FROM Cur INTO @Coluna, @Tipo;
	END

	CLOSE cur;
	DEALLOCATE cur;

	--Remove last common
	SET @SqlComando = LEFT(@SqlComando, LEN(@SqlComando)-1) + ');';

    EXEC(@SqlComando);

    -- Add constraints
    ALTER TABLE tRegimeAduaneiro
        ADD CONSTRAINT PK_REGIME_ADUANEIRO_ID PRIMARY KEY(iRegimeAduaneiroID);

    ALTER TABLE tRegimeAduaneiro
        ADD CONSTRAINT UQ_NOME_REGIME_ADUANEIRO UNIQUE(cNomeRegimeAduaneiro);

	--Show Table created
	SELECT * FROM tRegimeAduaneiro;--select table just be created

	COMMIT TRANSACTION;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Erro: %s', 16, 1, @ErrorMessage);

END CATCH;
GO
-------------------------------------------------------------------------- END tRegimeAduaneiro
/*
*/
-------------------------------------------------------------------------- BEGIN tModal
--START CREATING tModal TABLE

--sequence as id for table
CREATE SEQUENCE seqModal
	AS INT
	START WITH 1
	INCREMENT BY 1;
GO

--creating tRecintoAlfandegado using standard way
SET NOCOUNT ON

BEGIN TRANSACTION

	BEGIN TRY

	DECLARE @TableName NVARCHAR(50) = 'tModal';
	DECLARE @TableColumns TABLE (Collumn NVARCHAR(50), Typpe NVARCHAR(100));
	DECLARE @SqlCommand NVARCHAR(MAX) = '';

	--Set columns
	INSERT INTO @TableColumns (Collumn, Typpe)
	VALUES
	('iModalID', 'INT NOT NULL DEFAULT(NEXT VALUE FOR seqModal)'),
	('cNomeModal', 'VARCHAR(50) NOT NULL');

	--Command CREATE TABLE
	SET @SqlCommand = 'CREATE TABLE ' + @TableName+ ' (';

	DECLARE @Column NVARCHAR(50), @type NVARCHAR(100);

	DECLARE Cur CURSOR FOR
		SELECT Collumn, Typpe FROM @TableColumns;

	OPEN cur;
	FETCH NEXT FROM Cur INTO @Column, @Type;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		--Add Column Message
		RAISERROR( 'Adding column: %s', 0, 1, @Column) WITH NOWAIT;

		WAITFOR DELAY '00:00:05';

		--Add to SQL
		SET @SqlCommand+= @Column + ' ' + @type + ', ';

		FETCH NEXT FROM Cur INTO @Column, @Type;
	END

	CLOSE cur;
	DEALLOCATE cur;

	--Remove last common
	SET @SqlCommand = LEFT(@SqlCommand, LEN(@SqlCommand)-1) + ');';

    EXEC(@SqlCommand);

    -- Add constraints
    ALTER TABLE tModal
        ADD CONSTRAINT PK_MODAL_ID PRIMARY KEY(iModalID);

    ALTER TABLE tModal
        ADD CONSTRAINT UQ_NOME_MODAL UNIQUE(cNomeModal);

	--Show Table created
	SELECT * FROM tModal;--select table just be created

	COMMIT TRANSACTION;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR('Erro: %s', 16, 1, @ErrorMessage);

END CATCH;
GO
-------------------------------------------------------------------------- END tModal
/*
*/
-------------------------------------------------------------------------- BEGIN tEstado
--START CREATING tEstado TABLE
USE ProcessosTemporarios;

--sequence as id for table
CREATE SEQUENCE seqEstadoID
	AS INT
	START WITH 1
	INCREMENT BY 1;
GO
--creating tEstado using dinamic way with variables
SET NOCOUNT ON

BEGIN TRANSACTION

	BEGIN TRY

	DECLARE @NomeTabela VARCHAR(50) = 'tEstado';
	DECLARE @ColunasTabela TABLE (Coluna VARCHAR(50), Tipo NVARCHAR(100));
	DECLARE @SqlComando VARCHAR(MAX) = '';
	DECLARE @Contador INT = 0;

	INSERT INTO @ColunasTabela (Coluna, Tipo)
	VALUES
	('iEstadoID', 'INT NOT NULL DEFAULT(NEXT VALUE FOR seqEstadoID)'),
	('cEstadoNome', 'VARCHAR(100) NOT NULL'),
	('cEstadoSigla', 'CHAR(2) NOT NULL'),
	('mAliqICMS', 'DECIMAL(5,2) NOT NULL');

	SET @SqlComando = 'CREATE TABLE ' + @NomeTabela + ' (';

	DECLARE @Coluna VARCHAR(50), @Tipo VARCHAR(50);

	DECLARE cur CURSOR FOR
		SELECT Coluna, Tipo FROM @ColunasTabela;

	OPEN cur;
	FETCH NEXT FROM cur INTO @Coluna, @Tipo;

	WHILE @@FETCH_STATUS = 0
	BEGIN

		RAISERROR('Adding column: %s to table %s', 0, 1,@Coluna,@NomeTabela) WITH NOWAIT;
		WAITFOR DELAY '00:00:05';

		SET @SqlComando += @Coluna + ' ' + @Tipo + ', ';

		SET @Contador += 1;

		FETCH NEXT FROM cur INTO @Coluna, @Tipo;

	END

	CLOSE cur;
	DEALLOCATE cur;

	SET @SqlComando = LEFT(@SqlComando, LEN(@SqlComando)-1) + ');';

	EXEC(@SqlComando);

	RAISERROR('%d colunas adicionadas a tabela %s', 0, 1, @Contador, @NomeTabela) WITH NOWAIT;

	ALTER TABLE tEstado
		ADD CONSTRAINT PK_ESTADO_ID PRIMARY KEY(iEstadoID);

	ALTER TABLE tEstado
		ADD CONSTRAINT UQ_ESTADO_NOME UNIQUE(cEstadoNome);

	ALTER TABLE tEstado
		ADD CONSTRAINT UQ_ESTADO_SIGLA UNIQUE(cEstadoSigla);

	SELECT * FROM tEstado;

	COMMIT TRANSACTION;

END TRY
BEGIN CATCH

	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

	DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
	RAISERROR('Erro: %s', 16, 1, @ErrorMessage);

END CATCH;
GO
-------------------------------------------------------------------------- END tEstado
/*
*/
-------------------------------------------------------------------------- BEGIN tContrato
--START CREATING tContrato TABLE
USE ProcessosTemporarios;

IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION;

--sequence as id for table
IF NOT EXISTS (
	SELECT 1 FROM sys.sequences WHERE name = 'seqContratoID'
)
BEGIN
	CREATE SEQUENCE seqContratoID
		AS INT
		START WITH 1
		INCREMENT BY 1;
END
GO

--creating tContrato using dinamic way with variables
SET NOCOUNT ON

BEGIN TRANSACTION

	BEGIN TRY

		DECLARE @NomeTabela VARCHAR(50) = 'tContrato';
		DECLARE @ColunasTabela TABLE (Coluna VARCHAR(100), Tipo VARCHAR(100));
		DECLARE @SqlComando VARCHAR(MAX) = '';
		DECLARE @Contador INT = 0;

		INSERT INTO @ColunasTabela (Coluna, Tipo)
		VALUES
		('iContratoID', 'INT NOT NULL DEFAULT(NEXT VALUE FOR seqContratoID)'),
		('cNomeContrato', 'VARCHAR(200) NOT NULL'),
		('cNomeTipo', 'VARCHAR(25) NOT NULL'),
		('dContratoDataAssinatura', 'DATE'),
		('dContratoVencimento', 'DATE NOT NULL');

		SET @SqlComando = 'CREATE TABLE ' + @NomeTabela + ' (';

		DECLARE @Coluna VARCHAR(50), @Tipo VARCHAR(50);

		DECLARE cur CURSOR FOR
			SELECT Coluna, Tipo FROM @ColunasTabela;

		OPEN cur;
		FETCH NEXT FROM Cur INTO @Coluna, @Tipo;

		WHILE @@FETCH_STATUS = 0
		BEGIN

			RAISERROR('Adicionando coluna %s', 0, 1, @Coluna) WITH NOWAIT;
			WAITFOR DELAY '00:00:05';

			SET @SqlComando += @Coluna + ' '  + @Tipo + ', ';

			FETCH NEXT FROM cur INTO @Coluna, @Tipo;

		END

		CLOSE cur;
		DEALLOCATE cur;

		SET @SqlComando = LEFT(@SqlComando, LEN(@SqlComando)-1) + ');';

		EXEC(@SqlComando);

		ALTER TABLE tContrato
			ADD CONSTRAINT PK_CONTRATO_ID PRIMARY KEY(iContratoID);

		SELECT * FROM tContrato;

		COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
		RAISERROR('Erro: %s',16,1, @ErrorMessage);

	END CATCH;
GO
-------------------------------------------------------------------------- END tContrato
/*
*/
-------------------------------------------------------------------------- BEGIN tCeMercanteStatus
--START CREATING tCeMercanteStatus TABLE
USE ProcessosTemporarios;

IF @@TRANCOUNT > 0
	ROLLBACK;

--sequence as id for table
IF NOT EXISTS (SELECT 1 FROM sys.sequences WHERE name = 'seqtCeMercanteStatusID')
BEGIN
CREATE SEQUENCE seqtCeMercanteStatusID
	AS INT
	START WITH 1
	INCREMENT BY 1;
END
GO

--creating tContrato using dinamic way with variables
BEGIN TRANSACTION

	SET NOCOUNT ON;	

	BEGIN TRY

		IF @@TRANCOUNT > 1
		BEGIN
			RAISERROR('Há Transações abertas, fechando transações, tente rodar o codigo novamente',10,1);
			ROLLBACK;
			RETURN;
		END;
				
		DECLARE @NomeTabela VARCHAR(50) = 'tCeMercanteStatus';
		DECLARE @ColunasTabela TABLE (Coluna VARCHAR(100), Tipo VARCHAR(100));
		DECLARE @SqlComando VARCHAR(MAX) = '';
		DECLARE @Contador INT = 0;

		INSERT INTO @ColunasTabela (Coluna, Tipo)
		VALUES
		('iStatusCeID','INT NOT NULL DEFAULT(NEXT VALUE FOR seqtCeMercanteStatusID)'),
		('cStatusCe','VARCHAR(25) NOT NULL');

		SET @SqlComando = 'CREATE TABLE ' + @NomeTabela + ' (';

		DECLARE @Coluna VARCHAR(100), @Tipo VARCHAR(100);

		DECLARE cur CURSOR FOR
			SELECT Coluna, Tipo FROM @ColunasTabela;

		OPEN cur;
		FETCH NEXT FROM cur INTO @Coluna, @Tipo;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			RAISERROR('Adicionando coluna %s do tipo %s, na tabela %s', 0, 1,@Coluna, @Tipo, @NomeTabela) WITH NOWAIT;
			WAITFOR DELAY '00:00:02';

			SET @SqlComando += @Coluna + ' ' + @Tipo + ', ';
			SET @Contador += 1;
			FETCH NEXT FROM cur INTO @Coluna, @Tipo;

		END

		CLOSE cur;
		DEALLOCATE cur;

		SET @SqlComando = LEFT(@SqlComando, LEN(@SqlComando)-1) + ');';

		EXEC(@SqlComando);

		ALTER TABLE tCeMercanteStatus
			ADD CONSTRAINT PK_STATUS_CE_ID PRIMARY KEY(iStatusCeID);
		
		ALTER TABLE tCeMercanteStatus
			ADD CONSTRAINT UQ_STATUS_CE UNIQUE(cStatusCe);

		RAISERROR('%d colunas adicionadas com sucesso a tabela %s', 0, 1, @Contador, @NomeTabela);

		SELECT * FROM tCeMercanteStatus;

		COMMIT;

	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0
		ROLLBACK;

		DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
		RAISERROR('Erro: %s', 16, 1, @ErrorMessage);

	END CATCH;
GO
-------------------------------------------------------------------------- END tCeMercanteStatus
/*
*/
-------------------------------------------------------------------------- BEGIN tPais
--CRIAÇÃO da tabela tPais
USE ProcessosTemporarios;
IF @@TRANCOUNT > 0
BEGIN
	RAISERROR('Encerrando execuçao, transaçao aberta. Fechando...', 0, 1);
	ROLLBACK;
END

--sequence como id para a tabela
IF NOT EXISTS( SELECT 1 FROM sys.sequences WHERE name = 'seqtPaisID')
BEGIN
	CREATE SEQUENCE seqtPaisID
	AS INT
	START WITH 1
	INCREMENT BY 1;
END
GO

--criaçao da tabela usando variaveis dinamicas
BEGIN TRANSACTION

BEGIN TRY

	DECLARE @NomeTabela VARCHAR(100) = 'tPais';
	DECLARE @ColunasTabela TABLE (Coluna VARCHAR(100), Tipo VARCHAR(100));
	DECLARE @SqlComando VARCHAR(MAX) = '';
	DECLARE @Contador INT = 0;
	DECLARE @Coluna VARCHAR(100), @Tipo VARCHAR(100);

	INSERT INTO @ColunasTabela (Coluna, Tipo)
	VALUES
	('iPaisID','INT NOT NULL DEFAULT(NEXT VALUE FOR seqtPaisID)'),
	('cPaisNome','VARCHAR(100) NOT NULL');

	SET @SqlComando = 'CREATE TABLE ' + @NomeTabela + ' (';

	DECLARE cur CURSOR FOR
		SELECT Coluna, Tipo FROM @ColunasTabela;

	OPEN cur;
	FETCH NEXT FROM cur INTO @Coluna, @Tipo;

	WHILE @@FETCH_STATUS = 0
	BEGIN

		RAISERROR('Adicionando a coluna %s na tabela %s', 0, 1, @Coluna, @NomeTabela) WITH NOWAIT;
		WAITFOR DELAY '00:00:02';

		SET @SqlComando += @Coluna + ' ' + @Tipo + ', ';

		FETCH NEXT FROM cur INTO @Coluna, @Tipo;

	END

	CLOSE cur;
	DEALLOCATE cur;

	SET @SqlComando = LEFT(@SqlComando,LEN(@SqlComando)-1) + ');';

	EXEC(@SqlComando);

	ALTER TABLE tPais
		ADD CONSTRAINT PK_PAIS_ID PRIMARY KEY(iPaisID);

	ALTER TABLE tPais
		ADD CONSTRAINT UQ_NOME_PAIS UNIQUE(cPaisNome);

	SELECT * FROM tPais;

	COMMIT;

END TRY
BEGIN CATCH

	IF @@TRANCOUNT > 0
		ROLLBACK;

	DECLARE @ErrorMessage VARCHAR(MAX) = ERROR_MESSAGE();
	RAISERROR('Err: %s', 16, 1, @ErrorMessage);

END CATCH;
GO
-------------------------------------------------------------------------- END tPais
/*
*/
-------------------------------------------------------------------------- COMEÇO tNCM
--COMEÇO CRIAÇAO DA TABELA tNCM

EXEC stp_CriaTabela
@cSequenceNome = 'seqiNCM',
@cNomeTabela = 'tNCM',
@cNomeColunas = 'iNCM|cNCM|mAliqII|mAliqIPI|mAliqPIS|mAliqCofins',
@cTipoColunas = 'INT NOT NULL|CHAR(8) NOT NULL|DECIMAL(5,2) NOT NULL|DECIMAL(5,2) NOT NULL|DECIMAL(5,2) NOT NULL|DECIMAL(5,2) NOT NULL';

-------------------------------------------------------------------------- END tPais
/*
*/
-------------------------------------------------------------------------- COMEÇO tNCM
--COMEÇO CRIAÇAO DA TABELA tNCM
USE ProcessosTemporarios
GO

EXEC stp_CriaTabela
@cSequenceNome = 'seqtTaxaCambio',
@cNomeTabela = 'tTaxaCambio',
@cNomeColunas = 'iTaxaID|iDataRegistro|cCodigoMoeda|mTaxaCambio',
@cTipoColunas = 'INT NOT NULL|DATE NOT NULL|CHAR(3) NOT NULL|DECIMAL(5,4)';
-------------------------------------------------------------------------- END tNCM
/*
*/
-------------------------------------------------------------------------- COMEÇO tProcesso
--COMEÇO CRIAÇAO DA TABELA tProcesso
USE ProcessosTemporarios
GO

EXEC stp_CriaTabela
@cSequenceNome = 'seqiProcessoID',
@cNomeTabela = 'tProcesso',
@cNomeColunas = 'iProcessoID|iModal|iDeclaracaoID|cReferenciaBraslog|cReferenciaCliente|cHistorico|bIsAtivo',
@cTipoColunas = 'INT NOT NULL|INT NOT NULL|INT NOT NULL|CHAR(13) NOT NULL UNIQUE|VARCHAR(100)|VARCHAR(MAX) NOT NULL|BIT NOT NULL DEFAULT(1)';
-------------------------------------------------------------------------- END tNCM
/*
*/
-------------------------------------------------------------------------- COMEÇO tDeclaracao
--COMEÇO CRIAÇAO DA TABELA tDeclaracao
USE ProcessosTemporarios
GO

EXEC stp_CriaTabela
@cSequenceNome = 'seqiDeclaracaoID',
@cNomeTabela = 'tDeclaracao',
@cNomeColunas = 'iDeclaracaoID|iRegimeAduaneiroID|iCNPJID|iContratoID|iApoliceID|iRecintoID|iLogisticaID|iValoresCalculoAduaneiroID',
@cTipoColunas = 'INT NOT NULL|INT NOT NULL|INT NOT NULL|CHAR(13) NOT NULL UNIQUE|VARCHAR(100)|VARCHAR(MAX) NOT NULL|BIT NOT NULL DEFAULT(1)';
-------------------------------------------------------------------------- END tNCM
/*
*/
--------------------------------------------------------------------------
-- Tabela: tCNPJ
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiCNPJID',
    @cNomeTabela = 'tCNPJ',
    @cNomeColunas = 'iCNPJID|iCEPID|CNPJ|NomeEmpresa',
    @cTipoColunas = 'INT NOT NULL|INT NOT NULL|CHAR(14) NOT NULL UNIQUE|VARCHAR(100) NOT NULL';

--------------------------------------------------------------------------
-- Tabela: tCEPID
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiCEPID',
    @cNomeTabela = 'tCEPID',
    @cNomeColunas = 'iCEPID|iCidadeID|Ccep|cLogradouro|cNumeroLogradouro|cBairroLogradouro',
    @cTipoColunas = 'INT NOT NULL|INT NOT NULL|CHAR(8) NOT NULL|VARCHAR(100) NOT NULL|VARCHAR(20)|VARCHAR(100)';

--------------------------------------------------------------------------
-- Tabela: tCidade
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiCidadeID',
    @cNomeTabela = 'tCidade',
    @cNomeColunas = 'iCidadeID|EstadoID|CidadeNome',
    @cTipoColunas = 'INT NOT NULL|INT NOT NULL|VARCHAR(100) NOT NULL';

--------------------------------------------------------------------------
-- Tabela: tApolice
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiApoliceID',
    @cNomeTabela = 'tApolice',
    @cNomeColunas = 'iApoliceID|iRecintoID|cNumeroApolice|dVencimentoGarantia|dValorSegurado',
    @cTipoColunas = 'INT NOT NULL|INT NOT NULL|VARCHAR(25) NOT NULL|DATE NOT NULL|FLOAT';

--------------------------------------------------------------------------
-- Tabela: tRecinto
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiRecintoID',
    @cNomeTabela = 'tRecinto',
    @cNomeColunas = 'iRecintoID|iURFID|iCidadeID|cNumeroRecintoAduaneiro|cNomeRecinto',
    @cTipoColunas = 'INT NOT NULL|INT NOT NULL|INT NOT NULL|CHAR(7) NOT NULL UNIQUE|VARCHAR(100) NOT NULL UNIQUE';

--------------------------------------------------------------------------
-- Tabela: tURF
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiURFID',
    @cNomeTabela = 'tURF',
    @cNomeColunas = 'iURFID|iCidadeID|cUnidadeReceitaFederal|cNomeUnidadeReceitaFederal',
    @cTipoColunas = 'INT NOT NULL|INT NOT NULL|CHAR(7) NOT NULL UNIQUE|VARCHAR(100) NOT NULL UNIQUE';

--------------------------------------------------------------------------
-- Tabela: tLogistica
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiLogisticaID',
    @cNomeTabela = 'tLogistica',
    @cNomeColunas = 'iLogisticaID|iLocalEmbarqueID|iStatusCE|cNumeroCE|cConhecimentoEmbarque|dDataEmbarque|dDataChegadaBrasil|mValorAFRMMSuspenso|mFrete|mOutrasDespesas|cTaxaMercanteStatus|dValorCapatazias',
    @cTipoColunas = 'INT NOT NULL|INT NOT NULL|INT|VARCHAR(15)|VARCHAR(50) NOT NULL|DATE|DATE|FLOAT|FLOAT|FLOAT|FLOAT|FLOAT';

--------------------------------------------------------------------------
-- Tabela: tLocalEmbarque
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiLocalEmbarqueID',
    @cNomeTabela = 'tLocalEmbarque',
    @cNomeColunas = 'iLocalEmbarqueID|iCidadeEmbarqueID|cLocalEmbarque',
    @cTipoColunas = 'INT NOT NULL|INT NOT NULL|VARCHAR(100) NOT NULL UNIQUE';

--------------------------------------------------------------------------
-- Tabela: tCidadeEmbarque
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiCidadeEmbarqueID',
    @cNomeTabela = 'tCidadeEmbarque',
    @cNomeColunas = 'iCidadeEmbarqueID|iPaisID|cNomeCidadeEmbarque',
    @cTipoColunas = 'INT NOT NULL|INT NOT NULL|VARCHAR(100) NOT NULL';

--------------------------------------------------------------------------
-- Tabela: tValoresCalculoAduaneiro
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiValoresCalculoAduaneiroID',
    @cNomeTabela = 'tValoresCalculoAduaneiro',
    @cNomeColunas = 'iValoresCalculoAduaneiroID|dData|cCodigoMoeda|iDeclaracaoID|mAdicoes|mTaxaSiscomex|mSeguro',
    @cTipoColunas = 'INT NOT NULL|DATE NOT NULL|CHAR(3) NOT NULL|INT NOT NULL|INT|FLOAT NOT NULL|FLOAT';

--------------------------------------------------------------------------
-- Tabela: tDeclaracaoItem
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiDeclaracaoItemID',
    @cNomeTabela = 'tDeclaracaoItem',
    @cNomeColunas = 'iDeclaracaoItemID|iDeclaracaoID|iNCM|dDataSELIC|mTaxaSelicAcumulada|iProrrogacao|dDataCalculo|mValorFOB|mPesoLiquido|mValorAduaneiro|mIIValor|mIPIValor|mPISValor|mCOFINSValor|mICMSValor',
    @cTipoColunas = 'INT NOT NULL|INT NOT NULL|INT|DATE|FLOAT|INT DEFAULT(0)|DATE NOT NULL|FLOAT NOT NULL|FLOAT NOT NULL|FLOAT|FLOAT|FLOAT|FLOAT|FLOAT|FLOAT';
