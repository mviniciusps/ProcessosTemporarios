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
    public async Task<ActionResult<IEnumerable<InformacoesPorProcesso>>> GetContratos(int id)
    {
        try
        {
            if (id <= 0)
            {
                //Status 400
                return BadRequest
                (
                    new ApiResponse<Object>
                    {
                        Success = false,
                        Message = "O id informado é inválido!",
                        Data = null
                    }
                );
            }

            var contratos = await _context.contratosPorProcesso
                .FromSqlInterpolated($"SELECT * FROM dbo.contratosPorDeclaracao({id})")
                .AsNoTracking()
                .ToListAsync();

            //Status 404
            if (!contratos.Any())
            {
                return NotFound(new ApiResponse<Object>
                {
                    Success = false,
                    Message = "Nenhum contrato encontrado para o processo informado!",
                    Data = null
                });
            }

            //Status 200
            return Ok(new ApiResponse<object>
            {
                Success = true,
                Message = "Contrato(s) encontrado(s) com sucesso!",
                Data = contratos
            });

        }
        catch (Exception)
        {
            //Status 500
            return StatusCode(StatusCodes.Status500InternalServerError,
                new ApiResponse<object>
                {
                    Success = false,
                    Message = "Erro interno do servidor!",
                    Data = null
                }
            );
        }
    }
}