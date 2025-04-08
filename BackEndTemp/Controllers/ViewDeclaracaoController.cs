using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebApi.Models;

namespace BackEndTemp.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ViewDeclaracaoController
    {
        private readonly ProcessosTemporariosDBContext _context;

        public ViewDeclaracaoController(ProcessosTemporariosDBContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<ViewDeclaracao>>> GetViewDeclaracoes()
        {
            return await _context.VDeclaracao.ToListAsync();
        }
    }
}