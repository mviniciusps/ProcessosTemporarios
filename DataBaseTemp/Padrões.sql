/*
t   - Tabela
stp - Procedure
fn  - Fun��o
seq - Sequ�ncia 
trg - Trigger 
usr - Usu�rio de banco
lgn - Login da inst�ncia
pk  - Chave Prim�ria
fk  - Chave Estrangeira 
chk - Restri��o de verifica��o
dfl - Restri��o de valor padr�o
un  - Restri��o de valor �nico 
idc - �ndice cluster
idx - �ndice n�o cluster 
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

--Exibe estatisticas sobre a varredura no banco ap�s cONsulta
SET STATISTICS IO ON
GO

--Configura��o da conex�o antes de criar a view indexada.
SET numeric_roundabort OFF --evita erro ao arredondar numeros
SET ansi_padding ON --mantem espa�os em branco em colunas CHAR e VARCHAR
SET ansi_warnings ON --ativa avisos para oper�aoes invalidas
SET concat_null_yields_null ON --evita problemas com valores desconhecidos
SET arithabort ON --cancela a query decalculos com erros matematicos
SET quoted_identifier ON --permite usar aspas duplas
SET ansi_nulls ON --compara�ao de NULL com outro NULL

--Se h� transa��es abertas
SELECT @@TRANCOUNT