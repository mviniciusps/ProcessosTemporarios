using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebApi.Models;

namespace BackEndTemp.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ViewCeMercanteController : ControllerBase
    {
        private readonly ProcessosTemporariosDBContext _context;

        public ViewCeMercanteController(ProcessosTemporariosDBContext context)
        {
            _context = context;
        }

        // GET: api/ViewCeMercante
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ViewCeMercante>>> GetViewCeMercantes()
        {
            return await _context.VMercante.ToListAsync();
        }
    }
}