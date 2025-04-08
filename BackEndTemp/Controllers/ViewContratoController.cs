using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebApi.Models;

namespace BackEndTemp.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ViewContratoController : ControllerBase
    {
        private readonly ProcessosTemporariosDBContext _context;

        public ViewContratoController(ProcessosTemporariosDBContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<ViewContrato>>> GetViewContratos()
        {
            return await _context.VContrato.ToListAsync();
        }
    }
}