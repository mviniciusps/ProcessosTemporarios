using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BACKENDTEMPORARIOS.Models;

namespace BACKENDTEMPORARIOS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TCeMercantesController : ControllerBase
    {
        private readonly ProcessosTemporariosDBContext _context;

        public TCeMercantesController(ProcessosTemporariosDBContext context)
        {
            _context = context;
        }

        // GET: api/TCeMercantes
        [HttpGet]
        public async Task<ActionResult<IEnumerable<TCeMercante>>> GetTCeMercantes()
        {
            return await _context.TCeMercantes.ToListAsync();
        }

        // GET: api/TCeMercantes/5
        [HttpGet("{id}")]
        public async Task<ActionResult<TCeMercante>> GetTCeMercante(int? id)
        {
            var tCeMercante = await _context.TCeMercantes.FindAsync(id);

            if (tCeMercante == null)
            {
                return NotFound();
            }

            return tCeMercante;
        }

        // PUT: api/TCeMercantes/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutTCeMercante(int? id, TCeMercante tCeMercante)
        {
            if (id != tCeMercante.ICeid)
            {
                return BadRequest();
            }

            _context.Entry(tCeMercante).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!TCeMercanteExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // POST: api/TCeMercantes
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public async Task<ActionResult<TCeMercante>> PostTCeMercante(TCeMercante tCeMercante)
        {
            _context.TCeMercantes.Add(tCeMercante);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetTCeMercante", new { id = tCeMercante.ICeid }, tCeMercante);
        }

        // DELETE: api/TCeMercantes/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTCeMercante(int? id)
        {
            var tCeMercante = await _context.TCeMercantes.FindAsync(id);
            if (tCeMercante == null)
            {
                return NotFound();
            }

            _context.TCeMercantes.Remove(tCeMercante);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool TCeMercanteExists(int? id)
        {
            return _context.TCeMercantes.Any(e => e.ICeid == id);
        }
    }
}
