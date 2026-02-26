using Context;  
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Models;

namespace Controllers;

[ApiController]
[Route("[controller]")]
public class InformacoesGeraisTodasProrrogacoesPorProcessoController : ControllerBase
{
    private readonly BackEndTempContext _context;

    public InformacoesGeraisTodasProrrogacoesPorProcessoController(BackEndTempContext context)
    {
        _context = context;
    }

    [HttpGet("{id:int}")]
    public ActionResult<IEnumerable<InformacoesGeraisTodasProrrogacoesPorProcesso>> GetInformacoesGeraisTodasProrrogacoesPorProcesso(int id)
    {
        var info = _context.informacoesGeraisTodasProrrogacoesPorProcesso
            .FromSqlInterpolated($"SELECT * FROM dbo.informacoesGeraisTodasProrrogacoesPorProcesso({id})")
            .ToList();

        if (info is null)
        {
            return NotFound();
        }

        return Ok(info);
    }
}