/*------------------------------------------------------------
Author   : Marcus Paiva
DataBase : ProcessosTemporarios
Objective: Transferir os dados de controle da planilha
Date	 : 16/11/2025
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

/*------------------------------------------------------------
Author   : Marcus Paiva
DataBase : ProcessosTemporarios
Objective: Criaçao das tabelas através das Stored Procedures
		   e seus respectivos CONSTRAINTS
Date	 : 26/10/2025
------------------------------------------------------------*/
--------------------------------------------------------------------------
-- Tabela: tEstado
--------------------------------------------------------------------------
USE ProcessosTemporarios
GO

EXEC stp_CriaTabela
    @cSequenceNome = 'seqiEstadoId',
    @cNomeTabela = 'tEstado',
    @cNomeColunas = 'iEstadoId|cEstadoNome|cEstadoSigla|mAliqIcms',
    @cTipoColunas = 'INT NOT NULL|VARCHAR(100) NOT NULL|CHAR(2) NOT NULL|
					DECIMAL(5,2) NOT NULL';
GO

ALTER TABLE tEstado
	ADD CONSTRAINT PK_ESTADO_ID PRIMARY KEY(iEstadoId);

ALTER TABLE tEstado
	ADD CONSTRAINT UQ_NOME_ESTADO UNIQUE(cEstadoNome);

ALTER TABLE tEstado
	ADD CONSTRAINT UQ_ESTADO_SIGLA UNIQUE(cEstadoSigla);

GO

--------------------------------------------------------------------------
-- Tabela: tCidade
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiCidadeId',
    @cNomeTabela = 'tCidade',
    @cNomeColunas = 'iCidadeId|iEstadoId|cCidadeNome',
    @cTipoColunas = 'INT NOT NULL|INT NOT NULL|VARCHAR(100) NOT NULL';

ALTER TABLE tCidade
	ADD CONSTRAINT PK_CIDADE_ID PRIMARY KEY(iCidadeId);

ALTER TABLE tCidade
	ADD CONSTRAINT FK_CIDADE_ESTADO FOREIGN KEY(iEstadoId)
	REFERENCES tEstado(iEstadoId);

GO

--------------------------------------------------------------------------
-- Tabela: tCep
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiCepId',
    @cNomeTabela = 'tCep',
    @cNomeColunas = 'iCepId|iCidadeId|cCep|cNomeLogradouro|cNumeroLogradouro|
					cBairroLogradouro',
    @cTipoColunas = 'INT NOT NULL|INT NOT NULL|CHAR(8) NOT NULL|
					VARCHAR(100) NOT NULL|VARCHAR(20)|VARCHAR(100)';

ALTER TABLE tCep
	ADD CONSTRAINT PK_CEP_ID PRIMARY KEY(iCepId);

ALTER TABLE tCep
	ADD CONSTRAINT FK_CEP_CIDADE FOREIGN KEY(iCidadeId)
	REFERENCES tCidade(iCidadeId);

ALTER TABLE tCep
	ADD CONSTRAINT UQ_CEP UNIQUE(cCep);

GO

--------------------------------------------------------------------------
-- Tabela: tURF
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiUrfId',
    @cNomeTabela = 'tUrf',
    @cNomeColunas = 'iUrfId|cUnidadeReceitaFederal|cNomeUnidadeReceitaFederal',
    @cTipoColunas = 'INT NOT NULL|CHAR(7) NOT NULL|
					VARCHAR(200) NOT NULL';

ALTER TABLE tUrf
	ADD CONSTRAINT PK_URF_ID PRIMARY KEY(iUrfId);

ALTER TABLE tUrf
	ADD CONSTRAINT UQ_NUMERO_URF UNIQUE(cUnidadeReceitaFederal);

ALTER TABLE tUrf
	ADD CONSTRAINT UQ_NOME_URF UNIQUE(cNomeUnidadeReceitaFederal);

GO

--------------------------------------------------------------------------
-- Tabela: tRecinto
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiRecintoId',
    @cNomeTabela = 'tRecinto',
    @cNomeColunas = 'iRecintoId|iUrfId|iCepId|cNumeroRecintoAduaneiro|cNomeRecinto',
    @cTipoColunas = 'INT NOT NULL|INT NOT NULL|INT NOT NULL|CHAR(7) NOT NULL|
					VARCHAR(100) NOT NULL';

ALTER TABLE tRecinto
	ADD CONSTRAINT PK_RECINTO_ID PRIMARY KEY(iRecintoId);

ALTER TABLE tRecinto
	ADD CONSTRAINT FK_RECINTO_URF FOREIGN KEY(iUrfId)
	REFERENCES tUrf(iUrfId);

ALTER TABLE tRecinto
	ADD CONSTRAINT FK_RECINTO_CEP FOREIGN KEY(iCepId)
	REFERENCES tCep(iCepId);

GO

--------------------------------------------------------------------------
-- Tabela: tCnpj
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiCnpjId',
    @cNomeTabela = 'tCnpj',
    @cNomeColunas = 'iCnpjId|iCepId|cCnpj|cNomeEmpresa',
    @cTipoColunas = 'INT NOT NULL|INT NOT NULL|CHAR(14) NOT NULL|
					VARCHAR(100) NOT NULL';

ALTER TABLE tCnpj
	ADD CONSTRAINT PK_CNPJ_ID PRIMARY KEY(iCnpjId)

ALTER TABLE tCnpj
	ADD CONSTRAINT FK_CNPJ_CEP FOREIGN KEY(iCepId)
	REFERENCES tCep(iCepId);

ALTER TABLE tCnpj
	ADD CONSTRAINT UQ_CNPJ UNIQUE(cCnpj);

GO

--------------------------------------------------------------------------
-- Tabela: tTaxaCambio
--------------------------------------------------------------------------
USE ProcessosTemporarios
GO

EXEC stp_CriaTabela
@cSequenceNome = 'seqiTaxaCambioId',
@cNomeTabela = 'tTaxaCambio',
@cNomeColunas = 'iTaxaCambioId|dDataRegistro|cCodigoMoeda|mTaxaCambio',
@cTipoColunas = 'INT NOT NULL|DATE NOT NULL|CHAR(3) NOT NULL|DECIMAL(5,4)';

ALTER TABLE tTaxaCambio
	ADD CONSTRAINT PK_COMPOSTA_TAXA_CAMBIO_E_DATA_REGISTRO PRIMARY KEY(dDataRegistro, cCodigoMoeda);

GO

--------------------------------------------------------------------------
-- Tabela: tValoresCalculoAduaneiro
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiValoresCalculoAduaneiroId',
    @cNomeTabela = 'tValoresCalculoAduaneiro',
    @cNomeColunas = 'iValoresCalculoAduaneiroId|dDataRegistro|cCodigoMoeda|mAdicoes|
					mTaxaSiscomex|mSeguro',
    @cTipoColunas = 'INT NOT NULL|DATE NOT NULL|CHAR(3) NOT NULL|INT NOT NULL|
					DECIMAL(18,2) NOT NULL|DECIMAL(18,2)';

ALTER TABLE tValoresCalculoAduaneiro
	ADD CONSTRAINT PK_VALOR_ADUANEIRO PRIMARY KEY(iValoresCalculoAduaneiroId);

ALTER TABLE tValoresCalculoAduaneiro
	ADD CONSTRAINT FK_DATA_REGISTRO_CODIGO_MOEDA FOREIGN KEY(dDataRegistro, cCodigoMoeda)
	REFERENCES tTaxaCambio(dDataRegistro, cCodigoMoeda);

GO

--------------------------------------------------------------------------
-- Tabela: tRegimeAduaneiro
--------------------------------------------------------------------------
USE ProcessosTemporarios;
GO

EXEC stp_CriaTabela
    @cSequenceNome = 'seqiRegimeAduaneiroId',
    @cNomeTabela = 'tRegimeAduaneiro',
    @cNomeColunas = 'iRegimeAduaneiroId|cNomeRegimeAduaneiro',
    @cTipoColunas = 'INT NOT NULL|VARCHAR(50) NOT NULL';
GO

ALTER TABLE tRegimeAduaneiro
	ADD CONSTRAINT PK_REGIME_ADUANEIRO_ID PRIMARY KEY(iRegimeAduaneiroId);

ALTER TABLE tRegimeAduaneiro
	ADD CONSTRAINT UQ_REGIME_ADUANEIRO UNIQUE(cNomeRegimeAduaneiro);

GO

--------------------------------------------------------------------------
-- Tabela: tPais
--------------------------------------------------------------------------
USE ProcessosTemporarios
GO

EXEC stp_CriaTabela
    @cSequenceNome = 'seqiPaisId',
    @cNomeTabela = 'tPais',
    @cNomeColunas = 'iPaisId|cPaisNome',
    @cTipoColunas = 'INT NOT NULL|VARCHAR(100) NOT NULL';
GO

ALTER TABLE tPais
	ADD CONSTRAINT PK_PAIS_ID PRIMARY KEY(iPaisId);

ALTER TABLE tPais
	ADD CONSTRAINT UQ_PAIS_NOME UNIQUE(cPaisNome);

GO

--------------------------------------------------------------------------
-- Tabela: tCidadeEmbarque
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiCidadeEmbarqueId',
    @cNomeTabela = 'tCidadeEmbarque',
    @cNomeColunas = 'iCidadeEmbarqueId|iPaisId|cNomeCidadeEmbarque',
    @cTipoColunas = 'INT NOT NULL|INT NOT NULL|VARCHAR(100) NOT NULL';

ALTER TABLE tCidadeEmbarque
	ADD CONSTRAINT PK_CIDADE_EMBARQUE PRIMARY KEY(iCidadeEmbarqueId);

ALTER TABLE tCidadeEmbarque
	ADD CONSTRAINT FK_CIDADE_EMBARQUE_PAIS FOREIGN KEY(iPaisId)
	REFERENCES tPais(iPaisId);

GO

--------------------------------------------------------------------------
-- Tabela: tLocalEmbarque
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiLocalEmbarqueId',
    @cNomeTabela = 'tLocalEmbarque',
    @cNomeColunas = 'iLocalEmbarqueId|iCidadeEmbarqueId|cLocalEmbarque',
    @cTipoColunas = 'INT NOT NULL|INT NOT NULL|VARCHAR(100) NOT NULL';

ALTER TABLE tLocalEmbarque
	ADD CONSTRAINT PK_LOCAL_EMBARQUE PRIMARY KEY(iLocalEmbarqueId);

ALTER TABLE tLocalEmbarque
	ADD CONSTRAINT FK_LOCAL_EMBARQUE_CIDADE_EMBARQUE FOREIGN KEY(iCidadeEmbarqueId)
	REFERENCES tCidadeEmbarque(iCidadeEmbarqueId);

ALTER TABLE tLocalEmbarque
	ADD CONSTRAINT UQ_LOCAL_EMBARQUE UNIQUE(cLocalEmbarque);

GO

--------------------------------------------------------------------------
-- Tabela: tModal
--------------------------------------------------------------------------
USE ProcessosTemporarios
GO

EXEC stp_CriaTabela
    @cSequenceNome = 'seqiModalId',
    @cNomeTabela = 'tModal',
    @cNomeColunas = 'iModalId|cNomeModal',
    @cTipoColunas = 'INT NOT NULL|VARCHAR(50) NOT NULL';
GO

ALTER TABLE tModal
	ADD CONSTRAINT PK_MODAL_ID PRIMARY KEY(iModalId);

ALTER TABLE tModal
	ADD CONSTRAINT UQ_NOME_MODAL UNIQUE(cNomeModal);

GO

--------------------------------------------------------------------------
-- Tabela: tCeMercanteStatus
--------------------------------------------------------------------------
USE ProcessosTemporarios
GO

EXEC stp_CriaTabela
    @cSequenceNome = 'seqiCeMercanteStatusId',
    @cNomeTabela = 'tCeMercanteStatus',
    @cNomeColunas = 'iCeMercanteStatusId|cStatusCe',
    @cTipoColunas = 'INT NOT NULL|VARCHAR(25) NOT NULL';
GO

ALTER TABLE tCeMercanteStatus
	ADD CONSTRAINT PK_CE_MERCANTE_STATUS_ID PRIMARY KEY(iCeMercanteStatusId);

ALTER TABLE tCeMercanteStatus
	ADD CONSTRAINT UQ_STATUS_CE UNIQUE(cStatusCe);

GO

--------------------------------------------------------------------------
-- Tabela: tCeMercante
--------------------------------------------------------------------------
USE ProcessosTemporarios
GO

EXEC stp_CriaTabela
    @cSequenceNome = 'seqiCeId',
    @cNomeTabela = 'tCeMercante',
    @cNomeColunas = 'iCeId|iCeMercanteStatusId|cNumeroCe|mOutrasDespesas|mTaxaUtilizaçaoMercante|
					mValorAfrmmSuspenso|mValorCapatazias',
    @cTipoColunas = 'INT NOT NULL|INT NOT NULL|VARCHAR(15) NOT NULL|DECIMAL(18,2)|INT NOT NULL|
					DECIMAL(18,2)|DECIMAL(18,2)';
GO

ALTER TABLE tCeMercante
	ADD CONSTRAINT PK_CE_ID PRIMARY KEY(iCeId);

ALTER TABLE tCeMercante
	ADD CONSTRAINT CK_CE_TAXA_UTILIZACAO_MERCANTE CHECK(mTaxaUtilizaçaoMercante = 20 OR mTaxaUtilizaçaoMercante IS NULL);

ALTER TABLE tCeMercante
	ADD CONSTRAINT UQ_NUMERO_CE UNIQUE(cNumeroCe);

ALTER TABLE tCeMercante
	ADD CONSTRAINT FK_CE_CE_STATUS FOREIGN KEY(iCeMercanteStatusId)
	REFERENCES tCeMercanteStatus(iCeMercanteStatusId);

GO

--------------------------------------------------------------------------
-- Tabela: tLogistica
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiLogisticaId',
    @cNomeTabela = 'tLogistica',
    @cNomeColunas = 'iLogisticaId|iCeId|iModalId|iLocalEmbarqueId|
					cConhecimentoEmbarque|dDataEmbarque|dDataChegadaBrasil|mFrete',
    @cTipoColunas = 'INT NOT NULL|INT|INT NOT NULL|INT|VARCHAR(50) NOT NULL|DATE|
					DATE|DECIMAL(18,2)';

ALTER TABLE tLogistica
	ADD CONSTRAINT PK_LOGISTICA_ID PRIMARY KEY(iLogisticaId);

ALTER TABLE tLogistica
	ADD CONSTRAINT FK_LOGISTICA_LOCAL_EMBARQUE FOREIGN KEY(iLocalEmbarqueId)
	REFERENCES tLocalEmbarque(iLocalEmbarqueId);

ALTER TABLE tLogistica
	ADD CONSTRAINT FK_LOGISTICA_CE FOREIGN KEY(iCeId)
	REFERENCES tCeMercante(iCeId);

ALTER TABLE tLogistica
	ADD CONSTRAINT FK_LOGISTICA_MODAL FOREIGN KEY(iModalId)
	REFERENCES tModal(iModalId);

ALTER TABLE tLogistica
	ADD CONSTRAINT CK_DATA_CHEGADA CHECK(dDataChegadaBrasil >= dDataEmbarque);

GO

--------------------------------------------------------------------------
-- Tabela: tApolice
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiApoliceId',
    @cNomeTabela = 'tApolice',
    @cNomeColunas = 'iApoliceId|cNumeroApolice|dVencimentoGarantia|dValorSegurado',
    @cTipoColunas = 'INT NOT NULL|INT NOT NULL|DATE NOT NULL|DECIMAL(18,2)';

ALTER TABLE tApolice
	ADD CONSTRAINT PK_APOLICE_ID PRIMARY KEY(iApoliceId);

GO

--------------------------------------------------------------------------
-- Tabela: tNcm
--------------------------------------------------------------------------
USE ProcessosTemporarios
GO

EXEC stp_CriaTabela
@cSequenceNome = 'seqiNcmId',
@cNomeTabela = 'tNcm',
@cNomeColunas = 'iNcmId|cNcm|mAliqIi|mAliqIpi|mAliqPis|mAliqCofins',
@cTipoColunas = 'INT NOT NULL|CHAR(8) NOT NULL|DECIMAL(5,2) NOT NULL|
				DECIMAL(5,2) NOT NULL|DECIMAL(5,2) NOT NULL|DECIMAL(5,2) NOT NULL';

ALTER TABLE tNcm
	ADD CONSTRAINT PK_NCM_ID PRIMARY KEY(iNcmId);

ALTER TABLE tNcm
	ADD CONSTRAINT UQ_NCM UNIQUE(cNcm);

GO

--------------------------------------------------------------------------
-- Tabela: tDeclaracaoItem
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiDeclaracaoItemId',
    @cNomeTabela = 'tDeclaracaoItem',
    @cNomeColunas = 'iDeclaracaoItemId|iDeclaracaoId|iNcmId|dDataProrrogacao|mTaxaSelicAcumulada|
					iProrrogacao|mValorFob|mPesoLiquido|mValorAduaneiro|mIiValor|
					mIpiValor|mPpisValor|mCofinsValor|mIcmsValor',
    @cTipoColunas = 'INT NOT NULL|INT NOT NULL|INT NOT NULL|DATE NOT NULL|DECIMAL(5,2)|INT NOT NULL|
					DECIMAL(18,2) NOT NULL|DECIMAL(18,2) NOT NULL|DECIMAL(18,2) NOT NULL|
					DECIMAL(18,2) NOT NULL|DECIMAL(18,2) NOT NULL|DECIMAL(18,2) NOT NULL|
					DECIMAL(18,2) NOT NULL|DECIMAL(18,2) NOT NULL';

ALTER TABLE tDeclaracaoItem
	ADD CONSTRAINT PK_DECLARACAO_ITEM_ID PRIMARY KEY(iDeclaracaoItemId);

ALTER TABLE tDeclaracaoItem
	ADD CONSTRAINT FK_DECLARACAO_ITEM_DECLARACAO FOREIGN KEY(iDeclaracaoId)
	REFERENCES tDeclaracao(iDeclaracaoId);

ALTER TABLE tDeclaracaoItem
	ADD CONSTRAINT FK_DECLARACAO_ITEM_NCM FOREIGN KEY(iNcmId)
	REFERENCES tNcm(iNcmId);

GO

--------------------------------------------------------------------------
-- Tabela: tContratoTipo
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiContratoTipoId',
    @cNomeTabela = 'tContratoTipo',
    @cNomeColunas = 'iContratoTipoId|cContratoTipo',
    @cTipoColunas = 'INT NOT NULL|VARCHAR(50)';

ALTER TABLE tContratoTipo
	ADD CONSTRAINT PK_CONTRATO_TIPO_ID PRIMARY KEY(iContratoTipoId);

ALTER TABLE tContratoTipo
	ADD CONSTRAINT UQ_CONTRATO_TIPO UNIQUE(cContratoTipo);

GO

--------------------------------------------------------------------------
-- Tabela: tContrato
--------------------------------------------------------------------------
USE ProcessosTemporarios
GO

EXEC stp_CriaTabela
    @cSequenceNome = 'seqiContratoId',
    @cNomeTabela = 'tContrato',
    @cNomeColunas = 'iContratoId|cNomeContrato|iContratoTipoId|dContratoDataAssinatura|
					dContratoVencimento',
    @cTipoColunas = 'INT NOT NULL|VARCHAR(200) NOT NULL|INT|DATE|DATE';
GO

ALTER TABLE tContrato
	ADD CONSTRAINT PK_CONTRATO_ID PRIMARY KEY(iContratoId);

ALTER TABLE tContrato
	ADD CONSTRAINT CK_CONTRATO_VENCIMENTO CHECK(dContratoVencimento > dContratoDataAssinatura);

ALTER TABLE tContrato
	ADD CONSTRAINT FK_CONTRATO_CONTRATO_TIPO FOREIGN KEY(iContratoTipoId)
	REFERENCES tContratoTipo(iContratoTipoId);

GO

--------------------------------------------------------------------------
-- Tabela: tDeclaracao
--------------------------------------------------------------------------
USE ProcessosTemporarios
GO

EXEC stp_CriaTabela
@cSequenceNome = 'seqiDeclaracaoId',
@cNomeTabela = 'tDeclaracao',
@cNomeColunas = 'iDeclaracaoId|iRegimeAduaneiroId|iCnpjId|iApoliceId|iRecintoId|
				iLogisticaId|iValoresCalculoAduaneiroId|cNumeroDeclaracao|dDataDesembaraco|
				cNumeroDossie|cNumeroProcessoAdministrativo|cDescricao',
@cTipoColunas = 'INT NOT NULL|INT NOT NULL|INT NOT NULL|INT|INT NOT NULL|INT NOT NULL|
				INT NOT NULL|VARCHAR(12) NOT NULL|DATE|CHAR(15)|CHAR(17)|VARCHAR(MAX)';

ALTER TABLE tDeclaracao
	ADD CONSTRAINT PK_DECLARACO_ID PRIMARY KEY(iDeclaracaoId);

ALTER TABLE tDeclaracao
    ADD CONSTRAINT FK_DECLARACAO_REGIME_ADUANEIRO
    FOREIGN KEY(iRegimeAduaneiroId)
    REFERENCES tRegimeAduaneiro(iRegimeAduaneiroId);

ALTER TABLE tDeclaracao
    ADD CONSTRAINT FK_DECLARACAO_CNPJ
    FOREIGN KEY(iCnpjId)
    REFERENCES tCnpj(iCnpjId);

ALTER TABLE tDeclaracao
    ADD CONSTRAINT FK_DECLARACAO_APOLICE
    FOREIGN KEY(iApoliceId)
    REFERENCES tApolice(iApoliceId);

ALTER TABLE tDeclaracao
    ADD CONSTRAINT FK_DECLARACAO_RECINTO
    FOREIGN KEY(iRecintoId)
    REFERENCES tRecinto(iRecintoId);

ALTER TABLE tDeclaracao
    ADD CONSTRAINT FK_DECLARACAO_LOGISTICA
    FOREIGN KEY(iLogisticaId)
    REFERENCES tLogistica(iLogisticaId);

ALTER TABLE tDeclaracao
	ADD CONSTRAINT FK_DECLARACAO_VALORES_CALCULO_ADUANEIRO
	FOREIGN KEY(iValoresCalculoAduaneiroId)
	REFERENCES tValoresCalculoAduaneiro(iValoresCalculoAduaneiroId);

ALTER TABLE tDeclaracao
	ADD CONSTRAINT CK_NUMERO_DECLARACAO CHECK (LEN(cNumeroDeclaracao) IN (10, 12));

GO

--------------------------------------------------------------------------
-- Tabela: tContratoDeclaracao
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiContratoDeclaracaoId',
    @cNomeTabela = 'tContratoDeclaracao',
    @cNomeColunas = 'iContratoId|iDeclaracaoId',
    @cTipoColunas = 'INT NOT NULL|INT NOT NULL';

ALTER TABLE tContratoDeclaracao
	ADD CONSTRAINT PK_CONTRATO_DECLARACAO_ID PRIMARY KEY(iContratoId, iDeclaracaoId);

ALTER TABLE tContratoDeclaracao
	ADD CONSTRAINT FK_CONTRATO_DECLARACAO FOREIGN KEY(iContratoId) REFERENCES tContrato(iContratoId);

ALTER TABLE tContratoDeclaracao
	ADD CONSTRAINT FK_CONTRATO_DECLARACAO_DECLARACAO FOREIGN KEY(iDeclaracaoId) REFERENCES tDeclaracao(iDeclaracaoId);

GO

--------------------------------------------------------------------------
-- Tabela: tProcesso
--------------------------------------------------------------------------
USE ProcessosTemporarios
GO

EXEC stp_CriaTabela
@cSequenceNome = 'seqiProcessoId',
@cNomeTabela = 'tProcesso',
@cNomeColunas = 'iProcessoId|iDeclaracaoId|cReferenciaBraslog|cReferenciaCliente|cHistorico|bIsAtivo',
@cTipoColunas = 'INT NOT NULL|INT NOT NULL|INT NOT NULL|CHAR(13)|VARCHAR(MAX) NOT NULL|BIT NOT NULL';

ALTER TABLE tProcesso
	ADD CONSTRAINT PK_PROCESSO_ID PRIMARY KEY(iProcessoId);

ALTER TABLE tProcesso
	ADD CONSTRAINT FK_PROCESSO_DECLARACAO FOREIGN KEY(iDeclaracaoId)
	REFERENCES tDeclaracao(iDeclaracaoId);

ALTER TABLE tProcesso
	ADD CONSTRAINT UQ_REFERENCIA_BRASLOG UNIQUE(cReferenciaBraslog);

ALTER TABLE tProcesso
	ADD CONSTRAINT DF_HISTORICO DEFAULT(CONVERT(CHAR(10), GETDATE(), 103) + 
	' - Processo incluído no controle') FOR cHistorico;

ALTER TABLE tProcesso
	ADD CONSTRAINT DF_IS_ATIVO DEFAULT(1) FOR bIsAtivo;

GO

--------------------------------------------------------------------------
-- Tabela: tLogEventos
--------------------------------------------------------------------------
EXEC stp_CriaTabela
    @cSequenceNome = 'seqiEventoId',
    @cNomeTabela = 'tLogEventos',
    @cNomeColunas = 'iEventoId|dDataHoraEvento|cMensagemEvento',
    @cTipoColunas = 'INT NOT NULL|DATE NOT NULL|VARCHAR(512) NOT NULL';

ALTER TABLE tLogEventos
	ADD CONSTRAINT PK_LOG_EVENTOS_ID PRIMARY KEY(iEventoId);

ALTER TABLE tLogEventos
	ADD CONSTRAINT DF_DATA_HORA DEFAULT(GETDATE()) FOR dDataHoraEvento;

ALTER TABLE tLogEventos
	ADD CONSTRAINT CK_MENSAGEM_EVENTO CHECK(cMensagemEvento <> '');