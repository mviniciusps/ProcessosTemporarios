using Context;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Models;

namespace Controllers;

[ApiController]
[Route("[controller]")]
public class InformacoesDoProcessoController : ControllerBase
{
    private readonly BackEndTempContext _context;

    public InformacoesDoProcessoController(BackEndTempContext context)
    {
        _context = context;
    }

    [HttpGet("{id:int}")]
    public ActionResult<IEnumerable<InformacoesPorProcesso>> GetInformacoes(int id)
    {
        var infos = _context.informacoesPorProcessos
            .FromSqlInterpolated($"SELECT * FROM dbo.informacoesCadastroPorProcesso({id})")
            .AsNoTracking()
            .ToList();

        if (infos is null) return NotFound();
        return Ok(infos);
    }
}