CREATE OR ALTER VIEW vApoliceSeguroGarantia
AS
SELECT td.cReferenciaBraslog AS Processo, ta.cNumeroApolice AS [Apolice nº],
FORMAT(ta.dVencimentoGarantia, 'dd/MM/yyyy') AS [Vencimento da Apolice],
tr.cNomeRecinto AS [Recinto Alfandegado],
tr.cCidadeRecinto + '/' + 
    CASE 
        WHEN  tr.cEstadoRecinto = 'Acre' THEN 'AC' 
        WHEN  tr.cEstadoRecinto = 'Alagoas' THEN 'AL'
        WHEN  tr.cEstadoRecinto = 'Amapá' THEN 'AP'
        WHEN  tr.cEstadoRecinto = 'Amazonas' THEN 'AM'
        WHEN  tr.cEstadoRecinto = 'Bahia' THEN 'BA'
        WHEN  tr.cEstadoRecinto = 'Ceará' THEN 'CE'
        WHEN  tr.cEstadoRecinto = 'Distrito Federal' THEN 'DF'
        WHEN  tr.cEstadoRecinto = 'Espírito Santo' THEN 'ES'
        WHEN  tr.cEstadoRecinto = 'Goiás' THEN 'GO'
        WHEN  tr.cEstadoRecinto = 'Maranhão' THEN 'MA'
        WHEN  tr.cEstadoRecinto = 'Mato Grosso' THEN 'MT'
        WHEN  tr.cEstadoRecinto = 'Mato Grosso do Sul' THEN 'MS'
        WHEN  tr.cEstadoRecinto = 'Minas Gerais' THEN 'MG'
        WHEN  tr.cEstadoRecinto = 'Pará' THEN 'PA'
        WHEN  tr.cEstadoRecinto = 'Paraíba' THEN 'PB'
        WHEN  tr.cEstadoRecinto = 'Paraná' THEN 'PR'
        WHEN  tr.cEstadoRecinto = 'Pernambuco' THEN 'PE'
        WHEN  tr.cEstadoRecinto = 'Piauí' THEN 'PI'
        WHEN  tr.cEstadoRecinto = 'Rio de Janeiro' THEN 'RJ'
        WHEN  tr.cEstadoRecinto = 'Rio Grande do Norte' THEN 'RN'
        WHEN  tr.cEstadoRecinto = 'Rio Grande do Sul' THEN 'RS'
        WHEN  tr.cEstadoRecinto = 'Rondônia' THEN 'RO'
        WHEN  tr.cEstadoRecinto = 'Roraima' THEN 'RR'
        WHEN  tr.cEstadoRecinto = 'Santa Catarina' THEN 'SC'
        WHEN  tr.cEstadoRecinto = 'São Paulo' THEN 'SP'
        WHEN  tr.cEstadoRecinto = 'Sergipe' THEN 'SE'
        WHEN  tr.cEstadoRecinto = 'Tocantins' THEN 'TO'
        ELSE ' tr.cEstadoRecinto Inválido'
    END AS Cidade
FROM tApoliceSeguroGarantia ta
JOIN tRecintoAlfandegado tr
ON ta.iRecintoID = tr.iRecintoID
JOIN tDeclaracao td
ON ta.iApoliceID = td.iApoliceID
GO