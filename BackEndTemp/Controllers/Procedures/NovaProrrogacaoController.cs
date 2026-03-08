using System.Data;
using Context;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Models;
using Types;

namespace Controllers;

[ApiController]
[Route("[controller]")]
public class NovaProrrogacaoController : ControllerBase
{
    private readonly BackEndTempContext _context;

    public NovaProrrogacaoController(BackEndTempContext context)
    {
        _context = context;
    }

    [HttpPost]
    public ActionResult PostNovaProrrogacao(NovaProrrogacao prorrogacao)
    {
        if (prorrogacao is null)
            return BadRequest();

        var parametros = new[]
        {
            new SqlParameter("@iDeclaracaoId", prorrogacao.DeclaracaoId),
            new SqlParameter("@mTaxaSelicAcumulada", prorrogacao.TaxaSelicAcumulada),
            new SqlParameter("@tProrrogacao", SqlDbType.Structured)
            {
                TypeName = "dtProrrogacao",
                Value = prorrogacao.prorrogacao != null ? tProrrogacao(prorrogacao.prorrogacao) : DBNull.Value
            },
            new SqlParameter("@tContratos", SqlDbType.Structured)
            {
                TypeName = "dtContratoProrrogacao",
                Value = prorrogacao.contratoProrrogacaos != null ? tContratoDeclaracao(prorrogacao.contratoProrrogacaos) : DBNull.Value
            }
        };

        var info = _context
            .Set<IdPrincipal>()
            .FromSqlRaw(@"EXEC stp_NovaProrrogacao @iDeclaracaoId, @mTaxaSelicAcumulada, @tProrrogacao, @tContratos", parametros)
            .ToList()
            .FirstOrDefault();

        if (info is null)
            return BadRequest();

        return CreatedAtAction(
            "GetInformacoes",
            "InformacoesDoProcesso",
            new { id = info.iDeclaracaoId },
            prorrogacao);
    }

    private DataTable tProrrogacao(List<Prorrogacao> itens)
    {
        var table = new DataTable();

        table.Columns.Add("Ncm", typeof(string));
        table.Columns.Add("DeclaracaoItemId", typeof(int));
        table.Columns.Add("TaxaSelicAcumulada", typeof(decimal));
        table.Columns.Add("NumeroProrrogacao", typeof(int));
        table.Columns.Add("IiValorProrrogacao", typeof(decimal));
        table.Columns.Add("IpiValorProrrogacao", typeof(decimal));
        table.Columns.Add("PisValorProrrogacao", typeof(decimal));
        table.Columns.Add("CofinsValorProrrogacao", typeof(decimal));
        table.Columns.Add("IcmsValorProrrogacao", typeof(decimal));
        table.Columns.Add("DataProrrogacao", typeof(DateTime));
        table.Columns.Add("VencimentoProrrogacao", typeof(DateTime));

        foreach (var item in itens)
        {
            table.Rows.Add(
                item.Ncm ?? (object)DBNull.Value,
                item.DeclaracaoItemId ?? (object)DBNull.Value,
                item.TaxaSelicAcumulada ?? (object)DBNull.Value,
                item.NumeroProrrogacao ?? (object)DBNull.Value,
                item.IiValorProrrogacao ?? (object)DBNull.Value,
                item.IpiValorProrrogacao ?? (object)DBNull.Value,
                item.PisValorProrrogacao ?? (object)DBNull.Value,
                item.CofinsValorProrrogacao ?? (object)DBNull.Value,
                item.IcmsValorProrrogacao ?? (object)DBNull.Value,
                item.DataProrrogacao ?? (object)DBNull.Value,
                item.VencimentoProrrogacao ?? (object)DBNull.Value
            );
        }

        return table;
    }

    private DataTable tContratoDeclaracao(List<ContratoProrrogacao> contratos)
    {
        var table = new DataTable();

        table.Columns.Add("ContratoId", typeof(int));
        table.Columns.Add("NomeContrato", typeof(string));
        table.Columns.Add("ContratoVencimento", typeof(DateTime));
        table.Columns.Add("NumeroApolice", typeof(string));
        table.Columns.Add("ValorSegurado", typeof(decimal));
        table.Columns.Add("VencimentoApolice", typeof(DateTime));

        foreach (var contrato in contratos)
        {
            table.Rows.Add(
                contrato.ContratoId ?? (object)DBNull.Value,
                contrato.NomeContrato ?? (object)DBNull.Value,
                contrato.ContratoVencimento ?? (object)DBNull.Value,
                contrato.NumeroApolice ?? (object)DBNull.Value,
                contrato.ValorSegurado ?? (object)DBNull.Value,
                contrato.VencimentoApolice ?? (object)DBNull.Value
            );
        }

        return table;
    }
}