using Context;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Models;

namespace Controllers;

[ApiController]
[Route("[controller]")]
public class InformacoesGeraisPorProrrogacaoController : ControllerBase
{
    private readonly BackEndTempContext _context;

    public InformacoesGeraisPorProrrogacaoController(BackEndTempContext context)
    {
        _context = context;
    }

    [HttpGet("{id:int}")]
    public ActionResult<IEnumerable<InformacoesGeraisPorProrrogacao>> GetInformacoesProrrogacao(int id)
    {
        var infos = _context.informacoesGeraisPorProrrogacao
            .FromSqlInterpolated($"SELECT * FROM dbo.informacoesGeraisPorProrrogacaoProcesso({id})")
            .ToList();

        if (infos is null) return NotFound();
        return Ok(infos);
    }
}