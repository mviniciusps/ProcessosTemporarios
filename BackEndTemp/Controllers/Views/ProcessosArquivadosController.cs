using Context;
using Microsoft.AspNetCore.Mvc;
using Models;

namespace Controllers;

[ApiController]
[Route("[controller]")]
public class ProcessosArquivadosController : ControllerBase
{
    private readonly BackEndTempContext _context;

    public ProcessosArquivadosController(BackEndTempContext context)
    {
        _context = context;
    }

    [HttpGet]
    public ActionResult<IEnumerable<ProcessosArquivados>> Get()
    {
        var processosArquivados = _context.processosArquivados.ToList();
        if (processosArquivados is null) return NotFound();
        return processosArquivados;
    }
}