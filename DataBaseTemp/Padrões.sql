/*
t   - Tabela
stp - Procedure
fn  - Função
seq - Sequência 
trg - Trigger 
usr - Usuário de banco
lgn - Login da instância
pk  - Chave Primária
fk  - Chave Estrangeira 
chk - Restrição de verificação
dfl - Restrição de valor padrão
un  - Restrição de valor único 
idc - Índice cluster
idx - Índice não cluster 
*/

--Dados da View
SELECT * 
  FROM sys.views 
 WHERE NAME = 'vApoliceSeguroGarantia'
GO

--Colunas da View
SELECT * 
  FROM sys.columns
 WHERE object_id = object_id('vApoliceSeguroGarantia')
GO

--Exibe estatisticas sobre a varredura no banco após cONsulta
SET STATISTICS IO ON
GO

--Configuração da conexão antes de criar a view indexada.
SET numeric_roundabort OFF --evita erro ao arredondar numeros
SET ansi_padding ON --mantem espaços em branco em colunas CHAR e VARCHAR
SET ansi_warnings ON --ativa avisos para operçaoes invalidas
SET concat_null_yields_null ON --evita problemas com valores desconhecidos
SET arithabort ON --cancela a query decalculos com erros matematicos
SET quoted_identifier ON --permite usar aspas duplas
SET ansi_nulls ON --comparaçao de NULL com outro NULL

--Se há transações abertas
SELECT @@TRANCOUNT