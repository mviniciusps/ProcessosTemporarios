/*--------------------------------------------------------------------------------------------
Tipo Objeto		: Stored Procedure
Nome Objeto		: stp_ManipulaErro
Objetivo		: Usa a area CATCH para capturar qualquer erro que acontece em qualquer momento
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
Objetivo		: Criação de tabelas dinamicamente, evitando scripts grandes
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

    --Declaração das variáveis
    DECLARE @Sql VARCHAR(MAX) = '';
    DECLARE @ColunasTabela TABLE (ID INT IDENTITY(1,1),NomeColuna VARCHAR(MAX));
    DECLARE @TipoColuna TABLE (ID INT IDENTITY(1,1),TipoColuna VARCHAR(MAX));
    DECLARE @Coluna NVARCHAR(MAX), @Tipo VARCHAR(MAX),
            @Contador INT = 0;
    

    --Area para processamento/calculo
    BEGIN TRANSACTION

    BEGIN TRY
        
        --Insere os valores em tabelas temporarias distintas, separando pelo caractere |
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
        
        --Cursor para iterar sobre as linhas das tabelas temporárias
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

/*--------------------------------------------------------------------------------------------        
Tipo Objeto		: Stored Procedure
Objeto Nome		: stp_InserirDados
Objetivo		: Inserir dados abrangendo todas a inserção de todas as tabelas dependendo do
                  Regime Aduaneiro
Projeto			: ProcessosTemporarios
Criação			: 26/11/2025
Execução		: Na inserção de dados
Palavra-chave   : Insert
----------------------------------------------------------------------------------------------        
Observação		: Utiliza SEQUENCE ao invés de IDENTITY para geração de PKs
                  Padrão: INSERT com EXISTS validation + SELECT para atribuição de ID

----------------------------------------------------------------------------------------------        
Histórico		:        
Autor						IDBug Data		Descrição
----------------------		----- ---------- -------------------------------------------------
Marcus V. Paiva Silveira		  26/11/2025 Stored criada
Marcus V. Paiva Silveira    515   30/11/2025 Valor do Id inserido na variavel no if nao alocado
Marcus V. Paiva Silveira		  04/12/2025 Parametros precisão receber mais de um valor
Marcus V. Paiva Silveira		  08/12/2025 Padronização de SET statements e eliminação de redundâncias
Marcus V. Paiva Silveira          08/12/2025 --iCeMercanteStatus sendo inserido como Nulo
*/
CREATE OR ALTER PROCEDURE stp_InserirDados
    @cPaisNome NVARCHAR(100),
    @cNomeCidadeExterior NVARCHAR(100),
    @cNomeModal NVARCHAR(50),
    @cEstadoNomeRecinto NVARCHAR(MAX),
    @cCidadeNomeRecinto NVARCHAR(MAX),
    @cCepRecinto NVARCHAR(MAX),
    @cNomeLogradouroRecinto NVARCHAR(MAX),
    @cBairroLogradouroRecinto NVARCHAR(MAX),
    @cEstadoNomeCnpj NVARCHAR(MAX),
    @cCidadeNomeCnpj NVARCHAR(MAX),
    @cCepCnpj NVARCHAR(MAX),
    @cNomeLogradouroCnpj NVARCHAR(MAX),
    @cBairroLogradouroCnpj NVARCHAR(MAX),
    @cCnpj NVARCHAR(20),
    @cNomeEmpresa NVARCHAR(100),
    @cNumeroApolice NVARCHAR(50) = NULL,
    @dVencimentoGarantia DATE = NULL,
    @mValorSegurado DECIMAL(18,2) = NULL,
    @cNumeroCe NVARCHAR(15) = NULL,
    @cStatusCe NVARCHAR(50) = NULL,
    @mValorAfrmmSuspenso DECIMAL(18,2) = NULL,
    @cConhecimentoEmbarque NVARCHAR(50),
    @dDataEmbarque DATE,
    @dDataChegada DATE = NULL,    
    @cNomeRegimeAduaneiro NVARCHAR(50),
    @dDataRegistro DATE,
    @cNomeRecinto NVARCHAR(100),
    @cNumeroRecintoAduaneiro NVARCHAR(50),
    @cNomeUnidadeReceitaFederal NVARCHAR(100),
    @cUnidadeReceitaFederal NVARCHAR(100),
    @cDescricao NVARCHAR(200) = NULL,
    @cNumeroDeclaracao NVARCHAR(50),
    @cNumeroDossie NVARCHAR(50) = NULL,
    @cNumeroProcessoAdministrativo NVARCHAR(50) = NULL,
    @dDataDesembaraco DATE,
    @cNomeContratoAdmissao NVARCHAR(MAX) = NULL,
    @dContratoDataAssinaturaAdmissao DATE = NULL,
    @dContratoVencimentoAdmissao DATE = NULL,
    @cContratoTipoAdmissao NVARCHAR(50) = NULL,
    @cNomeContratoPrestacaoServico NVARCHAR(MAX) = NULL,
    @dContratoDataAssinaturaPrestacaoServico DATE = NULL,
    @dContratoVencimentoPrestacaoServico DATE = NULL,
    @cContratoTipoPrestacaoServico NVARCHAR(50) = NULL,
    @cReferenciaBraslog NVARCHAR(50),
    @cReferenciaCliente NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @iPaisId INT, @iCidadeExteriorId INT, @iModalId INT, @iEstadoIdRecinto INT, @iEstadoIdCnpj INT,
            @iCidadeIdRecinto INT, @iCidadeIdCnpj INT, @iCepIdRecinto INT, @iCepIdCnpj INT, @iCnpjId INT,
            @iApoliceId INT, @iCeMercanteStatusId INT, @iLogisticaId INT, @iRegimeAduaneiroId INT,
            @iValoresCalculoAduaneiroId INT, @iRecintoId INT, @iUrfId INT, @iContratoTipoIdPrestacao INT, @iContratoTipoIdAdmissao INT, @iContratoIdPrestacao INT, @iContratoIdAdmissao INT, @iDeclaracaoID INT, @iCeId INT;

    BEGIN TRANSACTION;
    BEGIN TRY
    
        -- 1) tPais
        INSERT INTO tPais (cPaisNome) SELECT @cPaisNome WHERE NOT EXISTS (SELECT 1 FROM tPais WHERE cPaisNome = @cPaisNome);
        SET @iPaisId = (SELECT iPaisId FROM tPais WHERE cPaisNome = @cPaisNome);

        -- 2) tCidadeExterior
        INSERT INTO tCidadeExterior (iPaisId, cNomeCidadeExterior) SELECT @iPaisId, @cNomeCidadeExterior 
            WHERE NOT EXISTS (SELECT 1 FROM tCidadeExterior WHERE cNomeCidadeExterior = @cNomeCidadeExterior);
        SET @iCidadeExteriorId = (SELECT iCidadeExteriorId FROM tCidadeExterior WHERE cNomeCidadeExterior = @cNomeCidadeExterior);

        -- 3) tModal
        INSERT INTO tModal (cNomeModal) SELECT @cNomeModal WHERE NOT EXISTS (SELECT 1 FROM tModal WHERE cNomeModal = @cNomeModal);
        SET @iModalId = (SELECT iModalId FROM tModal WHERE cNomeModal = @cNomeModal);

        -- 4) tEstado (Recinto)
        SET @iEstadoIdRecinto = (SELECT iEstadoId FROM tEstado WHERE cEstadoNome = @cEstadoNomeRecinto);

        -- 5) tCidade (Recinto)
        INSERT INTO tCidade (cCidadeNome, iEstadoId) SELECT @cCidadeNomeRecinto, @iEstadoIdRecinto 
            WHERE NOT EXISTS (SELECT 1 FROM tCidade WHERE cCidadeNome = @cCidadeNomeRecinto AND iEstadoId = @iEstadoIdRecinto);
        SET @iCidadeIdRecinto = (SELECT iCidadeId FROM tCidade WHERE cCidadeNome = @cCidadeNomeRecinto AND iEstadoId = @iEstadoIdRecinto);

        -- 6) tCep (Recinto)
        INSERT INTO tCep (iCidadeId, cCep, cNomeLogradouro, cBairroLogradouro) SELECT @iCidadeIdRecinto, @cCepRecinto, @cNomeLogradouroRecinto, @cBairroLogradouroRecinto 
            WHERE NOT EXISTS (SELECT 1 FROM tCep WHERE cCep = @cCepRecinto);
        SET @iCepIdRecinto = (SELECT iCepId FROM tCep WHERE cCep = @cCepRecinto);

        -- 7) tEstado (CNPJ)
        SET @iEstadoIdCnpj = (SELECT iEstadoId FROM tEstado WHERE cEstadoNome = @cEstadoNomeCnpj);

        -- 8) tCidade (CNPJ)
        INSERT INTO tCidade (cCidadeNome, iEstadoId) SELECT @cCidadeNomeCnpj, @iEstadoIdCnpj 
            WHERE NOT EXISTS (SELECT 1 FROM tCidade WHERE cCidadeNome = @cCidadeNomeCnpj AND iEstadoId = @iEstadoIdCnpj);
        SET @iCidadeIdCnpj = (SELECT iCidadeId FROM tCidade WHERE cCidadeNome = @cCidadeNomeCnpj AND iEstadoId = @iEstadoIdCnpj);

        -- 9) tCep (CNPJ)
        INSERT INTO tCep (iCidadeId, cCep, cNomeLogradouro, cBairroLogradouro) SELECT @iCidadeIdCnpj, @cCepCnpj, @cNomeLogradouroCnpj, @cBairroLogradouroCnpj 
            WHERE NOT EXISTS (SELECT 1 FROM tCep WHERE cCep = @cCepCnpj);
        SET @iCepIdCnpj = (SELECT iCepId FROM tCep WHERE cCep = @cCepCnpj);

        -- 10) tCnpj
        INSERT INTO tCnpj (cCnpj, cNomeEmpresa, iCepId) SELECT @cCnpj, @cNomeEmpresa, @iCepIdCnpj 
            WHERE NOT EXISTS (SELECT 1 FROM tCnpj WHERE cCnpj = @cCnpj);
        SET @iCnpjId = (SELECT iCnpjId FROM tCnpj WHERE cCnpj = @cCnpj);

        -- 11) tApolice
        IF @cNumeroApolice IS NOT NULL
        BEGIN
            INSERT INTO tApolice (cNumeroApolice, dVencimentoGarantia, mValorSegurado) SELECT @cNumeroApolice, @dVencimentoGarantia, @mValorSegurado 
                WHERE NOT EXISTS (SELECT 1 FROM tApolice WHERE cNumeroApolice = @cNumeroApolice);
            SET @iApoliceId = (SELECT iApoliceId FROM tApolice WHERE cNumeroApolice = @cNumeroApolice);
        END
        
        -- 12) tCeMercante e tCeMercanteStatus
        IF @cNumeroCe IS NOT NULL
        BEGIN
            INSERT INTO tCeMercanteStatus (cStatusCe) SELECT @cStatusCe WHERE NOT EXISTS (SELECT 1 FROM tCeMercanteStatus WHERE cStatusCe = @cStatusCe);            
            
            SET @iCeMercanteStatusId = (SELECT iCeMercanteStatusId FROM tCeMercanteStatus WHERE cStatusCe = @cStatusCe);

            INSERT INTO tCeMercante (cNumeroCe, iCeMercanteStatusId, mValorAfrmmSuspenso) SELECT @cNumeroCe, @iCeMercanteStatusId,@mValorAfrmmSuspenso 
                WHERE NOT EXISTS (SELECT 1 FROM tCeMercante WHERE cNumeroCe = @cNumeroCe);
            
            SET @iCeId = (SELECT iCeId FROM tCeMercante WHERE cNumeroCe = @cNumeroCe);
        
        END

        -- 13) tLogistica
        INSERT INTO tLogistica (iCeId, iCidadeExteriorId, iModalId, cConhecimentoEmbarque, dDataEmbarque, dDataChegadaBrasil) 
            SELECT @iCeId, @iCidadeExteriorId, @iModalId, @cConhecimentoEmbarque, @dDataEmbarque, @dDataChegada 
            WHERE NOT EXISTS (SELECT 1 FROM tLogistica WHERE cConhecimentoEmbarque = @cConhecimentoEmbarque AND iCidadeExteriorId = @iCidadeExteriorId);
        SET @iLogisticaId = (SELECT iLogisticaId FROM tLogistica WHERE cConhecimentoEmbarque = @cConhecimentoEmbarque AND iCidadeExteriorId = @iCidadeExteriorId);

        -- 14) tRegimeAduaneiro
        INSERT INTO tRegimeAduaneiro (cNomeRegimeAduaneiro) SELECT @cNomeRegimeAduaneiro 
            WHERE NOT EXISTS (SELECT 1 FROM tRegimeAduaneiro WHERE cNomeRegimeAduaneiro = @cNomeRegimeAduaneiro);
        SET @iRegimeAduaneiroId = (SELECT iRegimeAduaneiroId FROM tRegimeAduaneiro WHERE cNomeRegimeAduaneiro = @cNomeRegimeAduaneiro);

        -- 15) tValoresCalculoAduaneiro
        INSERT INTO tValoresCalculoAduaneiro (dDataRegistro) SELECT @dDataRegistro 
            WHERE NOT EXISTS (SELECT 1 FROM tValoresCalculoAduaneiro WHERE dDataRegistro = @dDataRegistro);
        SET @iValoresCalculoAduaneiroId = (SELECT iValoresCalculoAduaneiroId FROM tValoresCalculoAduaneiro WHERE dDataRegistro = @dDataRegistro);

        -- 16) tUrf
        INSERT INTO tUrf (cUnidadeReceitaFederal, cNomeUnidadeReceitaFederal) SELECT @cUnidadeReceitaFederal, @cNomeUnidadeReceitaFederal 
            WHERE NOT EXISTS (SELECT 1 FROM tUrf WHERE cUnidadeReceitaFederal = @cUnidadeReceitaFederal);
        SET @iUrfId = (SELECT iUrfId FROM tUrf WHERE cUnidadeReceitaFederal = @cUnidadeReceitaFederal);

        -- 17) tRecinto
        INSERT INTO tRecinto (cNomeRecinto, cNumeroRecintoAduaneiro, iCepId, iUrfId) SELECT @cNomeRecinto, @cNumeroRecintoAduaneiro, @iCepIdRecinto, @iUrfId 
            WHERE NOT EXISTS (SELECT 1 FROM tRecinto WHERE cNomeRecinto = @cNomeRecinto);
        SET @iRecintoId = (SELECT iRecintoId FROM tRecinto WHERE cNomeRecinto = @cNomeRecinto);

        -- 18) tDeclaracao
        INSERT INTO tDeclaracao (cDescricao, cNumeroDeclaracao, cNumeroDossie, cNumeroProcessoAdministrativo, dDataDesembaraco, iApoliceId, iCnpjId, iLogisticaId, iRecintoId, iRegimeAduaneiroId, iValoresCalculoAduaneiroId) 
            SELECT @cDescricao, @cNumeroDeclaracao, @cNumeroDossie, @cNumeroProcessoAdministrativo, @dDataDesembaraco, @iApoliceId, @iCnpjId, @iLogisticaId, @iRecintoId, @iRegimeAduaneiroId, @iValoresCalculoAduaneiroId 
            WHERE NOT EXISTS (SELECT 1 FROM tDeclaracao WHERE cNumeroDeclaracao = @cNumeroDeclaracao);
        SET @iDeclaracaoId = (SELECT iDeclaracaoId FROM tDeclaracao WHERE cNumeroDeclaracao = @cNumeroDeclaracao);

        -- 19) tContratoTipo (admissao)
        IF @cContratoTipoAdmissao IS NOT NULL
        BEGIN
            INSERT INTO tContratoTipo (cContratoTipo) SELECT @cContratoTipoAdmissao 
                WHERE NOT EXISTS (SELECT 1 FROM tContratoTipo WHERE cContratoTipo = @cContratoTipoAdmissao);
            SET @iContratoTipoIdAdmissao = (SELECT iContratoTipoId FROM tContratoTipo WHERE cContratoTipo = @cContratoTipoAdmissao);
        END

        -- 20) tContratoTipo (prestacao)
        IF @cContratoTipoPrestacaoServico IS NOT NULL
        BEGIN
            INSERT INTO tContratoTipo (cContratoTipo) SELECT @cContratoTipoPrestacaoServico 
                WHERE NOT EXISTS (SELECT 1 FROM tContratoTipo WHERE cContratoTipo = @cContratoTipoPrestacaoServico);
            SET @iContratoTipoIdPrestacao =                             (SELECT iContratoTipoId FROM tContratoTipo WHERE cContratoTipo = @cContratoTipoPrestacaoServico);
        END

        -- 21) tContrato
        INSERT INTO tContrato (cNomeContrato, dContratoDataAssinatura, dContratoVencimento, iContratoTipoId)
        SELECT cNomeContrato, dDataAssinatura, dVencimento, iContratoTipoId
        FROM (VALUES (@cNomeContratoAdmissao, @dContratoDataAssinaturaAdmissao, @dContratoVencimentoAdmissao, @iContratoTipoIdAdmissao),
                     (@cNomeContratoPrestacaoServico, @dContratoDataAssinaturaPrestacaoServico, @dContratoVencimentoPrestacaoServico, @iContratoTipoIdPrestacao)
        ) AS Contratos(cNomeContrato, dDataAssinatura, dVencimento, iContratoTipoId)
        WHERE cNomeContrato IS NOT NULL AND NOT EXISTS (SELECT 1 FROM tContrato WHERE cNomeContrato = Contratos.cNomeContrato);
        
        SET @iContratoIdAdmissao = (SELECT iContratoId FROM tContrato WHERE cNomeContrato = @cNomeContratoAdmissao);
        SET @iContratoIdPrestacao = (SELECT iContratoId FROM tContrato WHERE cNomeContrato = @cNomeContratoPrestacaoServico);

        -- 22) tContratoDeclaracao
        INSERT INTO tContratoDeclaracao (iContratoId, iDeclaracaoId)
        SELECT iContratoId, @iDeclaracaoId FROM (VALUES (@iContratoIdAdmissao), (@iContratoIdPrestacao)) AS ContratoDeclaracao(iContratoId)
        WHERE iContratoId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM tContratoDeclaracao WHERE iContratoId = ContratoDeclaracao.iContratoId AND iDeclaracaoId = @iDeclaracaoId);

        -- 23) tProcesso
        INSERT INTO tProcesso (iDeclaracaoId, cReferenciaBraslog, cReferenciaCliente) SELECT @iDeclaracaoId, @cReferenciaBraslog, @cReferenciaCliente 
            WHERE NOT EXISTS (SELECT 1 FROM tProcesso WHERE iDeclaracaoId = @iDeclaracaoId);

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        EXEC stp_ManipulaErro;
    END CATCH
END
GO

/*--------------------------------------------------------------------------------------------        
Tipo Objeto		: Stored Procedure
Objeto Nome		: stp_InserirDadosProcessosImportacao
Objetivo		: Inserir dados nas colunas relacionadas aos processos de Importação (utilização economica e
                  suspernsão total)
Projeto			: ProcessosTemporarios
Criação			: 08/12/2025
Execução		: Na inserção de dados
Palavra-chave   : Insert
----------------------------------------------------------------------------------------------        
Observação		: tNcm, tDeclaracaoItem e tProrrogacao precisam estar num procedure a parte;
                  Precisa converter para INT (CONVERT(INT, current_value)) das sequences antes
                  de atribuir
----------------------------------------------------------------------------------------------        
Histórico		:        
Autor						IDBug Data		Descrição
----------------------		----- ---------- -------------------------------------------------
Marcus V. Paiva Silveira		  08/12/2025 Stored criada
Marcus V. Paiva Silveira          20/12/2025 Variaveis para calculo aduaneiro precisam ser
                                             inseridas antes de adicionar o NCM
Marcus V. Paiva Silveira          547   24/12/2025 Conflito FK FK_DATA_REGISTRO_CODIGO_MOEDA ao inserir
                                             dados pela procedure
*/
CREATE OR ALTER PROCEDURE stp_InserirDadosProcessosImportacao
    -- LOGÍSTICA / MERCANTE
    @iCeId INT = NULL, --Recupera iCeId para inserir OutrasDespesas, e Capatazias do front (valor vem do back)
    @iLogisticaId INT, --Inserir valor do Frete
    @iValoresCalculoAduaneiroId INT, --Inserir valor do Seguro
    @iDeclaracaoId INT, --Inserir Id no tDeclaracaoItem

    @mFrete DECIMAL(18,2),
    @mOutrasDespesas DECIMAL(18,2) = NULL,
    @mSeguro DECIMAL(18,2) = NULL,
    @mValorCapatazias DECIMAL(18,2) = NULL,
    @mTaxaUtilizacaoMercante DECIMAL(4,2) = NULL, --Do backend tem que vir 20 (atual)

    -- TAXAS DE CÂMBIO
    @dDataRegistro DATE,

    @cCodigoMoedaFob CHAR(3),
    @mTaxaCambioFob DECIMAL(7,6),

    @cCodigoMoedaFrete CHAR(3),
    @mTaxaCambioFrete DECIMAL(7,6),

    @cCodigoMoedaSeguro CHAR(3) = NULL,
    @mTaxaCambioSeguro DECIMAL(7,6) = NULL,

    @cCodigoMoedaOutrasDespesas CHAR(3) = NULL,
    @mTaxaCambioOutrasDespesas DECIMAL(7,6) = NULL,

    -- VALORES ADUANEIROS
    @mAdicoes INT,
    @mTaxaSiscomex DECIMAL(18,2),

    -- ICMS (POR PROCESSO)
    @mAliqIcms DECIMAL(5,2),	

    -- PARAMETROS DO TIPO TABELA (iguais as tabelas originais)
    @tNcm dtNcm READONLY,
    @tDeclaracaoItem dtDeclaracaoItem READONLY,
	@tProrrogacao dtProrrogacao READONLY
AS 
BEGIN

    SET NOCOUNT ON;

        BEGIN TRANSACTION
        BEGIN TRY

        -- 1) tCeMercante
        IF @iCeId IS NOT NULL
        BEGIN
            UPDATE tCeMercante
            SET
                mOutrasDespesas = @mOutrasDespesas,
                mTaxaUtilizacaoMercante = @mTaxaUtilizacaoMercante,
                mValorCapatazias = @mValorCapatazias,
                cCodigoMoeda = @cCodigoMoedaOutrasDespesas
            WHERE iCeId = @iCeId;
        END

        -- 2) tLogistica
        UPDATE tLogistica
            SET mFrete = @mFrete,
            cCodigoMoeda = @cCodigoMoedaFrete
        WHERE iLogisticaId = @iLogisticaId;

        -- 3) tTaxaCambio
        INSERT INTO tTaxaCambio (dDataRegistro, cCodigoMoeda, mTaxaCambio)
        SELECT @dDataRegistro, x.cCodigoMoeda, x.mTaxaCambio
        FROM
        (
            SELECT @cCodigoMoedaFob, @mTaxaCambioFob
            UNION ALL
            SELECT @cCodigoMoedaFrete, @mTaxaCambioFrete
            UNION ALL
            SELECT @cCodigoMoedaSeguro, @mTaxaCambioSeguro
            UNION ALL
            SELECT @cCodigoMoedaOutrasDespesas, @mTaxaCambioOutrasDespesas
        ) x (cCodigoMoeda, mTaxaCambio)
        WHERE
            x.cCodigoMoeda IS NOT NULL
            AND x.mTaxaCambio IS NOT NULL
            AND NOT EXISTS
            (
                SELECT 1
                FROM tTaxaCambio tc
                WHERE tc.dDataRegistro = @dDataRegistro
                  AND tc.cCodigoMoeda = x.cCodigoMoeda
            );       

        -- 4) tValoresCalculoAduaneiro
        UPDATE tValoresCalculoAduaneiro
        SET
            cCodigoMoeda = @cCodigoMoedaSeguro,
            mAdicoes = @mAdicoes,
            mTaxaSiscomex = @mTaxaSiscomex,
            mSeguro = @mSeguro
        WHERE iValoresCalculoAduaneiroId = @iValoresCalculoAduaneiroId;

        --tNcm
        MERGE tNcm AS target
        USING @tNcm AS source
            ON source.cNcm = target.cNcm
        WHEN NOT MATCHED THEN
            INSERT (cNcm, mAliqIi, mAliqIpi, mAliqPis, mAliqCofins)
            VALUES
            (
                source.cNcm,
                source.mAliqIi,
                source.mAliqIpi,
                source.mAliqPis,
                source.mAliqCofins
            )
        WHEN MATCHED
        AND
        (
               target.mAliqIi     <> source.mAliqIi
            OR target.mAliqIpi    <> source.mAliqIpi
            OR target.mAliqPis    <> source.mAliqPis
            OR target.mAliqCofins <> source.mAliqCofins
        )
        THEN
            UPDATE SET
                mAliqIi     = source.mAliqIi,
                mAliqIpi    = source.mAliqIpi,
                mAliqPis    = source.mAliqPis,
                mAliqCofins = source.mAliqCofins;

        --tDeclaracaoItem
        INSERT INTO tDeclaracaoItem
        ( iDeclaracaoId, iNcmId, mValorFob, mPesoLiquido, mValorAduaneiro, mIiValor, mIpiValor, mPisValor, mCofinsValor, mIcmsValor )
        SELECT
            @iDeclaracaoId, n.iNcmId, di.mValorFob, di.mPesoLiquido, di.mValorAduaneiro, di.mIiValor, di.mIpiValor, di.mPisValor, di.mCofinsValor, di.mIcmsValor
        FROM @tDeclaracaoItem di
        JOIN tNcm n ON n.cNcm = di.cNcm;

        --tProrrogaçao
		INSERT INTO tProrrogacao
		(iDeclaracaoItemId, mTaxaSelicAcumulada, iProrrogacao, mIiValorProrrogacao, mIpiValorProrrogacao, mPisValorProrrogacao, mCofinsValorProrrogacao, mIcmsValorProrrogacao, dDataProrrogacao)
		SELECT
			iDeclaracaoItemId, mTaxaSelicAcumulada, iProrrogacao, mIiValorProrrogacao, mIpiValorProrrogacao, mPisValorProrrogacao, mCofinsValorProrrogacao, mIcmsValorProrrogacao, dDataProrrogacao
		FROM @tProrrogacao tp
		JOIN tDeclaracaoItem td
			ON td.iDeclaracaoId = @iDeclaracaoId
		JOIN tNcm tn
			ON tn.iNcmId = td.iNcmId
			AND tn.cNcm = tp.cNcm;
		

        --tEstado (aliquota ICMS)
        UPDATE te
        SET te.mAliqIcms = @mAliqIcms
        FROM tEstado te
        JOIN tCidade tci   ON tci.iEstadoId = te.iEstadoId
        JOIN tCep tc       ON tc.iCidadeId = tci.iCidadeId
        JOIN tRecinto tr   ON tr.iCepId = tc.iCepId
        JOIN tDeclaracao td ON td.iRecintoId = tr.iRecintoId
        WHERE td.iDeclaracaoId = @iDeclaracaoId;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;

        EXEC stp_ManipulaErro;
    END CATCH
END
GO