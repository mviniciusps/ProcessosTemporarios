using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebApi.Models;

namespace BackEndTemp.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ViewRecintoController
    {
        private readonly ProcessosTemporariosDBContext _context;

        public ViewRecintoController(ProcessosTemporariosDBContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<ViewRecintoAlfandegado>>> GetViewRecintos()
        {
            return await _context.VRecinto.ToListAsync();
        }
    }
}