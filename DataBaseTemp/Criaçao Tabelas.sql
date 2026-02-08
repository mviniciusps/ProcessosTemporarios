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
	EXEC stp_CriaTabela
		@cSequenceNome = 'seqiEstadoId',
		@cNomeTabela = 'tEstado',
		@cNomeColunas = 'iEstadoId|cEstadoNome|cEstadoSigla|mAliqIcms',
		@cTipoColunas = 'INT|VARCHAR(100)|CHAR(2)|
						DECIMAL(5,2)';
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
		@cTipoColunas = 'INT|INT|VARCHAR(100)';

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
		@cNomeColunas = 'iCepId|iCidadeId|cCep|cNomeLogradouro|cBairroLogradouro',
		@cTipoColunas = 'INT|INT|CHAR(8)|
						VARCHAR(100)|VARCHAR(100)';

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
		@cTipoColunas = 'INT|CHAR(7)|
						VARCHAR(200)';

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
		@cTipoColunas = 'INT|INT|INT|CHAR(7)|
						VARCHAR(100)';

	ALTER TABLE tRecinto
		ADD CONSTRAINT PK_RECINTO_ID PRIMARY KEY(iRecintoId);

	ALTER TABLE tRecinto
		ADD CONSTRAINT FK_RECINTO_URF FOREIGN KEY(iUrfId)
		REFERENCES tUrf(iUrfId);

	ALTER TABLE tRecinto
		ADD CONSTRAINT FK_RECINTO_CEP FOREIGN KEY(iCepId)
		REFERENCES tCep(iCepId);

	ALTER TABLE tRecinto
		ADD CONSTRAINT UQ_NUMERO_RECINTO UNIQUE(cNumeroRecintoAduaneiro);

	ALTER TABLE tRecinto
		ADD CONSTRAINT UQ_NOME_RECINTO UNIQUE(cNomeRecinto);

	GO

--------------------------------------------------------------------------
-- Tabela: tCnpj
--------------------------------------------------------------------------
	EXEC stp_CriaTabela
		@cSequenceNome = 'seqiCnpjId',
		@cNomeTabela = 'tCnpj',
		@cNomeColunas = 'iCnpjId|iCepId|cCnpj|cNomeEmpresa',
		@cTipoColunas = 'INT|INT|CHAR(14)|
						VARCHAR(100)';

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
	EXEC stp_CriaTabela
	@cSequenceNome = 'seqiTaxaCambioId',
	@cNomeTabela = 'tTaxaCambio',
	@cNomeColunas = 'dDataRegistro|cCodigoMoeda|mTaxaCambio',
	@cTipoColunas = 'DATE|CHAR(3)|DECIMAL(5,4)';

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
		@cTipoColunas = 'INT|DATE|CHAR(3)|INT|
						DECIMAL(18,2)|DECIMAL(18,2)';

	ALTER TABLE tValoresCalculoAduaneiro
		ADD CONSTRAINT PK_VALOR_ADUANEIRO PRIMARY KEY(iValoresCalculoAduaneiroId);

	ALTER TABLE tValoresCalculoAduaneiro
		ADD CONSTRAINT FK_DATA_REGISTRO_CODIGO_MOEDA FOREIGN KEY(dDataRegistro, cCodigoMoeda)
		REFERENCES tTaxaCambio(dDataRegistro, cCodigoMoeda);

	GO

--------------------------------------------------------------------------
-- Tabela: tRegimeAduaneiro
--------------------------------------------------------------------------
	EXEC stp_CriaTabela
		@cSequenceNome = 'seqiRegimeAduaneiroId',
		@cNomeTabela = 'tRegimeAduaneiro',
		@cNomeColunas = 'iRegimeAduaneiroId|cNomeRegimeAduaneiro',
		@cTipoColunas = 'INT|VARCHAR(50)';
	GO

	ALTER TABLE tRegimeAduaneiro
		ADD CONSTRAINT PK_REGIME_ADUANEIRO_ID PRIMARY KEY(iRegimeAduaneiroId);

	ALTER TABLE tRegimeAduaneiro
		ADD CONSTRAINT UQ_REGIME_ADUANEIRO UNIQUE(cNomeRegimeAduaneiro);

	GO

--------------------------------------------------------------------------
-- Tabela: tPais
--------------------------------------------------------------------------
	EXEC stp_CriaTabela
		@cSequenceNome = 'seqiPaisId',
		@cNomeTabela = 'tPais',
		@cNomeColunas = 'iPaisId|cPaisNome',
		@cTipoColunas = 'INT|VARCHAR(100)';
	GO

	ALTER TABLE tPais
		ADD CONSTRAINT PK_PAIS_ID PRIMARY KEY(iPaisId);

	ALTER TABLE tPais
		ADD CONSTRAINT UQ_PAIS_NOME UNIQUE(cPaisNome);

	GO

--------------------------------------------------------------------------
-- Tabela: tCidadeExterior
--------------------------------------------------------------------------
	EXEC stp_CriaTabela
		@cSequenceNome = 'seqiCidadeEmbarqueId',
		@cNomeTabela = 'tCidadeExterior',
		@cNomeColunas = 'iCidadeExteriorId|iPaisId|cNomeCidadeExterior',
		@cTipoColunas = 'INT|INT|VARCHAR(100)';

	ALTER TABLE tCidadeExterior
		ADD CONSTRAINT PK_CIDADE_EXTERIOR PRIMARY KEY(iCidadeExteriorId);

	ALTER TABLE tCidadeExterior
		ADD CONSTRAINT FK_CIDADE_EXTERIOR_PAIS FOREIGN KEY(iPaisId)
		REFERENCES tPais(iPaisId);


	GO

--------------------------------------------------------------------------
-- Tabela: tModal
--------------------------------------------------------------------------
	EXEC stp_CriaTabela
		@cSequenceNome = 'seqiModalId',
		@cNomeTabela = 'tModal',
		@cNomeColunas = 'iModalId|cNomeModal',
		@cTipoColunas = 'INT|VARCHAR(50)';
	GO

	ALTER TABLE tModal
		ADD CONSTRAINT PK_MODAL_ID PRIMARY KEY(iModalId);

	ALTER TABLE tModal
		ADD CONSTRAINT UQ_NOME_MODAL UNIQUE(cNomeModal);

	GO

--------------------------------------------------------------------------
-- Tabela: tCeMercanteStatus
--------------------------------------------------------------------------
	EXEC stp_CriaTabela
		@cSequenceNome = 'seqiCeMercanteStatusId',
		@cNomeTabela = 'tCeMercanteStatus',
		@cNomeColunas = 'iCeMercanteStatusId|cStatusCe',
		@cTipoColunas = 'INT|VARCHAR(25)';
	GO

	ALTER TABLE tCeMercanteStatus
		ADD CONSTRAINT PK_CE_MERCANTE_STATUS_ID PRIMARY KEY(iCeMercanteStatusId);

	ALTER TABLE tCeMercanteStatus
		ADD CONSTRAINT UQ_STATUS_CE UNIQUE(cStatusCe);

	GO

--------------------------------------------------------------------------
-- Tabela: tCeMercante
--------------------------------------------------------------------------
	EXEC stp_CriaTabela
		@cSequenceNome = 'seqiCeId',
		@cNomeTabela = 'tCeMercante',
		@cNomeColunas = 'iCeId|iCeMercanteStatusId|cNumeroCe|mOutrasDespesas|cCodigoMoeda|mTaxaUtilizacaoMercante|
						mValorAfrmmSuspenso|mValorCapatazias',
		@cTipoColunas = 'INT|INT|VARCHAR(15)|DECIMAL(18,2)|CHAR(3)|INT|
						DECIMAL(18,2)|DECIMAL(18,2)';
	GO

	ALTER TABLE tCeMercante
		ADD CONSTRAINT PK_CE_ID PRIMARY KEY(iCeId);

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
		@cNomeColunas = 'iLogisticaId|iCeId|iModalId|iLocalEmbarqueId|cConhecimentoEmbarque|
						dDataEmbarque|dDataChegadaBrasil|mFrete|cCodigoMoeda',
	@cTipoColunas = 'INT|INT|INT|INT|VARCHAR(50)|DATE
						|DATE|DECIMAL(18,2)|CHAR(3)';

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

	ALTER TABLE tLogistica
		ADD CONSTRAINT UQ_CONHECIMENTO_EMBARQUE UNIQUE(cConhecimentoEmbarque);

	ALTER TABLE tLogistica
		ADD iCidadeExteriorId INT;

	ALTER TABLE tLogistica
		ADD CONSTRAINT FK_LOGISTICA_CIDADE_EXTERIOR FOREIGN KEY(iCidadeExteriorId)
		REFERENCES tCidadeExterior(iCidadeExteriorId);

	GO

--------------------------------------------------------------------------
-- Tabela: tApolice
--------------------------------------------------------------------------
	EXEC stp_CriaTabela
		@cSequenceNome = 'seqiApoliceId',
		@cNomeTabela = 'tApolice',
		@cNomeColunas = 'iApoliceId|cNumeroApolice|dVencimentoGarantia|dValorSegurado',
		@cTipoColunas = 'INT|INT|DATE|DECIMAL(18,2)';

	ALTER TABLE tApolice
		ADD CONSTRAINT PK_APOLICE_ID PRIMARY KEY(iApoliceId);

	GO

--------------------------------------------------------------------------
-- Tabela: tNcm
--------------------------------------------------------------------------
	EXEC stp_CriaTabela
	@cSequenceNome = 'seqiNcmId',
	@cNomeTabela = 'tNcm',
	@cNomeColunas = 'iNcmId|cNcm|mAliqIi|mAliqIpi|mAliqPis|mAliqCofins',
	@cTipoColunas = 'INT|CHAR(8)|DECIMAL(5,2)|
					DECIMAL(5,2)|DECIMAL(5,2)|DECIMAL(5,2)';

	ALTER TABLE tNcm
		ADD CONSTRAINT PK_NCM_ID PRIMARY KEY(iNcmId);

	ALTER TABLE tNcm
		ADD CONSTRAINT UQ_NCM UNIQUE(cNcm);

	--Criaçao de variavel para parametro da procedure
	CREATE TYPE dtNcm
	AS TABLE (
		cNcm CHAR(8),
		mAliqIi DECIMAL(10,6),
		mAliqIpi DECIMAL(10,6),
		mAliqPis DECIMAL(10,6),
		mAliqCofins DECIMAL(10,6)
	);
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
		@cTipoColunas = 'INT|INT|INT|DATE|DECIMAL(5,2)|INT|DECIMAL(18,2)|DECIMAL(18,2)|DECIMAL(18,2)|
						DECIMAL(18,2)|DECIMAL(18,2)|DECIMAL(18,2)|DECIMAL(18,2)|DECIMAL(18,2)';

	ALTER TABLE tDeclaracaoItem
		ADD CONSTRAINT PK_DECLARACAO_ITEM_ID PRIMARY KEY(iDeclaracaoItemId);

	ALTER TABLE tDeclaracaoItem
		ADD CONSTRAINT FK_DECLARACAO_ITEM_DECLARACAO FOREIGN KEY(iDeclaracaoId)
		REFERENCES tDeclaracao(iDeclaracaoId);

	ALTER TABLE tDeclaracaoItem
		ADD CONSTRAINT FK_DECLARACAO_ITEM_NCM FOREIGN KEY(iNcmId)
		REFERENCES tNcm(iNcmId);

	DROP TYPE IF EXISTS dbo.dtDeclaracaoItem;
	GO

	--Criaçao de variavel para parametro da procedure
	CREATE TYPE dtDeclaracaoItem AS TABLE (
		cNcm CHAR(8),
		mValorFob DECIMAL(18,2),
		mPesoLiquido DECIMAL(18,2),
		mValorAduaneiro DECIMAL(18,2),
		mIiValor DECIMAL(18,2),
		mIpiValor DECIMAL(18,2),
		mPisValor DECIMAL(18,2),
		mCofinsValor DECIMAL(18,2),
		mIcmsValor DECIMAL(18,2)
	);
	GO

--------------------------------------------------------------------------
-- Tabela: tProrrogacao
--------------------------------------------------------------------------
	EXEC stp_CriaTabela
		@cSequenceNome = 'seqiProrrogacaoId',
		@cNomeTabela = 'tProrrogacao',
		@cNomeColunas = 'iProrrogacaoId|iDeclaracaoItemId|mTaxaSelicAcumulada|iProrrogacao|
						mIiValorProrrogacao|mIpiValorProrrogacao|mPisValorProrrogacao|mCofinsValorProrrogacao|
						mIcmsValorProrrogacao|dDataProrrogacao|dVencimentoProrrogacao',
		@cTipoColunas = 'INT|INT|DECIMAL(5,2)|INT|
						DECIMAL(18,2)|DECIMAL(18,2)|DECIMAL(18,2)|DECIMAL(18,2)|
						DECIMAL(18,2)|DATE|DATE';

	ALTER TABLE tProrrogacao
		ADD CONSTRAINT PK_PRORROGACAO_ID PRIMARY KEY(iProrrogacaoId);

	ALTER TABLE tProrrogacao
		ADD CONSTRAINT FK_PRORROGACAO_DECLARACAO_ITEM FOREIGN KEY (iDeclaracaoItemId)
		REFERENCES tDeclaracaoItem(iDeclaracaoItemId);
	
	--Criaçao de variavel para parametro da procedure
	CREATE TYPE dtProrrogacao AS TABLE (
		cNcm CHAR(8),
		mTaxaSelicAcumulada DECIMAL(5,2),
		iProrrogacao INT,
		mIiValorProrrogacao DECIMAL(18,2),
		mIpiValorProrrogacao DECIMAL(18,2),
		mPisValorProrrogacao DECIMAL(18,2),
		mCofinsValorProrrogacao DECIMAL(18,2),
		mIcmsValorProrrogacao DECIMAL(18,2),
		dDataProrrogacao DATE,
		dVencimentoProrrogacao DATE
	);
	GO
--------------------------------------------------------------------------
-- Tabela: tContratoTipo
--------------------------------------------------------------------------
	EXEC stp_CriaTabela
		@cSequenceNome = 'seqiContratoTipoId',
		@cNomeTabela = 'tContratoTipo',
		@cNomeColunas = 'iContratoTipoId|cContratoTipo',
		@cTipoColunas = 'INT|VARCHAR(50)';

	ALTER TABLE tContratoTipo
		ADD CONSTRAINT PK_CONTRATO_TIPO_ID PRIMARY KEY(iContratoTipoId);

	ALTER TABLE tContratoTipo
		ADD CONSTRAINT UQ_CONTRATO_TIPO UNIQUE(cContratoTipo);

	GO

--------------------------------------------------------------------------
-- Tabela: tContrato
--------------------------------------------------------------------------
	EXEC stp_CriaTabela
		@cSequenceNome = 'seqiContratoId',
		@cNomeTabela = 'tContrato',
		@cNomeColunas = 'iContratoId|cNomeContrato|iContratoTipoId|dContratoDataAssinatura|
						dContratoVencimento',
		@cTipoColunas = 'INT|VARCHAR(200)|INT|DATE|DATE';
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
	EXEC stp_CriaTabela
	@cSequenceNome = 'seqiDeclaracaoId',
	@cNomeTabela = 'tDeclaracao',
	@cNomeColunas = 'iDeclaracaoId|iRegimeAduaneiroId|iCnpjId|iApoliceId|iRecintoId|
					iLogisticaId|iValoresCalculoAduaneiroId|cNumeroDeclaracao|dDataDesembaraco|
					cNumeroDossie|cNumeroProcessoAdministrativo|cDescricao',
	@cTipoColunas = 'INT|INT|INT|INT|INT|INT|
					INT|VARCHAR(12)|DATE|CHAR(15)|CHAR(17)|VARCHAR(MAX)';

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

	ALTER TABLE tDeclaracao
		ADD CONSTRAINT UQ_NUMERO_DECLARACAO UNIQUE(cNumeroDeclaracao);

	ALTER TABLE tDeclaracao
		ADD CONSTRAINT UQ_NUMERO_DOSSIE UNIQUE(cNumeroDossie);
		
	GO

--------------------------------------------------------------------------
-- Tabela: tContratoDeclaracao
--------------------------------------------------------------------------
	EXEC stp_CriaTabela
		@cSequenceNome = 'seqiContratoDeclaracaoId',
		@cNomeTabela = 'tContratoDeclaracao',
		@cNomeColunas = 'iContratoId|iDeclaracaoId',
		@cTipoColunas = 'INT|INT';

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
	EXEC stp_CriaTabela
	@cSequenceNome = 'seqiProcessoId',
	@cNomeTabela = 'tProcesso',
	@cNomeColunas = 'iProcessoId|iDeclaracaoId|cReferenciaBraslog|cReferenciaCliente|cHistorico|bIsAtivo',
	@cTipoColunas = 'INT|INT|VARCHAR(50)|VARCHAR(13)|VARCHAR(MAX)|BIT';

	ALTER TABLE tProcesso
		ADD CONSTRAINT PK_PROCESSO_ID PRIMARY KEY(iProcessoId);

	ALTER TABLE tProcesso
		ADD CONSTRAINT FK_PROCESSO_DECLARACAO FOREIGN KEY(iDeclaracaoId)
		REFERENCES tDeclaracao(iDeclaracaoId);

	ALTER TABLE tProcesso
		ADD CONSTRAINT UQ_REFERENCIA_BRASLOG UNIQUE(cReferenciaBraslog);

	ALTER TABLE tProcesso
		ADD CONSTRAINT DF_HISTORICO DEFAULT(CONVERT(CHAR(10), GETDATE(), 103) + 
		' - Processo inclu�do no controle') FOR cHistorico;

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
		@cTipoColunas = 'INT|DATE|VARCHAR(512)';

	ALTER TABLE tLogEventos
		ADD CONSTRAINT PK_LOG_EVENTOS_ID PRIMARY KEY(iEventoId);

	ALTER TABLE tLogEventos
		ADD CONSTRAINT DF_DATA_HORA DEFAULT(GETDATE()) FOR dDataHoraEvento;

	ALTER TABLE tLogEventos
		ADD CONSTRAINT CK_MENSAGEM_EVENTO CHECK(cMensagemEvento <> '');