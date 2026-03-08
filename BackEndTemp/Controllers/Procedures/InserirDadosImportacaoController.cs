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
public class InserirDadosImportacaoController : ControllerBase
{
    private readonly BackEndTempContext _context;

    public InserirDadosImportacaoController(BackEndTempContext context)
    {
        _context = context;
    }

    [HttpPost]
    public ActionResult PostInserirDadosImportacao(InserirDadosImportacao inserir)
    {
        if (inserir is null)
            return BadRequest();

        var parametros = new[]
         {
            new SqlParameter("@iCeId", (object?)inserir.CeId ?? DBNull.Value),
            new SqlParameter("@iLogisticaId", inserir.LogisticaId),
            new SqlParameter("@iValoresCalculoAduaneiroId", inserir.ValoresCalculoAduaneiroid),
            new SqlParameter("@iDeclaracaoId", inserir.ValoresCalculoAduaneiroid),
            new SqlParameter("@mFrete", inserir.Frete),
            new SqlParameter("@mOutrasDespesas", (object?)inserir.OutrasDespesas ?? DBNull.Value),
            new SqlParameter("@mSeguro", (object?)inserir.Seguro ?? DBNull.Value),
            new SqlParameter("@mValorCapatazias", (object?)inserir.Capatazias ?? DBNull.Value),
            new SqlParameter("@mTaxaUtilizacaoMercante", (object?)inserir.TaxaMercante ?? DBNull.Value),
            new SqlParameter("@dDataRegistro", (object?)inserir.DataRegistro ?? DBNull.Value),
            new SqlParameter("@cCodigoMoedaFob", inserir.MoedaFOB),
            new SqlParameter("@mTaxaCambioFob", inserir.TaxaCambioFOB),
            new SqlParameter("@cCodigoMoedaFrete", inserir.MoedaFrete),
            new SqlParameter("@mTaxaCambioFrete", inserir.TaxaCambioFrete),
            new SqlParameter("@cCodigoMoedaSeguro", (object?)inserir.MoedaSeguro ?? DBNull.Value),
            new SqlParameter("@mTaxaCambioSeguro", (object?)inserir.TaxaCambioSeguro ?? DBNull.Value),
            new SqlParameter("@cCodigoMoedaOutrasDespesas", (object?)inserir.MoedaDespesas ?? DBNull.Value),
            new SqlParameter("@mTaxaCambioOutrasDespesas", (object?)inserir.TaxaCambioDespesas ?? DBNull.Value),
            new SqlParameter("@mAdicoes", inserir.Adicoes),
            new SqlParameter("@mTaxaSiscomex", inserir.TaxaSiscomex),
            new SqlParameter("@mAliqIcms", inserir.AliquotaICMS),

            new SqlParameter("@tNcm", SqlDbType.Structured)
            {
                TypeName = "dtNcm",
                Value = inserir.ncm != null ? tNcm(inserir.ncm) : DBNull.Value
            },
            new SqlParameter("@tDeclaracaoItem", SqlDbType.Structured)
            {
                TypeName = "dtDeclaracaoItem ",
                Value = inserir.item != null ? tDeclaracaoItem(inserir.item) : DBNull.Value
            },
            new SqlParameter("@tProrrogacao", SqlDbType.Structured)
            {
                TypeName = "dtProrrogacao",
                Value = inserir.prorrogacao != null ? tProrrogacao(inserir.prorrogacao) : DBNull.Value
            }
        };

        var info = _context
            .Set<IdPrincipal>()
            .FromSqlRaw(@"EXEC stp_InserirDadosProcessosImportacao @iCeId, @iLogisticaId, @iValoresCalculoAduaneiroId, @iDeclaracaoId, @mFrete, @mOutrasDespesas, @mSeguro, @mValorCapatazias, @mTaxaUtilizacaoMercante, @dDataRegistro, @cCodigoMoedaFob, @mTaxaCambioFob, @cCodigoMoedaFrete, @mTaxaCambioFrete, @cCodigoMoedaSeguro, @mTaxaCambioSeguro, @cCodigoMoedaOutrasDespesas, @mTaxaCambioOutrasDespesas, @mAdicoes, @mTaxaSiscomex, @mAliqIcms, @tNcm, @tDeclaracaoItem, @tProrrogacao",
            parametros)
            .ToList()
            .FirstOrDefault();

        if (info is null)
            return BadRequest();

        return CreatedAtAction(
            "GetInformacoes",
            "InformacoesDoProcesso",
            new { id = info.iDeclaracaoId },
            inserir);
    }

    private DataTable tNcm(List<Ncm> itens)
    {
        var table = new DataTable();

        table.Columns.Add("NcmCodigo", typeof(string));
        table.Columns.Add("AliquotaII", typeof(decimal));
        table.Columns.Add("AliquotaIPI", typeof(decimal));
        table.Columns.Add("AliquotaPIS", typeof(decimal));
        table.Columns.Add("AliquotaCOFINS", typeof(decimal));

        foreach (var item in itens)
        {
            table.Rows.Add(
                item.NcmCodigo ?? (object)DBNull.Value,
                item.AliquotaII ?? (object)DBNull.Value,
                item.AliquotaIPI ?? (object)DBNull.Value,
                item.AliquotaPIS ?? (object)DBNull.Value,
                item.AliquotaCOFINS ?? (object)DBNull.Value
            );
        }

        return table;
    }

    private DataTable tDeclaracaoItem(List<Item> itens)
    {
        var table = new DataTable();

        table.Columns.Add("Ncm", typeof(string));
        table.Columns.Add("ValorFob", typeof(decimal));
        table.Columns.Add("PesoLiquido", typeof(decimal));
        table.Columns.Add("ValorAduaneiro", typeof(decimal));
        table.Columns.Add("IiValor", typeof(decimal));
        table.Columns.Add("IpiValor", typeof(decimal));
        table.Columns.Add("PisValor", typeof(decimal));
        table.Columns.Add("CofinsValor", typeof(decimal));
        table.Columns.Add("IcmsValor", typeof(decimal));

        foreach (var item in itens)
        {
            table.Rows.Add(
                item.Ncm ?? (object)DBNull.Value,
                item.ValorFob ?? (object)DBNull.Value,
                item.PesoLiquido ?? (object)DBNull.Value,
                item.ValorAduaneiro ?? (object)DBNull.Value,
                item.IiValor ?? (object)DBNull.Value,
                item.IpiValor ?? (object)DBNull.Value,
                item.PisValor ?? (object)DBNull.Value,
                item.CofinsValor ?? (object)DBNull.Value,
                item.IcmsValor ?? (object)DBNull.Value
            );
        }

        return table;
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
}