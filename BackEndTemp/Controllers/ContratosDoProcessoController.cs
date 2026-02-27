using Context;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Models;

namespace Controllers;

[ApiController]
[Route("[controller]")]
public class ContratosDoProcessoController : ControllerBase
{
    private readonly BackEndTempContext _context;

    public ContratosDoProcessoController(BackEndTempContext context)
    {
        _context = context;
    }

    [HttpGet("{id:int}")]
    public ActionResult<IEnumerable<InformacoesPorProcesso>> GetContratos(int id)
    {
        var infos = _context.contratosPorProcesso
            .FromSqlInterpolated($"SELECT * FROM dbo.contratosPorDeclaracao({id})")
            .ToList();

        if (infos is null) return NotFound();
        return Ok(infos);
    }
}