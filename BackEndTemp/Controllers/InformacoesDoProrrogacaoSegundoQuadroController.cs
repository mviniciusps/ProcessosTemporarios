using Context;  
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Models;

namespace Controllers;

[ApiController]
[Route("[controller]")]
public class InformacoesDoProrrogacaoSegundoQuadroController : ControllerBase
{
    private readonly BackEndTempContext _context;

    public InformacoesDoProrrogacaoSegundoQuadroController(BackEndTempContext context)
    {
        _context = context;
    }

    [HttpGet("{id:int}")]
    public ActionResult<IEnumerable<InformacoesGeraisPorProrrogacaoSegundoQuadro>> GetInformacoesProrrogacaoSegundoQuadro(int id)
    {
        var info = _context.informacoesGeraisPorProrrogacaoSegundoQuadro
            .FromSqlInterpolated($"SELECT * FROM dbo.informacoesGeraisPorProrrogacaoProcessoSegundoQuadro({id})")
            .ToList();

        if (info is null)
        {
            return NotFound();
        }

        return Ok(info);
    }
}