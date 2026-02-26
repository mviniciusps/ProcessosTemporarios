using Context;
using Microsoft.AspNetCore.Mvc;
using Models;

namespace Controllers;

[ApiController]
[Route("[controller]")]
public class ProcessosAtivosController : ControllerBase
{
    private readonly BackEndTempContext _context;

    public ProcessosAtivosController(BackEndTempContext context)
    {
        _context = context;
    }

    [HttpGet]
    public ActionResult<IEnumerable<ProcessosAtivos>> Get()
    {
        var processosAtivos = _context.processosAtivos.ToList();
        if (processosAtivos is null) return NotFound();
        return processosAtivos;
    }
}