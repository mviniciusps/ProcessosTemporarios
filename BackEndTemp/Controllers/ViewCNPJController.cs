using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebApi.Models; // Altere para o namespace correto do seu projeto

namespace BackEndTemp.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ViewCNPJController : ControllerBase
    {
        private readonly ProcessosTemporariosDBContext _context;

        public ViewCNPJController(ProcessosTemporariosDBContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<ViewCNPJ>>> GetViewCNPJs()
        {
            return await _context.VCNPJ.ToListAsync();
        }
    }
}