using Context;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Models;

namespace Controllers;

[ApiController]
[Route("[controller]")]
public class InserirDadosController : ControllerBase
{
    private readonly BackEndTempContext _context;

    public InserirDadosController(BackEndTempContext context)
    {
        _context = context;
    }

    [HttpPost]
    public ActionResult Post(InserirDados inserir)
    {
        if (inserir is null)
            return BadRequest();

        var parametros = new[]
        {
            new SqlParameter("@cPaisNome", inserir.PaisNome),
            new SqlParameter("@cNomeCidadeExterior", inserir.NomeCidadeExterior),
            new SqlParameter("@cNomeModal", inserir.NomeModal),
            new SqlParameter("@cEstadoNomeRecinto", inserir.EstadoNomeRecinto),
            new SqlParameter("@cCidadeNomeRecinto", inserir.CidadeNomeRecinto),
            new SqlParameter("@cCepRecinto", inserir.CepRecinto),
            new SqlParameter("@cNomeLogradouroRecinto", inserir.NomeLogradouroRecinto),
            new SqlParameter("@cBairroLogradouroRecinto", inserir.BairroLogradouroRecinto),
            new SqlParameter("@cEstadoNomeCnpj", inserir.EstadoNomeCnpj),
            new SqlParameter("@cCidadeNomeCnpj", inserir.CidadeNomeCnpj),
            new SqlParameter("@cCepCnpj", inserir.CepCnpj),
            new SqlParameter("@cNomeLogradouroCnpj", inserir.NomeLogradouroCnpj),
            new SqlParameter("@cBairroLogradouroCnpj", inserir.BairroLogradouroCnpj),
            new SqlParameter("@cCnpj", inserir.Cnpj),
            new SqlParameter("@cNomeEmpresa", inserir.NomeEmpresa),

            new SqlParameter("@cNumeroApolice", (object?)inserir.NumeroApolice ?? DBNull.Value),
            new SqlParameter("@dVencimentoGarantia", (object?)inserir.VencimentoGarantia ?? DBNull.Value),
            new SqlParameter("@mValorSegurado", (object?)inserir.ValorSegurado ?? DBNull.Value),
            new SqlParameter("@cNumeroCe", (object?)inserir.NumeroCe ?? DBNull.Value),
            new SqlParameter("@cStatusCe", (object?)inserir.StatusCe ?? DBNull.Value),
            new SqlParameter("@mValorAfrmmSuspenso", (object?)inserir.ValorAfrmmSuspenso ?? DBNull.Value),

            new SqlParameter("@cConhecimentoEmbarque", inserir.ConhecimentoEmbarque),
            new SqlParameter("@dDataEmbarque", inserir.DataEmbarque),
            new SqlParameter("@dDataChegada", (object?)inserir.DataChegada ?? DBNull.Value),

            new SqlParameter("@cNomeRegimeAduaneiro", inserir.NomeRegimeAduaneiro),
            new SqlParameter("@dDataRegistro", inserir.DataRegistro),

            new SqlParameter("@cNomeRecinto", inserir.NomeRecinto),
            new SqlParameter("@cNumeroRecintoAduaneiro", inserir.NumeroRecintoAduaneiro),
            new SqlParameter("@cNomeUnidadeReceitaFederal", inserir.NomeUnidadeReceitaFederal),
            new SqlParameter("@cUnidadeReceitaFederal", inserir.UnidadeReceitaFederal),

            new SqlParameter("@cDescricao", (object?)inserir.Descricao ?? DBNull.Value),
            new SqlParameter("@cNumeroDeclaracao", inserir.NumeroDeclaracao),
            new SqlParameter("@cNumeroDossie", (object?)inserir.NumeroDossie ?? DBNull.Value),
            new SqlParameter("@cNumeroProcessoAdministrativo", (object?)inserir.NumeroProcessoAdministrativo ?? DBNull.Value),

            new SqlParameter("@dDataDesembaraco", inserir.DataDesembaraco),

            new SqlParameter("@cNomeContratoAdmissao", (object?)inserir.NomeContratoAdmissao ?? DBNull.Value),
            new SqlParameter("@dContratoDataAssinaturaAdmissao", (object?)inserir.ContratoDataAssinaturaAdmissao ?? DBNull.Value),
            new SqlParameter("@dContratoVencimentoAdmissao", (object?)inserir.ContratoVencimentoAdmissao ?? DBNull.Value),
            new SqlParameter("@cContratoTipoAdmissao", (object?)inserir.ContratoTipoAdmissao ?? DBNull.Value),

            new SqlParameter("@cNomeContratoPrestacaoServico", (object?)inserir.NomeContratoPrestacaoServico ?? DBNull.Value),
            new SqlParameter("@dContratoDataAssinaturaPrestacaoServico", (object?)inserir.ContratoDataAssinaturaPrestacaoServico ?? DBNull.Value),
            new SqlParameter("@dContratoVencimentoPrestacaoServico", (object?)inserir.ContratoVencimentoPrestacaoServico ?? DBNull.Value),
            new SqlParameter("@cContratoTipoPrestacaoServico", (object?)inserir.ContratoTipoPrestacaoServico ?? DBNull.Value),

            new SqlParameter("@cReferenciaBraslog", inserir.ReferenciaBraslog),
            new SqlParameter("@cReferenciaCliente", (object?)inserir.ReferenciaCliente ?? DBNull.Value)
        };

        var info = _context
            .Set<IdPrincipal>()
            .FromSqlRaw("EXEC stp_InserirDados @cPaisNome, @cNomeCidadeExterior, @cNomeModal, @cEstadoNomeRecinto, @cCidadeNomeRecinto, @cCepRecinto, @cNomeLogradouroRecinto, @cBairroLogradouroRecinto, @cEstadoNomeCnpj, @cCidadeNomeCnpj, @cCepCnpj, @cNomeLogradouroCnpj, @cBairroLogradouroCnpj, @cCnpj, @cNomeEmpresa, @cNumeroApolice, @dVencimentoGarantia, @mValorSegurado, @cNumeroCe, @cStatusCe, @mValorAfrmmSuspenso, @cConhecimentoEmbarque, @dDataEmbarque, @dDataChegada, @cNomeRegimeAduaneiro, @dDataRegistro, @cNomeRecinto, @cNumeroRecintoAduaneiro, @cNomeUnidadeReceitaFederal, @cUnidadeReceitaFederal, @cDescricao, @cNumeroDeclaracao, @cNumeroDossie, @cNumeroProcessoAdministrativo, @dDataDesembaraco, @cNomeContratoAdmissao, @dContratoDataAssinaturaAdmissao, @dContratoVencimentoAdmissao, @cContratoTipoAdmissao, @cNomeContratoPrestacaoServico, @dContratoDataAssinaturaPrestacaoServico, @dContratoVencimentoPrestacaoServico, @cContratoTipoPrestacaoServico, @cReferenciaBraslog, @cReferenciaCliente",
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
}